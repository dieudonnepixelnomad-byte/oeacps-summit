enum AccreditationStatus { pending, inReview, approved, rejected }

enum DocFileType { pdf, jpg, png }

class FakeDocument {
  final String id;
  final String filename;
  final DocFileType fileType;
  final String sizeLabel;
  final String? path; // Ajout du path local pour l'upload

  FakeDocument({
    required this.id,
    required this.filename,
    required this.fileType,
    required this.sizeLabel,
    this.path,
  });
}

class AccreditationRequest {
  final String id;
  final String firstName;
  final String lastName;
  final String nationality;
  final String email;
  final String phone;
  final String category;
  final List<FakeDocument> documents;
  AccreditationStatus status;
  final DateTime createdAt;

  AccreditationRequest({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.nationality,
    required this.email,
    required this.phone,
    required this.category,
    required this.documents,
    this.status = AccreditationStatus.pending,
    required this.createdAt,
  });
}
