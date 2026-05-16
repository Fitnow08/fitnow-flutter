import 'package:fitnow/presentation/start/pages/hello.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HelloPage()),
      GoRoute(path: '/hello', builder: (context, state) => const HelloPage()),
    ],
  );
}
