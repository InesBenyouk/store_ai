import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail({super.key});

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController(); // Nouveau contrôleur pour l'URL de l'image
  final TextEditingController _categoryController =
      TextEditingController(); // Nouveau contrôleur pour la catégorie
  final TextEditingController _descriptionController =
      TextEditingController(); // Nouveau contrôleur pour la description

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Variables pour les catégories
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Récupérer les catégories depuis Firebase
  void _fetchCategories() async {
    try {
      final snapshot = await _database.child('categories/clothing').get();

      if (snapshot.exists) {
        final List<dynamic> categoriesList = snapshot.value as List<dynamic>;

        setState(() {
          _categories =
              categoriesList.map((category) => category.toString()).toList();
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fonction pour ajouter un élément à Firebase Realtime Database
  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Générer une nouvelle clé unique pour l'élément
        DatabaseReference newItemRef = _database.child('clothingItems').push();

        // Ajouter l'élément à la base de données
        await newItemRef.set({
          'title': _titleController.text,
          'size': _sizeController.text,
          'brand': _brandController.text,
          'price': double.parse(_priceController.text),
          'imageUrl': _imageUrlController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'timestamp': ServerValue.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Élément ajouté avec succès !")),
        );

        // Réinitialiser le formulaire
        _formKey.currentState!.reset();
        _clearControllers();
      } catch (e) {
        print("Erreur lors de l'ajout de l'élément : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout de l'élément : $e")),
        );
      }
    }
  }

  void _clearControllers() {
    _titleController.clear();
    _sizeController.clear();
    _brandController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _categoryController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un article'),
        backgroundColor: Colors.pink,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  labelStyle: TextStyle(color: Colors.pink[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un titre'
                    : null,
              ),
              const SizedBox(height: 16),

              // Catégorie (Menu déroulant dynamique)
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Catégorie',
                        labelStyle: TextStyle(color: Colors.pink[800]),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.pink),
                        ),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Sélectionnez une catégorie'),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner une catégorie'
                          : null,
                    ),
              const SizedBox(height: 16),

              // Taille
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(
                  labelText: 'Taille',
                  labelStyle: TextStyle(color: Colors.pink[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer une taille'
                    : null,
              ),
              const SizedBox(height: 16),

              // Marque
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Marque',
                  labelStyle: TextStyle(color: Colors.pink[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer une marque'
                    : null,
              ),
              const SizedBox(height: 16),

              // Prix
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix',
                  labelStyle: TextStyle(color: Colors.pink[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un prix';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Entrez un prix valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de l'image
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: "URL de l'image",
                  labelStyle: TextStyle(color: Colors.pink[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer l'URL d'une image";
                  }
                  // Validation facultative de l'URL
                  if (!value.startsWith('http') && !value.startsWith('https')) {
                    return 'Entrez une URL valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Soumettre'),
              ),

              // Aperçu de l'image si l'URL est fournie
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.network(
                    _imageUrlController.text,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Impossible de charger l\'image'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
