import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';

class PrimafitApp extends StatelessWidget {
  const PrimafitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primafit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
