import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import '../widgets/app_image.dart';

class PressRoomScreen extends StatefulWidget {
  const PressRoomScreen({super.key});

  static const Color _green = Color(0xFF169447);
  static const Color _red = Color(0xFFE14B42);
  static const Color _lightGrey = Color(0xFFF1F1F3);
  static const Color _textDark = Color(0xFF2F2F2F);
  static const Color _textSoft = Color(0xFF4E4E4E);

  static final Uri _kitPressFrZipUrl = Uri.parse(
    "https://summitoacps.com/wp-content/uploads/2026/02/Kit-presse2.zip",
  );

  static final Uri _kitPressEnEsZipUrl = Uri.parse(
    "https://summitoacps.com/wp-content/uploads/2026/03/Kit-presse-Ang-et-Eps.zip",
  );

  static final Map<String, String> _pressRoomDocuments = {
    'fr':
        'https://summitoacps.com/wp-content/uploads/2026/03/Dossier-de-Presse-F27.pdf',
    'en':
        'https://summitoacps.com/wp-content/uploads/2026/02/En_Pitch_OEACP.pdf',
    'es':
        'https://summitoacps.com/wp-content/uploads/2026/03/DP-Version-Esp.pdf',
  };

  static final Map<String, Map<String, String>> _localizedContent = {
    'fr': {
      'page_title': 'SALLE DE PRESSE',
      'breadcrumb': 'Accueil / Salle de Presse',

      'press_kit_title': 'Kit de presse',
      'press_kit_intro':
          'Le Kit Presse met à la disposition des médias et partenaires l’ensemble des ressources nécessaires à une couverture professionnelle de l’événement.\n\n'
          'Cette section centralise les documents de référence, supports visuels et éléments d’information validés par le Comité d’Organisation.',
      'download_press_fr': 'Télécharger kit presse fr',
      'download_press_en_es': 'Télécharger kit presse en, es',

      'documents_title': 'Documents',
      'doc_pitch': 'LE PITCH',
      'doc_press_fr': 'DOSSIER DE PRESSE fr',
      'doc_press_es': 'DOSSIER DE PRESSE es',

      'certified_media_title': 'Médias\ncertifiés',
      'certified_media_content':
          'Bibliothèque officielle de contenus visuels et audiovisuels :\n\n'
          '• Photos institutionnelles HD\n'
          '• Vidéos officielles\n'
          '• Logos et chartes graphiques\n'
          '• Captations événementielles\n'
          '• Supports de communication validés\n\n'
          'Tous les contenus sont certifiés, libres d’utilisation dans un cadre éditorial officiel.',
      'download_media': 'Télécharger les media',

      'faq_title': 'FAQ – Médias &\nPresse',

      'faq_q1': 'Comment obtenir une accréditation presse ?',
      'faq_a1':
          'Les professionnels des médias doivent compléter le formulaire officiel d’accréditation presse disponible dans la section Accréditations.',

      'faq_q2': 'Quels documents sont requis pour l’accréditation ?',
      'faq_a2':
          'Les éléments suivants sont obligatoires :\n\n'
          '• Formulaire complété en majuscules\n'
          '• Copie du passeport valide\n'
          '• Carte professionnelle de presse\n'
          '• Numéro d’enregistrement du matériel',

      'faq_q3': 'Les contenus du kit presse sont-ils libres d’utilisation ?',
      'faq_a3':
          'Oui, les contenus validés dans le kit presse peuvent être utilisés dans le cadre de la couverture éditoriale officielle du Sommet, sous réserve du respect des crédits et consignes de diffusion.',

      'faq_q4': 'Où récupérer les visuels et médias officiels ?',
      'faq_a4':
          'Les médias officiels, visuels institutionnels, logos et vidéos sont disponibles dans la section Médias certifiés.',

      'faq_q5': 'À qui s’adresser pour un besoin presse spécifique ?',
      'faq_a5':
          'Les demandes spécifiques peuvent être adressées au point focal presse ou au comité d’organisation via les contacts officiels communiqués sur le site.',

      'download_start': 'Téléchargement en cours...',
      'download_success': 'Téléchargement terminé.',
      'download_error': 'Erreur de téléchargement.',
      'file_saved': 'Fichier enregistré :',
      'cannot_open_file': 'Impossible d\'ouvrir le fichier',
    },

    'en': {
      'page_title': 'PRESS ROOM',
      'breadcrumb': 'Home / Press Room',

      'press_kit_title': 'Press kit',
      'press_kit_intro':
          'The Press Kit provides media professionals and partners with all resources required for professional event coverage.\n\n'
          'This section centralizes reference documents, visual materials, and information assets validated by the Organizing Committee.',
      'download_press_fr': 'Download press kit fr',
      'download_press_en_es': 'Download press kit en, es',

      'documents_title': 'Documents',
      'doc_pitch': 'THE PITCH',
      'doc_press_fr': 'PRESS KIT fr',
      'doc_press_es': 'PRESS KIT es',

      'certified_media_title': 'Certified\nmedia',
      'certified_media_content':
          'Official library of visual and audiovisual content:\n\n'
          '• Institutional HD photos\n'
          '• Official videos\n'
          '• Logos and brand guidelines\n'
          '• Event recordings\n'
          '• Approved communication materials\n\n'
          'All content is certified and may be used within an official editorial framework.',
      'download_media': 'Download media',

      'faq_title': 'FAQ – Media &\nPress',

      'faq_q1': 'How can I obtain press accreditation?',
      'faq_a1':
          'Media professionals must complete the official press accreditation form available in the Accreditation section.',

      'faq_q2': 'Which documents are required for accreditation?',
      'faq_a2':
          'The following items are mandatory:\n\n'
          '• Form completed in capital letters\n'
          '• Copy of a valid passport\n'
          '• Professional press card\n'
          '• Equipment registration number',

      'faq_q3': 'Are the contents of the press kit free to use?',
      'faq_a3':
          'Yes, the approved contents of the press kit may be used for official editorial coverage of the Summit, subject to compliance with credits and distribution guidelines.',

      'faq_q4': 'Where can I access official visuals and media?',
      'faq_a4':
          'Official media, institutional visuals, logos, and videos are available in the Certified Media section.',

      'faq_q5': 'Who should I contact for a specific press request?',
      'faq_a5':
          'Specific requests may be addressed to the press focal point or to the organizing committee through the official contacts provided on the website.',

      'download_start': 'Downloading...',
      'download_success': 'Download complete.',
      'download_error': 'Download error.',
      'file_saved': 'File saved:',
      'cannot_open_file': 'Cannot open file',
    },

    'es': {
      'page_title': 'SALA DE PRENSA',
      'breadcrumb': 'Inicio / Sala de Prensa',

      'press_kit_title': 'Kit de prensa',
      'press_kit_intro':
          'El Kit de Prensa pone a disposición de los medios y socios todos los recursos necesarios para una cobertura profesional del evento.\n\n'
          'Esta sección centraliza los documentos de referencia, soportes visuales y elementos informativos validados por el Comité de Organización.',
      'download_press_fr': 'Descargar kit de prensa fr',
      'download_press_en_es': 'Descargar kit de prensa en, es',

      'documents_title': 'Documentos',
      'doc_pitch': 'EL PITCH',
      'doc_press_fr': 'DOSSIER DE PRENSA fr',
      'doc_press_es': 'DOSSIER DE PRENSA es',

      'certified_media_title': 'Medios\ncertificados',
      'certified_media_content':
          'Biblioteca oficial de contenidos visuales y audiovisuales:\n\n'
          '• Fotografías institucionales HD\n'
          '• Videos oficiales\n'
          '• Logotipos y manuales de identidad\n'
          '• Coberturas del evento\n'
          '• Soportes de comunicación validados\n\n'
          'Todos los contenidos están certificados y son de libre uso dentro de un marco editorial oficial.',
      'download_media': 'Descargar media',

      'faq_title': 'FAQ – Medios y\nPrensa',

      'faq_q1': '¿Cómo obtener una acreditación de prensa?',
      'faq_a1':
          'Los profesionales de los medios deben completar el formulario oficial de acreditación de prensa disponible en la sección de Acreditaciones.',

      'faq_q2': '¿Qué documentos se requieren para la acreditación?',
      'faq_a2':
          'Los siguientes elementos son obligatorios:\n\n'
          '• Formulario completado en mayúsculas\n'
          '• Copia del pasaporte válido\n'
          '• Carné profesional de prensa\n'
          '• Número de registro del material',

      'faq_q3': '¿Los contenidos del kit de prensa son de libre uso?',
      'faq_a3':
          'Sí, los contenidos validados del kit de prensa pueden utilizarse en el marco de la cobertura editorial oficial de la Cumbre, respetando los créditos y las normas de difusión.',

      'faq_q4': '¿Dónde obtener los visuales y medios oficiales?',
      'faq_a4':
          'Los medios oficiales, visuales institucionales, logotipos y videos están disponibles en la sección de Medios certificados.',

      'faq_q5': '¿A quién dirigirse para una solicitud de prensa específica?',
      'faq_a5':
          'Las solicitudes específicas pueden dirigirse al punto focal de prensa o al comité de organización a través de los contactos oficiales comunicados en el sitio web.',

      'download_start': 'Descargando...',
      'download_success': 'Descarga completa.',
      'download_error': 'Error de descarga.',
      'file_saved': 'Archivo guardado:',
      'cannot_open_file': 'No se puede abrir el archivo',
    },
  };

