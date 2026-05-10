const https = require("https");
const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, UpdateCommand } = require("@aws-sdk/lib-dynamodb");

const CF_ID = process.env.CASHFREE_CLIENT_ID || "";
const CF_SECRET = process.env.CASHFREE_CLIENT_SECRET || "";
const CF_BASE = process.env.CASHFREE_BASE_URL || "https://api.cashfree.com/verification";
const SARVAM_KEY = process.env.SARVAM_KEY || "";
const NVIDIA_KEY = process.env.NVIDIA_KEY || "";
const GEMINI_KEY = process.env.GEMINI_KEY || "";
const MISTRAL_KEY = process.env.MISTRAL_KEY || "";
const AWS_REGION = process.env.AWS_REGION || "ap-south-1";

const CF_HEADERS = {
  "Content-Type": "application/json",
  "x-client-id": CF_ID,
  "x-client-secret": CF_SECRET,
};

// DynamoDB client for saving questions
const ddbClient = new DynamoDBClient({ region: AWS_REGION });
const db = DynamoDBDocumentClient.from(ddbClient, { marshallOptions: { removeUndefinedValues: true } });

function httpsRequest(hostname, path, method, headers, body) {
  return new Promise((resolve, reject) => {
    const bodyStr = body ? JSON.stringify(body) : null;
    const options = {
      hostname,
      path,
      method,
      headers: { ...headers, ...(bodyStr ? { "Content-Length": Buffer.byteLength(bodyStr) } : {}) },
    };
    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (c) => (data += c));
      res.on("end", () => {
        try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, body: { error: "Invalid JSON", raw: data.slice(0, 300) } }); }
      });
    });
    req.on("error", reject);
    if (bodyStr) req.write(bodyStr);
    req.end();
  });
}

function cfFetch(path, method = "GET", body = null) {
  const url = new URL(`${CF_BASE}${path}`);
  return httpsRequest(url.hostname, url.pathname + url.search, method, CF_HEADERS, body).then(r => r.body);
}

function extractQuestions(data) {
  const raw =
    data.candidates?.[0]?.content?.parts?.[0]?.text ||
    data.choices?.[0]?.message?.reasoning_content ||
    data.choices?.[0]?.message?.content ||
    "";
  const text = raw.replace(/<think>[\s\S]*?<\/think>/g, "").replace(/```json|```/g, "").trim();

  const objMatch = text.match(/\{[\s\S]*\}/);
  if (objMatch) {
    try {
      const parsed = JSON.parse(objMatch[0]);
      if (Array.isArray(parsed.questions) && parsed.questions.length >= 5) return parsed.questions;
    } catch (_) {}
  }
  const arrMatch = text.match(/\[[\s\S]*\]/);
  if (arrMatch) {
    try {
      const arr = JSON.parse(arrMatch[0]);
      if (Array.isArray(arr) && arr.length >= 5) return arr;
    } catch (_) {}
  }
  return null;
}

function resp(statusCode, body) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "https://app.homeguruworld.com" },
    body: JSON.stringify(body),
  };
}

async function generateWithRace(prompt) {
  const makeAttempt = (fn) =>
    fn().then((data) => {
      const qs = extractQuestions(data);
      if (!qs) throw new Error("no valid questions");
      return qs;
    });

  const attempts = [];

  if (GEMINI_KEY) {
    attempts.push(makeAttempt(() =>
      httpsRequest(
        "generativelanguage.googleapis.com",
        `/v1beta/models/gemini-flash-latest:generateContent?key=${GEMINI_KEY}`,
        "POST",
        { "Content-Type": "application/json" },
        { contents: [{ parts: [{ text: prompt }] }] }
      ).then(r => { if (r.status >= 400) throw new Error(`Gemini ${r.status}`); return r.body; })
    ));
  }

  if (SARVAM_KEY) {
    attempts.push(makeAttempt(() =>
      httpsRequest(
        "api.sarvam.ai",
        "/v1/chat/completions",
        "POST",
        { "api-subscription-key": SARVAM_KEY, "Content-Type": "application/json" },
        { model: "sarvam-30b", messages: [{ role: "user", content: prompt }], temperature: 0.4, max_tokens: 8000 }
      ).then(r => { if (r.status >= 400) throw new Error(`Sarvam ${r.status}`); return r.body; })
    ));
  }

  if (NVIDIA_KEY) {
    attempts.push(makeAttempt(() =>
      httpsRequest(
        "integrate.api.nvidia.com",
        "/v1/chat/completions",
        "POST",
        { Authorization: `Bearer ${NVIDIA_KEY}`, "Content-Type": "application/json" },
        { model: "mistralai/mistral-7b-instruct-v0.3", messages: [{ role: "user", content: prompt }], temperature: 0.4, max_tokens: 4000 }
      ).then(r => { if (r.status >= 400) throw new Error(`NVIDIA ${r.status}`); return r.body; })
    ));
  }

  if (MISTRAL_KEY) {
    attempts.push(makeAttempt(() =>
      httpsRequest(
        "api.mistral.ai",
        "/v1/chat/completions",
        "POST",
        { Authorization: `Bearer ${MISTRAL_KEY}`, "Content-Type": "application/json" },
        { model: "mistral-small-latest", messages: [{ role: "user", content: prompt }], temperature: 0.4, max_tokens: 4000 }
      ).then(r => { if (r.status >= 400) throw new Error(`Mistral ${r.status}`); return r.body; })
    ));
  }

  if (!attempts.length) return null;
  try { return await Promise.any(attempts); }
  catch (_) { return null; }
}

