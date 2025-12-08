import 'package:auto_route/auto_route.dart';
import 'package:saprbar_desktop/core/router/router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
          page: HomeRoute.page,
          path: '/',
        ),
  ];
}