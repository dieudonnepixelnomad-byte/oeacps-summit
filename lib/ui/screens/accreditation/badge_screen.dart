import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../../../models/accreditation.dart';

class BadgeScreen extends StatefulWidget {
  const BadgeScreen({super.key});

  @override
  State<BadgeScreen> createState() => _BadgeScreenState();
}

class _BadgeScreenState extends State<BadgeScreen> {
  // In a real app, we would get the user's ID/Email from auth provider.
  // Here, we'll simulate by checking the last submitted request or a hardcoded one if none.
  // For the POC, we'll ask the repo for any request, or simulate one.

  // Actually, better: we can store the email in local storage or just ask the user to "Simulate Login"
  // For V1 POC, let's just fetch the *last submitted* request from the mock repo if possible,
  // or show a "Enter your email" field to retrieve it.

  final _emailController = TextEditingController();
  AccreditationRequest? _request;
  bool _checked = false;
  bool _isLoading = false;

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    /* final req = await context
        .read<WordpressService>()
        .getAccreditationStatus(_emailController.text); */
    setState(() {
      _request = null;
      _checked = true;
      _isLoading = false;
    });
  }

  void _simulateValidation() {
    // Helper for demo: force status to Approved
    if (_request != null) {
      // Update in repository
      /* context.read<WordpressService>().updateAccreditationStatus(
          _request!.id, AccreditationStatus.approved); */

      // Update local state
      setState(() {
        _request = AccreditationRequest(
          id: _request!.id,
          firstName: _request!.firstName,
          lastName: _request!.lastName,
          nationality: _request!.nationality,
          email: _request!.email,
          phone: _request!.phone,
          category: _request!.category,
          documents: _request!.documents,
          status: AccreditationStatus.approved, // FORCE APPROVED
          createdAt: _request!.createdAt,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('my_badge_title'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (!_checked || _request == null) ...[
              const Icon(Icons.badge, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(
                l10n.translate('track_request_title'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.translate('email_field_label'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _checkStatus,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(l10n.translate('check_status_btn')),
              ),
              if (_checked && _request == null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    l10n.translate('no_request_found'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ] else ...[
              // Request Found
              _buildStatusCard(_request!, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AccreditationRequest request, AppLocalizations l10n) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (request.status) {
      case AccreditationStatus.pending:
        statusColor = Colors.orange;
        statusText = l10n.translate('status_pending');
        statusIcon = Icons.hourglass_empty;
        break;
      case AccreditationStatus.inReview:
        statusColor = Colors.blue;
        statusText = l10n.translate('status_review');
        statusIcon = Icons.search;
        break;
      case AccreditationStatus.approved:
        statusColor = Colors.green;
        statusText = l10n.translate('status_approved');
        statusIcon = Icons.check_circle;
        break;
      case AccreditationStatus.rejected:
        statusColor = Colors.red;
        statusText = l10n.translate('status_rejected');
        statusIcon = Icons.cancel;
        break;
    }

    return Column(
      children: [
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      statusText.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoRow(
                  l10n.translate('label_name'),
                  '${request.firstName} ${request.lastName}',
                ),
                _buildInfoRow(
                  l10n.translate('label_category'),
                  request.category,
                ),
                _buildInfoRow(l10n.translate('label_email'), request.email),
                const SizedBox(height: 24),
                if (request.status == AccreditationStatus.approved) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: 'OEACP-BADGE-${request.id}',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('qr_code_instruction'),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ] else ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('badge_pending_msg'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            setState(() {
              _request = null;
              _checked = false;
            });
          },
          child: const Text('RECHERCHER UNE AUTRE DEMANDE'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
