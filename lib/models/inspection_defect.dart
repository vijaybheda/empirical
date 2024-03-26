class InspectionDefect {
  final String? id;
  final String? name;
  final String? description;
  final String? status;
  final String? inspectionId;
  final String? defectId;
  final String? defectName;
  final String? defectDescription;
  final String? defectStatus;
  final String? defectType;
  final String? defectTypeId;
  final String? defectTypeName;
  final String? defectTypeDescription;
  final String? defectTypeStatus;
  final String? defectTypeCreatedAt;
  final String? defectTypeUpdatedAt;
  final String? defectTypeDeletedAt;
  final String? defectCreatedAt;
  final String? defectUpdatedAt;
  final String? defectDeletedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  InspectionDefect({
    this.id,
    this.name,
    this.description,
    this.status,
    this.inspectionId,
    this.defectId,
    this.defectName,
    this.defectDescription,
    this.defectStatus,
    this.defectType,
    this.defectTypeId,
    this.defectTypeName,
    this.defectTypeDescription,
    this.defectTypeStatus,
    this.defectTypeCreatedAt,
    this.defectTypeUpdatedAt,
    this.defectTypeDeletedAt,
    this.defectCreatedAt,
    this.defectUpdatedAt,
    this.defectDeletedAt,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory InspectionDefect.fromJson(Map<String, dynamic> json) {
    return InspectionDefect(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        status: json['status'],
        inspectionId: json['inspection_id'],
        defectId: json['defect_id'],
        defectName: json['defect_name'],
        defectDescription: json['defect_description'],
        defectStatus: json['defect_status'],
        defectType: json['defect_type'],
        defectTypeId: json['defect_type_id'],
        defectTypeName: json['defect_type_name'],
        defectTypeDescription: json['defect_type_description'],
        defectTypeStatus: json['defect_type_status'],
        defectTypeCreatedAt: json['defect_type_created_at'],
        defectTypeUpdatedAt: json['defect_type_updated_at'],
        defectTypeDeletedAt: json['defect_type_deleted_at'],
        defectCreatedAt: json['defect_created_at'],
        defectUpdatedAt: json['defect_updated_at'],
        defectDeletedAt: json['defect_deleted_at'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        deletedAt: json['deleted_at']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'inspection_id': inspectionId,
      'defect_id': defectId,
      'defect_name': defectName,
      'defect_description': defectDescription,
      'defect_status': defectStatus,
      'defect_type': defectType,
      'defect_type_id': defectTypeId,
      'defect_type_name': defectTypeName,
      'defect_type_description': defectTypeDescription,
      'defect_type_status': defectTypeStatus,
      'defect_type_created_at': defectTypeCreatedAt,
      'defect_type_updated_at': defectTypeUpdatedAt,
      'defect_type_deleted_at': defectTypeDeletedAt,
      'defect_created_at': defectCreatedAt,
      'defect_updated_at': defectUpdatedAt,
      'defect_deleted_at': defectDeletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'deleted_at': deletedAt
    };
  }

  // copyWith
  InspectionDefect copyWith({
    String? id,
    String? name,
    String? description,
    String? status,
    String? inspectionId,
    String? defectId,
    String? defectName,
    String? defectDescription,
    String? defectStatus,
    String? defectType,
    String? defectTypeId,
    String? defectTypeName,
    String? defectTypeDescription,
    String? defectTypeStatus,
    String? defectTypeCreatedAt,
    String? defectTypeUpdatedAt,
    String? defectTypeDeletedAt,
    String? defectCreatedAt,
    String? defectUpdatedAt,
    String? defectDeletedAt,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) {
    return InspectionDefect(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      inspectionId: inspectionId ?? this.inspectionId,
      defectId: defectId ?? this.defectId,
      defectName: defectName ?? this.defectName,
      defectDescription: defectDescription ?? this.defectDescription,
      defectStatus: defectStatus ?? this.defectStatus,
      defectType: defectType ?? this.defectType,
      defectTypeId: defectTypeId ?? this.defectTypeId,
      defectTypeName: defectTypeName ?? this.defectTypeName,
      defectTypeDescription:
          defectTypeDescription ?? this.defectTypeDescription,
      defectTypeStatus: defectTypeStatus ?? this.defectTypeStatus,
      defectTypeCreatedAt: defectTypeCreatedAt ?? this.defectTypeCreatedAt,
      defectTypeUpdatedAt: defectTypeUpdatedAt ?? this.defectTypeUpdatedAt,
      defectTypeDeletedAt: defectTypeDeletedAt ?? this.defectTypeDeletedAt,
      defectCreatedAt: defectCreatedAt ?? this.defectCreatedAt,
      defectUpdatedAt: defectUpdatedAt ?? this.defectUpdatedAt,
      defectDeletedAt: defectDeletedAt ?? this.defectDeletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
