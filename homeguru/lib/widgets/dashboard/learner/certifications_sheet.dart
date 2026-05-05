import 'package:flutter/material.dart';

const _certs = [
  (title: 'Mathematics', tutor: 'Mr. Arjun Nair', grade: 'A+'),
  (title: 'English', tutor: 'Ms. Priya Iyer', grade: 'A'),
  (title: 'Physics', tutor: 'Dr. Rahul Verma', grade: ''),
];

class CertificationsSheet extends StatelessWidget {
  const CertificationsSheet({super.key});

  static void show(BuildContext context) => showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => const CertificationsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final completed = _certs.where((c) => c.grade.isNotEmpty).length;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // handle + open
          Row(
            children: [
              const Spacer(),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.open_in_new_rounded, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // title + count
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text('Certifications',
                  style: tt.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                ),
                child: Text('$completed',
                    style: tt.labelMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // certs
          ..._certs.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: c.grade.isNotEmpty ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: c.grade.isNotEmpty ? 0.35 : 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        c.grade.isNotEmpty
                            ? Icons.workspace_premium_rounded
                            : Icons.lock_outline_rounded,
                        color: Colors.white.withValues(alpha: c.grade.isNotEmpty ? 1.0 : 0.5),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.title,
                                style: tt.bodyMedium?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.w700)),
                            Text(c.tutor,
                                style: tt.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                      if (c.grade.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(c.grade,
                              style: tt.labelMedium?.copyWith(
                                  color: Colors.black87, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.download_rounded, size: 16, color: Colors.white),
                      ],
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
