import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MicrosoftIntegrationService {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  Future<void> connectMicrosoft({required String orgId}) async {
    try {
      final callable = _functions.httpsCallable('connectMicrosoft');
      final result = await callable.call({'orgId': orgId});
      final url = result.data['url'];
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('code: ${e.code}');
      debugPrint('message: ${e.message}');
      debugPrint('details: ${e.details}');
    } catch (e) {
      debugPrint('error: $e');
    }
  }

  Future<void> disconnectMicrosoft({required String orgId}) async {
    final callable = _functions.httpsCallable('disconnectMicrosoft');
    await callable.call({'orgId': orgId});
  }
}