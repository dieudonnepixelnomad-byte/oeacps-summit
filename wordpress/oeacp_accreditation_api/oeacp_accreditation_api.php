<?php
/**
 * Plugin Name: OEACP Summit Accreditation API
 * Description: Gère les demandes d'accréditation via API REST (envoi email admin + confirmation utilisateur + pièce jointe).
 * Version: 1.9
 * Author: Dieudonne GWET BIKOUN
 */

if (!defined('ABSPATH')) {
    exit;
}

class OEACP_Accreditation_API {

    public function __construct() {
        add_action('rest_api_init', array($this, 'register_api_routes'));
    }

    public function register_api_routes() {
        register_rest_route('oeacp/v1', '/accreditation', array(
            'methods'  => 'POST',
            'callback' => array($this, 'handle_accreditation_request'),
            'permission_callback' => '__return_true',
        ));
    }

    public function handle_accreditation_request($request) {
        $params = $request->get_params();
        $files  = $request->get_file_params();

        $required_fields = array('first_name', 'last_name', 'email', 'category');

        foreach ($required_fields as $field) {
            if (empty($params[$field])) {
                return new WP_REST_Response(array(
                    'success' => false,
                    'message' => "Le champ {$field} est obligatoire.",
                    'data' => null,
                ), 400);
            }
        }

        $first_name   = sanitize_text_field($params['first_name']);
        $last_name    = sanitize_text_field($params['last_name']);
        $email        = sanitize_email($params['email']);
        $phone        = sanitize_text_field($params['phone'] ?? '');
        $category     = sanitize_text_field($params['category']);

        if (!is_email($email)) {
            return new WP_REST_Response(array(
                'success' => false,
                'message' => 'Adresse email invalide.',
                'data' => null,
            ), 400);
        }

        $attachments = array();
        $upload_error = null;

        if (!empty($files['document']) && !empty($files['document']['tmp_name'])) {
            $file = $files['document'];

            if (!empty($file['error']) && $file['error'] !== UPLOAD_ERR_OK) {
                return new WP_REST_Response(array(
                    'success' => false,
                    'message' => 'Erreur lors de l’upload du document.',
                    'data' => null,
                ), 400);
            }

            $max_size = 5 * 1024 * 1024; // 5 MB
            if (!empty($file['size']) && $file['size'] > $max_size) {
                return new WP_REST_Response(array(
                    'success' => false,
                    'message' => 'Le fichier dépasse la taille maximale autorisée (5 MB).',
                    'data' => null,
                ), 400);
            }

            $allowed_mimes = array(
                'pdf'  => 'application/pdf',
                'jpg'  => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'png'  => 'image/png',
            );

            $check_filetype = wp_check_filetype_and_ext(
                $file['tmp_name'],
                $file['name'],
                $allowed_mimes
            );

            if (empty($check_filetype['type']) || empty($check_filetype['ext'])) {
                return new WP_REST_Response(array(
                    'success' => false,
                    'message' => 'Type de fichier non autorisé (PDF, JPG, JPEG, PNG uniquement).',
                    'data' => null,
                ), 400);
            }

            if (!function_exists('wp_handle_upload')) {
                require_once(ABSPATH . 'wp-admin/includes/file.php');
            }

            $uploaded_file = wp_handle_upload($file, array('test_form' => false));

            if (isset($uploaded_file['file'])) {
                $attachments[] = $uploaded_file['file'];
            } else {
                $upload_error = $uploaded_file['error'] ?? 'Erreur inconnue lors de l’upload';
                error_log('OEACP Accreditation: upload error - ' . $upload_error);
            }
        }

        $admin_emails = array_unique(array_filter(array(
            get_option('admin_email'),
            'dieudonnegwet86@gmail.com',
            'dieudonnepixelnomad@gmail.com',
        )));

        if (empty($admin_emails)) {
            return new WP_REST_Response(array(
                'success' => false,
                'message' => 'Aucun email administrateur n’est configuré.',
                'data' => null,
            ), 500);
        }

        $site_name  = wp_specialchars_decode(get_bloginfo('name'), ENT_QUOTES);
        $from_email = get_option('admin_email');

        $headers = array(
            'Content-Type: text/plain; charset=UTF-8',
            "From: {$site_name} <{$from_email}>",
        );

        $admin_headers = $headers;
        $admin_headers[] = "Reply-To: {$first_name} {$last_name} <{$email}>";

        $admin_subject = "[OEACP Summit] Nouvelle demande d'accréditation - {$first_name} {$last_name}";

        $admin_message  = "Une nouvelle demande d'accréditation a été reçue :\n\n";
        $admin_message .= "Prénom : {$first_name}\n";
        $admin_message .= "Nom : {$last_name}\n";
        $admin_message .= "Email : {$email}\n";
        $admin_message .= "Téléphone : {$phone}\n";
        $admin_message .= "Catégorie : {$category}\n";

        if (!empty($attachments)) {
            $admin_message .= "Document joint : Oui\n";
        } else {
            $admin_message .= "Document joint : Non";
            if ($upload_error) {
                $admin_message .= " (Erreur upload : {$upload_error})";
            }
            $admin_message .= "\n";
        }

        $admin_sent = wp_mail(
            $admin_emails,
            $admin_subject,
            $admin_message,
            $admin_headers,
            $attachments
        );

        $user_headers = $headers;
        $user_headers[] = "Reply-To: {$site_name} <{$from_email}>";

        $user_subject = "Confirmation de votre demande d'accréditation - Sommet OEACP 2026";
        $user_message  = "Bonjour {$first_name} {$last_name},\n\n";
        $user_message .= "Nous avons bien reçu votre demande d'accréditation pour le 11ème Sommet OEACP.\n";
        $user_message .= "Votre dossier est en cours d'examen par nos équipes.\n\n";
        $user_message .= "Vous recevrez une notification dès que votre statut sera mis à jour.\n\n";
        $user_message .= "Cordialement,\nLe Secrétariat du Sommet OEACP";

        $user_sent = wp_mail(
            $email,
            $user_subject,
            $user_message,
            $user_headers
        );

        if (!$admin_sent) {
            error_log('OEACP Accreditation: échec envoi email admin.');
        }

        if (!$user_sent) {
            error_log("OEACP Accreditation: échec envoi email utilisateur à {$email}.");
        }

        if ($admin_sent && $user_sent) {
            return new WP_REST_Response(array(
                'success' => true,
                'message' => 'Demande envoyée avec succès.',
                'data' => array(
                    'id' => time(),
                    'status' => 'pending',
                    'admin_email_sent' => true,
                    'user_confirmation_sent' => true,
                ),
            ), 200);
        }

        return new WP_REST_Response(array(
            'success' => false,
            'message' => 'La demande a été reçue, mais un ou plusieurs emails n’ont pas pu être envoyés.',
            'data' => array(
                'id' => time(),
                'status' => 'pending',
                'admin_email_sent' => (bool) $admin_sent,
                'user_confirmation_sent' => (bool) $user_sent,
            ),
        ), 500);
    }
}

new OEACP_Accreditation_API();