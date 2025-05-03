// lib/widgets/animated_like_button.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class AnimatedLikeButton extends StatefulWidget {
  final bool isInitiallyLiked;
  final int initialLikes;
  final String paletteId;

  const AnimatedLikeButton({
    Key? key,
    required this.paletteId,
    required this.initialLikes,
    required this.isInitiallyLiked,
  }) : super(key: key);

  @override
  _AnimatedLikeButtonState createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late bool isLiked;
  late int likes;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    isLiked = widget.isInitiallyLiked;
    likes = widget.initialLikes;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 1.0,
      upperBound: 1.2,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> toggleLike1() async {
    final newLikes = await toggleLike(widget.paletteId);
    setState(() {
      isLiked = !isLiked;
      likes = newLikes;
    });
    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleLike1,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffCBD5E1)),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _controller,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                size: 26,
                color: isLiked ? const Color(0xffD2DAFF) : Colors.black,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '$likes',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
