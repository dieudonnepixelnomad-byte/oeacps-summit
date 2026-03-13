import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ResendService {
  // Liste des emails administrateurs
  static const List<String> _adminEmails = [
    'dieudonnegwet86@gmail.com',
    'dieudonnepixelnomad@gmail.com',
    'dev@summitoacps.com', // 3ème email (placeholder)
  ];

  /// Envoie un email via l'API Resend
  Future<bool> sendEmail({
    required List<String> to,
    required String subject,
    required String htmlContent,
    String from = 'OEACP Summit <noreply@summitoacps.com>',
    List<File>? attachments,
    String? replyTo,
  }) async {
    final url = Uri.parse(kResendApiUrl);

    try {
      final List<Map<String, dynamic>> processedAttachments = [];

      if (attachments != null) {
        for (var file in attachments) {
          if (await file.exists()) {
            final bytes = await file.readAsBytes();
            final content = base64Encode(bytes);
            final filename = file.uri.pathSegments.last;

            processedAttachments.add({
              'filename': filename,
              'content': content,
            });
          }
        }
      }

      final Map<String, dynamic> body = {
        'from': from,
        'to': to,
        'subject': subject,
        'html': htmlContent,
        'reply_to': ?replyTo,
        if (processedAttachments.isNotEmpty)
          'attachments': processedAttachments,
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $kResendApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        developer.log('Email sent successfully to $to', name: 'ResendService');
        return true;
      } else {
        developer.log(
          'Failed to send email: ${response.body}',
          name: 'ResendService',
          error: 'Status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      developer.log('Exception sending email', name: 'ResendService', error: e);
      return false;
    }
  }

  /// Traite la demande d'accréditation
  /// 1. Envoie un email aux administrateurs avec les détails et la pièce jointe
  /// 2. Envoie un email de confirmation à l'utilisateur
  Future<bool> sendAccreditationRequest({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String category,
    String? filePath,
  }) async {
    // Préparation de la pièce jointe
    List<File>? files;
    if (filePath != null && filePath.isNotEmpty) {
      files = [File(filePath)];
    }

    // 1. Email aux administrateurs
    final adminSubject =
        '[OEACP Summit] Nouvelle demande d\'accréditation - $firstName $lastName';
    final adminHtml =
        '''
      <h2>Nouvelle demande d'accréditation reçue</h2>
      <p><strong>Prénom :</strong> $firstName</p>
      <p><strong>Nom :</strong> $lastName</p>
      <p><strong>Email :</strong> $email</p>
      <p><strong>Téléphone :</strong> $phone</p>
      <p><strong>Catégorie :</strong> $category</p>
      <hr>
      <p>Le document justificatif est joint à cet email.</p>
    ''';

    final adminSent = await sendEmail(
      to: _adminEmails,
      subject: adminSubject,
      htmlContent: adminHtml,
      attachments: files,
      replyTo: email,
    );

    if (!adminSent) {
      developer.log('Failed to send admin email', name: 'ResendService');
      // On continue quand même pour essayer d'envoyer la confirmation utilisateur ?
      // Non, si les admins ne reçoivent pas, c'est critique.
      return false;
    }

    // 2. Email de confirmation à l'utilisateur
    final userSubject =
        'Confirmation de votre demande d\'accréditation - Sommet OEACP 2026';
    final userHtml =
        '''
      <p>Bonjour <strong>$firstName $lastName</strong>,</p>
      <p>Nous avons bien reçu votre demande d'accréditation pour le 11ème Sommet OEACP.</p>
      <p>Votre dossier est en cours d'examen par nos équipes.</p>
      <p>Vous recevrez une notification dès que votre statut sera mis à jour.</p>
      <br>
      <p>Cordialement,</p>
      <p><strong>Le Secrétariat du Sommet OEACP</strong></p>
    ''';

    // On ne joint pas le document à la confirmation utilisateur pour économiser la bande passante
    final userSent = await sendEmail(
      to: [email],
      subject: userSubject,
      htmlContent: userHtml,
    );

    if (!userSent) {
      developer.log(
        'Failed to send user confirmation email',
        name: 'ResendService',
      );
      // On retourne quand même true car l'admin a reçu la demande, c'est le plus important.
      // L'utilisateur verra l'écran de confirmation dans l'app.
    }

    return adminSent;
  }
}
