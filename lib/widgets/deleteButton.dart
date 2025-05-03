// lib/widgets/animated_like_button.dart
import 'package:flutter/material.dart';
import 'package:swe463project/models/palette_model.dart';
import 'package:swe463project/services/firestore_service.dart';

import '../Profile.dart';


class DeleteButton extends StatefulWidget {
  final PaletteModel mainPalette;
  const DeleteButton( {Key? key, required this.mainPalette}) : super(key: key);

  @override
  _DeleteButtonState createState() => _DeleteButtonState();
}

class _DeleteButtonState extends State<DeleteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
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

  Future<void> Confirm(BuildContext context, AnimationController _controller) async {
    _controller.forward().then((_) => _controller.reverse());
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete Palette?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to proceed?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 8),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      deletePalette(widget.mainPalette.id);
      _controller.forward().then((_) => _controller.reverse());
      // Force a refresh — pop and push the current route again
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Palette Deleted')),
      );// optional if inside dialog
    } else {
      print('Cancelled');
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Confirm(context, _controller),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.shade200),
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _controller,
              child: Icon(
                 Icons.delete_outline,
                size: 26,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
