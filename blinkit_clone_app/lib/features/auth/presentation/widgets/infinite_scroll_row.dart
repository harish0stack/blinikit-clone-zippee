// lib/features/auth/presentation/widgets/infinite_scroll_row.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class InfiniteScrollRow extends StatefulWidget {
  final List<String> images;
  final bool reverse;
  final double speed; // Pixels per second

  const InfiniteScrollRow({
    super.key,
    required this.images,
    this.reverse = false,
    this.speed = 22.0,
  });

  @override
  State<InfiniteScrollRow> createState() => _InfiniteScrollRowState();
}

class _InfiniteScrollRowState extends State<InfiniteScrollRow> {
  late final ScrollController _scrollController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start at mid offset if reverse to allow leftward scroll
    final initialOffset = widget.reverse ? 3000.0 : 0.0;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    const frameRate = Duration(milliseconds: 32); // ~30-60 fps smooth step
    final step = (widget.speed * 0.032);

    _timer = Timer.periodic(frameRate, (timer) {
      if (!_scrollController.hasClients) return;

      double nextOffset;
      if (widget.reverse) {
        nextOffset = _scrollController.offset - step;
        if (nextOffset <= _scrollController.position.minScrollExtent) {
          nextOffset = 4000.0; // Jump ahead seamlessly
        }
      } else {
        nextOffset = _scrollController.offset + step;
        if (nextOffset >= _scrollController.position.maxScrollExtent - 200) {
          nextOffset = 0.0; // Loop back seamlessly
        }
      }

      _scrollController.jumpTo(nextOffset);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Repeat images list to create an endless loop
    final repeatedImages = List.generate(
      20,
      (index) => widget.images[index % widget.images.length],
    );

    return SizedBox(
      height: 122,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(), // Managed programmatically
        itemCount: repeatedImages.length,
        itemBuilder: (context, index) {
          final asset = repeatedImages[index];
          return Container(
            width: 105,
            height: 105,
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF8FB), // Soft cyan-tinted background matching Figma
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: const Color(0xFFE2F0F6),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF0C831F),
                  size: 34,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
