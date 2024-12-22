import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:ines_app/screens/add_ithem.dart';
import 'package:ines_app/screens/itemdetails.dart';
import 'package:ines_app/services/cart_service.dart';

import 'bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _clothingItems = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? itemData;

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  // Ajouter un article au panier
  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    CartService.addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article ajouté au panier!')),
    );
  }

  // Récupérer les articles de vêtement
  void _fetchClothingItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await _database.child('clothingItems').get();

      if (snapshot.exists) {
        final items = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _clothingItems = items.entries.map((entry) {
            return {
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value as Map),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _clothingItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des articles : $e");
      setState(() {
        _clothingItems = [];
        _isLoading = false;
      });
    }
  }

  // Changer la page lorsque l'élément de la barre de navigation est sélectionné
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ines App', style: TextStyle(fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.pink, // Couleur principale
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClothingItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clothingItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Aucun article disponible",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchClothingItems,
                        child: const Text("Actualiser"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink, // Couleur du bouton
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = _clothingItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailPage(itemId: item['id']),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                topRight: Radius.circular(12.0),
                              ),
                              child: Image.network(
                                item['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                height: 200, // Fixed height for images
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Prix: ${item['price']} MAD',
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () => _addToCart(context, item),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.pink, // Couleur de l'icône
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Bar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemDetail()),
          ).then((_) => _fetchClothingItems());
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.pink, // Couleur du bouton flottant
      ),
    );
  }
}
