// lib/models/palette_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class PaletteModel {
  final String id;
  final List<String> colorHexCodes;
  final List<double> hues;
  final int likes;
  final DateTime createdAt;
  final String createdBy;
  final String userName;
  final bool isLiked;
  final List<String> likedBy;

  PaletteModel({
    required this.id,
    required this.colorHexCodes,
    required this.hues,
    required this.likes,
    required this.createdAt,
    required this.createdBy,
    required this.userName,
    this.isLiked = false,
    required this.likedBy,
  });

  factory PaletteModel.fromMap(
      Map<String, dynamic> map, String id, String uid) {
    final rawColors = map['colors'];
    final rawHues = map['hues'];
    final likedByList =
        map['likedBy'] != null ? List<String>.from(map['likedBy']) : <String>[];

    return PaletteModel(
      id: id,
      colorHexCodes: rawColors is List ? List<String>.from(rawColors) : [],
      hues: rawHues is List ? List<double>.from(rawHues) : [],
      likes: map['likes'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: map['createdBy'] ?? "Lawwen",
      userName: map['userName'] ?? "Lawwen",
      likedBy: likedByList,
      isLiked: likedByList.contains(uid),
    );
  }
}
