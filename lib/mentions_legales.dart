import 'package:flutter/material.dart';

// --- Réutilise les constantes si nécessaire ---
const Color primaryColor = Color(0xFF0D1A26); // Ou importe depuis main.dart

class MentionsLegalesPage extends StatelessWidget {
  const MentionsLegalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mentions Légales"),
        backgroundColor: primaryColor, // Utilise une couleur cohérente
      ),
      body: SingleChildScrollView(
        // Permet le défilement si le contenu est long
        padding: const EdgeInsets.all(20.0), // Ajoute de l'espace autour
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Aligne le texte à gauche
          children: [
            _buildLegalInfoSection(
                "Nom de l’entreprise", "W Meca Solutions GC SRL"),
            _buildLegalInfoSection("Forme juridique", "SRL"),
            _buildLegalInfoSection("Adresse du siège social",
                "Allée de la Liberté 5\n7503 Froyennes\nBelgique"),
            _buildLegalInfoSection("Coordonnées de contact",
                "E-mail : wmecasolutionsgc@gmail.com\nTéléphone : +32 (0) 496 39 83 27"),
            _buildLegalInfoSection("Numéro de TVA", "BE1009.335.082"),
          ],
        ),
      ),
    );
  }

  // Helper Widget pour afficher une section d'information légale
  Widget _buildLegalInfoSection(String title, String content) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 15.0), // Espace après chaque section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title :",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4), // Petit espace entre titre et contenu
          Text(
            content,
            style: const TextStyle(
                fontSize: 15, height: 1.4), // Hauteur de ligne pour lisibilité
          ),
        ],
      ),
    );
  }
}
