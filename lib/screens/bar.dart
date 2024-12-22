import 'package:flutter/material.dart';
import 'package:ines_app/screens/profile.dart';
import 'package:ines_app/screens/cart.dart';
import 'package:ines_app/screens/add_ithem.dart'; // Importation de l'écran pour ajouter un élément

class Bar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const Bar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemDetail()),
          );
        } else {
          onTap(index);
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart,
              color: Colors.pink), // Couleur modifiée en rose
          label: 'Acheter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_basket),
          label: 'Panier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      selectedItemColor: Colors.pink, // Couleur de l'icône sélectionnée en rose
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    );
  }
}
