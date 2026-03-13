import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:summitoeacp/data/resend_service.dart';
import 'package:summitoeacp/providers/language_provider.dart';
import 'package:summitoeacp/l10n/app_localizations.dart';
import '../../models/accreditation.dart';
import '../theme/app_theme.dart';

class AccreditationScreen extends StatefulWidget {
  const AccreditationScreen({super.key});

  @override
  State<AccreditationScreen> createState() => _AccreditationScreenState();
}

class _AccreditationScreenState extends State<AccreditationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedCategory;
  final List<FakeDocument> _documents = [];
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _getCategoriesData(AppLocalizations l10n) {
    return [
      {
        'label': l10n.translate('cat_head_state'),
        'subtitle': l10n.translate('cat_head_state_desc'),
        'icon': Icons.account_balance,
      },
      {
        'label': l10n.translate('cat_minister'),
        'subtitle': l10n.translate('cat_minister_desc'),
        'icon': Icons.gavel,
      },
      {
        'label': l10n.translate('cat_delegate'),
        'subtitle': l10n.translate('cat_delegate_desc'),
        'icon': Icons.assignment_ind,
      },
      {
        'label': l10n.translate('cat_parliamentarian'),
        'subtitle': l10n.translate('cat_parliamentarian_desc'),
        'icon': Icons.how_to_vote,
      },
      {
        'label': l10n.translate('cat_first_lady'),
        'subtitle': l10n.translate('cat_first_lady_desc'),
        'icon': Icons.emoji_events,
      },
      {
        'label': l10n.translate('cat_press'),
        'subtitle': l10n.translate('cat_press_desc'),
        'icon': Icons.mic,
      },
      {
        'label': l10n.translate('cat_private_sector'),
        'subtitle': l10n.translate('cat_private_sector_desc'),
        'icon': Icons.business_center,
      },
      {
        'label': l10n.translate('cat_civil_society'),
        'subtitle': l10n.translate('cat_civil_society_desc'),
        'icon': Icons.groups,
      },
      {
        'label': l10n.translate('cat_observer'),
        'subtitle': l10n.translate('cat_observer_desc'),
        'icon': Icons.remove_red_eye,
      },
      {
        'label': l10n.translate('cat_support_staff'),
        'subtitle': l10n.translate('cat_support_staff_desc'),
        'icon': Icons.support_agent,
      },
      {
        'label': l10n.translate('cat_security_armed'),
        'subtitle': l10n.translate('cat_security_armed_desc'),
        'icon': Icons.security,
      },
      {
        'label': l10n.translate('cat_security_unarmed'),
        'subtitle': l10n.translate('cat_security_unarmed_desc'),
        'icon': Icons.shield,
      },
      {
        'label': l10n.translate('cat_protocol'),
        'subtitle': l10n.translate('cat_protocol_desc'),
        'icon': Icons.event_note,
      },
    ];
  }

  final Uri _accreditationPdfUrl = Uri.parse(
    "https://summitoacps.com/wp-content/uploads/2026/03/FICHE-DACCREDITATION-EN.pdf",
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Provider.of<LanguageProvider>(
      context,
      listen: false,
    ).currentLocale;
    final l10n = AppLocalizations(lang);
    _selectedCategory ??= _getCategoriesData(l10n).first['label'] as String;
  }

  Future<void> _openAccreditationPdf(AppLocalizations l10n) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(l10n.translate('downloading_program'))),
      );

      Directory? dir;
      if (Platform.isAndroid) {
        dir = await getDownloadsDirectory();
      }
      dir ??= await getApplicationDocumentsDirectory();

      final filename = "FICHE-DACCREDITATION-EN.pdf";
      final file = File('${dir.path}/$filename');

      final response = await http.get(_accreditationPdfUrl);

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              "${l10n.translate('download_completed')} ${dir.path}",
            ),
          ),
        );

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

  void _openCategorySelector(AppLocalizations l10n) {
    final categories = _getCategoriesData(l10n);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.translate('label_category_protocol'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];

                      return ListTile(
                        leading: Icon(cat['icon']),
                        title: Text(cat['label']),
                        subtitle: Text(cat['subtitle']),
                        trailing: _selectedCategory == cat['label']
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCategory = cat['label'] as String;
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = result.files.single;

      setState(() {
        _documents.add(
          FakeDocument(
            id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
            filename: file.name,
            fileType: _mapFileType(file.extension),
            sizeLabel: '${(file.size / 1024 / 1024).toStringAsFixed(2)} MB',
            path: file.path,
          ),
        );
      });
    }
  }

  DocFileType _mapFileType(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return DocFileType.jpg;
      case 'png':
        return DocFileType.png;
      case 'pdf':
      default:
        return DocFileType.pdf;
    }
  }

  void _removeDocument(FakeDocument doc) {
    setState(() {
      _documents.remove(doc);
    });
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requis';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Requis';
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email invalide';
    }

    return null;
  }

  Future<void> _submitForm(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null || _selectedCategory!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une catégorie.')),
      );
      return;
    }

    if (_documents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('error_docs_required'))),
      );
      return;
    }

    if (_documents.first.path == null || _documents.first.path!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le fichier sélectionné est invalide.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await context
          .read<ResendService>()
          .sendAccreditationRequest(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            category: _selectedCategory!,
            filePath: _documents.first.path,
          );

      if (!mounted) return;

      if (success) {
        context.go('/accreditation/confirmation', extra: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de l'envoi. Veuillez réessayer."),
          ),
        );
      }
    } catch (e, stackTrace) {
      await FirebaseCrashlytics.instance.recordError(e, stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).currentLocale;
    final l10n = AppLocalizations(lang);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          l10n.translate('accreditation_page_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(l10n.translate('procedure_intro')),
            const SizedBox(height: 12),
            _Bullet(l10n.translate('procedure_step1')),
            _Bullet(l10n.translate('procedure_step2')),
            _Bullet(l10n.translate('procedure_step3')),
            _Bullet(l10n.translate('procedure_step4')),
            _Bullet(l10n.translate('procedure_step5')),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openAccreditationPdf(l10n),
              icon: const Icon(Icons.download),
              label: Text(l10n.translate('download_form_btn')),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.translate('procedure_warning'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.deepOrangeAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 20, color: Colors.grey),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: l10n.translate('label_firstname'),
                          hint: 'Jean',
                          validator: _requiredValidator,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: l10n.translate('label_lastname'),
                          hint: 'Dupont',
                          validator: _requiredValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _emailController,
                    label: l10n.translate('label_email'),
                    hint: 'exemple@email.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(
                    controller: _phoneController,
                    label: l10n.translate('label_phone'),
                    hint: '+123 456 789',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: _requiredValidator,
                  ),
                  const SizedBox(height: 24),

                  Text(
                    l10n.translate('label_category'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.translate('select_placeholder'),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _openCategorySelector(l10n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategory ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    l10n.translate('label_required_doc'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _pickDocument,
                    borderRadius: BorderRadius.circular(12),
                    child: DottedBorder(
                      color: AppTheme.primaryColor.withValues(alpha: 0.5),
                      strokeWidth: 1.5,
                      dashPattern: const [6, 4],
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (_documents.isEmpty) ...[
                              Icon(
                                Icons.cloud_upload,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.translate('upload_placeholder'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'PDF ou JPG (max. 5MB)',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ] else ...[
                              ..._documents.map(
                                (doc) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          doc.filename,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                        onPressed: () => _removeDocument(doc),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Ajouter un autre fichier',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitForm(l10n),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.translate('submit_request_btn'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.send_rounded, size: 20),
                            ],
                          ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    IconData? prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: _inputDecoration(hint: hint, prefixIcon: prefixIcon),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: const Color(0xFF6B7280))
          : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppTheme.primaryColor),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(height: 1.4)),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
