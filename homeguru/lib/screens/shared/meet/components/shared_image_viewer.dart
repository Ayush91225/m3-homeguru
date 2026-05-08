import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SharedImageViewer extends StatelessWidget {
  final String imageUrl;
  final VoidCallback onClose;

  const SharedImageViewer({
    super.key,
    required this.imageUrl,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: cs.surface),
          onPressed: onClose,
        ),
        title: Text(
          'Shared Image',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: cs.surface),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(color: cs.primary),
            ),
            errorWidget: (context, url, error) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(fontSize: 14, color: cs.surface),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
