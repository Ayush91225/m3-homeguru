import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../screens/shared/feed/blog_detail_screen.dart';
import '../../../../../screens/shared/feed/feed_models.dart';
import '../tutor_intro_video.dart';

class TutorAboutTab extends StatelessWidget {
  const TutorAboutTab({super.key, this.viewMode = false});
  
  final bool viewMode;

  static const _tags = [
    'Mathematics',
    'Physics',
    'JEE Preparation',
    'NEET Physics',
    'Board Exams',
    'Problem Solving',
    'Concept Building',
  ];

  static const _subjects = [
    {'name': 'Mathematics', 'rate': '₹500', 'level': 'JEE/Advanced'},
    {'name': 'Physics', 'rate': '₹500', 'level': 'JEE/NEET'},
    {'name': 'Mathematics', 'rate': '₹350', 'level': 'Class 11-12'},
    {'name': 'Physics', 'rate': '₹350', 'level': 'Class 11-12'},
  ];

  static const _experience = [
    {
      'title': 'Senior Physics Tutor',
      'org': 'Vedantu',
      'period': '2022 - Present',
      'type': 'Online',
    },
    {
      'title': 'Mathematics Teacher',
      'org': 'Delhi Public School',
      'period': '2019 - 2022',
      'type': 'Full-time',
    },
  ];

  static final _blogs = [
    HgBlog(
      id: 't1',
      title: '5 Tips to Master Calculus for JEE Advanced',
      body: 'Calculus is often considered one of the most challenging topics in JEE Advanced preparation. However, with the right approach and consistent practice, you can master it.\n\n1. Build Strong Fundamentals: Before diving into complex problems, ensure you have a solid understanding of limits, derivatives, and integrals. These are the building blocks of calculus.\n\n2. Practice Visualization: Try to visualize graphs and curves. Understanding the geometric interpretation of derivatives and integrals will make problem-solving much easier.\n\n3. Solve Previous Year Papers: JEE Advanced has specific patterns in calculus questions. Solving past papers will help you identify these patterns and prepare accordingly.\n\n4. Focus on Application: Don\'t just memorize formulas. Understand when and how to apply them. Practice problems that require multiple concepts.\n\n5. Regular Revision: Calculus requires consistent practice. Set aside time each week to revise concepts and solve problems.',
      imageUrl: 'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=800',
      authorName: 'Rajesh Kumar',
      authorAvatar: 'https://i.pravatar.cc/150?img=15',
      tags: ['Mathematics', 'JEE', 'Calculus'],
      publishedAt: '2 days ago',
    ),
    HgBlog(
      id: 't2',
      title: 'Understanding Newton\'s Laws Through Real-World Examples',
      body: 'Newton\'s Laws of Motion form the foundation of classical mechanics. While they might seem abstract in textbooks, they govern everything around us.\n\nFirst Law (Inertia): Ever noticed how you jerk forward when a bus suddenly stops? That\'s inertia in action. Your body wants to continue moving at the same speed.\n\nSecond Law (F=ma): When you push a shopping cart, the harder you push (more force), the faster it accelerates. If the cart is loaded with groceries (more mass), it\'s harder to accelerate.\n\nThird Law (Action-Reaction): When you jump, you push the ground downward, and the ground pushes you upward with equal force. That\'s why you can\'t jump in mid-air!\n\nUnderstanding these laws through real-world examples makes physics intuitive rather than just memorizing formulas.',
      imageUrl: 'https://images.unsplash.com/photo-1636466497217-26a8cbeaf0aa?w=800',
      authorName: 'Rajesh Kumar',
      authorAvatar: 'https://i.pravatar.cc/150?img=15',
      tags: ['Physics', 'Newton', 'Mechanics'],
      publishedAt: '1 week ago',
    ),
    HgBlog(
      id: 't3',
      title: 'Common Mistakes Students Make in Trigonometry',
      body: 'Trigonometry is a scoring topic if you avoid common pitfalls. Here are mistakes I see students make repeatedly:\n\n1. Confusing Degrees and Radians: Always check which unit the problem uses. Most calculus problems use radians.\n\n2. Sign Errors: Remember ASTC (All Students Take Calculus) to determine signs in different quadrants.\n\n3. Not Simplifying: Many students stop at complex expressions. Always try to simplify using identities.\n\n4. Memorizing Without Understanding: Don\'t just memorize formulas. Understand how they\'re derived. This helps in solving complex problems.\n\n5. Ignoring Domain and Range: Always consider the domain and range of trigonometric functions, especially in inverse trig problems.\n\nPractice these concepts regularly, and trigonometry will become one of your strongest topics!',
      imageUrl: 'https://images.unsplash.com/photo-1509228468518-180dd4864904?w=800',
      authorName: 'Rajesh Kumar',
      authorAvatar: 'https://i.pravatar.cc/150?img=15',
      tags: ['Mathematics', 'Trigonometry'],
      publishedAt: '2 weeks ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(0),
      children: [
        const SizedBox(height: 24),
        
        // Intro Video
        if (!viewMode) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TutorIntroVideo(
              videoUrl: 'https://youtu.be/0-FUhQKe-eU?si=qubQmsRNgu7LB-dy',
              height: 200,
            ),
          ),
          const SizedBox(height: 32),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 32),
        ],
        
