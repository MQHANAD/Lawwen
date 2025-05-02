import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/palette_model.dart';

/// Saves a 4-color palette under the current user.
/// [colors]  – list of 4 hex strings WITHOUT the leading “#”.
/// [title]   – optional palette name.
/// [category]– optional category tag.
Future<void> savePaletteToFirestore({
  required List<String> colors,
  String? title,
  String? category,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception('User not logged in');

  await FirebaseFirestore.instance.collection('palettes').add({
    'colors': colors, // e.g. ["F72585", "7209B7", …]
    'createdBy': user.uid,
    'createdAt': FieldValue.serverTimestamp(),
    'likes': 0,
    'likedBy': <String>[],
  });
}

Stream<List<PaletteModel>> streamAllPalettes() {
  return FirebaseFirestore.instance
      .collection('palettes')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((query) => query.docs.map(_docToPalette).toList());
}

Stream<List<PaletteModel>> streamUserPalettes(String uid) {
  return FirebaseFirestore.instance
      .collection('palettes')
      .where('createdBy', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((qs) => qs.docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return PaletteModel(
              id: d.id,
              colorHexCodes: List<String>.from(data['colors']),
              likes: data['likes'] ?? 0,
              createdAt:
                  (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            );
          }).toList());
}

PaletteModel _docToPalette(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  final d = doc.data();
  return PaletteModel(
    id: doc.id,
    colorHexCodes: List<String>.from(d['colors']),
    likes: d['likes'] ?? 0,
    createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    // add createdBy if your model has it
  );
}

Future<void> deletePalette(String paletteId) =>
    FirebaseFirestore.instance.collection('palettes').doc(paletteId).delete();
