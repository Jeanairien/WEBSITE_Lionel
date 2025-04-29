import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'mentions_legales.dart';
import 'dart:ui_web' as ui_web; // Nécessaire pour platformViewRegistry
import 'dart:html' as html; // Nécessaire pour créer l'IFrameElement
import 'package:url_launcher/url_launcher.dart'; // Importe si tu utilises les liens cliquables
// import 'package:url_launcher/url_launcher.dart'; // Décommente si tu veux rendre les liens cliquables

// --- Constantes (tu peux les ajuster) ---
const Color primaryColor = Color(0xFF0D1A26); // Un bleu/gris très foncé
const Color accentColor = Color(0xFF26A69A); // Le teal des icônes
const double sectionSpacing = 50.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Ride & Shine (Exemple)',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Ou une couleur qui correspond mieux
        scaffoldBackgroundColor: const Color.fromARGB(
            255, 255, 255, 255), // Fond par défaut des sections
        brightness: Brightness.light,
        fontFamily: 'Arial', // Choisis une police si tu veux
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Contrôleur pour le défilement
  final ScrollController _scrollController = ScrollController();

  // Clés globales pour identifier les sections où faire défiler
  final GlobalKey _presentationKey = GlobalKey();
  final GlobalKey _contactKey =
      GlobalKey(); // Le pied de page servira de contact
  final GlobalKey _locationKey =
      GlobalKey(); // Clé pour la section localisation
  final GlobalKey _servicesKey = GlobalKey();
  // État pour le carrousel
  int _currentCarouselIndex = 0;
  final List<String> imgList = [
    'assets/images/machine_pneu.jpg',
    'assets/images/moteur_out.jpg',
    'assets/images/moteur_ouvert.jpg',
    'assets/images/plateau1.jpg',
    'assets/images/V_jaune_ouverte.jpg',
    'assets/images/plateau2.jpg',
    'assets/images/voiture_ouverte_2.jpg',
  ]; // Remplace par tes URLs ou assets/images/...

  // Fonction pour faire défiler vers une section
  void _scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  // --- NOUVELLE FONCTION pour afficher la pop-up de contact ---
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contactez-nous"),
          content: SingleChildScrollView(
            // Au cas où il y aurait beaucoup d'infos
            child: ListBody(
              // Utilise ListBody pour un espacement correct dans une colonne
              children: <Widget>[
                _buildContactDialogRow(
                  Icons.phone,
                  "Téléphone",
                  "+32 496 39 83 27", // Remplace par XXXX
                  "tel:+32496398327", // Remplace par le numéro sans espaces/parenthèses pour l'URI
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.email,
                  "E-mail",
                  "wmecasolutionsgc@gmail.com", // Remplace par XXXX
                  "mailto:wmecasolutionsgc@gmail.com", // Remplace par l'email pour l'URI
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.location_on,
                  "Adresse",
                  "Chaussée de Lille 883 Hertain", // Remplace par XXXX
                  null, // Pas d'action directe simple pour l'adresse, ou tu pourrais mettre un lien Google Maps
                ),
                // Tu pourrais ajouter un lien vers le formulaire de contact du site ici si tu en as un
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }

  // Helper pour créer une ligne dans la pop-up de contact (avec lien optionnel)
  Widget _buildContactDialogRow(
      IconData icon, String label, String value, String? url) {
    final contactContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accentColor, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(value),
            ],
          ),
        ),
      ],
    );

    if (url != null) {
      return InkWell(
        // Rend la ligne cliquable
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            // Gérer l'erreur si l'URL ne peut pas être lancée
            print('Impossible de lancer $url');
            // Optionnel : afficher un message d'erreur à l'utilisateur
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Impossible d\'ouvrir le lien pour $label')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: 8.0), // Ajoute un peu d'espace pour le clic
          child: contactContent,
        ),
      );
    } else {
      // Si pas d'URL, retourne juste le contenu non cliquable
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: contactContent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildTopBar(),
            _buildHeader(),
            const SizedBox(height: sectionSpacing),
            _buildPresentationSection(),
            const SizedBox(height: sectionSpacing),
            _buildServicesSection(),
            const SizedBox(height: sectionSpacing),
            _buildCarouselSection(),
            const SizedBox(
                height: sectionSpacing), // Espace avant la nouvelle section
            _buildLocationSection(), // <-- AJOUT DE LA NOUVELLE SECTION
            const SizedBox(height: sectionSpacing), // Espace après
            _buildFooter(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ... (FAB reste inchangé) ...
        onPressed: () {
          _showContactDialog(context);
        },
        backgroundColor: accentColor,
        tooltip: 'Contact Rapide',
        child: const Icon(Icons.contact_phone, color: Colors.white),
      ),
    );
  }

  // --- Widgets pour chaque section ---

  // 1. Barre Supérieure
  Widget _buildTopBar() {
    return Container(
      color:
          primaryColor.withOpacity(0.8), // Un peu transparent ou couleur pleine
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Éloigne les infos des icônes sociales
        children: [
          // Infos de contact groupées
          Row(
            children: [
              _buildTopContactInfo(Icons.phone, "+32 496 39 83 27"),
              const SizedBox(width: 25),
              _buildTopContactInfo(Icons.email, "wmecasolutionsgc@gmail.com"),
              const SizedBox(width: 25),
              _buildTopContactInfo(
                  Icons.location_on, "Chaussée de Lille 883 Hertain"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  /*// 2. Header
  Widget _buildHeader() {
    // Utilise une Stack pour superposer le contenu sur l'image de fond
    return Stack(
      alignment: Alignment.center,
      children: [
        // Image de fond
        Container(
          height: 350, // Ajuste la hauteur
          width: double.infinity,
          child: Image.asset(
            // 'assets/images/ras_logo_placeholder.png', // ANCIENNE LIGNE
            'assets/images/atelier_grand_plan2.jpg', // <-- REMPLACE ICI par le nom de ton fichier logo
            height: 80,
            errorBuilder: (context, error, stackTrace) => const Text(
              'Logo', /* ... */
            ),
          ),
        ),

        // Contenu (Logo et Navigation)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Logo à gauche, Nav à droite
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/Logo_lionel.JPG', // REMPLACE par le chemin de ton logo
                height: 80, // Ajuste la taille
                errorBuilder: (context, error, stackTrace) => const Text('Logo',
                    style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 5, 5, 5),
                        fontWeight:
                            FontWeight.bold)), // Texte si l'image ne charge pas
              ),

              // Navigation
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavLink(
                      "Accueil",
                      () => _scrollToSection(
                          _presentationKey)), // Accueil peut pointer vers présentation ou haut de page
                  _buildNavLink(
                      "Présentation", () => _scrollToSection(_presentationKey)),
                  _buildNavLink(
                      "Où nous trouver", () => _scrollToSection(_locationKey)),
                  _buildNavLink(
                      "Nos Services", () => _scrollToSection(_servicesKey)),

                  _buildNavLink("Réalisations", () {
                    /* TODO: Ajouter clé et section Réalisations (ou faire pointer vers carrousel) */
                  }),
                  _buildNavLink("Vidéos", () {
                    /* TODO: Ajouter clé et section Vidéos */
                  }),
                  _buildNavLink(
                      "Nous contacter",
                      () => _scrollToSection(
                          _contactKey)), // Pointe vers le pied de page
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
*/
  Widget _buildHeader() {
    // Utilise une Stack pour superposer le contenu sur l'image de fond
    return Stack(
      alignment:
          Alignment.center, // Garde le contenu centré verticalement par défaut
      children: [
        // 1. Image de fond (reste en premier, en arrière-plan)
        Container(
          height: 800, // Ajuste la hauteur si besoin
          width: double.infinity, // Assure la pleine largeur
          child: Image.asset(
            // Ou Image.network si tu utilises une URL
            'assets/images/atelier_grand_plan2.jpg', // REMPLACE par le chemin/URL de ton image de fond
            fit: BoxFit.cover, // Très important pour couvrir toute la zone
            // Retire la superposition de couleur ici si tu la mets dans la couche suivante
            // color: Colors.black.withOpacity(0.5),
            // colorBlendMode: BlendMode.darken,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 350,
              color: Colors.grey[800], // Fond sombre si l'image ne charge pas
              child: Center(
                  child: Text('Image de fond indisponible',
                      style: TextStyle(color: Colors.white))),
            ),
          ),
        ),

        // 2. NOUVEAU : Couche de couleur semi-transparente (devant l'image, derrière le contenu)
        Container(
          height: 200, // Doit correspondre à la hauteur du header
          width: double.infinity,
          // Choisis ta couleur et ton opacité
          // Exemple : Couleur primaire foncée avec 70% d'opacité
          color: primaryColor.withOpacity(0.7),
          // Autre exemple : Noir avec 50% d'opacité
          // color: Colors.black.withOpacity(0.5),
        ),

        // 3. Contenu (Logo et Navigation) (reste en dernier, au premier plan)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          // Optionnel : Limiter la largeur maximale du contenu si besoin sur écrans très larges
          // constraints: BoxConstraints(maxWidth: 1400),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween, // ANCIENNE LIGNE
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo (reste à gauche)
              Image.asset(
                'assets/images/Logo_lionel.JPG', // REMPLACE par le chemin de ton logo
                height: 80, // Ajuste la taille
                errorBuilder: (context, error, stackTrace) => const Text('Logo',
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors
                            .white, // Assure-toi que le texte "Logo" est visible
                        fontWeight: FontWeight.bold)),
              ),

              // Espace flexible qui pousse la navigation vers la droite
              const Spacer(), // <-- AJOUT DU SPACER

              // Navigation (maintenant regroupée à droite)
              Row(
                mainAxisSize: MainAxisSize
                    .min, // Important pour que la Row prenne juste la place nécessaire
                children: [
                  _buildNavLink(
                      "Accueil", () => _scrollToSection(_presentationKey)),
                  _buildNavLink(
                      "Présentation", () => _scrollToSection(_presentationKey)),
                  _buildNavLink(
                      "Nos Services", () => _scrollToSection(_servicesKey)),
                  _buildNavLink(
                      "Où nous trouver", () => _scrollToSection(_locationKey)),
                  _buildNavLink("Réalisations", () {
                    /* pointer vers carrousel ou autre */
                    // Exemple: Faire défiler vers le carrousel si tu lui ajoutes une clé
                    // final GlobalKey _carouselKey = GlobalKey(); // Déclarer la clé en haut
                    // _scrollToSection(_carouselKey);
                  }),
                  // _buildNavLink("Vidéos", () { /* TODO */ }), // Décommenter si besoin
                  _buildNavLink(
                      "Nous contacter", () => _scrollToSection(_contactKey)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size(50, 30), // taille minimale
          alignment: Alignment.center,
          // Effet au survol (optionnel mais bien pour le web)
          // overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.1)),
        ),
      ),
    );
  }

  // 3. Section Présentation
  Widget _buildPresentationSection() {
    // Utilise la clé globale ici pour pouvoir y défiler
    return Container(
      key: _presentationKey,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      constraints: const BoxConstraints(
          maxWidth: 1200), // Limite la largeur sur grand écran
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Colonne de Texte (Gauche)
          Expanded(
            flex: 2, // Prend plus de place
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Présentation de Votre Garage", // Ton Titre
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                SizedBox(height: 20),
                Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                  style: TextStyle(
                      fontSize: 16, height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                // Tu peux ajouter un bouton ici si tu veux
                // ElevatedButton(onPressed: () {}, child: Text("En savoir plus"))
              ],
            ),
          ),
          const SizedBox(width: 50), // Espace entre texte et image
          // Image (Droite)
          Expanded(
              flex: 1, // Prend moins de place
              child: ClipRRect(
                // Pour arrondir les coins si tu veux
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  'https://via.placeholder.com/500x350/eeeeee/969696?text=Image+Atelier/Equipe', // Remplace par une image pertinente
                  fit: BoxFit.cover,
                  height: 350, // Hauteur fixe ou dynamique
                ),
              )),
        ],
      ),
    );
  }

