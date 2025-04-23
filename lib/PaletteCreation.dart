import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

/// Advanced Color Picker Dialog
/// This dialog allows a user to select any color via a continuous picker and
/// enter a hex code manually.
Future<Color?> showAdvancedColorPickerDialog(
    BuildContext context, Color initialColor) async {
  Color currentColor = initialColor;
  TextEditingController hexController = TextEditingController(
      text:
          '#${initialColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}');

  return showDialog<Color>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Color'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Continuous color picker widget.
                  ColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: (Color color) {
                      setState(() {
                        currentColor = color;
                        hexController.text =
                            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                      });
                    },
                    pickerAreaHeightPercent: 0.6,
                    enableAlpha: false,
                    displayThumbColor: true,
                    showLabel: false,
                  ),
                  const SizedBox(height: 20),
                  // Text field for hex code.
                  TextField(
                    controller: hexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex Code',
                      hintText: '#FFFFFF',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      String cleaned = value.replaceAll('#', '').trim();
                      if (cleaned.length == 6) {
                        try {
                          Color parsedColor =
                              Color(int.parse('FF$cleaned', radix: 16));
                          setState(() {
                            currentColor = parsedColor;
                          });
                        } catch (e) {
                          // You can show an error if needed.
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Colors.red, // sets the text color for the Cancel button
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFB1B2FF), // sets the background color
              foregroundColor: Colors.white, // sets the text color
            ),
            onPressed: () {
              Navigator.of(context).pop(currentColor);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// Modal for Creating a New Palette with Advanced Color Selection.
/// Each of 4 slots is tappable to choose a custom color.
class CreatePaletteModal extends StatefulWidget {
  /// The scrollController provided by DraggableScrollableSheet.

  const CreatePaletteModal({Key? key})
      : super(key: key);

  @override
  State<CreatePaletteModal> createState() => _CreatePaletteModalState();
}

class _CreatePaletteModalState extends State<CreatePaletteModal> {
  // We have 4 color slots in our palette; if a slot is null, no color is assigned.
  List<Color?> paletteColors = [null, null, null, null];

  /// Returns true if all slots have a chosen color.
  bool get _allColorsChosen => paletteColors.every((c) => c != null);

  /// Opens the custom advanced color picker dialog.
  /// [index] indicates which color slot to update.
  Future<void> _pickColor(int index) async {
    // Default to grey if no color has been chosen yet.
    Color initialColor = paletteColors[index] ?? Colors.grey;
    Color? pickedColor = await showAdvancedColorPickerDialog(
      context,
      initialColor,
    );

    if (pickedColor != null) {
      setState(() {
        paletteColors[index] = pickedColor;
      });
    }
  }

  /// Submits the palette; if any slot is unassigned, shows an error.
  void _submitPalette() {
    if (!_allColorsChosen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick all colors before submitting.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    // Convert each selected color to a hex string.
    final colorStrings = paletteColors.map((color) {
      final value = color!.value.toRadixString(16).padLeft(8, '0');
      // Skip alpha channel if desired:
      return '#${value.substring(2).toUpperCase()}';
    }).toList();
    print('Created palette: $colorStrings');
    Navigator.of(context).pop(); // Close the modal.
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Rounded top corners + white background for the modal.
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Title
                const Text(
                  'Create New Color Palette',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Big box that displays 4 color blocks.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 44.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: List.generate(paletteColors.length, (i) {
                        Color displayColor =
                            paletteColors[i] ?? Colors.grey[400]!;
                        String hexString =
                            '#${displayColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                        return GestureDetector(
                          onTap: () => _pickColor(i),
                          child: Stack(
                            children: [
                              Container(
                                height: 85,
                                decoration: BoxDecoration(
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                  color: displayColor,
                                  borderRadius: i == 0
                                      ? const BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                        )
                                      : i == paletteColors.length - 1
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(24),
                                              bottomRight: Radius.circular(24),
                                            )
                                          : null,
                                ),
                              ),
                              // Positioned text in the bottom left showing hex code.
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF484848).withOpacity(
                                        0.2), // 20% transparent background
                                    borderRadius: BorderRadius.circular(6),

                                  ),
                                  child: Text(
                                    hexString,
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
                              )
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Submit button.
                SizedBox(
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _submitPalette,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFB1B2FF),
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text(
                      "Submit Palette",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
