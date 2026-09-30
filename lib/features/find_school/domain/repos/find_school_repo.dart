import 'package:classroom_quiz_admin_portal/features/find_school/data/models/school_model.dart';

abstract class FindSchoolRepo {
  Future<List<SchoolModel>> getSchoolsByName({required String query});
  Future<SchoolModel?> getSchoolByCode({required String code});
}