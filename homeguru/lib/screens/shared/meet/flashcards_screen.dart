import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/meeting_signaling_service.dart';

class FlashcardsScreen extends StatefulWidget {
  final MeetingSignalingService? signalingService;

  const FlashcardsScreen({super.key, this.signalingService});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _flipped = false;
  String _mode = 'select'; // select, manual, study
  final _frontController = TextEditingController();
  final _backController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCards();
    _listenToSignaling();
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('flashcards');
    if (json != null) {
      try {
        final list = jsonDecode(json) as List;
        setState(() => _cards = list.map((e) => Flashcard.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading flashcards: $e');
      }
    }
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('flashcards', jsonEncode(_cards.map((c) => c.toJson()).toList()));
  }

  void _listenToSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'flashcards-sync') {
        if (msg['currentIndex'] != null) {
          setState(() => _currentIndex = msg['currentIndex']);
        }
        if (msg['flipped'] != null) {
          setState(() => _flipped = msg['flipped']);
        }
        if (msg['cards'] != null) {
          final cards = (msg['cards'] as List).map((e) => Flashcard.fromJson(e)).toList();
          setState(() {
            _cards = cards;
            _currentIndex = msg['currentIndex'] ?? 0;
            _flipped = msg['flipped'] ?? false;
            _mode = 'study';
          });
        }
      }
    });
  }

  void _addCard() {
    if (_frontController.text.trim().isEmpty || _backController.text.trim().isEmpty) return;

    setState(() {
      _cards.add(Flashcard(
        id: DateTime.now().toString(),
        front: _frontController.text.trim(),
        back: _backController.text.trim(),
        status: 'new',
      ));
      _frontController.clear();
      _backController.clear();
    });
    _saveCards();
  }

  void _deleteCard(String id) {
    setState(() {
      _cards.removeWhere((c) => c.id == id);
      if (_currentIndex >= _cards.length) {
        _currentIndex = _cards.length - 1;
      }
    });
    _saveCards();
  }

  void _goToCard(int index) {
    setState(() {
      _currentIndex = index;
      _flipped = false;
    });
    widget.signalingService?.send({
      'action': 'flashcards-sync',
      'currentIndex': index,
      'flipped': false,
    });
  }

  void _toggleFlip() {
    setState(() => _flipped = !_flipped);
    widget.signalingService?.send({
      'action': 'flashcards-sync',
      'currentIndex': _currentIndex,
      'flipped': !_flipped,
    });
  }

  void _setStatus(String status) {
    if (_currentIndex >= _cards.length) return;
    setState(() {
      _cards[_currentIndex] = Flashcard(
        id: _cards[_currentIndex].id,
        front: _cards[_currentIndex].front,
        back: _cards[_currentIndex].back,
        status: status,
      );
    });
    _saveCards();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_currentIndex < _cards.length - 1) {
        _goToCard(_currentIndex + 1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_mode == 'select') {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Flashcards', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _OptionCard(
                icon: Icons.add,
                title: 'Manual Build',
                subtitle: 'Create your own cards',
                color: cs.tertiary,
                onTap: () => setState(() => _mode = 'manual'),
              ),
              const SizedBox(height: 12),
              if (_cards.isNotEmpty)
                _OptionCard(
                  icon: Icons.school,
                  title: 'Study Mode',
                  subtitle: '${_cards.length} cards ready',
                  color: cs.primary,
                  onTap: () {
                    setState(() {
                      _mode = 'study';
                      _currentIndex = 0;
                      _flipped = false;
                    });
                    widget.signalingService?.send({
                      'action': 'flashcards-sync',
                      'cards': _cards.map((c) => c.toJson()).toList(),
                      'currentIndex': 0,
                      'flipped': false,
                    });
                  },
                ),
            ],
          ),
        ),
      );
    }

    if (_mode == 'manual') {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: cs.onSurface),
            onPressed: () => setState(() => _mode = 'select'),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Manual Builder', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface)),
              Text('${_cards.length} cards added', style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant)),
            ],
          ),
          actions: [
            if (_cards.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _mode = 'study';
                    _currentIndex = 0;
                    _flipped = false;
                  });
                  widget.signalingService?.send({
                    'action': 'flashcards-sync',
                    'cards': _cards.map((c) => c.toJson()).toList(),
                    'currentIndex': 0,
                    'flipped': false,
                  });
                },
                child: const Text('Study', style: TextStyle(fontSize: 9)),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_cards.isNotEmpty)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _cards.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final card = _cards[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: cs.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            alignment: Alignment.center,
                            child: Text('${i + 1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(card.front, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(card.back, style: TextStyle(fontSize: 8, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 10, color: cs.error),
                            onPressed: () => _deleteCard(card.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(child: SizedBox()),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _frontController,
                    decoration: InputDecoration(
                      labelText: 'Front (Question)',
                      labelStyle: TextStyle(fontSize: 8, color: cs.onSurfaceVariant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: TextStyle(fontSize: 11, color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _backController,
                    decoration: InputDecoration(
                      labelText: 'Back (Answer)',
                      labelStyle: TextStyle(fontSize: 8, color: cs.onSurfaceVariant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: TextStyle(fontSize: 11, color: cs.onSurface),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _addCard,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text('Add Card', style: TextStyle(fontSize: 10)),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.tertiary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_mode == 'study' && _cards.isNotEmpty) {
      final card = _cards[_currentIndex];
      final newCount = _cards.where((c) => c.status == 'new').length;
      final learningCount = _cards.where((c) => c.status == 'learning').length;
      final masteredCount = _cards.where((c) => c.status == 'mastered').length;
      final progress = (_cards.isNotEmpty ? (masteredCount / _cards.length * 100).round() : 0);

      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: cs.onSurface),
            onPressed: () => setState(() => _mode = 'select'),
          ),
          title: Row(
            children: [
              Icon(Icons.style, size: 16, color: cs.onSurface),
              const SizedBox(width: 8),
              Text('${_currentIndex + 1}/${_cards.length}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurface)),
              const SizedBox(width: 8),
              Text('· $progress% mastered', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _cards.clear();
                  _mode = 'select';
                });
                _saveCards();
              },
              child: Text('New', style: TextStyle(fontSize: 8, color: cs.error)),
            ),
          ],
        ),
        body: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _cards.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: i == _currentIndex
                            ? cs.primary
                            : c.status == 'mastered'
                                ? cs.tertiary
                                : c.status == 'learning'
                                    ? cs.secondary
                                    : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GestureDetector(
                    onTap: _toggleFlip,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _flipped ? cs.primary : cs.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _flipped ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_flipped) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: card.status == 'new'
                                    ? cs.surfaceContainerLow
                                    : card.status == 'learning'
                                        ? cs.secondaryContainer
                                        : cs.tertiaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                card.status == 'new' ? 'NEW' : card.status == 'learning' ? 'LEARNING' : 'MASTERED',
                                style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w700,
                                  color: card.status == 'new'
                                      ? cs.onSurfaceVariant
                                      : card.status == 'learning'
                                          ? cs.secondary
                                          : cs.tertiary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              card.front,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.refresh, size: 10, color: cs.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text('TAP TO REVEAL', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                              ],
                            ),
                          ] else ...[
                            Text('ANSWER', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.onPrimary.withValues(alpha: 0.4), letterSpacing: 1.5)),
                            const SizedBox(height: 12),
                            Text(
                              card.back,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Column(
                children: [
                  if (_flipped)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _setStatus('new'),
                              child: const Text('😐 Again', style: TextStyle(fontSize: 8)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _setStatus('learning'),
                              child: const Text('🤔 Hard', style: TextStyle(fontSize: 8)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _setStatus('mastered'),
                              child: const Text('✅ Easy', style: TextStyle(fontSize: 8)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _currentIndex > 0 ? () => _goToCard(_currentIndex - 1) : null,
                        icon: Icon(Icons.chevron_left, color: _currentIndex > 0 ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        style: IconButton.styleFrom(
                          backgroundColor: cs.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFlip,
                          icon: const Icon(Icons.refresh, size: 13),
                          label: Text(_flipped ? 'Show Question' : 'Reveal Answer', style: const TextStyle(fontSize: 9)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _currentIndex < _cards.length - 1 ? () => _goToCard(_currentIndex + 1) : null,
                        icon: Icon(Icons.chevron_right, color: _currentIndex < _cards.length - 1 ? cs.onPrimary : cs.onSurfaceVariant.withValues(alpha: 0.3)),
                        style: IconButton.styleFrom(
                          backgroundColor: _currentIndex < _cards.length - 1 ? cs.primary : cs.surfaceContainerLow,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: cs.surfaceContainerLow,
                      child: Column(
                        children: [
                          Text('$newCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                          Text('NEW', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: cs.secondaryContainer,
                      child: Column(
                        children: [
                          Text('$learningCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.secondary)),
                          Text('LEARNING', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.secondary, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      color: cs.tertiaryContainer,
                      child: Column(
                        children: [
                          Text('$masteredCount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: cs.tertiary)),
                          Text('MASTERED', style: TextStyle(fontSize: 7, fontWeight: FontWeight.w600, color: cs.tertiary, letterSpacing: 1.2)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurface)),
                    Text(subtitle, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Flashcard {
  final String id;
  final String front;
  final String back;
  final String status;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'status': status,
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        front: json['front'],
        back: json['back'],
        status: json['status'],
      );
}
