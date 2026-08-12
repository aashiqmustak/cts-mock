import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Returns true if the app is currently running on mobile size or a native mobile platform.
bool isMobileLayout(BuildContext context) {
  final isMobilePlatform = defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;
  return MediaQuery.of(context).size.width < 768 || isMobilePlatform;
}
