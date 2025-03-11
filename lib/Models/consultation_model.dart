class Consultation {
  final String id;
  final String homeownerId;
  final String architectId;
  final String projectId;
  final String projectTitle;
  final DateTime date;
  final String status;
  final String notes;

  Consultation({
    required this.id,
    required this.homeownerId,
    required this.architectId,
    required this.projectId,
    required this.projectTitle,
    required this.date,
    required this.status,
    this.notes = '',
  });

  factory Consultation.fromJson(String id, Map<String, dynamic> json) {
    return Consultation(
      id: id,
      homeownerId: json['homeownerId']?.toString() ?? '',
      architectId: json['architectId']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      projectTitle: json['projectTitle']?.toString() ?? 'Untitled Project',
      date: json['date'] != null
          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
          : DateTime.now(),
      status: json['status']?.toString() ?? 'Pending',
      notes: json['notes']?.toString() ?? '',
    );
  }

  Consultation copyWith({
    String? id,
    String? homeownerId,
    String? architectId,
    String? projectId,
    String? projectTitle,
    DateTime? date,
    String? status,
    String? notes,
  }) {
    return Consultation(
      id: id ?? this.id,
      homeownerId: homeownerId ?? this.homeownerId,
      architectId: architectId ?? this.architectId,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}