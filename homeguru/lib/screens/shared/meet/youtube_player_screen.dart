import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../../services/meeting_signaling_service.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final MeetingSignalingService? signalingService;

  const YouTubePlayerScreen({super.key, this.signalingService});

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen> {
  final _urlController = TextEditingController();
  String? _videoId;
  bool _isHost = false;
  StreamSubscription? _syncSubscription;

  static const _suggested = [
    {'id': 'dQw4w9WgXcQ', 'title': 'Introduction to Quantum Mechanics', 'channel': 'MIT OpenCourseWare', 'duration': '12:45'},
    {'id': '9bZkp7q19f0', 'title': 'The History of Ancient Rome', 'channel': 'CrashCourse', 'duration': '18:20'},
    {'id': 'rfscVS0vtbw', 'title': 'Python Full Course for Beginners', 'channel': 'freeCodeCamp', 'duration': '4:26:52'},
    {'id': 'HXV3zeQKqGY', 'title': 'Calculus: Limits & Derivatives', 'channel': '3Blue1Brown', 'duration': '25:10'},
  ];

  @override
  void initState() {
    super.initState();
    _setupWebSocketSync();
  }

  void _setupWebSocketSync() {
    _syncSubscription = widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'youtube-sync' && msg['state'] != null) {
        final state = msg['state'];

        if (state['videoId'] != null) {
          if (state['videoId'] == null) {
            setState(() {
              _videoId = null;
              _isHost = false;
            });
          } else if (state['videoId'] != _videoId) {
            setState(() {
              _videoId = state['videoId'];
              _isHost = false;
            });
          }
        }
      }
    });
  }

  String? _extractVideoId(String input) {
    final regex = RegExp(r'(?:youtu\.be\/|v=|embed\/|shorts\/)([a-zA-Z0-9_-]{11})');
    final match = regex.firstMatch(input);
    return match?.group(1);
  }

  void _selectVideo(String id) {
    setState(() {
      _videoId = id;
      _isHost = true;
    });
    widget.signalingService?.send({'action': 'youtube-sync', 'state': {'videoId': id}});
  }

  void _handleShare() {
    final id = _extractVideoId(_urlController.text);
    if (id != null) _selectVideo(id);
  }

  void _resetVideo() {
    setState(() {
      _videoId = null;
      _isHost = false;
    });
    widget.signalingService?.send({'action': 'youtube-sync', 'state': {'videoId': null}});
  }

  @override
  void dispose() {
    _urlController.dispose();
    _syncSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_videoId != null) {
      final embedUrl = 'https://www.youtube.com/embed/$_videoId?autoplay=1&rel=0&modestbranding=1&playsinline=1&controls=${_isHost ? 1 : 0}&enablejsapi=1&origin=https://flutter.dev';
      
      return Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(
                color: Colors.black,
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(embedUrl)),
                  initialSettings: InAppWebViewSettings(
                    mediaPlaybackRequiresUserGesture: false,
                    allowsInlineMediaPlayback: true,
                    javaScriptEnabled: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    useHybridComposition: true,
                    allowsBackForwardNavigationGestures: false,
                    transparentBackground: false,
                    disableContextMenu: true,
                    supportZoom: false,
                    useShouldOverrideUrlLoading: false,
                    clearCache: false,
                    cacheEnabled: true,
                  ),
                ),
              ),
              if (!_isHost) 
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(color: Colors.transparent),
                  ),
                ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(
                          color: cs.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isHost ? 'YOU CONTROL PLAYBACK' : 'SYNCED PLAYBACK',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: cs.surfaceContainerLow.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _resetVideo,
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Row(
                              children: [
                                const Icon(Icons.refresh, size: 13, color: Colors.white),
                                const SizedBox(width: 4),
                                const Text('Change', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: cs.surfaceContainerLow.withValues(alpha: 0.3),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 32, height: 32,
                            alignment: Alignment.center,
                            child: const Icon(Icons.close, size: 15, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_isHost)
                Positioned(
                  bottom: 16, left: 0, right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: cs.tertiary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Host controls playback',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.play_circle_filled, size: 20, color: cs.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Watch Together', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                      Text('Synced playback for everyone', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Material(
                  color: cs.surfaceContainerLow,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 32, height: 32,
                      alignment: Alignment.center,
                      child: Icon(Icons.close, size: 15, color: cs.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.link, size: 16, color: cs.onSurfaceVariant),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  hintText: 'Paste YouTube link...',
                                  hintStyle: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(fontSize: 13, color: cs.onSurface, fontWeight: FontWeight.w500),
                                onSubmitted: (_) => _handleShare(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: _urlController.text.trim().isEmpty ? cs.surfaceContainerLow : cs.error,
                      borderRadius: BorderRadius.circular(22),
                      child: InkWell(
                        onTap: _urlController.text.trim().isEmpty ? null : _handleShare,
                        borderRadius: BorderRadius.circular(22),
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Icon(Icons.play_arrow, size: 14, color: _urlController.text.trim().isEmpty ? cs.onSurfaceVariant : cs.onError),
                              const SizedBox(width: 4),
                              Text('Play', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _urlController.text.trim().isEmpty ? cs.onSurfaceVariant : cs.onError)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Text('SUGGESTED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
                    const SizedBox(width: 12),
                    Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 1)),
                  ],
                ),
                const SizedBox(height: 12),
                ..._suggested.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () => _selectVideo(v['id']!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 120, height: 72,
                                color: Colors.black,
                                child: Stack(
                                  children: [
                                    Image.network(
                                      'https://img.youtube.com/vi/${v['id']}/mqdefault.jpg',
                                      width: 120, height: 72,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
                                    ),
                                    Positioned(
                                      bottom: 4, right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(v['duration']!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v['title']!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(v['channel']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text('SYNCED PLAYBACK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant, letterSpacing: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
