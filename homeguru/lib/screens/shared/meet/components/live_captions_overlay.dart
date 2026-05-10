import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class LiveCaptionsOverlay extends StatefulWidget {
  const LiveCaptionsOverlay({super.key});

  @override
  State<LiveCaptionsOverlay> createState() => _LiveCaptionsOverlayState();
}

class _LiveCaptionsOverlayState extends State<LiveCaptionsOverlay>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _caption = '';
  String _previousCaption = '';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _isAvailable = await _speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if (status == stt.SpeechToText.notListeningStatus && _isListening) {
          // Auto-restart after end-of-speech
          _startListening();
        }
      },
    );
    if (_isAvailable && mounted) {
      setState(() {});
      _startListening();
    }
  }

  void _startListening() {
    if (!_isAvailable || !mounted) return;
    setState(() => _isListening = true);
    _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _previousCaption = _caption;
            _caption = result.recognizedWords;
          } else {
            _caption = result.recognizedWords;
          }
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
      localeId: 'en_US',
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Caption text box
        if (_caption.isNotEmpty || _previousCaption.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_previousCaption.isNotEmpty)
                  Text(
                    _previousCaption,
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (_caption.isNotEmpty)
                  Text(
                    _caption,
                    style: tt.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // Controls row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status indicator
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, _) {
                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Color.lerp(
                            Colors.red,
                            Colors.red.withValues(alpha: 0.3),
                            _pulseController.value,
                          )
                        : Colors.grey,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            Text(
              _isListening ? 'Live Captions On' : 'Live Captions Off',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 12),
            // Toggle button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isListening
                      ? cs.errorContainer
                      : cs.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isListening ? 'Stop' : 'Start',
                  style: TextStyle(
                    color: _isListening
                        ? cs.onErrorContainer
                        : cs.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
