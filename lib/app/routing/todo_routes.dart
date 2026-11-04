import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:taskee/app/routing/app_route.dart';
import 'package:taskee/features/todo/presentation/pages/home/home_screen.dart';

final List<RouteBase> todoRoutes = <RouteBase>[
  GoRoute(
    path: Routes.homeScreen,
    builder: (BuildContext context, GoRouterState state) => const HomeScreen(),
  ),
];
