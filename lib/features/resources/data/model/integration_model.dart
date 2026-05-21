import 'package:flutter/material.dart';

class IntegrationModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool connected;
  final String actionText;
  final VoidCallback onTap;

  IntegrationModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.connected,
    required this.actionText,
    required this.onTap,
  });
}