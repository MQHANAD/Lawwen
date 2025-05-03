// lib/models/palette_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaletteModel {
  final String id;
  final List<String> colorHexCodes;
  final List<double> hues; // ✅ new field
  final int likes;
  final DateTime createdAt;
  final String createdBy;
  final String userName;

  PaletteModel({
    required this.id,
    required this.colorHexCodes,
    required this.hues,
    required this.likes,
    required this.createdAt,
    required this.createdBy,
    required this.userName,
  });

  factory PaletteModel.fromMap(Map<String, dynamic> map, String id) {
    final rawColors = map['colors'];
    final rawHues = map['hues'];

    return PaletteModel(
      id: id,
      colorHexCodes: rawColors is List ? List<String>.from(rawColors) : [],
      hues: rawHues is List ? List<double>.from(rawHues) : [], // ✅ read hues
      likes: map['likes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      createdBy: map['createdBy'] ?? "Lawwen",
      userName: map['userName'] ?? "Lawwen",
    );
  }
}

