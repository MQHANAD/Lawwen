// lib/models/palette_model.dart
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
