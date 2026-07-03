import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleIntegrationService {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> connectGoogle({required String orgId}) async {
    final callable = _functions.httpsCallable('connectGoogle');
    final result = await callable.call({'orgId': orgId});
    final url = result.data['url'];

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  Future<void> disconnectGoogle({required String orgId}) async {
    final callable = _functions.httpsCallable('disconnectGoogle');
    await callable.call({'orgId': orgId});
  }
}
