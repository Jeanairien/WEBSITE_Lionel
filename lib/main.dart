import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'mentions_legales.dart'; // Assure-toi que ce fichier existe
import 'dart:ui_web' as ui_web; // Nécessaire pour platformViewRegistry
import 'dart:html' as html; // Nécessaire pour créer l'IFrameElement
import 'package:url_launcher/url_launcher.dart'; // Importe si tu utilises les liens cliquables

// --- Constantes (Ajuste selon tes besoins) ---
const Color primaryColor = Color(0xFF0D1A26); // Un bleu/gris très foncé
const Color accentColor = Color(0xFF26A69A); // Le teal des icônes
const double sectionSpacing = 50.0; // Espacement standard entre les sections
const double headerImageHeight =
    400.0; // Hauteur de l'image de fond initiale (AJUSTE SI BESOIN)
const double stickyNavBarHeight =
    90.0; // Hauteur de la barre de navigation qui reste collée (AJUSTE SI BESOIN)
const double logoHeightInStickyBar =
    70.0; // Hauteur du logo DANS la barre collée (AJUSTE SI BESOIN)

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage Ride & Shine', // Nom mis à jour
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        brightness: Brightness.light,
        fontFamily: 'Arial',
        // Style global pour TextButton pour éviter l'effet de survol par défaut si souhaité
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              // Si tu ne veux AUCUN effet au survol/clic, décommente :
              // overlayColor: Colors.transparent,
              ),
        ),
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
  final ScrollController _scrollController = ScrollController();

  // Clés globales pour le défilement
  final GlobalKey _presentationKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey(); // Clé pour le carrousel
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _contactKey =
      GlobalKey(); // Footer (utilisé comme section contact)

  // État du carrousel
  int _currentCarouselIndex = 0;
  // Liste des images pour le carrousel (vérifie les chemins !)
  final List<String> imgList = [
    'assets/images/machine_pneu.jpg',
    'assets/images/moteur_out.jpg',
    'assets/images/moteur_ouvert.jpg',
    'assets/images/plateau1.jpg',
    'assets/images/V_jaune_ouverte.jpg',
    'assets/images/plateau2.jpg',
    'assets/images/voiture_ouverte_2.jpg',
  ];

  // --- Fonction de Défilement vers une section ---
  void _scrollToSection(GlobalKey key) {
    // Délai court pour laisser le temps au layout de se stabiliser
    Future.delayed(const Duration(milliseconds: 50), () {
      final context = key.currentContext;
      if (context != null) {
        // Hauteur de la barre de navigation collante à compenser
        const double stickyHeaderHeight = stickyNavBarHeight;

        // Méthode 1: Utilisation de Scrollable.ensureVisible (plus simple, mais peut manquer de précision)
        // Fonctionne souvent bien pour les cas simples.
        Scrollable.ensureVisible(
          context,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          alignment:
              0.0, // Tente d'aligner le haut de la section avec le haut de la zone visible
        );

        // Méthode 2: Calcul manuel de l'offset (plus précis si ensureVisible ne suffit pas)
        // Si la section commence DERRIÈRE la barre collante avec la méthode 1, essaie celle-ci.
        // Pour l'activer : commente l'appel Scrollable.ensureVisible ci-dessus et décommente ce bloc.
        /*
        try {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            // Position de l'élément par rapport au coin supérieur gauche de la fenêtre (global)
            final position = renderBox.localToGlobal(Offset.zero);
            // Position actuelle du scroll
            final scrollOffset = _scrollController.offset;
            // Calcule l'offset cible : position actuelle + position de l'élément - hauteur barre collante
            final targetOffset = scrollOffset + position.dy - stickyHeaderHeight;

            _scrollController.animateTo(
              // Assure que l'offset reste dans les limites valides du scroll
              targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
            );
        } catch (e) {
             print("Erreur de calcul de défilement: $e");
             // Solution de repli si le calcul échoue
             Scrollable.ensureVisible(
                context,
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
              );
        }
        */
      } else {
        print("Impossible de trouver le contexte pour la clé: $key");
      }
    });
  }

  // --- Pop-up de contact ---
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contactez-nous"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _buildContactDialogRow(
                  Icons.phone,
                  "Téléphone",
                  "+32 496 39 83 27", // Numéro réel
                  "tel:+32496398327", // URI pour l'appel
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.email,
                  "E-mail",
                  "wmecasolutionsgc@gmail.com", // Email réel
                  "mailto:wmecasolutionsgc@gmail.com", // URI pour l'email
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.location_on,
                  "Adresse",
                  "Chaussée de Lille 883 Hertain", // Adresse réelle
                  null, // Pas d'action directe, mais on pourrait ouvrir Maps ici
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Fermer'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Helper pour une ligne dans la pop-up contact (avec lien cliquable optionnel)
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
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            print('Impossible de lancer $url');
            if (mounted) {
              // Vérifie si le widget est toujours dans l'arbre
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Impossible d\'ouvrir le lien pour $label')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: contactContent,
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: contactContent,
      );
    }
  }

  // --- Construction de l'UI principale ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le body utilise CustomScrollView pour gérer les Slivers (éléments scrollables avancés)
      body: CustomScrollView(
        controller: _scrollController, // Attache le contrôleur de défilement
        slivers: <Widget>[
          // Sliver 1: Barre d'informations tout en haut (ne défile pas de manière spéciale)
          SliverToBoxAdapter(
            child: _buildTopBar(),
          ),

          // Sliver 2: Image de fond du Header (ne défile pas de manière spéciale)
          SliverToBoxAdapter(
            child:
                _buildHeaderBackgroundImage(), // Fonction qui retourne juste l'image
          ),

          // Sliver 3: Barre de Navigation (Logo + Liens) - CELLE QUI DEVIENT COLLANTE (STICKY)
          SliverAppBar(
            pinned: true, // Rend la barre collante en haut quand on scrolle
            floating:
                false, // Ne réapparaît pas immédiatement en scrollant vers le haut
            snap: false, // Ne s'anime pas pour s'accrocher
            automaticallyImplyLeading:
                false, // Enlève l'espace par défaut à gauche (pour bouton retour)
            backgroundColor: primaryColor.withOpacity(
                0.90), // Fond semi-transparent pour la barre collée (ajuste l'opacité)
            toolbarHeight: stickyNavBarHeight, // Hauteur fixe pour cette barre
            titleSpacing: 0, // Enlève l'espacement par défaut autour du titre

            // Le 'title' de SliverAppBar contient ici le logo aligné à gauche
            title: Padding(
              padding:
                  const EdgeInsets.only(left: 60.0), // Marge à gauche du logo
              child: Image.asset(
                'assets/images/Logo_lionel.JPG', // CHEMIN VERS TON LOGO
                height:
                    logoHeightInStickyBar, // Hauteur définie pour le logo dans cette barre
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Logo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Les 'actions' de SliverAppBar contiennent les éléments alignés à droite (les liens)
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    right: 45.0), // Marge à droite des liens
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // La Row prend juste la largeur nécessaire
                  children: [
                    _buildNavLink(
                        "Accueil", () => _scrollToSection(_presentationKey)),
                    _buildNavLink("Présentation",
                        () => _scrollToSection(_presentationKey)),
                    _buildNavLink(
                        "Nos Services", () => _scrollToSection(_servicesKey)),
                    _buildNavLink(
                        "Réalisations",
                        () => _scrollToSection(
                            _carouselKey)), // Lien vers le carrousel
                    // _buildNavLink("Vidéos", () { /* TODO */ }), // Décommenter si nécessaire
                    _buildNavLink("Où nous trouver",
                        () => _scrollToSection(_locationKey)),
                    _buildNavLink(
                        "Nous contacter",
                        () => _scrollToSection(
                            _contactKey)), // Lien vers le footer
                  ],
                ),
              ),
            ],
          ),

          // Slivers 4...N: Le reste du contenu de la page, chaque section dans un SliverToBoxAdapter
          // On ajoute un espacement standard entre chaque section de contenu.
          _buildSliverSectionSpacing(), // Espace après la barre collante
          SliverToBoxAdapter(child: _buildPresentationSection()),
          _buildSliverSectionSpacing(),
          SliverToBoxAdapter(child: _buildServicesSection()),
          _buildSliverSectionSpacing(),
          SliverToBoxAdapter(child: _buildCarouselSection()),
          _buildSliverSectionSpacing(),
          SliverToBoxAdapter(child: _buildLocationSection()),
          _buildSliverSectionSpacing(),
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
      // Bouton d'action flottant pour contact rapide
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(context),
        backgroundColor: accentColor,
        tooltip: 'Contact Rapide',
        child: const Icon(Icons.contact_phone, color: Colors.white),
      ),
    );
  }

  // --- Fonctions Helper pour construire les différentes parties de l'UI ---

  // Helper pour ajouter un espacement vertical standard entre les sections dans le CustomScrollView
  Widget _buildSliverSectionSpacing() {
    return const SliverToBoxAdapter(
      child: SizedBox(height: sectionSpacing),
    );
  }

  // 1. Barre Supérieure avec infos de contact (non-sticky)
  Widget _buildTopBar() {
    return Container(
      color: primaryColor.withOpacity(0.8), // Fond légèrement transparent
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Espace entre infos et potentiels liens sociaux
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
          // Ajoute ici des icônes de réseaux sociaux si tu en as
        ],
      ),
    );
  }

  // Helper pour une information de contact dans la barre supérieure
  Widget _buildTopContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ],
    );
  }

  // NOUVEAU: Widget retournant UNIQUEMENT l'image de fond du header (non-sticky)
  Widget _buildHeaderBackgroundImage() {
    return Container(
      height: headerImageHeight, // Utilise la constante définie en haut
      width: double.infinity, // Prend toute la largeur
      child: Image.asset(
        'assets/images/atelier_grand_plan2.jpg', // CHEMIN VERS TON IMAGE DE FOND
        fit: BoxFit.cover, // Couvre la zone du Container
        // Widget affiché si l'image ne peut pas être chargée
        errorBuilder: (context, error, stackTrace) => Container(
          height: headerImageHeight,
          color: Colors.grey[800], // Fond sombre en cas d'erreur
          child: const Center(
            child: Text('Image de fond indisponible',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // Widget pour créer un lien de navigation dans la barre (SliverAppBar)
  // La partie 'overlayColor' avec MaterialStateProperty a été retirée.
  Widget _buildNavLink(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 15.0), // Espace entre les liens
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero, // Pas de padding interne au bouton
          minimumSize: const Size(50, 30), // Taille minimale cliquable
          alignment: Alignment.center, // Alignement du texte
          // foregroundColor: Colors.white.withOpacity(0.9), // Option: couleur légèrement moins vive
          // Si tu veux un effet simple au survol SANS MaterialStateProperty (fonctionne sur web):
          // hoverColor: Colors.white.withOpacity(0.1),
        ),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors
                .white, // Texte blanc pour contraster avec la barre foncée
            fontSize: 16,
            fontWeight: FontWeight.w600, // Texte légèrement gras
          ),
        ),
      ),
    );
  }

  // 3. Section Présentation
  Widget _buildPresentationSection() {
    // La clé est assignée au Container racine de la section
    return Container(
      key: _presentationKey,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 30),
      constraints: const BoxConstraints(
          maxWidth: 1200), // Limite la largeur sur grands écrans
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Colonne Texte à Gauche
          Expanded(
            flex: 2, // Prend 2/3 de l'espace
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Présentation de Votre Garage",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                ),
                SizedBox(height: 20),
                Text(
                  "Bienvenue chez WMécaSolutions, votre partenaire de confiance pour l'entretien et la réparation de tous types de véhicules à Hertain et ses environs. Forts de notre expertise et de notre passion pour la mécanique, nous nous engageons à fournir un service de qualité supérieure, honnête et transparent.\n\nQue ce soit pour une simple vidange, une réparation complexe de moteur, un problème hydraulique ou un diagnostic électronique, notre équipe qualifiée est équipée pour répondre à vos besoins avec professionnalisme et efficacité. Votre satisfaction et la sécurité de votre véhicule sont nos priorités absolues.",
                  style: TextStyle(
                      fontSize: 16, height: 1.6, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(width: 50), // Espace entre texte et image
          // Image à Droite
          Expanded(
            flex: 1, // Prend 1/3 de l'espace
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Coins arrondis
              child: Image.asset(
                // Utilise une image d'asset pertinente ici
                'assets/images/moteur_out.jpg', // EXEMPLE: REMPLACE par une image de l'équipe ou de l'atelier
                fit: BoxFit.cover,
                height: 350, // Hauteur de l'image
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 350,
                  color: Colors.grey[300],
                  child: Center(
                      child: Text('Image Présentation',
                          style: TextStyle(color: Colors.grey[600]))),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3.B Section Services
  Widget _buildServicesSection() {
    // Liste des services (tu peux ajuster les icônes)
    final List<Map<String, dynamic>> servicesList = [
      {'name': 'Réparation Voitures', 'icon': Icons.directions_car},
      {'name': 'Réparation Camions', 'icon': Icons.local_shipping},
      {'name': 'Maintenance Grues', 'icon': Icons.construction},
      {'name': 'Systèmes Hydrauliques', 'icon': Icons.opacity},
      {'name': 'Réfection Culasse', 'icon': Icons.settings},
      {'name': 'Remplacement Embrayage', 'icon': Icons.drive_eta_outlined},
      {
        'name': 'Préparation Contrôle Technique',
        'icon': Icons.check_circle_outline
      },
      {'name': 'Montage & Équilibrage Pneus', 'icon': Icons.tire_repair},
      {'name': 'Dépannage Rapide', 'icon': Icons.car_repair},
      {'name': 'Récupération de Véhicule', 'icon': Icons.sync_problem},
      {
        'name': 'Kit / Chaîne de Distribution',
        'icon': Icons.settings_applications
      },
      {
        'name': 'Diagnostic Pannes Électriques',
        'icon': Icons.electrical_services
      },
      {'name': 'Diagnostic Électronique (Ordinateur)', 'icon': Icons.computer},
    ];

    // La clé est assignée au Container racine
    return Container(
      key: _servicesKey,
      color: const Color(0xFFF5F5F5), // Fond légèrement gris pour différencier
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Nos Services",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          const Text(
            "Nous prenons en charge une large gamme de véhicules et de réparations. Découvrez nos principales expertises :",
            style: TextStyle(fontSize: 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Grille flexible des services
          Wrap(
            spacing: 20.0, // Espace horizontal
            runSpacing: 25.0, // Espace vertical entre lignes
            alignment: WrapAlignment.center, // Centre les éléments
            children: servicesList.map((service) {
              return _buildServiceItem(
                service['icon'] as IconData,
                service['name'] as String,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Helper pour afficher un élément de service dans la grille
  Widget _buildServiceItem(IconData icon, String name) {
    return Container(
      width: 280, // Largeur fixe pour un meilleur alignement
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc pour chaque item
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            // Ombre légère
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 30), // Icône
          const SizedBox(width: 15),
          Expanded(
            // Permet au texte de passer à la ligne
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Section Carrousel ("Réalisations")
  Widget _buildCarouselSection() {
    // La clé est assignée au Container (ou Column) racine
    return Container(
      key: _carouselKey,
      padding:
          const EdgeInsets.symmetric(vertical: 30.0), // Ajoute un peu d'air
      color: Colors.grey[200], // Léger fond pour la section carrousel
      child: Column(
        children: [
          const Text(
            "Nos Réalisations en Images",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          CarouselSlider(
            items: imgList.map((itemPath) {
              return Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 5.0), // Espace entre images
                decoration: BoxDecoration(
                    // Optionnel: Ombre ou bordure
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ]),
                child: ClipRRect(
                  // Pour arrondir les coins de l'image
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    itemPath, // Charge l'image depuis les assets
                    fit: BoxFit.cover,
                    width: 1000, // Largeur indicative
                    errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[400],
                        child: Center(
                            child: Text('Erreur image',
                                style: TextStyle(color: Colors.white)))),
                  ),
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 500, // Hauteur du carrousel (ajuste si besoin)
              autoPlay: true, // Lecture automatique
              enlargeCenterPage: true, // Image centrale plus grande
              aspectRatio: 16 / 9, // Ratio d'aspect des images
              autoPlayCurve: Curves.fastOutSlowIn, // Animation de transition
              enableInfiniteScroll: true, // Défilement infini
              autoPlayAnimationDuration:
                  const Duration(milliseconds: 800), // Durée de l'animation
              viewportFraction:
                  0.8, // Fraction de la largeur pour chaque image (plus petite = voit les voisines)
              onPageChanged: (index, reason) {
                // Met à jour l'indicateur actif
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
          ),
          // Indicateurs (points sous le carrousel)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {/* Pourrait contrôler le carrousel au clic */},
                child: Container(
                  width: 10.0, // Taille des points
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0), // Espacement
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Forme circulaire
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : primaryColor)
                        .withOpacity(_currentCarouselIndex == entry.key
                            ? 0.9
                            : 0.3), // Opacité différente si actif
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 5. Section Localisation
  Widget _buildLocationSection() {
    const String iframeElementId = 'google-map-iframe';
    // URL d'intégration Google Maps pour l'adresse spécifiée
    const String googleMapsEmbedUrl =
        'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2532.0135057121715!2d3.2787450770321174!3d50.60828657598596!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47c2d8c926d4fba9%3A0xf5258fe578a74466!2sChau.%20de%20Lille%20883%2C%207522%20Tournai!5e0!3m2!1sfr!2sbe!4v1745831881043!5m2!1sfr!2sbe';

    // Enregistre la 'factory' pour créer l'élément IFrame HTML pour la vue web
    // Doit être fait avant que HtmlElementView ne soit construit
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      iframeElementId,
      (int viewId) {
        // Cette fonction crée l'élément HTML demandé
        final html.IFrameElement iframeElement = html.IFrameElement()
          ..src = googleMapsEmbedUrl // Définit la source de l'iframe
          ..style.border = 'none' // Supprime la bordure par défaut
          ..style.width = '100%' // Prend toute la largeur disponible
          ..style.height = '100%'; // Prend toute la hauteur disponible
        return iframeElement; // Retourne l'élément IFrame configuré
      },
    );

    // La clé est assignée au Container racine
    return Container(
      key: _locationKey,
      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 50),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          const Text(
            "Où nous trouver",
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          // Contenu en ligne (Texte/Image à gauche, Carte/Bouton à droite)
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Aligne les éléments en haut
            children: [
              // Partie Gauche: Texte descriptif + Image
              Expanded(
                flex: 1, // Prend la moitié de l'espace (ajuste si besoin)
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Accès Facile & Parking",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: primaryColor),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Notre garage est idéalement situé sur la Chaussée de Lille à Hertain (Tournai), facilement accessible depuis les axes principaux. Un parking dédié à notre clientèle est disponible devant l'établissement pour votre confort.",
                      style: TextStyle(
                          fontSize: 16, height: 1.5, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      // Image illustrative
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        // Utilise une photo de la façade ou de l'entrée
                        'assets/images/plateau1.jpg', // EXEMPLE: REMPLACE par ta photo
                        fit: BoxFit.cover,
                        width: double
                            .infinity, // Prend toute la largeur de la colonne
                        height: 250, // Hauteur indicative
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 250,
                          color: Colors.grey[300],
                          child: Center(
                              child: Text('Image Façade',
                                  style: TextStyle(color: Colors.grey[600]))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40), // Espace entre les deux colonnes
              // Partie Droite: Carte Google Maps + Bouton Itinéraire
              Expanded(
                flex: 1, // Prend l'autre moitié de l'espace
                child: Column(
                  children: [
                    // Conteneur pour la carte intégrée
                    Container(
                      height: 400, // Hauteur fixe pour la carte
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.grey.shade300), // Bordure légère
                        borderRadius:
                            BorderRadius.circular(8), // Coins arrondis
                      ),
                      child: ClipRRect(
                        // Assure que l'iframe respecte les coins arrondis
                        borderRadius: BorderRadius.circular(8.0),
                        // Affiche l'élément HTML (iframe) créé par la factory
                        child: HtmlElementView(viewType: iframeElementId),
                      ),
                    ),
                    const SizedBox(height: 25), // Espace entre carte et bouton
                    // Bouton pour lancer Google Maps Directions
                    ElevatedButton.icon(
                      icon: const Icon(Icons.directions),
                      label: const Text("Obtenir l'itinéraire"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor, // Couleur du bouton
                        foregroundColor: Colors.white, // Couleur texte/icône
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8)), // Coins arrondis
                      ),
                      onPressed: () {
                        // Adresse de destination encodée pour l'URL
                        const String destinationAddressEncoded =
                            'Chaussee+de+Lille+883,+7522+Hertain,+Tournai,+Belgium';
                        _launchMapsUrl(
                            destinationAddressEncoded); // Lance la fonction pour ouvrir Maps
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

  // Helper pour lancer Google Maps (ou autre app de cartes) avec l'itinéraire
  Future<void> _launchMapsUrl(String destinationAddressEncoded) async {
    // Construit l'URL universelle pour Google Maps Directions
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$destinationAddressEncoded';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        // Tente d'ouvrir l'URL dans une application externe (préfère l'app Maps si installée)
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Impossible de lancer $googleMapsUrl');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible d\'ouvrir Google Maps.')),
          );
        }
      }
    } catch (e) {
      print('Erreur lors du lancement de l\'URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Erreur lors de l\'ouverture de Google Maps.')),
        );
      }
    }
  }

  // 6. Pied de page
  Widget _buildFooter() {
    // La clé est assignée au Container racine
    return Container(
      key: _contactKey,
      color: const Color(0xFF1C1C1C), // Fond très sombre
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
      child: Column(
        children: [
          // Logo (utilise une version claire/blanche si possible)
          Image.asset(
            'assets/images/Logo_lionel.JPG', // REMPLACE si tu as un logo blanc/clair, sinon garde le principal
            height: 70, // Hauteur du logo dans le footer
            // Optionnel: Appliquer une couleur si c'est un PNG avec transparence
            // color: Colors.white.withOpacity(0.8),
            errorBuilder: (context, error, stackTrace) => const Text(
              'LOGO',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          // Coordonnées principales répétées pour accessibilité
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Espace équitablement
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFooterContactColumn(
                  Icons.phone, "Téléphone", "+32 496 39 83 27"),
              _buildFooterContactColumn(
                  Icons.email, "E-mail", "wmecasolutionsgc@gmail.com"),
              _buildFooterContactColumn(Icons.location_on, "Adresse",
                  "Chaussée de Lille 883\n7522 Hertain (Tournai)"), // Adresse sur deux lignes
            ],
          ),
          const SizedBox(height: 40),
          const Divider(color: Colors.white30), // Ligne de séparation
          const SizedBox(height: 20),
          // Copyright et liens légaux
          Wrap(
            // Utilise Wrap pour que ça passe à la ligne sur petits écrans
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 15.0, // Espace horizontal
            runSpacing: 8.0, // Espace vertical si passage à la ligne
            children: [
              Text(
                "© ${DateTime.now().year} WMécaSolutions GC", // Nom du garage
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                "- Réalisé par Nikko Verquin", // Ton nom ou celui du créateur
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              _buildFooterLink("Mentions légales", () {
                // Navigue vers la page des mentions légales
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MentionsLegalesPage()),
                );
              }),
              // Ajoute ici d'autres liens si nécessaire (Politique de confidentialité, CGV...)
              // _buildFooterLink("Confidentialité", () { /* ... */ }),
            ],
          )
        ],
      ),
    );
  }

  // Helper pour créer un lien cliquable dans le footer
  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            horizontal: 5), // Léger padding pour le clic
        minimumSize: const Size(50, 20),
        alignment: Alignment.center,
        tapTargetSize: MaterialTapTargetSize
            .shrinkWrap, // Réduit la zone de clic superflue
        foregroundColor: Colors.white70, // Couleur du texte par défaut
      ),
      child: Text(
        text,
        style: const TextStyle(
          // color: Colors.white70, // La couleur est définie dans foregroundColor du styleFrom
          fontSize: 13,
          decoration:
              TextDecoration.underline, // Souligne pour indiquer un lien
          decorationColor: Colors.white70, // Couleur du soulignement
        ),
      ),
    );
  }

  // Helper pour afficher une colonne d'info contact dans le footer
  Widget _buildFooterContactColumn(IconData icon, String title, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prend la hauteur minimale nécessaire
      children: [
        Icon(icon, color: accentColor, size: 30),
        const SizedBox(height: 10),
        Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4), // Hauteur de ligne pour multi-lignes
          textAlign:
              TextAlign.center, // Centre le texte si sur plusieurs lignes
        ),
      ],
    );
  }

  // --- Fin des Widgets ---

  // Libère les ressources (ScrollController) quand le widget est détruit
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
