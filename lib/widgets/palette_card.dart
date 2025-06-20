// lib/widgets/palette_card.dart
import 'package:flutter/material.dart';
import '../PaletteDetails.dart';
import '../models/palette_model.dart';
import 'animated_like_button.dart';

class PaletteCard extends StatefulWidget {
  final PaletteModel palette;
  final String timeAgoText;

  const PaletteCard({
    Key? key,
    required this.palette,
    required this.timeAgoText,
  }) : super(key: key);

  @override
  _PaletteCardState createState() => _PaletteCardState();
}

class _PaletteCardState extends State<PaletteCard> {
  bool _pressed = false;

  // Converts a hex string into a Color
  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // Defines a transformation matrix for a subtle 3D press effect
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..rotateX(_pressed ? 0.05 : 0)
      ..rotateY(_pressed ? 0.02 : 0)
      ..scale(_pressed ? 0.97 : 1.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Color display area with press effects
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                print("Palette colors: ${widget.palette.colorHexCodes}");
                // Navigator.push(context, MaterialPageRoute(builder: (context) => PaletteInfoScreen(palette: widget.palette,)),
                // );
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Allows full-screen height if needed.
                  backgroundColor: Colors.transparent, // So your custom rounded container shows properly.
                  builder: (BuildContext context) {
                    return DraggableScrollableSheet(
                      initialChildSize: 0.86, // Adjust as needed.
                      minChildSize: 0.5,
                      maxChildSize: 1.0,
                      builder: (BuildContext context, ScrollController scrollController) {
                        return Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                            child: PaletteInfoScreen(
                              palette: widget.palette,
                            ),
                        );
                      },
                    );
                  },
                );

              },
              onTapDown: (_) {
                setState(() {
                  _pressed = true;
                });
              },
              onTapUp: (_) {
                setState(() {
                  _pressed = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  _pressed = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
                transform: transform,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    // Displays the list of colors vertically
                    child: Column(
                      children: widget.palette.colorHexCodes
                          .map(
                            (hex) => Expanded(
                          child: Container(
                            color: hexToColor(hex),
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Bottom section with the like button and time text
          Expanded(
            flex: 1,
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedLikeButton(
                    isInitiallyLiked: widget.palette.isLiked,   // ✅ correct boolean
                    initialLikes: widget.palette.likes,         // ✅ correct integer
                    paletteId: widget.palette.id,
                  ),

                  Text(widget.timeAgoText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
