import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/meeting_signaling_service.dart';

class PollsScreen extends StatefulWidget {
  final String meetingId;
  final MeetingSignalingService? signalingService;

  const PollsScreen({
    super.key,
    this.meetingId = 'default',
    this.signalingService,
  });

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<Poll> _polls = [];
  Map<String, String> _votedPolls = {};
  bool _isCreating = false;
  final _questionController = TextEditingController();
  List<TextEditingController> _optionControllers = [];

  @override
  void initState() {
    super.initState();
    _loadPolls();
    _listenToSignaling();
    _initOptionControllers();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _initOptionControllers() {
    _optionControllers = [TextEditingController(), TextEditingController()];
  }

  Future<void> _loadPolls() async {
    final prefs = await SharedPreferences.getInstance();
    final pollsJson = prefs.getString('oneonone_polls_${widget.meetingId}');
    final votesJson = prefs.getString('oneonone_votes_${widget.meetingId}');

    if (pollsJson != null) {
      try {
        final list = jsonDecode(pollsJson) as List;
        setState(() => _polls = list.map((e) => Poll.fromJson(e)).toList());
      } catch (e) {
        debugPrint('Error loading polls: $e');
      }
    }

    if (votesJson != null) {
      try {
        setState(() => _votedPolls = Map<String, String>.from(jsonDecode(votesJson)));
      } catch (e) {
        debugPrint('Error loading votes: $e');
      }
    }
  }

  void _listenToSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'poll-create' && msg['poll'] != null) {
        final poll = Poll.fromJson(msg['poll']);
        if (!_polls.any((p) => p.id == poll.id)) {
          setState(() => _polls.insert(0, poll));
          _persist();
        }
      } else if (msg['action'] == 'poll-update' && msg['poll'] != null) {
        final poll = Poll.fromJson(msg['poll']);
        setState(() {
          final index = _polls.indexWhere((p) => p.id == poll.id);
          if (index != -1) _polls[index] = poll;
        });
        _persist();
      } else if (msg['action'] == 'poll-delete' && msg['pollId'] != null) {
        setState(() => _polls.removeWhere((p) => p.id == msg['pollId']));
        _persist();
      }
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('oneonone_polls_${widget.meetingId}', jsonEncode(_polls.map((p) => p.toJson()).toList()));
    await prefs.setString('oneonone_votes_${widget.meetingId}', jsonEncode(_votedPolls));
  }

  void _createPoll() {
    final question = _questionController.text.trim();
    final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();

    if (question.isEmpty || options.length < 2) return;

    final poll = Poll(
      id: '${DateTime.now().millisecondsSinceEpoch}-${DateTime.now().microsecond}',
      question: question,
      options: options.map((text) => PollOption(id: DateTime.now().toString(), text: text, votes: 0)).toList(),
      isClosed: false,
      totalVotes: 0,
      createdAt: DateTime.now(),
    );

    setState(() {
      _polls.insert(0, poll);
      _isCreating = false;
      _questionController.clear();
      for (var c in _optionControllers) {
        c.clear();
      }
    });
    _persist();
    widget.signalingService?.send({'action': 'poll-create', 'poll': poll.toJson()});
  }

  void _vote(String pollId, String optionId) {
    if (_votedPolls.containsKey(pollId)) return;

    setState(() {
      final index = _polls.indexWhere((p) => p.id == pollId);
      if (index != -1) {
        final poll = _polls[index];
        final optIndex = poll.options.indexWhere((o) => o.id == optionId);
        if (optIndex != -1) {
          poll.options[optIndex] = PollOption(
            id: poll.options[optIndex].id,
            text: poll.options[optIndex].text,
            votes: poll.options[optIndex].votes + 1,
          );
          _polls[index] = Poll(
            id: poll.id,
            question: poll.question,
            options: poll.options,
            isClosed: poll.isClosed,
            totalVotes: poll.totalVotes + 1,
            createdAt: poll.createdAt,
          );
        }
      }
      _votedPolls[pollId] = optionId;
    });
    _persist();
    widget.signalingService?.send({'action': 'poll-vote', 'pollId': pollId, 'optionId': optionId});
  }

  void _closePoll(String pollId) {
    setState(() {
      final index = _polls.indexWhere((p) => p.id == pollId);
      if (index != -1) {
        final poll = _polls[index];
        _polls[index] = Poll(
          id: poll.id,
          question: poll.question,
          options: poll.options,
          isClosed: true,
          totalVotes: poll.totalVotes,
          createdAt: poll.createdAt,
        );
      }
    });
    _persist();
    widget.signalingService?.send({'action': 'poll-close', 'pollId': pollId});
  }

  void _deletePoll(String pollId) {
    setState(() {
      _polls.removeWhere((p) => p.id == pollId);
      _votedPolls.remove(pollId);
    });
    _persist();
    widget.signalingService?.send({'action': 'poll-delete', 'pollId': pollId});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeCount = _polls.where((p) => !p.isClosed).length;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Polls', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface)),
            Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeCount > 0 ? cs.tertiary : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  activeCount > 0 ? '$activeCount active' : 'No active polls',
                  style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_polls.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  _polls.clear();
                  _votedPolls.clear();
                });
                _persist();
              },
              child: Text('Clear All', style: TextStyle(fontSize: 9, color: cs.error)),
            ),
          if (!_isCreating)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () => setState(() => _isCreating = true),
                icon: const Icon(Icons.add, size: 12),
                label: const Text('New', style: TextStyle(fontSize: 11)),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          if (_isCreating) ...[
            Container(
              padding: const EdgeInsets.all(16),
              color: cs.surfaceContainerLow,
              child: Column(
                children: [
                  TextField(
                    controller: _questionController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  ..._optionControllers.asMap().entries.map((entry) {
                    final i = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: 'Option ${i + 1}',
                                filled: true,
                                fillColor: cs.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: cs.outlineVariant),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.only(left: 12, right: 8),
                                  width: 14, height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cs.outlineVariant, width: 2),
                                  ),
                                ),
                              ),
                              style: TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w500),
                            ),
                          ),
                          if (_optionControllers.length > 2)
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 13, color: cs.error),
                              onPressed: () {
                                setState(() {
                                  controller.dispose();
                                  _optionControllers.removeAt(i);
                                });
                              },
                            ),
                        ],
                      ),
                    );
                  }),
                  if (_optionControllers.length < 6)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() => _optionControllers.add(TextEditingController())),
                        icon: const Icon(Icons.add, size: 11),
                        label: const Text('Add Option', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _createPoll,
                          icon: const Icon(Icons.send, size: 14),
                          label: const Text('Launch Poll', style: TextStyle(fontSize: 12)),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _isCreating = false;
                            _questionController.clear();
                            for (var c in _optionControllers) {
                              c.clear();
                            }
                          });
                        },
                        child: const Text('Cancel', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          Expanded(
            child: _polls.isEmpty && !_isCreating
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Icon(Icons.bar_chart, size: 24, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        Text('No polls yet', style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          'Create a poll to gather feedback\nfrom participants',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _polls.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _PollCard(
                      poll: _polls[i],
                      votedOptionId: _votedPolls[_polls[i].id],
                      onVote: (optionId) => _vote(_polls[i].id, optionId),
                      onClose: () => _closePoll(_polls[i].id),
                      onDelete: () => _deletePoll(_polls[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PollCard extends StatelessWidget {
  final Poll poll;
  final String? votedOptionId;
  final Function(String) onVote;
  final VoidCallback onClose;
  final VoidCallback onDelete;

  const _PollCard({
    required this.poll,
    this.votedOptionId,
    required this.onVote,
    required this.onClose,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasVoted = votedOptionId != null;
    final showResults = hasVoted || poll.isClosed;
    final maxVotes = poll.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: poll.isClosed ? cs.surfaceContainerLow : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    poll.question,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: poll.isClosed ? cs.surfaceContainerLow : cs.tertiaryContainer,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: poll.isClosed ? cs.outlineVariant : cs.tertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    poll.isClosed ? 'Closed' : 'Live',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: poll.isClosed ? cs.onSurfaceVariant : cs.tertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: poll.options.map((opt) {
                final pct = poll.totalVotes > 0 ? (opt.votes / poll.totalVotes * 100).round() : 0;
                final isVoted = votedOptionId == opt.id;
                final isWinner = showResults && opt.votes == maxVotes && maxVotes > 0;
                final canVote = !hasVoted && !poll.isClosed;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: canVote ? () => onVote(opt.id) : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isVoted ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Stack(
                          children: [
                            if (showResults)
                              Positioned.fill(
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: pct / 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isWinner ? cs.primary : cs.surfaceContainerLow,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                children: [
                                  if (isVoted)
                                    Icon(Icons.check_circle, size: 13, color: cs.primary)
                                  else if (!showResults)
                                    Container(
                                      width: 14, height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cs.onSurfaceVariant, width: 2),
                                      ),
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      opt.text,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isWinner && pct > 40 ? cs.onPrimary : cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (showResults)
                                    Text(
                                      '$pct%',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: isWinner && pct > 40 ? cs.onPrimary : cs.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${poll.totalVotes} ${poll.totalVotes == 1 ? 'vote' : 'votes'}${hasVoted && !poll.isClosed ? ' · Voted ✓' : ''}',
                  style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
                Row(
                  children: [
                    if (!poll.isClosed)
                      TextButton(
                        onPressed: onClose,
                        child: Text('Close', style: TextStyle(fontSize: 9, color: cs.primary)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: const Size(0, 24),
                        ),
                      ),
                    TextButton(
                      onPressed: onDelete,
                      child: Text('Delete', style: TextStyle(fontSize: 9, color: cs.error)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Poll {
  final String id;
  final String question;
  final List<PollOption> options;
  final bool isClosed;
  final int totalVotes;
  final DateTime createdAt;

  Poll({
    required this.id,
    required this.question,
    required this.options,
    required this.isClosed,
    required this.totalVotes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options.map((o) => o.toJson()).toList(),
        'isClosed': isClosed,
        'totalVotes': totalVotes,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory Poll.fromJson(Map<String, dynamic> json) => Poll(
        id: json['id'],
        question: json['question'],
        options: (json['options'] as List).map((o) => PollOption.fromJson(o)).toList(),
        isClosed: json['isClosed'],
        totalVotes: json['totalVotes'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      );
}

class PollOption {
  final String id;
  final String text;
  final int votes;

  PollOption({required this.id, required this.text, required this.votes});

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'votes': votes};

  factory PollOption.fromJson(Map<String, dynamic> json) =>
      PollOption(id: json['id'], text: json['text'], votes: json['votes']);
}
