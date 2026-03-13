class Speaker {
  final String id;
  final String fullName;
  final String titleRole;
  final String organization;
  final String countryCode;
  final String avatarUrl;
  final String bio;
  final String contactEmail;
  final String websiteUrl;
  final bool isFeatured;
  bool isBookmarked;

  Speaker({
    required this.id,
    required this.fullName,
    required this.titleRole,
    required this.organization,
    required this.countryCode,
    required this.avatarUrl,
    required this.bio,
    required this.contactEmail,
    required this.websiteUrl,
    this.isFeatured = false,
    this.isBookmarked = false,
  });

  Speaker copyWith({
    String? fullName,
    String? titleRole,
    String? organization,
    String? bio,
  }) {
    return Speaker(
      id: id,
      fullName: fullName ?? this.fullName,
      titleRole: titleRole ?? this.titleRole,
      organization: organization ?? this.organization,
      countryCode: countryCode,
      avatarUrl: avatarUrl,
      bio: bio ?? this.bio,
      contactEmail: contactEmail,
      websiteUrl: websiteUrl,
      isFeatured: isFeatured,
      isBookmarked: isBookmarked,
    );
  }

  factory Speaker.fromCustomApiJson(Map<String, dynamic> json) {
    // Photo: ton plugin renvoie "photo"
    final String photo = (json['photo'] as String?)?.trim().isNotEmpty == true
        ? (json['photo'] as String)
        : 'assets/images/speaker_placeholder.png';

    // Bio: liste renvoie bio_plain, détail renvoie bio_plain + bio_html
    final String bioPlain = (json['bio_plain'] as String?) ?? '';
    final String bioHtml = (json['bio_html'] as String?) ?? '';
    final String bio = bioPlain.isNotEmpty ? bioPlain : bioHtml;

    // Socials: [{type,url}] → extraire website si présent
    String website = '';
    final socials = json['socials'];
    if (socials is List) {
      for (final item in socials) {
        if (item is Map<String, dynamic>) {
          final type = (item['type'] as String?)?.toLowerCase().trim() ?? '';
          final url = (item['url'] as String?)?.trim() ?? '';
          if (url.isEmpty) continue;

          if (type == 'website' || type == 'site' || type == 'web') {
            website = url;
            break;
          }
        }
      }
    }

    return Speaker(
      id: json['id'].toString(),
      fullName: (json['name'] as String?)?.trim().isNotEmpty == true
          ? (json['name'] as String)
          : 'Nom inconnu',
      titleRole: (json['designation'] as String?) ?? '',
      organization: (json['company'] as String?) ?? '',
      countryCode:
          (json['country_code'] as String?) ??
          'BE', // optionnel (si tu l’ajoutes plus tard)
      avatarUrl: photo,
      bio: bio,
      contactEmail:
          (json['email'] as String?) ??
          '', // optionnel (si tu l’ajoutes plus tard)
      websiteUrl: website,
      isFeatured:
          json['is_featured'] == true, // optionnel (si tu l’ajoutes plus tard)
      isBookmarked: false,
    );
  }

  // Tu peux garder fromWordpressJson si tu veux, mais si tout passe par Custom API,
  // tu peux progressivement le supprimer une fois stable.
}
