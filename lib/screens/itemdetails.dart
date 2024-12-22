import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ines_app/services/cart_service.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  Map<String, dynamic>? itemData;

  @override
  void initState() {
    super.initState();
    _loadItemData();
  }

  // Charger les données de l'article
  Future<void> _loadItemData() async {
    final snapshot =
        await database.child('clothingItems/${widget.itemId}').get();
    if (snapshot.exists) {
      setState(() {
        itemData = Map<String, dynamic>.from(snapshot.value as Map);
      });
    }
  }

  // Ajouter l'article au panier
  void _addToCart(BuildContext context) {
    if (itemData != null) {
      CartService.addItem(itemData!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article ajouté au panier!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Afficher un indicateur de chargement si les données de l'article ne sont pas encore disponibles
    if (itemData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(itemData!['title'] ?? 'Détail article'),
        centerTitle: true,
        backgroundColor: Colors.pink, // Couleur principale
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    itemData!['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catégorie: ${itemData!['category']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Taille: ${itemData!['size']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Marque: ${itemData!['brand']}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Prix: ${itemData!['price']} MAD',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink), // Couleur du prix
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.pink, // Couleur du bouton
                  ),
                  child: const Text('Retour', style: TextStyle(fontSize: 16)),
                ),
                ElevatedButton(
                  onPressed: () => _addToCart(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    backgroundColor: Colors.pink, // Couleur du bouton
                  ),
                  child: const Text('Ajouter au panier',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
