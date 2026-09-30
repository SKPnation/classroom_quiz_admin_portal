import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id; // orgId (doc id)
  final String name;
  final String? nameLower;
  final String? logoUrl;
  final String? code;
  final List<String> allowedDomains;
  final bool isActive;

  const SchoolModel({
    required this.id,
    required this.name,
    this.nameLower,
    this.logoUrl,
    this.code,
    required this.allowedDomains,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'nameLower': nameLower ?? name.toLowerCase(),
      'logoUrl': logoUrl,
      'code': code,
      'allowedDomains': allowedDomains,
      'isActive': isActive,
    };
  }

  factory SchoolModel.fromDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();
    return SchoolModel(
      id: doc.id,
      name: (data['name'] ?? doc.id).toString(),
      nameLower: data['nameLower'] as String?,
      logoUrl: data['logoUrl'] as String?,
      code: data['code'] as String?,
      allowedDomains: (data['allowedDomains'] as List?)?.cast<String>() ?? [],
      isActive: (data['isActive'] as bool?) ?? true,
    );
  }

  factory SchoolModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return SchoolModel(
      // Use docId if provided, otherwise look for 'id' in the json, or default to empty
      id: docId ?? json['id'] ?? '',
      name: (json['name'] ?? '').toString(),
      nameLower: json['nameLower'] as String?,
      logoUrl: json['logoUrl'] as String?,
      code: json['code'] as String?,
      allowedDomains: (json['allowedDomains'] as List?)?.cast<String>() ?? [],
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
