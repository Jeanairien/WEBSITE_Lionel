import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'mentions_legales.dart'; // Assure-toi que ce fichier existe
import 'dart:ui_web' as ui_web; // Nécessaire pour platformViewRegistry
import 'dart:html' as html; // Nécessaire pour créer l'IFrameElement
import 'package:url_launcher/url_launcher.dart';

// --- Constantes ---
const Color primaryColor = Color(0xFF0D1A26);
const Color accentColor = Color(0xFF26A69A);
const double sectionSpacingDesktop = 50.0;
const double sectionSpacingMobile = 30.0;
const double headerImageHeightDesktop = 400.0;
const double headerImageHeightMobile = 250.0;
const double stickyNavBarHeight = 90.0;
const double logoHeightInStickyBar = 70.0;

// --- Breakpoints pour la responsivité ---
const double mobileBreakpoint = 768.0;
const double tabletBreakpoint = 1200.0; // Moins utilisé dans cet exemple simple

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garage WMécaSolution',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        brightness: Brightness.light,
        fontFamily: 'Arial',
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(),
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
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // Pour le Drawer

  final GlobalKey _presentationKey = GlobalKey();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _carouselKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  int _currentCarouselIndex = 0;
  final List<String> imgList = [
    'assets/images/machine_pneu.jpg',
    'assets/images/moteur_out.jpg',
    'assets/images/moteur_ouvert.jpg',
    'assets/images/plateau1.jpg',
    'assets/images/V_jaune_ouverte.jpg',
    'assets/images/plateau2.jpg',
    'assets/images/voiture_ouverte_2.jpg',
  ];

  void _scrollToSection(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 50), () {
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          alignment: 0.0,
        );
      } else {
        print("Impossible de trouver le contexte pour la clé: $key");
      }
    });
  }

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
                  "+32 496 39 83 27",
                  "tel:+32496398327",
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.email,
                  "E-mail",
                  "wmecasolutionsgc@gmail.com",
                  "mailto:wmecasolutionsgc@gmail.com",
                ),
                const SizedBox(height: 15),
                _buildContactDialogRow(
                  Icons.location_on,
                  "Adresse",
                  "Chaussée de Lille 883 Hertain",
                  null,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < mobileBreakpoint;
    final double currentSectionSpacing =
        isMobile ? sectionSpacingMobile : sectionSpacingDesktop;
    final double currentHeaderImageHeight =
        isMobile ? headerImageHeightMobile : headerImageHeightDesktop;

    return Scaffold(
      key: _scaffoldKey, // Clé pour le Scaffold
      endDrawer: isMobile ? _buildAppDrawer() : null, // Drawer pour mobile
      body: CustomScrollView(
        controller: _scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _buildTopBar(isMobile),
          ),
          SliverToBoxAdapter(
            child: _buildHeaderBackgroundImage(currentHeaderImageHeight),
          ),
          SliverAppBar(
            pinned: true,
            floating: false,
            snap: false,
            automaticallyImplyLeading: false,
            backgroundColor: primaryColor.withOpacity(0.90),
            toolbarHeight: stickyNavBarHeight,
            titleSpacing: 0,
            title: Padding(
              padding: EdgeInsets.only(left: isMobile ? 20.0 : 60.0),
              child: Image.asset(
                'assets/images/Logo_lionel.jpg',
                height: logoHeightInStickyBar,
                errorBuilder: (context, error, stackTrace) => const Text(
                  'Logo',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            actions: <Widget>[
              if (isMobile)
                Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                    onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 45.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildNavLinksList(isMobile),
                  ),
                ),
            ],
          ),
          _buildSliverSectionSpacing(currentSectionSpacing),
          SliverToBoxAdapter(child: _buildPresentationSection(isMobile)),
          _buildSliverSectionSpacing(currentSectionSpacing),
          SliverToBoxAdapter(child: _buildServicesSection(isMobile)),
          _buildSliverSectionSpacing(currentSectionSpacing),
          SliverToBoxAdapter(child: _buildCarouselSection(isMobile)),
          _buildSliverSectionSpacing(currentSectionSpacing),
          SliverToBoxAdapter(child: _buildLocationSection(isMobile)),
          _buildSliverSectionSpacing(currentSectionSpacing),
          SliverToBoxAdapter(child: _buildFooter(isMobile)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactDialog(context),
        backgroundColor: accentColor,
        tooltip: 'Contact Rapide',
        child: const Icon(Icons.contact_phone, color: Colors.white),
      ),
    );
  }

  // Helper pour l'espacement, maintenant avec paramètre
  Widget _buildSliverSectionSpacing(double spacing) {
    return SliverToBoxAdapter(
      child: SizedBox(height: spacing),
    );
  }

  // --- Drawer pour la navigation mobile ---
  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              child: Image.asset(
                // Ou un Text avec le nom du garage
                'assets/images/Logo_lionel.jpg',
                height: 60, // Ajuste la taille du logo dans le drawer
                errorBuilder: (context, error, stackTrace) => const Text(
                  'WmécaSolution',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              )),
          ..._buildNavLinksList(true,
              isDrawer: true), // true pour isMobile, true pour isDrawer
        ],
      ),
    );
  }

  // --- Liste des liens de navigation (utilisé pour la barre et le drawer) ---
  List<Widget> _buildNavLinksList(bool isMobile, {bool isDrawer = false}) {
    final links = [
      {"title": "Accueil", "key": _presentationKey},
      {"title": "Présentation", "key": _presentationKey},
      {"title": "Nos Services", "key": _servicesKey},
      {"title": "Réalisations", "key": _carouselKey},
      {"title": "Où nous trouver", "key": _locationKey},
      {"title": "Nous contacter", "key": _contactKey},
    ];

    return links.map((link) {
      if (isDrawer) {
        return ListTile(
          title: Text(link["title"] as String,
              style: TextStyle(fontSize: 16, color: primaryColor)),
          onTap: () {
            Navigator.pop(context); // Ferme le drawer
            _scrollToSection(link["key"] as GlobalKey);
          },
        );
      } else {
        return _buildNavLink(
          link["title"] as String,
          () => _scrollToSection(link["key"] as GlobalKey),
          isMobile,
        );
      }
    }).toList();
  }

  Widget _buildTopBar(bool isMobile) {
    List<Widget> contactItems = [
      _buildTopContactInfo(Icons.phone, "+32 496 39 83 27", isMobile),
      if (!isMobile) const SizedBox(width: 25),
      _buildTopContactInfo(Icons.email, "wmecasolutionsgc@gmail.com", isMobile),
      if (!isMobile) const SizedBox(width: 25),
      _buildTopContactInfo(
          Icons.location_on, "Chaussée de Lille 883 Hertain", isMobile),
    ];

    return Container(
      color: primaryColor.withOpacity(0.8),
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 15 : 40, vertical: 8),
      child: isMobile
          ? Column(
              // Empile verticalement sur mobile
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contactItems
                  .map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: item,
                      ))
                  .toList(),
            )
          : Row(
              // Reste en ligne sur desktop
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: contactItems),
                // Ajoute ici des icônes de réseaux sociaux si tu en as
              ],
            ),
    );
  }

  Widget _buildTopContactInfo(IconData icon, String text, bool isMobile) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accentColor, size: isMobile ? 16 : 18),
        SizedBox(width: isMobile ? 6 : 8),
        Text(text,
            style:
                TextStyle(color: Colors.white, fontSize: isMobile ? 11 : 13)),
      ],
    );
  }

  Widget _buildHeaderBackgroundImage(double height) {
    return Container(
      height: height,
      width: double.infinity,
      child: Image.asset(
        'assets/images/atelier_grand_plan2.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: height,
          color: Colors.grey[800],
          child: const Center(
            child: Text('Image de fond indisponible',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(String title, VoidCallback onPressed, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8.0 : 15.0),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(50, 30),
          alignment: Alignment.center,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPresentationSection(bool isMobile) {
    final textContent = Expanded(
      flex: isMobile
          ? 0
          : 2, // Sur mobile, ne pas expandre pour que l'image prenne sa place
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            "Présentation de Votre Garage",
            style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: primaryColor),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 20),
          Text(
            "Bienvenue chez WMécaSolutions, votre partenaire de confiance pour l'entretien et la réparation de tous types de véhicules à Hertain et ses environs. Forts de notre expertise et de notre passion pour la mécanique, nous nous engageons à fournir un service de qualité supérieure, honnête et transparent.\n\nQue ce soit pour une simple vidange, une réparation complexe de moteur, un problème hydraulique ou un diagnostic électronique, notre équipe qualifiée est équipée pour répondre à vos besoins avec professionnalisme et efficacité. Votre satisfaction et la sécurité de votre véhicule sont nos priorités absolues.",
            style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.6,
                color: Colors.black87),
            textAlign: isMobile ? TextAlign.left : TextAlign.left,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );

    final imageContent = Expanded(
      flex: isMobile ? 0 : 1, // Sur mobile, ne pas expandre
      child: Padding(
        padding: EdgeInsets.only(
            top: isMobile ? 20.0 : 0.0), // Espace si l'image est en dessous
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/moteur_out.jpg',
            fit: BoxFit.cover,
            height: isMobile ? 250 : 350,
            width: isMobile
                ? double.infinity
                : null, // Prend toute la largeur sur mobile
            errorBuilder: (context, error, stackTrace) => Container(
              height: isMobile ? 250 : 350,
              color: Colors.grey[300],
              child: Center(
                  child: Text('Image Présentation',
                      style: TextStyle(color: Colors.grey[600]))),
            ),
          ),
        ),
      ),
    );

    return Container(
      key: _presentationKey,
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 20 : 80, vertical: 30),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: isMobile
          ? Column(
              // Empiler sur mobile
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [textContent, imageContent],
            )
          : Row(
              // Garder en ligne sur desktop
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                textContent,
                const SizedBox(width: 50),
                imageContent,
              ],
            ),
    );
  }

  Widget _buildServicesSection(bool isMobile) {
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

    return Container(
      key: _servicesKey,
      color: const Color(0xFFF5F5F5),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 80, vertical: isMobile ? 30 : 50),
      constraints: const BoxConstraints(
          maxWidth: 1200), // Garder la contrainte de largeur max
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Nos Services",
            style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: primaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "Nous prenons en charge une large gamme de véhicules et de réparations. Découvrez nos principales expertises :",
            style:
                TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Wrap(
            spacing: isMobile ? 15.0 : 20.0,
            runSpacing: isMobile ? 15.0 : 25.0,
            alignment: WrapAlignment.center,
            children: servicesList.map((service) {
              return _buildServiceItem(
                service['icon'] as IconData,
                service['name'] as String,
                isMobile,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String name, bool isMobile) {
    // Sur mobile, on peut laisser Wrap gérer la largeur ou la fixer un peu moins grande
    double itemWidth =
        isMobile ? (MediaQuery.of(context).size.width * 0.8) : 280;
    if (!isMobile &&
        MediaQuery.of(context).size.width < 900 &&
        MediaQuery.of(context).size.width >= mobileBreakpoint) {
      // Pour tablettes étroites
      itemWidth = 240;
    }

    return Container(
      width:
          itemWidth, // La largeur peut être plus flexible sur mobile si besoin
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: isMobile ? 26 : 30),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection(bool isMobile) {
    return Container(
      key: _carouselKey,
      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 30.0),
      color: Colors.grey[200],
      child: Column(
        children: [
          Text(
            "Nos Réalisations en Images",
            style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: primaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 20 : 30),
          CarouselSlider(
            items: imgList.map((itemPath) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4))
                    ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    itemPath,
                    fit: BoxFit.cover,
                    width: 1000,
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
              height: isMobile ? 350 : 500, // Hauteur réduite sur mobile
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 16 / 9,
              autoPlayCurve: Curves.fastOutSlowIn,
              enableInfiniteScroll: true,
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              viewportFraction:
                  isMobile ? 0.9 : 0.8, // Plus d'une image visible sur mobile
              onPageChanged: (index, reason) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: imgList.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 5.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : primaryColor)
                        .withOpacity(
                            _currentCarouselIndex == entry.key ? 0.9 : 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(bool isMobile) {
    const String iframeElementId = 'google-map-iframe';
    const String googleMapsEmbedUrl =
        'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2532.0135057121715!2d3.2787450770321174!3d50.60828657598596!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x47c2d8c926d4fba9%3A0xf5258fe578a74466!2sChau.%20de%20Lille%20883%2C%207522%20Tournai!5e0!3m2!1sfr!2sbe!4v1745831881043!5m2!1sfr!2sbe';

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      iframeElementId,
      (int viewId) {
        final html.IFrameElement iframeElement = html.IFrameElement()
          ..src = googleMapsEmbedUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        return iframeElement;
      },
    );

    final leftContent = Expanded(
      flex: isMobile ? 0 : 1,
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Text(
            "Accès Facile & Parking",
            style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w600,
                color: primaryColor),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),
          const SizedBox(height: 15),
          Text(
            "Notre garage est idéalement situé sur la Chaussée de Lille à Hertain (Tournai), facilement accessible depuis les axes principaux. Un parking dédié à notre clientèle est disponible devant l'établissement pour votre confort.",
            style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                height: 1.5,
                color: Colors.black87),
            textAlign: isMobile ? TextAlign.center : TextAlign.justify,
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              'assets/images/plateau1.jpg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: isMobile ? 200 : 250,
              errorBuilder: (context, error, stackTrace) => Container(
                height: isMobile ? 200 : 250,
                color: Colors.grey[300],
                child: Center(
                    child: Text('Image Façade',
                        style: TextStyle(color: Colors.grey[600]))),
              ),
            ),
          ),
        ],
      ),
    );

    final rightContent = Expanded(
      flex: isMobile ? 0 : 1,
      child: Column(
        children: [
          if (isMobile)
            const SizedBox(height: 30), // Espace sur mobile si empilé
          Container(
            height: isMobile ? 300 : 400, // Hauteur de carte réduite sur mobile
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: HtmlElementView(viewType: iframeElementId),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            icon: const Icon(Icons.directions),
            label: const Text("Obtenir l'itinéraire"),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: 25, vertical: isMobile ? 12 : 15),
              textStyle: TextStyle(fontSize: isMobile ? 14 : 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              const String destinationAddressEncoded =
                  'Chaussee+de+Lille+883,+7522+Hertain,+Tournai,+Belgium';
              _launchMapsUrl(destinationAddressEncoded);
            },
          ),
        ],
      ),
    );

    return Container(
      key: _locationKey,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 80, vertical: isMobile ? 30 : 50),
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        // Toujours une colonne pour le titre principal
        children: [
          Text(
            "Où nous trouver",
            style: TextStyle(
                fontSize: isMobile ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: primaryColor),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isMobile ? 20 : 30),
          isMobile
              ? Column(
                  // Empiler sur mobile
                  children: [leftContent, rightContent],
                )
              : Row(
                  // Garder en ligne sur desktop
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    leftContent,
                    const SizedBox(width: 40),
                    rightContent,
                  ],
                ),
        ],
      ),
    );
  }

  Future<void> _launchMapsUrl(String destinationAddressEncoded) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$destinationAddressEncoded';
    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
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

  Widget _buildFooter(bool isMobile) {
    final contactColumns = [
      _buildFooterContactColumn(
          Icons.phone, "Téléphone", "+32 496 39 83 27", isMobile),
      if (isMobile) const SizedBox(height: 20),
      _buildFooterContactColumn(
          Icons.email, "E-mail", "wmecasolutionsgc@gmail.com", isMobile),
      if (isMobile) const SizedBox(height: 20),
      _buildFooterContactColumn(Icons.location_on, "Adresse",
          "Chaussée de Lille 883\n7522 Hertain (Tournai)", isMobile),
    ];

    return Container(
      key: _contactKey,
      color: const Color(0xFF1C1C1C),
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : 60, vertical: isMobile ? 30 : 40),
      child: Column(
        children: [
          Image.asset(
            'assets/images/Logo_lionel.JPG',
            height: isMobile ? 60 : 70,
            errorBuilder: (context, error, stackTrace) => const Text(
              'LOGO',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          isMobile
              ? Column(
                  // Empiler les colonnes de contact sur mobile
                  mainAxisSize: MainAxisSize.min,
                  children: contactColumns,
                )
              : Row(
                  // Garder en ligne sur desktop
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: contactColumns,
                ),
          SizedBox(height: isMobile ? 30 : 40),
          const Divider(color: Colors.white30),
          SizedBox(height: isMobile ? 15 : 20),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 15.0,
            runSpacing: 8.0,
            children: [
              Text(
                "© ${DateTime.now().year} WMécaSolutions GC",
                style: TextStyle(
                    color: Colors.white70, fontSize: isMobile ? 11 : 13),
              ),
              Text(
                "- Réalisé par Nikko Verquin",
                style: TextStyle(
                    color: Colors.white70, fontSize: isMobile ? 11 : 13),
              ),
              _buildFooterLink("Mentions légales", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MentionsLegalesPage()),
                );
              }, isMobile),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onPressed, bool isMobile) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        minimumSize: const Size(50, 20),
        alignment: Alignment.center,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: Colors.white70,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isMobile ? 11 : 13,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildFooterContactColumn(
      IconData icon, String title, String value, bool isMobile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: accentColor, size: isMobile ? 26 : 30),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
              color: Colors.white70, fontSize: isMobile ? 12 : 14, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