// 3.B Section services
  Widget _buildServicesSection() {
    // Liste des services avec nom et icône suggérée
    // N'hésite pas à ajuster les icônes pour qu'elles correspondent mieux !
    final List<Map<String, dynamic>> servicesList = [
      {'name': 'Réparation Voitures', 'icon': Icons.directions_car},
      {'name': 'Réparation Camions', 'icon': Icons.local_shipping},
      {
        'name': 'Maintenance Grues',
        'icon': Icons.construction
      }, // Icône générique
      {
        'name': 'Systèmes Hydrauliques',
        'icon': Icons.opacity
      }, // Goutte (fluide) ou Icons.settings_input_component
      {
        'name': 'Réfection Culasse',
        'icon': Icons.settings
      }, // Engrenage/Réglage
      {
        'name': 'Remplacement Embrayage',
        'icon': Icons.drive_eta_outlined
      }, // Lié à la conduite
      {
        'name': 'Préparation Contrôle Technique',
        'icon': Icons.check_circle_outline
      },
      {'name': 'Montage & Équilibrage Pneus', 'icon': Icons.tire_repair},
      {'name': 'Dépannage Rapide', 'icon': Icons.car_repair},
      {
        'name': 'Récupération de Véhicule',
        'icon': Icons.sync_problem
      }, // Ou Icons.local_shipping avec un style différent?
      {
        'name': 'Kit / Chaîne de Distribution',
        'icon': Icons.settings_applications
      }, // Engrenages
      {
        'name': 'Diagnostic Pannes Électriques',
        'icon': Icons.electrical_services
      },
      {'name': 'Diagnostic Électronique (Ordinateur)', 'icon': Icons.computer},
    ];

    return Container(
      key: _servicesKey, // Assigne la clé pour le défilement
      color: const Color.fromARGB(
          255, 255, 255, 255), // Léger fond gris pour différencier la section
      padding: const EdgeInsets.symmetric(
          horizontal: 80, vertical: 50), // Padding standard
      constraints: const BoxConstraints(maxWidth: 1200), // Limite la largeur
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centre le titre
        children: [
          // Titre de la section
          const Text(
            "Nos Services",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          // Petite introduction (optionnelle)
          const Text(
            "Nous prenons en charge une large gamme de véhicules et de réparations. Découvrez nos principales expertises :",
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40), // Espace avant la liste

          // Utilisation de Wrap pour une grille flexible
          Wrap(
            spacing: 20.0, // Espace horizontal entre les éléments
            runSpacing: 25.0, // Espace vertical entre les lignes
            alignment: WrapAlignment.center, // Centre les éléments dans le Wrap
            children: servicesList.map((service) {
              // Pour chaque service dans la liste, crée un widget d'affichage
              return _buildServiceItem(
                service['icon'] as IconData,
                service['name'] as String,
              );
            }).toList(), // Convertit l'iterable map en une liste de Widgets
          ),
        ],
      ),
    );
  }

  // Helper Widget pour afficher un service individuel (Icône + Texte)
  Widget _buildServiceItem(IconData icon, String name) {
    return Container(
      width:
          280, // Donne une largeur fixe pour un alignement plus propre en grille
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 234, 232, 232),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 158, 158, 158).withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3), // Ombre légère en dessous
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 30), // Icône du service
          const SizedBox(width: 15), // Espace entre icône et texte
          // Utilise Expanded pour que le texte puisse passer à la ligne si besoin
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500, // Un peu plus gras
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Section Carrousel
  Widget _buildCarouselSection() {
    return Column(
      children: [
        CarouselSlider(
          items: imgList
              .map((item) => Container(
                      child: Center(
                    child: Image.asset(item, fit: BoxFit.cover, width: 1000),
                  )))
              .toList(),
          options: CarouselOptions(
              height: 800, // Hauteur du carrousel
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              }),
        ),
        // Indicateurs (points)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () {
                /* Pourrait faire changer le slide au clic sur le point */
              },
              child: Container(
                width: 12.0,
                height: 12.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : primaryColor)
                        .withOpacity(
                            _currentCarouselIndex == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    // ID unique pour la vue HTML de la carte
    const String iframeElementId = 'google-map-iframe';

    // !!! REMPLACE CECI par l'URL 'src' de l'iframe Google Maps Embed !!!
    // Pour obtenir cette URL :
    // 1. Va sur Google Maps.
    // 2. Cherche l'adresse de ton garage.
    // 3. Clique sur "Partager".
    // 4. Choisis l'onglet "Intégrer une carte".
    // 5. Copie UNIQUEMENT l'URL qui se trouve DANS l'attribut `src="..."` du code iframe proposé.
    const String googleMapsEmbedUrl =
        'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2532.0135057121715!2d3.2787450770321174!3d50.60828657598596!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47c2d8c926d4fba9%3A0xf5258fe578a74466!2sChau.%20de%20Lille%20883%2C%207522%20Tournai!5e0!3m2!1sfr!2sbe!4v1745831881043!5m2!1sfr!2sbe'; // <--- METS TON URL ICI

    // Enregistre la factory pour créer l'élément IFrame pour le web
    // Fais cela juste avant de construire le widget HtmlElementView
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      iframeElementId,
      (int viewId) {
        final html.IFrameElement iframeElement = html.IFrameElement()
          ..src = googleMapsEmbedUrl
          ..style.border = 'none' // Supprime la bordure par défaut
          ..width = '100%' // Prend toute la largeur du conteneur parent
          ..height = '100%'; // Prend toute la hauteur du conteneur parent
        return iframeElement;
      },
    );

    return Container(
      key: _locationKey, // Assigne la clé si tu veux y scroller
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      constraints: const BoxConstraints(maxWidth: 1200), // Limite la largeur
      child: Column(
        children: [
          // Titre de la section
          const Text(
            "Où nous trouver",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Contenu principal (Texte/Image + Carte) en ligne
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Partie Gauche: Texte Descriptif et Image
              Expanded(
                flex: 1, // Ajuste le flex pour la largeur désirée
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Accès Facile & Parking", // Sous-titre
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryColor),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Notre garage est idéalement situé à XXXX Ville, facilement accessible depuis [mentionne une route principale, sortie d'autoroute, etc.].\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Sed non risus. Suspendisse lectus tortor, dignissim sit amet, adipiscing nec, ultricies sed, dolor. Cras elementum ultrices diam. Maecenas ligula massa, varius a.\n\nUn parking est à votre disposition devant l'établissement.",
                      style: TextStyle(
                          fontSize: 16, height: 1.5, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      // Image illustrative (façade, plan d'accès simple...)
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        'https://via.placeholder.com/500x300/eeeeee/969696?text=Image+Façade/Accès', // REMPLACE par ta photo
                        fit: BoxFit.cover,
                        width:
                            double.infinity, // Prend la largeur de la colonne
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40), // Espace entre les deux colonnes

              // Partie Droite: Carte et Bouton Itinéraire
              Expanded(
                flex: 1, // Ajuste le flex
                child: Column(
                  children: [
                    // Conteneur pour la carte (iframe)
                    Container(
                      height: 400, // Hauteur fixe pour la carte
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors
                                .grey.shade300), // Optionnel: petite bordure
                        borderRadius: BorderRadius.circular(
                            8), // Optionnel: coins arrondis
                      ),
                      child: ClipRRect(
                        // Assure que l'iframe respecte les coins arrondis
                        borderRadius: BorderRadius.circular(8.0),
                        child: HtmlElementView(
                          viewType: iframeElementId,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Espace entre carte et bouton

                    // Bouton Itinéraire
                    ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text("Obtenir l'itinéraire"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // Couleur du bouton
                        foregroundColor: Colors.white, // Couleur du texte/icône
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        // !!! REMPLACE CECI par ton adresse URL-encodée !!!
                        // Pour encoder : remplace les espaces par '+' ou '%20', gère les caractères spéciaux.
                        // Outil en ligne : https://www.urlencoder.org/
                        const String destinationAddressEncoded =
                            'Rue+de+XXXX,+XX,+XXXX+Ville,+Belgique'; // <--- TON ADRESSE ENCODÉE ICI
                        _launchMapsUrl(destinationAddressEncoded);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper pour lancer Google Maps Directions
  Future<void> _launchMapsUrl(String destinationAddressEncoded) async {
    // Construit l'URL de Google Maps Directions
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$destinationAddressEncoded';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri,
            mode: LaunchMode
                .externalApplication); // Préfère ouvrir l'app Maps si possible
      } else {
        print('Impossible de lancer $googleMapsUrl');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir Google Maps.')),
        );
      }
    } catch (e) {
      print('Erreur lors du lancement de l\'URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Erreur lors de l\'ouverture de Google Maps.')),
      );
    }
  }

  // 5. Pied de page
  Widget _buildFooter() {
    // Utilise la clé globale ici pour pouvoir y défiler
    return Container(
      key: _contactKey,
      color:
          const Color(0xFF1C1C1C), // Noir/Gris très foncé comme dans l'exemple
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        children: [
          // ... (Logo et Coordonnées restent inchangés) ...
          Image.asset(
            'assets/images/ras_logo_placeholder_white.png', // REMPLACE - Version blanche/claire du logo si besoin
            height: 60,
            errorBuilder: (context, error, stackTrace) => const Text('LOGO',
                style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 30),

          // Coordonnées avec icônes
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Répartit l'espace
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterContactColumn(
                Icons.phone,
                "Téléphone",
                "+32 496 39 83 27", // Remplace par XXXX
              ),
              _buildFooterContactColumn(
                Icons.email,
                "E-mail",
                "wmecasolutionsgc@gmail.com", // Remplace par XXXX
              ),
              _buildFooterContactColumn(
                Icons.location_on,
                "Adresse",
                "Chaussée de Lille 883 Hertain", // Remplace par XXXX
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white30),
          const SizedBox(height: 20),

          // Copyright et liens légaux
          Wrap(
            // Utilise Wrap pour une meilleure gestion sur petits écrans
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10.0, // Espace horizontal entre les éléments
            runSpacing: 5.0, // Espace vertical si ça passe à la ligne
            children: [
              Text(
                "© ${DateTime.now().year} WMécaSolutions - Réalisé par Nikko Verquin", // Complète le nom et le réalisateur
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              // Sépare les liens pour plus de clarté si tu en ajoutes d'autres
              _buildFooterLink("Mentions légales", () {
                // Navigation vers la nouvelle page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MentionsLegalesPage()),
                );
              }),
              // Ajoute d'autres liens ici si nécessaire (Confidentialité, CGV...)
              // _buildFooterLink("Confidentialité", () { /* TODO: Naviguer vers page Confidentialité */ }),
              // _buildFooterLink("Conditions générales", () { /* TODO: Naviguer vers page CGV */ }),
            ],
          )
        ],
      ),
    );
  }

  // Helper widget pour créer les liens du footer
  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(50, 20), // Petite taille minimale
        alignment: Alignment.center,
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Réduit la zone de clic
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          decoration:
              TextDecoration.underline, // Souligne pour indiquer un lien
          decorationColor: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildFooterContactColumn(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: accentColor, size: 30),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center),
      ],
    );
  }

  // --- Fin des Widgets de section ---

  @override
  void dispose() {
    _scrollController.dispose(); // Libère le contrôleur de défilement
    super.dispose();
  }
}