  @override
  State<PressRoomScreen> createState() => _PressRoomScreenState();
}

class _PressRoomScreenState extends State<PressRoomScreen> {
  String _t(BuildContext context, String key, {bool listen = true}) {
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: listen,
    ).currentLanguageCode;
    return PressRoomScreen._localizedContent[lang]?[key] ??
        PressRoomScreen._localizedContent['fr']?[key] ??
        key;
  }

  Future<void> _downloadKitPressFrZip(BuildContext context) async {
    await _downloadFile(context, PressRoomScreen._kitPressFrZipUrl);
  }

  Future<void> _downloadKitPressEnEsZip(BuildContext context) async {
    await _downloadFile(context, PressRoomScreen._kitPressEnEsZipUrl);
  }

  Future<void> _downloadFile(BuildContext context, Uri url) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final startMsg = _t(context, 'download_start', listen: false);
    final savedMsg = _t(context, 'file_saved', listen: false);
    final cannotOpenMsg = _t(context, 'cannot_open_file', listen: false);
    final errorMsg = _t(context, 'download_error', listen: false);

    // Show persistent banner
    scaffoldMessenger.showMaterialBanner(
      MaterialBanner(
        content: Text(startMsg),
        leading: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => scaffoldMessenger.hideCurrentMaterialBanner(),
            child: const Icon(Icons.close, color: PressRoomScreen._green),
          ),
        ],
      ),
    );

    try {
      // 1. Déterminer le dossier de téléchargement
      Directory? dir;
      if (Platform.isAndroid) {
        // Sur Android, on essaie d'abord le dossier public "Download"
        // Note: getExternalStorageDirectory() donne /storage/emulated/0/Android/data/.../files
        // Pour accéder au dossier public "Download", on utilise souvent un path fixe ou une lib externe.
        // Ici on va utiliser getApplicationDocumentsDirectory par défaut pour la compatibilité,
        // ou getExternalStorageDirectory() si on veut que ce soit accessible via un gestionnaire de fichiers dans le dossier de l'app.
        // Pour une vraie sauvegarde dans "Documents" public sans permission complexe, le plus simple est le dossier de l'app.
        // Mais l'utilisateur a demandé "documents du téléphone".
        // On va utiliser getApplicationDocumentsDirectory() qui est safe.
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      // 2. Télécharger
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. Écrire le fichier
        final filename = url.pathSegments.last;
        final file = File('${dir.path}/$filename');
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('$savedMsg ${file.path}'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Ouvrir',
              onPressed: () {
                OpenFilex.open(file.path).then((result) {
                  if (result.type != ResultType.done) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('$cannotOpenMsg: ${result.message}'),
                      ),
                    );
                  }
                });
              },
            ),
          ),
        );
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('$errorMsg ($e)')));
    } finally {
      // Hide banner when done (success or error)
      scaffoldMessenger.hideCurrentMaterialBanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PressRoomScreen._lightGrey,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopHeader(context),
              _buildHero(context),
              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildPressKitSection(context),
                    const SizedBox(height: 42),
                    _buildDocumentsSection(context),
                    const SizedBox(height: 42),
                    /* _buildFaqSection(context),
                    const SizedBox(height: 32), */
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildTopHeader(BuildContext context) {
    return AppBar(title: Text(_t(context, 'page_title')));
  }

  Widget _buildHero(BuildContext context) {
    return SizedBox(
      height: 195,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AppImage('assets/images/table.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withValues(alpha: 0.28)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPressKitSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t(context, 'press_kit_title')),
        const SizedBox(height: 28),
        _bodyText(_t(context, 'press_kit_intro')),
        const SizedBox(height: 34),
        _greenButton(
          label: _t(context, 'download_press_fr'),
          onTap: () {
            _downloadKitPressFrZip(context);
          },
        ),
        const SizedBox(height: 20),
        _greenButton(
          label: _t(context, 'download_press_en_es'),
          onTap: () {
            _downloadKitPressEnEsZip(context);
          },
        ),
      ],
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t(context, 'documents_title')),
        const SizedBox(height: 34),
        _documentLink(
          _t(context, 'doc_pitch'),
          PressRoomScreen._pressRoomDocuments['en']!,
        ),
        const SizedBox(height: 24),
        _documentLink(
          _t(context, 'doc_press_fr'),
          PressRoomScreen._pressRoomDocuments['fr']!,
        ),
        const SizedBox(height: 24),
        _documentLink(
          _t(context, 'doc_press_es'),
          PressRoomScreen._pressRoomDocuments['es']!,
        ),
      ],
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(_t(context, 'faq_title')),
        const SizedBox(height: 30),

        _faqItem(
          question: _t(context, 'faq_q1'),
          answer: _t(context, 'faq_a1'),
        ),
        _faqDivider(),

        _faqItem(
          question: _t(context, 'faq_q2'),
          answer: _t(context, 'faq_a2'),
        ),
        _faqDivider(),

        _faqItem(
          question: _t(context, 'faq_q3'),
          answer: _t(context, 'faq_a3'),
        ),
        _faqDivider(),

        _faqItem(
          question: _t(context, 'faq_q4'),
          answer: _t(context, 'faq_a4'),
        ),
        _faqDivider(),

        _faqItem(
          question: _t(context, 'faq_q5'),
          answer: _t(context, 'faq_a5'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            height: 1.15,
            fontWeight: FontWeight.w800,
            color: PressRoomScreen._textDark,
          ),
        ),
        const SizedBox(height: 12),
        _underline(),
      ],
    );
  }

  Widget _underline() {
    return Container(width: 58, height: 4, color: PressRoomScreen._red);
  }

  Widget _bodyText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.65,
        color: PressRoomScreen._textSoft,
      ),
    );
  }

  Widget _greenButton({required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: PressRoomScreen._green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _documentLink(String title, String url) {
    return Row(
      children: [
        const Icon(
          Icons.arrow_circle_down_rounded,
          color: PressRoomScreen._green,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              _downloadFile(context, Uri.parse(url));
            },
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: PressRoomScreen._green,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _faqItem({required String question, required String answer}) {
    return Container(
      width: double.infinity,
      color: Colors.white.withValues(alpha: 0.22),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '–$question',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: PressRoomScreen._green,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              height: 1.65,
              color: PressRoomScreen._textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 22),
      height: 1,
      color: Colors.grey.shade300,
    );
  }
}
