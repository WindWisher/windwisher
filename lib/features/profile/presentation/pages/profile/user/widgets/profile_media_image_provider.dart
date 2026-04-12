import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider<Object>? profileMediaImageProvider(String? path) {
  if (path == null || path.trim().isEmpty) {
    return null;
  }
  final trimmedPath = path.trim();
  final uri = Uri.tryParse(trimmedPath);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return NetworkImage(trimmedPath);
  }
  return FileImage(File(trimmedPath));
}
