import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';
import 'package:classroom_quiz_admin_portal/features/find_school/domain/repos/find_school_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FindSchoolRepoImpl extends FindSchoolRepo {
  final CollectionReference<Map<String, dynamic>> organisations =
      FirebaseFirestore.instance.collection('orgDirectory');

  final CollectionReference<Map<String, dynamic>> users = FirebaseFirestore
      .instance
      .collection('users');

  @override
  Future<List<SchoolModel>> getSchoolsByName({required String query}) async {
    final q = query.trim().toLowerCase();

    Query<Map<String, dynamic>> ref = organisations.where(
      'isActive',
      isEqualTo: true,
    );

    // If empty query, show top schools (first 15 alphabetical)
    if (q.isEmpty) {
      final snap = await ref.orderBy('name').limit(15).get();
      return snap.docs.map((d) => SchoolModel.fromDoc(d)).toList();
    }

    // Prefix search on nameLower
    final snap = await ref
        .orderBy('nameLower')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(15)
        .get();

    return snap.docs.map((d) => SchoolModel.fromDoc(d)).toList();
  }

  @override
  Future<SchoolModel?> getSchoolByCode({required String code}) async {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return null;

    final snap = await organisations
        .where('isActive', isEqualTo: true)
        .where('code', isEqualTo: c)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return SchoolModel.fromDoc(snap.docs.first);
  }
}