        // Bio Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(
                'Experienced mathematics and physics tutor with 5+ years of teaching experience. Specialized in JEE/NEET preparation and board exam coaching. Passionate about making complex concepts simple and engaging through interactive problem-solving sessions.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.6),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: cs.tertiary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 32),
        
        // Subjects & Pricing
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Subjects & Pricing', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Per hour rates', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 20),
            ],
          ),
        ),
        ..._subjects.map((subject) => _SubjectPricingRow(
          subject: subject['name'] as String,
          rate: subject['rate'] as String,
          level: subject['level'] as String,
          cs: cs,
          tt: tt,
        )),
        
        const SizedBox(height: 32),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 32),
        
        // Experience
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Experience', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
            ],
          ),
        ),
        ..._experience.map((exp) => _ExperienceRow(
          title: exp['title'] as String,
          org: exp['org'] as String,
          period: exp['period'] as String,
          type: exp['type'] as String,
          cs: cs,
          tt: tt,
        )),
        
        const SizedBox(height: 32),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 32),
        
        // Qualifications
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Education', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _QualificationRow(
          icon: Icons.school_rounded,
          title: 'B.Tech in Mechanical Engineering',
          subtitle: 'IIT Delhi • 2015-2019',
          cs: cs,
          tt: tt,
        ),
        _QualificationRow(
          icon: Icons.workspace_premium_rounded,
          title: 'CTET Qualified',
          subtitle: 'Central Teacher Eligibility Test',
          cs: cs,
          tt: tt,
        ),
        
        const SizedBox(height: 32),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 32),
        
        // Teaching Approach
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Teaching Approach', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
            ],
          ),
        ),
        _ApproachRow(icon: Icons.psychology_outlined, label: 'Concept-focused learning', cs: cs, tt: tt),
        _ApproachRow(icon: Icons.quiz_outlined, label: 'Regular practice tests & assessments', cs: cs, tt: tt),
        _ApproachRow(icon: Icons.support_agent_rounded, label: '24/7 doubt clearing support', cs: cs, tt: tt),
        _ApproachRow(icon: Icons.trending_up_rounded, label: 'Personalized progress tracking', cs: cs, tt: tt),
        _ApproachRow(icon: Icons.video_library_outlined, label: 'Recorded session access', cs: cs, tt: tt),
        
        const SizedBox(height: 32),
        Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.3)),
        const SizedBox(height: 32),
        
        // Blogs
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Blog Posts', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _blogs.length,
            itemBuilder: (context, index) {
              final blog = _blogs[index];
              return Padding(
                padding: EdgeInsets.only(right: index < _blogs.length - 1 ? 12 : 0),
                child: _BlogCard(
                  blog: blog,
                  cs: cs,
                  tt: tt,
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SubjectPricingRow extends StatelessWidget {
  const _SubjectPricingRow({
    required this.subject,
    required this.rate,
    required this.level,
    required this.cs,
    required this.tt,
  });
  final String subject, rate, level;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(level, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          Text(
            '$rate/hr',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  const _ExperienceRow({
    required this.title,
    required this.org,
    required this.period,
    required this.type,
    required this.cs,
    required this.tt,
  });
  final String title, org, period, type;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(org, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(period, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              Text(' • ', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              Text(type, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QualificationRow extends StatelessWidget {
  const _QualificationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cs,
    required this.tt,
  });
  final IconData icon;
  final String title, subtitle;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: cs.tertiary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApproachRow extends StatelessWidget {
  const _ApproachRow({required this.icon, required this.label, required this.cs, required this.tt});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: cs.tertiary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}

class _BlogCard extends StatelessWidget {
  const _BlogCard({
    required this.blog,
    required this.cs,
    required this.tt,
  });
  final HgBlog blog;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlogDetailScreen(blog: blog),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: blog.imageUrl,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, _) =>
                  Container(height: 140, color: cs.surfaceContainerHighest),
              errorWidget: (_, _, _) =>
                  Container(height: 140, color: cs.surfaceContainerHighest),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    blog.title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: blog.tags
                        .map((t) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.tertiaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.onTertiaryContainer)),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
