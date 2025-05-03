import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/palette_model.dart';

/// Saves a 4-color palette under the current user.
Future<void> savePaletteToFirestore({
  required List<String> colors,
  String? title,
  String? category,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');

  final hues = colors.map((hex) {
    final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    return HSLColor.fromColor(color).hue;
  }).toList();

  await FirebaseFirestore.instance.collection('palettes').add({
    'colors': colors,
    'hues': hues,
    'createdBy': user.uid,
    'userName': user.displayName,
    'createdAt': FieldValue.serverTimestamp(),
    'likes': 0,
    'likedBy': <String>[],
  });
}

Future<List<PaletteModel>> fetchPalettes({
  String? filterHex,
  String sortField = 'createdAt',
  bool descending = true,
  DocumentSnapshot? startAfterDoc,
  int limit = 10,
}) async {
  Query<Map<String, dynamic>> q =
  FirebaseFirestore.instance.collection('palettes');

  if (filterHex != null && filterHex.isNotEmpty) {
    final targetColor = Color(int.parse('FF${filterHex.replaceAll('#', '')}', radix: 16));
    final hue = HSLColor.fromColor(targetColor).hue.round();
    final range = List.generate(31, (i) => (hue - 15 + i + 360) % 360);
    final hueSubset = range.take(10).toList();
    q = q.where('hues', arrayContainsAny: hueSubset);
  }

  q = q.orderBy(sortField, descending: descending).limit(limit);

  if (startAfterDoc != null) {
    q = q.startAfterDocument(startAfterDoc);
  }

  final snap = await q.get();
  return snap.docs
      .map((d) => PaletteModel.fromMap(d.data(), d.id))
      .toList();
}

Future<List<PaletteModel>> fetchUserPalettes({
  required String uid,
  DocumentSnapshot? startAfter,
  int limit = 6,
}) async {
  Query query = FirebaseFirestore.instance
      .collection('palettes')
      .where('createdBy', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .limit(limit);

  if (startAfter != null) {
    query = query.startAfterDocument(startAfter);
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaletteModel(
        id: doc.id,
        colorHexCodes: List<String>.from(data['colors']),
        likes: data['likes'] ?? 0,
        createdAt:
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdBy:  (data['createdBy'] as String?)?.toString() ?? "Lawwen",
        userName: (data['userName'] as String?)?.toString() ?? "Lawwen",
        hues: (data['hues'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),

    );
  }).toList();
}


Future<void> updatePalette({
  required List<String> docID,
  required List<String> colors,
  String? title,
  String? category,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');

  final hues = colors.map((hex) {
    final color = Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
    return HSLColor.fromColor(color).hue;
  }).toList();

  await FirebaseFirestore.instance.collection('palettes').doc(docID.first).update({
    'colors': colors,
    'hues': hues,
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
  });
}



Future<void> deletePalette(String paletteId) =>
    FirebaseFirestore.instance.collection('palettes').doc(paletteId).delete();

Future<int> toggleLike(String paletteId) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final docRef =
  FirebaseFirestore.instance.collection('palettes').doc(paletteId);

  return FirebaseFirestore.instance.runTransaction<int>((tx) async {
    final snap = await tx.get(docRef);
    if (!snap.exists) throw Exception('Palette not found');

    final data = snap.data() as Map<String, dynamic>;
    final List likedBy = List.from(data['likedBy'] ?? []);
    int likes = (data['likes'] ?? 0) as int;

    final alreadyLiked = likedBy.contains(uid);

    if (alreadyLiked) {
      likedBy.remove(uid);
      likes--;
    } else {
      likedBy.add(uid);
      likes++;
    }

    tx.update(docRef, {
      'likedBy': likedBy,
      'likes': likes,
    });

    return likes;
  });
}