exports.handler = async (event) => {
  try {
    // Direct Lambda invoke (InvocationType: Event) sends payload as event directly
    // API Gateway wraps it in event.body as a string
    const body = event.action
      ? event
      : typeof event.body === "string" ? JSON.parse(event.body) : (event.body || {});
    const action = body.action || event.pathParameters?.action;

    // ── Generate and save to DynamoDB (async invocation) ──
    if (action === "generate_and_save") {
      const { testId, subjects = [], level = "secondary", bio = "" } = body;
      if (!subjects.length) return resp(400, { success: false, error: "subjects required" });

      const LEVEL_LABELS = {
        primary: "Primary School (Classes 1-5)",
        secondary: "Secondary School (Classes 6-10)",
        senior_secondary: "Senior Secondary (Classes 11-12)",
        competitive: "Competitive Exams (JEE/NEET/UPSC)",
        college: "College & Above",
        olympiad: "Olympiad & Advanced",
      };
      const levelLabel = LEVEL_LABELS[level] || LEVEL_LABELS.secondary;

      const prompt = `You are an expert educator for HomeGuru, an Indian tutoring platform.
Generate exactly 10 scenario-based MCQ questions to assess a tutor's knowledge of ${subjects.join(", ")} for ${levelLabel}.
${bio ? `Tutor background: ${bio}` : ""}

Each question MUST have:
- A real-world scenario (2-3 sentences of context)
- A specific question based on that scenario
- Exactly 4 options with full answer text (not just A/B/C/D labels)
- One correct answer (0-indexed: 0=A, 1=B, 2=C, 3=D)
- A brief explanation

Test the TUTOR's depth of knowledge, not a student.

Return ONLY valid JSON, no markdown:
{"questions":[{"id":1,"category":"topic","scenario":"real world context","question":"specific question","options":["full option A","full option B","full option C","full option D"],"correct":0,"explanation":"why correct"}]}`;

      const questions = await generateWithRace(prompt);
      if (!questions) return resp(503, { success: false, error: "AI unavailable" });

      const normalized = questions.slice(0, 10).map((q, i) => ({
        id: i + 1,
        category: q.category || subjects[0] || "General",
        scenario: q.scenario || "",
        question: q.question || "",
        options: Array.isArray(q.options) && q.options.length === 4 ? q.options : ["", "", "", ""],
        correct: typeof q.correct === "number" ? q.correct : 0,
        explanation: q.explanation || "",
      }));

      // Save to DynamoDB if testId provided
      if (testId) {
        await db.send(new UpdateCommand({
          TableName: "hg-tutor-tests",
          Key: { testId },
          UpdateExpression: "SET questions = :q, questionsReady = :r",
          ExpressionAttributeValues: { ":q": normalized, ":r": true },
        }));
      }

      return resp(200, { success: true, questions: normalized });
    }

    // ── Generate questions (sync, for direct API calls) ──
    if (action === "generate_questions") {
      // Reuse generate_and_save without saving
      return exports.handler({ ...event, body: JSON.stringify({ ...body, action: "generate_and_save", testId: null }) });
    }

    // ── DigiLocker: initiate ──
    if (action === "digilocker_initiate") {
      const { verificationId, redirectUrl } = body;
      if (!verificationId || !redirectUrl) return resp(400, { success: false, error: "verificationId and redirectUrl required" });
      const data = await cfFetch("/digilocker", "POST", {
        verification_id: verificationId,
        document_requested: ["AADHAAR", "PAN"],
        redirect_url: redirectUrl,
        user_flow: "signup",
      });
      if (!data.url) return resp(502, { success: false, error: data.message || "Failed to create DigiLocker URL" });
      return resp(200, { success: true, url: data.url });
    }

    // ── DigiLocker: status ──
    if (action === "digilocker_status") {
      const { verificationId } = body;
      if (!verificationId) return resp(400, { success: false, error: "verificationId required" });
      const data = await cfFetch(`/digilocker?verification_id=${verificationId}`);
      return resp(200, { success: true, status: data.status, user_details: data.user_details, document_consent: data.document_consent, document_consent_validity: data.document_consent_validity });
    }

    // ── DigiLocker: get document ──
    if (action === "digilocker_document") {
      const { verificationId, documentType } = body;
      if (!verificationId || !documentType) return resp(400, { success: false, error: "verificationId and documentType required" });
      const data = await cfFetch(`/digilocker/document/${documentType}?verification_id=${verificationId}`);
      return resp(200, { success: data.status === "SUCCESS", data });
    }

    // ── Bank account sync ──
    if (action === "bank_verify") {
      const { bankAccount, ifsc, name, phone } = body;
      if (!bankAccount || !ifsc || !name) return resp(400, { success: false, error: "bankAccount, ifsc, name required" });
      const payload = { bank_account: bankAccount, ifsc: ifsc.toUpperCase(), name };
      if (phone) payload.phone = phone.replace(/\D/g, "").slice(-10);
      const data = await cfFetch("/bank-account/sync", "POST", payload);
      return resp(200, { success: data.account_status === "VALID", data });
    }

    return resp(400, { success: false, error: `Unknown action: ${action}` });
  } catch (err) {
    console.error("[hg-tutor-lambda]", err);
    return resp(500, { success: false, error: err.message });
  }
};
