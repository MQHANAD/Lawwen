import 'package:flutter/material.dart';
import '../main.dart'; // for mainColor

// Palette Model
class PaletteModel {
  final String id;
  final List<String> colorHexCodes;
  final int likes;
  final DateTime createdAt;

  PaletteModel({
    required this.id,
    required this.colorHexCodes,
    required this.likes,
    required this.createdAt,
  });
}
class AnimatedLikeButton extends StatefulWidget {
  final int likes;
  const AnimatedLikeButton({Key? key, required this.likes}) : super(key: key);

  @override
  _AnimatedLikeButtonState createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  // Track the "liked" state
  bool isLiked = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation controller for scaling effect
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

  // Toggles the like state and triggers the scale animation.
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    // Animate: scale up then back to normal
    _controller.forward().then((_) => _controller.reverse());
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleLike,
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
                color: isLiked ? Color(0xffD2DAFF) : Colors.black,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '${widget.likes}',
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
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Full list of palettes
  final List<PaletteModel> allPalettes = [
    PaletteModel(
      id: "1",
      colorHexCodes: ["c5c9ff", "d2d7ff", "e0e4ff", "EEF1FF"],
      likes: 2,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    PaletteModel(
      id: "2",
      colorHexCodes: ["212529", "495057", "0dcaf0", "EEEEEE"],
      likes: 10,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    PaletteModel(
      id: "3",
      colorHexCodes: ["f8c8dc", "fdfd96", "9bf6ff", "73C7C7"],
      likes: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    PaletteModel(
      id: "4",
      colorHexCodes: ["c92a2a", "fa5252", "ffd6a5", "F6DED8"],
      likes: 15000,
      createdAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    PaletteModel(
      id: "5",
      colorHexCodes: ["f9ca24", "40739e", "273c75", "00cec9"],
      likes: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    PaletteModel(
      id: "6",
      colorHexCodes: ["00cec9", "2d3436", "ff7675", "00cec9"],
      likes: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  List<PaletteModel> displayedPalettes = [];



  @override
  void initState() {
    super.initState();
    displayedPalettes = List.from(allPalettes);
  }

  // Sort functions
  void sortByNewest() {
    setState(() {
      displayedPalettes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void sortByLikes() {
    setState(() {
      displayedPalettes.sort((a, b) => b.likes.compareTo(a.likes));
    });
  }

  // Customizable filter logic
  void showCustomizableFilterSheet() {
    int minLikes = 0;
    DateTime? selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Likes Input
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Likes',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        minLikes = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Date Picker
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().subtract(const Duration(days: 7)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      setSheetState(() {
                        selectedDate = picked;
                      });
                    },
                    child: Text(selectedDate == null
                        ? 'Pick Created After Date'
                        : 'Picked: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                  ),
                  const SizedBox(height: 20),
                  // Apply Button
                  ElevatedButton(
                    onPressed: () {
                      applyCustomFilters(minLikes, selectedDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void applyCustomFilters(int minLikes, DateTime? createdAfter) {
    setState(() {
      displayedPalettes = allPalettes.where((p) {
        bool likesOk = p.likes >= minLikes;
        bool dateOk = createdAfter == null || p.createdAt.isAfter(createdAfter);
        return likesOk && dateOk;
      }).toList();
    });
  }

  void resetFilters() {
    setState(() {
      displayedPalettes = List.from(allPalettes);
    });
  }

  // Helper to format "x hours ago"
  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set entire screen background to white
      body: SafeArea(
        child: Column(
          children: [
            // Logo remains at the top
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Image.asset('assets/images/logo.png', height: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => showSortOptions(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.sort, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Sort',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xff414141)),
                            ),
                            Text(
                              'Sorted by',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff4B5563)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => showCustomizableFilterSheet(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.filter_alt, size: 28),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Filters',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xff414141)),
                            ),
                            Text(
                              'Custom',
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xff4B5563)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Outer Container (card-like) with upward shadow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.5),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(29) ,topRight:Radius.circular(29)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(
                            0, -1), // negative offset => shadow above
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Expanded Palette Grid inside the container
                        Expanded(
                          child: GridView.builder(
                            itemCount: displayedPalettes.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.7,
                            ),
                            itemBuilder: (context, index) {
                              return PaletteCard(
                                palette: displayedPalettes[index],
                                timeAgoText:
                                    timeAgo(displayedPalettes[index].createdAt),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Sort by Newest'),
              onTap: () {
                sortByNewest();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Sort by Most Liked'),
              onTap: () {
                sortByLikes();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.clear),
              title: const Text('Clear Sort / Filter'),
              onTap: () {
                resetFilters();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

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

  // Helper function to convert hex string to Color
  Color hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // Define a transformation matrix for the 3D press effect
    final Matrix4 transform = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // adds perspective
      ..rotateX(_pressed ? 0.05 : 0) // slight X-axis rotation when pressed
      ..rotateY(_pressed ? 0.02 : 0) // slight Y-axis rotation when pressed
      ..scale(_pressed ? 0.97 : 1.0); // scale down a bit when pressed

    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // background for the card
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Only the first Expanded (color display area) has GestureDetector
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                // Print the palette colors when tapped
                print("Palette colors: ${widget.palette.colorHexCodes}");
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
                    // Display colors in a vertical layout
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
          // Second Expanded remains unaffected by the GestureDetector.
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedLikeButton(likes: widget.palette.likes),
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

