import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:swe463project/widgets/deleteButton.dart';
import '../models/palette_model.dart';
import '../widgets/palette_card.dart';
import '../widgets/animated_like_button.dart';

class PaletteInfoScreen extends StatefulWidget {
  /// The primary palette to display in the large color area.
  final PaletteModel palette;

  const PaletteInfoScreen({
    Key? key,
    required this.palette,
  }) : super(key: key);

  @override
  State<PaletteInfoScreen> createState() => _PaletteInfoScreenState();
}

class _PaletteInfoScreenState extends State<PaletteInfoScreen> {
  /// Fixed list of palettes to use for the "Other Palettes" section.
  final List<PaletteModel> allPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["c5c9ff", "d2d7ff", "e0e4ff", "EEF1FF"],
      likes: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [233.1, 233.1, 233.1, 233.1],
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["212529", "495057", "0dcaf0", "EEEEEE"],
      likes: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [210.0, 210.0, 189.8, 0.0],
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f8c8dc", "fdfd96", "9bf6ff", "73C7C7"],
      likes: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [340.0, 60.0, 188.6, 180.0],
    ),
    PaletteModel(
      id: "4",
      colorHexCodes: ["c92a2a", "fa5252", "ffd6a5", "F6DED8"],
      likes: 15000,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [0.0, 0.0, 36.0, 10.3],
    ),
    PaletteModel(
      id: "5",
      colorHexCodes: ["f9ca24", "40739e", "273c75", "00cec9"],
      likes: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [47.6, 217.7, 223.6, 182.0],
    ),
    PaletteModel(
      id: "6",
      colorHexCodes: ["00cec9", "2d3436", "ff7675", "00cec9"],
      likes: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      createdBy: "Lawwen",
      userName: "Lawwen",
      hues: [182.0, 200.0, 1.1, 182.0],
    ),
  ];


  /// A list to track which color blocks have been tapped (to show "Copied")
  late List<bool> _copiedList;

  @override
  void initState() {
    super.initState();
    // Initialize the copied status for each color in the main palette.
    _copiedList = List<bool>.filled(widget.palette.colorHexCodes.length, false);
  }

  /// Converts a [DateTime] to a relative string (e.g., "2d ago").
  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final years = (diff.inDays / 365).floor();
      return '${years}y ago';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inMinutes}m ago';
    }
  }

  /// Copies the given hex code to the clipboard and shows a SnackBar confirmation.
  void _copyHex(String hex, int index) {
    final formattedHex = hex.startsWith('#') ? hex : '#$hex';
    Clipboard.setData(ClipboardData(text: formattedHex)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied $formattedHex to clipboard')),
      );
      // Set the tapped index to true, so "Copied" appears.
      setState(() {
        _copiedList[index] = true;
      });
      // Revert back after 2 seconds.
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _copiedList[index] = false;
        });
      });
    });
  }

  /// Converts a hexadecimal string (without '#') to a [Color].
  Color _hexToColor(String hex) {
    final sanitized = hex.replaceAll('#', '').trim();
    return Color(int.parse('FF$sanitized', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final mainPalette = widget.palette;

    return Container(
      // Wrap in a container to provide decoration for the modal.
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          // The entire page will scroll vertically.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Title: "Palette information"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Palette information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // -- Big Palette Display with color blocks that show hex code.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
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
                  child: Column(
                    children:
                        mainPalette.colorHexCodes.asMap().entries.map((entry) {
                      int index = entry.key;
                      String hex = entry.value;
                      return GestureDetector(
                        onTap: () => _copyHex(hex, index),
                        child: Stack(
                          children: [
                            Container(
                              height: 85, // Adjust height as needed
                              decoration: BoxDecoration(
                                color: _hexToColor(hex),
                                borderRadius: mainPalette.colorHexCodes.first ==
                                        hex
                                    ? const BorderRadius.only(
                                        topLeft: Radius.circular(24),
                                        topRight: Radius.circular(24),
                                      )
                                    : mainPalette.colorHexCodes.last == hex
                                        ? const BorderRadius.only(
                                            bottomLeft: Radius.circular(24),
                                            bottomRight: Radius.circular(24),
                                          )
                                        : null,
                              ),
                            ),
                            // Positioned text at the bottom left.
                            Positioned(
                              bottom: 10,
                              left: 13,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  // Make the background color 20% transparent; here 0.8 opacity means 20% transparent.
                                  color:
                                      const Color(0xFF484848).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(
                                      8), // Adjust the radius as needed.
                                ),
                                child: Text(
                                  _copiedList[index] ? "Copied" : "#$hex",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 4.0,
                                        color: Colors.black45,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 46),

              // -- Creator & Like Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Created By ' + mainPalette.userName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    AnimatedLikeButton(likes: mainPalette.likes),
                  ],
                ),
              ),
              // Time info (e.g., "2d ago")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(0,0,0,50),
                    child: Text(
                      timeAgo(mainPalette.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const Spacer(),
                  if(FirebaseAuth.instance.currentUser?.uid == mainPalette.createdBy)
                    Padding(
                      padding: EdgeInsets.fromLTRB(100,0,0,0),
                      child: DeleteButton(mainPalette: mainPalette),
                    )
                  ]),
              ),
              const SizedBox(height: 36),

              // -- Other Palettes Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Other Palettes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // -- Vertically Scrolling Grid of Other Palettes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling.
                  shrinkWrap: true,
                  itemCount: allPalettes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemBuilder: (context, index) {
                    final palette = allPalettes[index];
                    return PaletteCard(
                      palette: palette,
                      timeAgoText: timeAgo(palette.createdAt),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
