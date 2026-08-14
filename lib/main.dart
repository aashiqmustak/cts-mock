import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'repositories/data_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey, // ignore: deprecated_member_use
  );

  // Initialize data from Supabase / Seed database
  await DataRepository.instance.initialize();

  runApp(const ProviderScope(child: PriorXApp()));
}

class PriorXApp extends ConsumerWidget {
  const PriorXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PriorX',
      debugShowCheckedModeBanner: false, 
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => ResponsiveBreakpoints.builder(
        child: child!,
        breakpoints: [
          const Breakpoint(start: 0,    end: 480,  name: MOBILE),
          const Breakpoint(start: 481,  end: 768,  name: TABLET),
          const Breakpoint(start: 769,  end: 1100, name: DESKTOP),
          const Breakpoint(start: 1101, end: 1920, name: '4K'),
        ],
      ),
    );
  }
}
