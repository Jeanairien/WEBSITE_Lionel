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
            _buildLegalInfoSection("Nom de l’entreprise",
                "XXXX Nom Commercial / Dénomination Sociale"),
            _buildLegalInfoSection(
                "Forme juridique", "XXXX (SRL, SA, ASBL, Indépendant, etc.)"),
            _buildLegalInfoSection("Adresse du siège social",
                "XXXX Rue de l'Adresse, Numéro\nXXXX Code Postal, Ville\nBelgique"), // Utilise \n pour les retours à la ligne
            _buildLegalInfoSection(
              "Coordonnées de contact",
              "E-mail : info@XXXX-XXXX.be\nTéléphone : +32 (0) 496 39 83 27", // Téléphone obligatoire
              // Optionnel : "Formulaire de contact : [Lien vers le formulaire si applicable]"
            ),
            _buildLegalInfoSection("Numéro d’entreprise (BCE)", "XXXX.XXX.XXX"),
            _buildLegalInfoSection(
                "Numéro de TVA", "BE 1009.335.082 (si applicable)"),

            // --- Sections Optionnelles (ajoute si nécessaire) ---
            const SizedBox(height: 15),
            const Text(
              "Informations additionnelles (si applicable) :",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            const Divider(),
            const SizedBox(height: 10),

            _buildLegalInfoSection("Autorité de surveillance compétente",
                "XXXX Nom de l'autorité (si activité réglementée, ex: SPF Economie, IPI pour immobilier, etc.)\nXXXX Adresse de l'autorité"),
            _buildLegalInfoSection("Profession réglementée",
                "Titre professionnel : XXXX\nAssociation/Ordre professionnel : XXXX\nPays d'octroi : Belgique\nRègles professionnelles applicables : [Lien ou référence] XXXX"),
            _buildLegalInfoSection("Code(s) de conduite applicable(s)",
                "[Nom du code] consultable à l'adresse : XXXX"),
            _buildLegalInfoSection("Registre des personnes morales (RPM)",
                "RPM XXXX (Ville du tribunal de l'entreprise compétent)"),

            // Note: Tu peux supprimer les sections optionnelles non pertinentes.

            const SizedBox(height: 30),
            Text(
              "Note : Ces informations sont fournies à titre indicatif et doivent être complétées avec les données spécifiques à votre entreprise.",
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey[600]),
            ),
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
