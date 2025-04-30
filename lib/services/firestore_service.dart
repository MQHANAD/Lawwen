import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> savePaletteToFirestore({
  required String title,
  required List<String> colors,
  required String category,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print("User not logged in");
    return;
  }

  await FirebaseFirestore.instance.collection('palettes').add({
    'title': title,
    'colors': colors,
    'category': category,
    'createdBy': user.uid,
    'createdAt': Timestamp.now(),
  });
}
//Example Getter:
//
// await savePaletteToFirestore(
// title: 'Cool Summer',
// colors: ['#FF0000', '#00FF00', '#0000FF'],
// category: 'Nature',
// );
