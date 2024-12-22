import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ajoute un vêtement dans Firestore
  Future<void> addClothingItem(Map<String, dynamic> clothingItem) async {
    try {
      await _firestore.collection("clothingItems").add(clothingItem);
      print("Vêtement ajouté avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout : $e");
      rethrow;
    }
  }
}
