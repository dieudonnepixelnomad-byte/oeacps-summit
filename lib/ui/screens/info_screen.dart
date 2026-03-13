import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import '../widgets/app_image.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  static const Color _green = Color(0xFF169447);
  static const Color _red = Color(0xFFE14B42);
  static const Color _lightGrey = Color(0xFFF1F1F3);
  static const Color _beige = Color(0xFFF1ECCD);
  static const Color _gold = Color(0xFFB88B4A);
  static const Color _textDark = Color(0xFF2F2F2F);
  static const Color _textSoft = Color(0xFF555555);

  static final Uri _eventProgramPdfUrl = Uri.parse(
    "https://summitoacps.com/wp-content/uploads/2026/02/Agenda-11eme-Sommet-oeacp-2026.pdf",
  );

  static final Map<String, Map<String, String>> _localizedContent = {
    'fr': {
      'top_badge':
          '11ème sommet des Chefs d’État et de Gouvernement de l’OEACP',
      'page_title': 'GUIDE DU SOMMET',
      'breadcrumb': 'Accueil / Guide du sommet',
      'hero_title': 'Guide pratique du participant',
      'intro':
          'Ce guide recense les informations logistiques essentielles pour votre séjour à Malabo.',
      'program_title': 'Programme du sommet',
      'program_content':
          'Le programme officiel comprend :\n\n'
          '• 26–27 mars : Forums thématiques et réunions préparatoires\n'
          '• 27–29 mars : Sessions officielles du Sommet\n'
          '• Événements parallèles : Sommet des Affaires et Table ronde de mobilisation des ressources\n\n'
          'Le programme détaillé est disponible dans la section « Programme » du site.',
      'program_button': 'PROGRAMME',
      'location_title': 'Plan du Centre de conférence\nde Sipopo',
      'location_intro':
          'Lieu principal des travaux :\nCentre de Conférences de Sipopo',
      'location_content':
          'Le plan officiel du site comprend :\n\n'
          '• Salle plénière\n'
          '• Salles ministérielles\n'
          '• Espaces bilatéraux\n'
          '• Salle de presse\n'
          '• Zones VIP\n'
          '• Espaces logistiques\n\n'
          'Un plan téléchargeable en PDF est disponible pour faciliter l’orientation des délégations.',
      'location_coming_soon': 'plan bientôt disponible',
      'accreditation_title': 'Procédure\nd’accréditation',
      'accreditation_content':
          'Procédure :\n\n'
          '• Soumission du formulaire en ligne\n'
          '• Vérification administrative\n'
          '• Validation par le comité d’organisation\n'
          '• Notification par email',
      'badge_title': 'Retrait des badges\n(Badge Pickup)',
      'badge_content':
          'Les badges officiels peuvent être retirés :\n\n'
          '• À l’aéroport international à l’arrivée (délégations officielles)\n'
          '• Au Centre d’accréditation à Sipopo\n\n'
          'Une pièce d’identité valide est exigée.',
      'badge_button': 'ESPACE ACCRÉDITATIONS',
      'transport_title': 'Transport : Aéroport – Hôtels',
      'transport_airport':
          'Aéroport d’arrivée :\nAéroport international de Malabo',
      'transport_subtitle': 'Navette officielle',
      'transport_content':
          'Un service de navettes officielles sera assuré :\n\n'
          '• Aéroport → Hôtels partenaires\n'
          '• Hôtels partenaires → Centre de Conférences\n'
          '• Centre de Conférences → Hôtels\n\n'
          'Les horaires seront communiqués aux délégations accréditées.',
      'services_title': 'Services pratiques pour\nvotre séjour à Malabo',
      'services_intro':
          'Afin de garantir un séjour confortable, sécurisé et fluide à l’occasion du 11ᵉ Sommet des Chefs d’État et de Gouvernement de l’OEACP, cette section regroupe les principales informations relatives à l’hébergement, à la restauration, aux services de santé ainsi qu’aux solutions de transport disponibles à Malabo.\n\n'
          'Les établissements et services mentionnés sont situés à proximité du site officiel du Sommet ou dans le centre-ville, et offrent différentes catégories adaptées aux besoins protocolaires, professionnels et logistiques des délégations.',
      'hotels_title': 'Hôtels recommandés',
      'hotels_content':
          'Les établissements ci-dessous sont situés à proximité du site du Sommet ou du centre-ville de Malabo.\n\n'
          '• Hôtels 5 étoiles\n'
          '• Hôtels 4 étoiles\n'
          '• Hôtels 3 étoiles\n'
          '• Autres hôtels',
      'restaurants_title': 'Restaurants sélectionnés',
      'restaurants_content':
          'Malabo propose une offre variée :\n\n'
          '• Cuisine internationale\n'
          '• Cuisine africaine\n'
          '• Cuisine méditerranéenne\n'
          '• Restaurants gastronomiques\n'
          '• Options plus accessibles\n\n'
          'Des recommandations spécifiques seront communiquées.',
      'cars_title': 'Location de voitures et\ntransports locaux',
      'cars_content':
          'Des agences locales et internationales proposent :\n\n'
          '• Véhicules standards\n'
          '• SUV\n'
          '• Véhicules avec chauffeur\n\n'
          'Tarifs variables selon catégorie et durée.',
      'health_title': 'Hôpitaux et Points de Santé',
      'health_content':
          'En cas de besoin médical, les établissements suivants sont accessibles :\n\n'
          '1. Hospital General de Malabo\n'
          '2. Cliniques privées et centres médicaux sont également disponibles en centre-ville.\n'
          '3. Un dispositif médical d’urgence sera présent sur le site du Sommet.',
      'patronage_title': 'Sous le Haut Patronage de',
      'patronage_country': 'la République de Guinée\néquatoriale',
      'patronage_content':
          'Les autorités nationales accompagnent et soutiennent officiellement l’organisation du 11ᵉ Sommet des Chefs d’État et de Gouvernement de l’OEACP à Malabo.',
    },
    'en': {
      'top_badge': '11th Summit of OACPS Heads of State and Government',
      'page_title': 'SUMMIT GUIDE',
      'breadcrumb': 'Home / Summit guide',
      'hero_title': 'Participant practical guide',
      'intro':
          'This guide lists essential logistical information for your stay in Malabo.',
      'program_title': 'Summit programme',
      'program_content':
          'The official programme includes:\n\n'
          '• March 26–27: Thematic forums and preparatory meetings\n'
          '• March 27–29: Official Summit sessions\n'
          '• Side events: Business Summit and Resource Mobilization Roundtable\n\n'
          'The detailed programme is available in the “Programme” section of the site.',
      'program_button': 'PROGRAMME',
      'location_title': 'Sipopo Conference Centre\nMap',
      'location_intro': 'Main venue:\nSipopo Conference Centre',
      'location_content':
          'The official site plan includes:\n\n'
          '• Plenary Hall\n'
          '• Ministerial Rooms\n'
          '• Bilateral Spaces\n'
          '• Press Room\n'
          '• VIP Zones\n'
          '• Logistics Areas\n\n'
          'A downloadable PDF map is available to facilitate delegation orientation.',
      'location_coming_soon': 'map coming soon',
      'accreditation_title': 'Accreditation\nProcedure',
      'accreditation_content':
          'Procedure:\n\n'
          '• Online form submission\n'
          '• Administrative verification\n'
          '• Validation by the organizing committee\n'
          '• Email notification',
      'badge_title': 'Badge Pickup',
      'badge_content':
          'Official badges can be collected:\n\n'
          '• At the international airport upon arrival (official delegations)\n'
          '• At the Accreditation Centre in Sipopo\n\n'
          'A valid ID is required.',
      'badge_button': 'ACCREDITATION AREA',
      'transport_title': 'Transport: Airport – Hotels',
      'transport_airport': 'Arrival airport:\nMalabo International Airport',
      'transport_subtitle': 'Official shuttle',
      'transport_content':
          'An official shuttle service will be provided:\n\n'
          '• Airport → Partner hotels\n'
          '• Partner hotels → Conference Centre\n'
          '• Conference Centre → Hotels\n\n'
          'Schedules will be communicated to accredited delegations.',
      'services_title': 'Practical services for\nyour stay in Malabo',
      'services_intro':
          'To ensure a comfortable, safe, and smooth stay during the 11th Summit of OACPS Heads of State and Government, this section brings together key information regarding accommodation, dining, health services, and transport options available in Malabo.\n\n'
          'The establishments and services mentioned are located near the official Summit venue or in the city centre, and offer categories adapted to the protocol, professional, and logistical needs of delegations.',
      'hotels_title': 'Recommended hotels',
      'hotels_content':
          'The establishments below are located near the Summit venue or in Malabo city centre.\n\n'
          '• 5-star hotels\n'
          '• 4-star hotels\n'
          '• 3-star hotels\n'
          '• Other hotels',
      'restaurants_title': 'Selected restaurants',
      'restaurants_content':
          'Malabo offers a varied selection:\n\n'
          '• International cuisine\n'
          '• African cuisine\n'
          '• Mediterranean cuisine\n'
          '• Gourmet restaurants\n'
          '• More accessible options\n\n'
          'Specific recommendations will be communicated.',
      'cars_title': 'Car rental and\nlocal transport',
      'cars_content':
          'Local and international agencies offer:\n\n'
          '• Standard vehicles\n'
          '• SUVs\n'
          '• Chauffeur-driven vehicles\n\n'
          'Rates vary depending on category and duration.',
      'health_title': 'Hospitals and Health Points',
      'health_content':
          'In case of medical need, the following facilities are accessible:\n\n'
          '1. Malabo General Hospital\n'
          '2. Private clinics and medical centres are also available in the city centre.\n'
          '3. An emergency medical unit will be present on the Summit site.',
      'patronage_title': 'Under the High Patronage of',
      'patronage_country': 'the Republic of\nEquatorial Guinea',
      'patronage_content':
          'National authorities officially accompany and support the organization of the 11th Summit of OACPS Heads of State and Government in Malabo.',
    },
    'es': {
      'top_badge': '11.º Cumbre de Jefes de Estado y de Gobierno de la OACPS',
      'page_title': 'GUÍA DE LA CUMBRE',
      'breadcrumb': 'Inicio / Guía de la cumbre',
      'hero_title': 'Guía práctica del participante',
      'intro':
          'Esta guía recopila la información logística esencial para su estancia en Malabo.',
      'program_title': 'Programa de la cumbre',
      'program_content':
          'El programa oficial incluye:\n\n'
          '• 26–27 de marzo: Foros temáticos y reuniones preparatorias\n'
          '• 27–29 de marzo: Sesiones oficiales de la Cumbre\n'
          '• Eventos paralelos: Cumbre de Negocios y Mesa Redonda de Movilización de Recursos\n\n'
          'El programa detallado está disponible en la sección “Programa” del sitio.',
      'program_button': 'PROGRAMA',
      'location_title': 'Mapa del Centro de Conferencias\nde Sipopo',
      'location_intro': 'Lugar principal:\nCentro de Conferencias de Sipopo',
      'location_content':
          'El plano oficial del recinto incluye:\n\n'
          '• Sala de Plenarios\n'
          '• Salas Ministeriales\n'
          '• Espacios Bilaterales\n'
          '• Sala de Prensa\n'
          '• Zonas VIP\n'
          '• Áreas Logísticas\n\n'
          'Hay un mapa PDF descargable para facilitar la orientación de las delegaciones.',
      'location_coming_soon': 'mapa próximamente',
      'accreditation_title': 'Procedimiento\nde Acreditación',
      'accreditation_content':
          'Procedimiento:\n\n'
          '• Envío del formulario en línea\n'
          '• Verificación administrativa\n'
          '• Validación por el comité organizador\n'
          '• Notificación por correo electrónico',
      'badge_title': 'Recogida de Gafetes',
      'badge_content':
          'Los gafetes oficiales se pueden recoger:\n\n'
          '• En el aeropuerto internacional a la llegada (delegaciones oficiales)\n'
          '• En el Centro de Acreditación en Sipopo\n\n'
          'Se requiere un documento de identidad válido.',
      'badge_button': 'ZONA DE ACREDITACIÓN',
      'transport_title': 'Transporte: Aeropuerto – Hoteles',
      'transport_airport':
          'Aeropuerto de llegada:\nAeropuerto Internacional de Malabo',
      'transport_subtitle': 'Transporte oficial',
      'transport_content':
          'Se proporcionará un servicio de transporte oficial:\n\n'
          '• Aeropuerto → Hoteles asociados\n'
          '• Hoteles asociados → Centro de Conferencias\n'
          '• Centro de Conferencias → Hoteles\n\n'
          'Los horarios se comunicarán a las delegaciones acreditadas.',
      'services_title': 'Servicios prácticos para\nsu estancia en Malabo',
      'services_intro':
          'Para garantizar una estancia cómoda, segura y sin contratiempos durante la 11.ª Cumbre de Jefes de Estado y de Gobierno de la OACPS, esta sección reúne información clave sobre alojamiento, restauración, servicios sanitarios y opciones de transporte disponibles en Malabo.\n\n'
          'Los establecimientos y servicios mencionados están ubicados cerca del lugar oficial de la Cumbre o en el centro de la ciudad, y ofrecen categorías adaptadas a las necesidades protocolarias, profesionales y logísticas de las delegaciones.',
      'hotels_title': 'Hoteles recomendados',
      'hotels_content':
          'Los establecimientos siguientes están ubicados cerca del lugar de la Cumbre o en el centro de Malabo.\n\n'
          '• Hoteles de 5 estrellas\n'
          '• Hoteles de 4 estrellas\n'
          '• Hoteles de 3 estrellas\n'
          '• Otros hoteles',
      'restaurants_title': 'Restaurantes seleccionados',
      'restaurants_content':
          'Malabo ofrece una variada selección:\n\n'
          '• Cocina internacional\n'
          '• Cocina africana\n'
          '• Cocina mediterránea\n'
          '• Restaurantes gastronómicos\n'
          '• Opciones más accesibles\n\n'
          'Se comunicarán recomendaciones específicas.',
      'cars_title': 'Alquiler de coches y\ntransporte local',
      'cars_content':
          'Agencias locales e internacionales ofrecen:\n\n'
          '• Vehículos estándar\n'
          '• SUV\n'
          '• Vehículos con conductor\n\n'
          'Las tarifas varían según la categoría y la duración.',
      'health_title': 'Hospitales y Puntos de Salud',
      'health_content':
          'En caso de necesidad médica, están accesibles los siguientes centros:\n\n'
          '1. Hospital General de Malabo\n'
          '2. Clínicas privadas y centros médicos también están disponibles en el centro de la ciudad.\n'
          '3. Una unidad médica de emergencia estará presente en el lugar de la Cumbre.',
      'patronage_title': 'Bajo el Alto Patrocinio de',
      'patronage_country': 'la República\nde Guinea Ecuatorial',
      'patronage_content':
          'Las autoridades nacionales acompañan y apoyan oficialmente la organización de la 11.ª Cumbre de Jefes de Estado y de Gobierno de la OACPS en Malabo.',
    },
  };

  String _t(BuildContext context, String key) {
    final lang = Provider.of<LanguageProvider>(context).currentLanguageCode;
    return _localizedContent[lang]?[key] ??
        _localizedContent['fr']?[key] ??
        key;
  }

  Future<void> _openEventProgramPdf(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLocale;
    final l10n = AppLocalizations(lang);

    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('downloading_program'))),
      );

      // Récupération du dossier
      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getDownloadsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final filename = "Agenda-11eme-Sommet-oeacp-2026.pdf";
      final file = File('${dir.path}/$filename');

      // Téléchargement
      final response = await http.get(_eventProgramPdfUrl);

      if (response.statusCode == 200) {
        // Écriture du fichier
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "${l10n.translate('download_completed')} ${dir.path}",
            ),
          ),
        );

        // Ouverture du fichier
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                "${l10n.translate('cannot_open_file')}: ${result.message}",
              ),
            ),
          );
        }
      } else {
        throw Exception(
          '${l10n.translate('http_error')} ${response.statusCode}',
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text("${l10n.translate('download_error')} ($e)")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopHeader(context),
              _buildHero(context),
              _buildIntroSection(context),
              _buildProgramSection(context),
              _buildLocationSection(context),
              _buildAccreditationSection(context),
              _buildTransportSection(context),
              _buildServicesSection(context),
              _buildPatronageSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    return AppBar(title: Text(_t(context, 'page_title')));
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage(
            'assets/images/dossiers-de-presse-banner.jpg',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.35)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _t(context, 'page_title'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _lightGrey,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      child: Column(
        children: [
          Text(
            _t(context, 'top_badge'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6D5E45),
              fontSize: 15,
              height: 1.6,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            _t(context, 'hero_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildUnderline(_red, width: 60),
          const SizedBox(height: 56),
          Text(
            _t(context, 'intro'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              height: 1.7,
              color: Color(0xFF3D4352),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _lightGrey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftTitle(_t(context, 'program_title'), underlineColor: _red),
          const SizedBox(height: 24),
          _buildBodyText(_t(context, 'program_content')),
          const SizedBox(height: 28),
          _buildPrimaryButton(
            label: _t(context, 'program_button'),
            backgroundColor: _green,
            textColor: Colors.white,
            onTap: () {
              _openEventProgramPdf(context);
            },
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _lightGrey,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 30),
      child: Column(
        children: [
          Text(
            _t(context, 'location_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildUnderline(_red, width: 60),
          const SizedBox(height: 48),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildBodyText(_t(context, 'location_intro')),
          ),
          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: _buildBodyText(_t(context, 'location_content')),
          ),
          const SizedBox(height: 110),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _t(context, 'location_coming_soon'),
              style: const TextStyle(fontSize: 16, color: _textSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccreditationSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _beige,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftTitle(
            _t(context, 'accreditation_title'),
            underlineColor: _gold,
          ),
          const SizedBox(height: 34),
          _buildBodyText(_t(context, 'accreditation_content')),
          const SizedBox(height: 28),
          _buildLeftTitle(_t(context, 'badge_title'), underlineColor: _gold),
          const SizedBox(height: 34),
          _buildBodyText(_t(context, 'badge_content')),
          const SizedBox(height: 28),
          _buildOutlinedAccentButton(
            label: _t(context, 'badge_button'),
            onTap: () {
              context.go('/accreditation');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransportSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _lightGrey,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLeftTitle(_t(context, 'transport_title'), underlineColor: _red),
          const SizedBox(height: 28),
          _buildBodyText(_t(context, 'transport_airport')),
          const SizedBox(height: 34),
          _buildLeftTitle(
            _t(context, 'transport_subtitle'),
            underlineColor: _red,
          ),
          const SizedBox(height: 36),
          _buildBodyText(_t(context, 'transport_content')),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _lightGrey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLeftTitle(
                  _t(context, 'services_title'),
                  underlineColor: _red,
                ),
                const SizedBox(height: 28),
                _buildJustifiedText(_t(context, 'services_intro')),
                const SizedBox(height: 44),
                _buildGreenTitle(_t(context, 'hotels_title')),
                const SizedBox(height: 18),
                _buildBodyText(_t(context, 'hotels_content')),
                const SizedBox(height: 22),

                _buildGreenTitle(_t(context, 'restaurants_title')),
                const SizedBox(height: 18),
                _buildBodyText(_t(context, 'restaurants_content')),
                const SizedBox(height: 34),
                _buildGreenTitle(_t(context, 'cars_title')),
                const SizedBox(height: 18),
                _buildBodyText(_t(context, 'cars_content')),
                const SizedBox(height: 34),
                _buildGreenTitle(_t(context, 'health_title')),
                const SizedBox(height: 18),
                _buildBodyText(_t(context, 'health_content')),
                const SizedBox(height: 22),
                const AppImage('assets/images/guide.jpg', fit: BoxFit.cover),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatronageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFEDEDEF),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 30),
      child: Column(
        children: [
          const SizedBox(height: 6),
          Text(
            _t(context, 'patronage_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A3A3A),
            ),
          ),
          const SizedBox(height: 24),
          const AppImage(
            'assets/images/Teodoro_Obiang.png',
            width: 252,
            height: 300,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 18),
          const AppImage(
            'assets/images/Armoiries@150x.png',
            width: 240,
            height: 240,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 28),
          Text(
            _t(context, 'patronage_country'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              height: 1.2,
              color: _green,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _t(context, 'patronage_content'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftTitle(String text, {required Color underlineColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: const TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: _textDark,
          ),
        ),
        const SizedBox(height: 10),
        _buildUnderline(underlineColor, width: 58),
      ],
    );
  }

  Widget _buildGreenTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        height: 1.1,
        fontWeight: FontWeight.w800,
        color: _green,
      ),
    );
  }

  Widget _buildUnderline(Color color, {double width = 56}) {
    return Container(width: width, height: 4, color: color);
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.6, color: _textSoft),
    );
  }

  Widget _buildJustifiedText(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 16, height: 1.75, color: _textSoft),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 145,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }

  Widget _buildOutlinedAccentButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
