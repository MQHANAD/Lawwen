import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
