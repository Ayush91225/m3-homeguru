import 'package:flutter/material.dart';
import '../../../../services/meeting_signaling_service.dart';
import 'quiz_running_mode.dart';
import 'quiz_select_mode.dart';
import 'quiz_topic_mode.dart';
import 'quiz_manual_mode.dart';
import 'quiz_preview_mode.dart';
import 'quiz_results_mode.dart';
import 'quiz_hosting_mode.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correct;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correct,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'options': options,
    'correct': correct,
  };

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    correct: json['correct'] as int,
  );
}

enum QuizMode { select, topic, manual, preview, running, results, hosting }

class QuizScreen extends StatefulWidget {
  final bool isHost;
  final MeetingSignalingService? signalingService;

  const QuizScreen({
    super.key,
    this.isHost = false,
    this.signalingService,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizMode _mode = QuizMode.select;
  List<QuizQuestion> _questions = [];
  int _currentIdx = 0;
  int? _selectedOption;
  int _score = 0;
  bool _generating = false;
  String _error = '';
  String _topicInput = '';
  int _questionCount = 10;
  
  // Manual mode
  String _manualQuestion = '';
  List<String> _manualOptions = ['', '', '', ''];
  int _manualCorrect = 0;
  
  final _markingScheme = {'correct': 4, 'incorrect': -1, 'skipped': 0};
  List<int?> _myAnswers = [];
  List<Map<String, dynamic>> _submissions = [];
  String? _expandedUser;

  @override
  void initState() {
    super.initState();
    _setupSignaling();
  }

  void _setupSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'quiz-start' && _mode != QuizMode.hosting) {
        _handleQuizStart(msg);
      } else if (msg['action'] == 'quiz-end' && _mode != QuizMode.hosting) {
        _handleQuizEnd();
      } else if (msg['action'] == 'quiz-submit') {
        _handleSubmission(msg);
      }
    });
  }

  void _handleQuizStart(Map<String, dynamic> msg) {
    final quiz = msg['quiz'] as Map<String, dynamic>?;
    if (quiz == null) return;
    
    final questions = (quiz['questions'] as List?)
        ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
        .toList() ?? [];
    
    setState(() {
      _questions = questions;
      _mode = QuizMode.running;
      _currentIdx = 0;
      _selectedOption = null;
      _score = 0;
      _myAnswers = List.filled(questions.length, null);
    });
  }

  void _handleQuizEnd() {
    setState(() {
      _mode = QuizMode.select;
      _questions = [];
      _myAnswers = [];
      _submissions = [];
    });
  }

  void _handleSubmission(Map<String, dynamic> msg) {
    final submission = msg['submission'] as Map<String, dynamic>?;
    final userName = msg['userName'] as String?;
    if (submission == null || userName == null) return;

    setState(() {
      if (!_submissions.any((s) => s['userName'] == userName)) {
        _submissions.add({
          ...submission,
          'userName': userName,
        });
      }
    });
  }

  Future<void> _generateQuiz() async {
    setState(() {
      _generating = true;
      _error = '';
    });

    // TODO: Implement API call to generate quiz
    // For now, create mock questions
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _questions = List.generate(
        _questionCount,
        (i) => QuizQuestion(
          id: 'q_$i',
          question: 'Sample question ${i + 1} about $_topicInput?',
          options: ['Option A', 'Option B', 'Option C', 'Option D'],
          correct: 0,
        ),
      );
      _generating = false;
      _mode = QuizMode.preview;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHost && _mode == QuizMode.select) {
      return _buildWaitingState();
    }

    switch (_mode) {
      case QuizMode.select:
        return _buildSelectMode();
      case QuizMode.topic:
        return _buildTopicMode();
      case QuizMode.manual:
        return _buildManualMode();
      case QuizMode.preview:
        return _buildPreviewMode();
      case QuizMode.running:
        return _buildRunningMode();
      case QuizMode.results:
        return _buildResultsMode();
      case QuizMode.hosting:
        return _buildHostingMode();
    }
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No active session',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Host will post a quiz soon',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectMode() {
    return QuizSelectMode(
      markingScheme: _markingScheme,
      onTopicBased: () => setState(() => _mode = QuizMode.topic),
      onClassBased: () => setState(() => _mode = QuizMode.topic),
      onManualBuild: () {
        setState(() {
          _questions = [];
          _mode = QuizMode.manual;
        });
      },
    );
  }

  Widget _buildTopicMode() {
    return QuizTopicMode(
      initialTopic: _topicInput,
      questionCount: _questionCount,
      generating: _generating,
      error: _error,
      onBack: () => setState(() => _mode = QuizMode.select),
      onTopicChanged: (v) => setState(() => _topicInput = v),
      onCountChanged: (c) => setState(() => _questionCount = c),
      onGenerate: _generateQuiz,
    );
  }

  Widget _buildManualMode() {
    return QuizManualMode(
      questions: _questions,
      onBack: () => setState(() => _mode = QuizMode.select),
      onPreview: () => setState(() => _mode = QuizMode.preview),
      onPost: _startQuiz,
      onAddQuestion: (q) => setState(() => _questions.add(q)),
      onDeleteQuestion: (i) => setState(() => _questions.removeAt(i)),
    );
  }

  void _startQuiz() {
    setState(() {
      _currentIdx = 0;
      _selectedOption = null;
      _score = 0;
      _myAnswers = List.filled(_questions.length, null);
      _submissions = [];
      _mode = QuizMode.hosting;
    });

    widget.signalingService?.send({
      'action': 'quiz-start',
      'quiz': {
        'questions': _questions.map((q) => q.toJson()).toList(),
        'markingScheme': _markingScheme,
      },
    });
  }

  Widget _buildPreviewMode() {
    return QuizPreviewMode(
      questions: _questions,
      markingScheme: _markingScheme,
      onRegenerate: () => setState(() => _mode = QuizMode.topic),
      onPost: _startQuiz,
      onDelete: (i) => setState(() => _questions.removeAt(i)),
    );
  }

  Widget _buildRunningMode() {
    return QuizRunningMode(
      questions: _questions,
      currentIdx: _currentIdx,
      selectedOption: _selectedOption,
      score: _score,
      markingScheme: _markingScheme,
      onSelectOption: (i) => setState(() => _selectedOption = i),
      onAnswer: _handleAnswer,
    );
  }

  void _handleAnswer() {
    final picked = _selectedOption;
    final correct = _questions[_currentIdx].correct;
    
    _myAnswers[_currentIdx] = picked;
    
    if (picked == correct) {
      _score += _markingScheme['correct']!;
    } else if (picked != null) {
      _score += _markingScheme['incorrect']!;
    }

    if (_currentIdx < _questions.length - 1) {
      setState(() {
        _currentIdx++;
        _selectedOption = null;
      });
    } else {
      final finalAnswers = List<int?>.from(_myAnswers);
      finalAnswers[_currentIdx] = picked;
      
      int finalScore = 0;
      for (int i = 0; i < finalAnswers.length; i++) {
        if (finalAnswers[i] == _questions[i].correct) {
          finalScore += _markingScheme['correct']!;
        } else if (finalAnswers[i] != null) {
          finalScore += _markingScheme['incorrect']!;
        }
      }
      
      widget.signalingService?.send({
        'action': 'quiz-submit',
        'submission': {
          'answers': finalAnswers,
          'score': finalScore,
          'total': _questions.length * _markingScheme['correct']!,
          'submittedAt': DateTime.now().millisecondsSinceEpoch,
        },
      });
      
      setState(() {
        _score = finalScore;
        _mode = QuizMode.results;
      });
    }
  }

  Widget _buildResultsMode() {
    return QuizResultsMode(
      questions: _questions,
      myAnswers: _myAnswers,
      score: _score,
      markingScheme: _markingScheme,
      onClose: () {
        setState(() {
          _mode = QuizMode.select;
          _questions = [];
          _myAnswers = [];
        });
      },
    );
  }

  Widget _buildHostingMode() {
    return QuizHostingMode(
      questions: _questions,
      submissions: _submissions,
      markingScheme: _markingScheme,
      onEndQuiz: () {
        widget.signalingService?.send({
          'action': 'quiz-end',
          'results': _submissions,
        });
        setState(() {
          _mode = QuizMode.select;
          _questions = [];
          _submissions = [];
          _myAnswers = [];
        });
      },
    );
  }
}
 