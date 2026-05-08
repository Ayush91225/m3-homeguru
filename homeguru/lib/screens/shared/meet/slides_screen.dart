import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../services/meeting_signaling_service.dart';

class SlidesScreen extends StatefulWidget {
  final MeetingSignalingService? signalingService;

  const SlidesScreen({super.key, this.signalingService});

  @override
  State<SlidesScreen> createState() => _SlidesScreenState();
}

class _SlidesScreenState extends State<SlidesScreen> {
  List<String> _slides = [];
  int _currentSlide = 0;
  bool _isPresenter = false;
  String _fileName = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _listenToSignaling();
    _requestSync();
  }

  void _listenToSignaling() {
    widget.signalingService?.messages.listen((msg) {
      if (msg['action'] == 'presentation-sync' && msg['slide'] != null) {
        setState(() => _currentSlide = msg['slide']);
      } else if (msg['action'] == 'presentation-share' && msg['slideUrls'] != null) {
        setState(() {
          _slides = List<String>.from(msg['slideUrls']);
          _fileName = msg['fileName'] ?? 'Slides';
          _currentSlide = msg['currentSlide'] ?? 0;
          _isPresenter = false;
        });
      } else if (msg['action'] == 'presentation-request-sync' && _slides.isNotEmpty) {
        widget.signalingService?.send({
          'action': 'presentation-share',
          'slideUrls': _slides,
          'fileName': _fileName,
          'currentSlide': _currentSlide,
        });
      }
    });
  }

  void _requestSync() {
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.signalingService?.send({'action': 'presentation-request-sync'});
    });
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'pptx', 'ppt'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = true;
          _fileName = result.files.first.name;
        });

        // TODO: Convert PDF/PPTX to images
        // For now, show placeholder
        await Future.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        setState(() {
          _slides = List.generate(5, (i) => 'slide_$i'); // Placeholder
          _currentSlide = 0;
          _isPresenter = true;
          _loading = false;
        });

        widget.signalingService?.send({
          'action': 'presentation-share',
          'slideUrls': _slides,
          'fileName': _fileName,
          'currentSlide': 0,
        });
      }
    } catch (e) {
      debugPrint('Error picking file: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goToSlide(int index) {
    if (index < 0 || index >= _slides.length) return;
    setState(() => _currentSlide = index);
    widget.signalingService?.send({
      'action': 'presentation-sync',
      'slide': index,
      'totalSlides': _slides.length,
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.slideshow, size: 22, color: cs.primary),
              ),
              const SizedBox(height: 16),
              CircularProgressIndicator(color: cs.primary),
              const SizedBox(height: 16),
              Text('Processing...', style: TextStyle(fontSize: 12, color: cs.onSurface, fontWeight: FontWeight.w500)),
              Text(_fileName, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    if (_slides.isEmpty) {
      return Scaffold(
        backgroundColor: cs.surface,
        appBar: AppBar(
          backgroundColor: cs.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close, color: cs.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Slides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.slideshow, size: 28, color: cs.primary),
              ),
              const SizedBox(height: 24),
              Text(
                'Present Slides',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: cs.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload .pdf or .pptx to present',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file, size: 16),
                label: const Text('Upload File', style: TextStyle(fontSize: 13)),
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'First to upload controls the slideshow',
                style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
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
            Text('Slides', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
            Text(_fileName, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          if (_isPresenter)
            TextButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file, size: 10),
              label: const Text('Change', style: TextStyle(fontSize: 9)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image, size: 48, color: cs.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        'Slide ${_currentSlide + 1}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDF rendering coming soon',
                        style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_slides.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentSlide > 0 ? () => _goToSlide(_currentSlide - 1) : null,
                    icon: Icon(Icons.chevron_left, color: _currentSlide > 0 ? cs.onSurface : cs.onSurfaceVariant.withValues(alpha: 0.3)),
                    style: IconButton.styleFrom(
                      backgroundColor: cs.surfaceContainerLow,
                      shape: const CircleBorder(),
                    ),
                  ),
                  Text(
                    '${_currentSlide + 1} / ${_slides.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                  IconButton(
                    onPressed: _currentSlide < _slides.length - 1 ? () => _goToSlide(_currentSlide + 1) : null,
                    icon: Icon(Icons.chevron_right, color: _currentSlide < _slides.length - 1 ? cs.onPrimary : cs.onSurfaceVariant.withValues(alpha: 0.3)),
                    style: IconButton.styleFrom(
                      backgroundColor: _currentSlide < _slides.length - 1 ? cs.primary : cs.surfaceContainerLow,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
