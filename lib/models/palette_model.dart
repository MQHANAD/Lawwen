// lib/models/palette_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

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
  factory PaletteModel.fromMap(Map<String, dynamic> map, String id) {
    final rawColors = map['colors'];
    return PaletteModel(
      id: id,
      colorHexCodes: rawColors is List ? List<String>.from(rawColors) : [],
      likes: map['likes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }


}
