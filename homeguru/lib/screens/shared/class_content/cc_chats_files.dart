import 'package:flutter/material.dart';
import 'cc_shared.dart';

// ── Chats ─────────────────────────────────────────────────────────────────────

const _mockChats = [
  ('Vikram Singh', 'Please open page 42 of your textbook.', '10:02 AM', true),
  ('You', 'Done!', '10:03 AM', false),
  ('Vikram Singh', 'Great. Now solve problem 3 and share your working.', '10:04 AM', true),
  ('You', 'Here it is — F = 1000 × 2 = 2000 N', '10:06 AM', false),
  ('Vikram Singh', 'Perfect. Well done 👏', '10:07 AM', true),
  ('Vikram Singh', 'Now let\'s try another one. A 200 kg object accelerates at 5 m/s². What is the force?', '10:09 AM', true),
  ('You', '1000 N!', '10:10 AM', false),
  ('Vikram Singh', 'Correct! You\'re getting the hang of it.', '10:11 AM', true),
];

class ChatsSection extends StatelessWidget {
  const ChatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _mockChats.map((msg) {
        final (sender, text, time, isTutor) = msg;
        return Padding(
          padding: EdgeInsets.fromLTRB(isTutor ? 0 : 40, 0, isTutor ? 40 : 0, 10),
          child: Column(
            crossAxisAlignment: isTutor ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isTutor)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(sender, style: tt.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isTutor ? cs.surfaceContainerLow : cs.primaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isTutor ? 4 : 16),
                    bottomRight: Radius.circular(isTutor ? 16 : 4),
                  ),
                ),
                child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurface)),
              ),
              const SizedBox(height: 2),
              Text(time, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
            ],
          ),
        );
      }).toList(),
    );

    return CollapsibleSection(
      section: ClassSection.chats,
      previewHeight: 240,
      child: content,
    );
  }
}

// ── Files ─────────────────────────────────────────────────────────────────────

const _fileData = [
  ('Newton\'s Laws Notes.pdf', 'pdf', '1.2 MB'),
  ('Class Slides.pptx', 'pptx', '3.4 MB'),
  ('Practice Problems.docx', 'docx', '540 KB'),
  ('Class Recording.mp4', 'mp4', '128 MB'),
];

const _fileIcons = {
  'pdf': Icons.picture_as_pdf_rounded,
  'pptx': Icons.slideshow_rounded,
  'docx': Icons.description_rounded,
  'mp4': Icons.video_file_rounded,
};

class FilesSection extends StatelessWidget {
  final Map<String, dynamic> session;
  const FilesSection({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final count = (session['files'] as int?) ?? 3;
    final files = _fileData.take(count).toList();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: files.map((f) {
        final (name, ext, size) = f;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            tileColor: cs.surfaceContainerLow,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
              child: Icon(_fileIcons[ext] ?? Icons.insert_drive_file_rounded, size: 20, color: cs.primary),
            ),
            title: Text(name, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
            subtitle: Text(size, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
            trailing: Icon(Icons.visibility_outlined, size: 20, color: cs.onSurfaceVariant),
          ),
        );
      }).toList(),
    );

    return CollapsibleSection(
      section: ClassSection.files,
      previewHeight: count > 2 ? 160 : double.infinity,
      child: content,
    );
  }
}
