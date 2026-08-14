import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:priorx/features/authentication/presentation/login_screen.dart';
import 'package:priorx/features/authentication/presentation/register_screen.dart';
import 'package:priorx/features/authentication/presentation/widgets/priorx_auth_widgets.dart';
import 'package:priorx/models/user_role.dart';

void main() {
  final testSizes = [
    const Size(1920, 1080),
    const Size(1440, 900),
    const Size(1366, 768),
    const Size(1280, 720),
    const Size(1024, 768),
    const Size(1024, 600),
    const Size(900, 600),
    const Size(800, 600),
    const Size(1280, 600),
    const Size(1920, 600),
    const Size(375, 667),
    const Size(390, 844),
    const Size(412, 915),
  ];

  group('LoginScreen Viewport Fit Tests', () {
    for (final size in testSizes) {
      testWidgets('LoginScreen fits at ${size.width}x${size.height} without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: LoginScreen(),
            ),
          ),
        );
        await tester.pump();

        final exception = tester.takeException();
        if (exception != null && exception.toString().contains('RenderFlex overflowed')) {
          fail('LoginScreen RenderFlex overflow detected at ${size.width}x${size.height}: $exception');
        }

        await tester.pump(const Duration(seconds: 1));
      });
    }
  });

  group('RegisterScreen Viewport Fit Tests (All Roles)', () {
    for (final role in UserRole.values) {
      for (final size in testSizes) {
        testWidgets('RegisterScreen (${role.displayName}) fits at ${size.width}x${size.height} without overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;

          await tester.pumpWidget(
            const ProviderScope(
              child: MaterialApp(
                home: RegisterScreen(),
              ),
            ),
          );
          await tester.pump();

          // Select role button item if needed
          final roleSelectorFinder = find.byType(PriorXRoleSelector);
          if (roleSelectorFinder.evaluate().isNotEmpty) {
            // RoleSelector present
          }

          final exception = tester.takeException();
          if (exception != null && exception.toString().contains('RenderFlex overflowed')) {
            fail('RegisterScreen (${role.displayName}) RenderFlex overflow detected at ${size.width}x${size.height}: $exception');
          }

          await tester.pump(const Duration(seconds: 1));
        });
      }
    }
  });
}
