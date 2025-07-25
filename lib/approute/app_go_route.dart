import 'package:dicabs/approute/routes.dart';
import 'package:dicabs/screen/dashboard/ui/dashboard.dart';
import 'package:dicabs/screen/login/ui/login_page.dart';
import 'package:dicabs/screen/mainpage/bloc/form_bloc.dart';
import 'package:dicabs/screen/mainpage/repo/main_page_repo.dart';
import 'package:dicabs/screen/mainpage/ui/main_page.dart';
import 'package:dicabs/screen/permission/ui/permission_page.dart';
import 'package:dicabs/screen/splash/splash_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

late final MainPageRepository dataRepository;

String baseUrl = 'http://180.211.118.210:90/api/Home/v1';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      name: "splashPage",
      path: AppRoutes.splashPage,
      builder: (context, state) => BlocProvider(
        create: (_) => FormBloc(dataRepository)..add(LoadCategories()),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      name: 'permissionPage',
      path: AppRoutes.permissionPage,
      builder: (context, state) => const PermissionPage(),
    ),
    // GoRoute(
    //   name: 'dashboard',
    //   path: AppRoutes.dashboard,
    //   builder: (context, state) =>  Dashboard(userCode: '', salesCode: '',),
    // ),
    GoRoute(
      name: 'dashboard',
      path: AppRoutes.dashboard,
      builder: (context, state) {
        final data = state.extra as Map<String, String>?;

        return Dashboard(
          userCode: data?['userCode'] ?? '',
          salesCode: data?['salesCode'] ?? '',
        );
      },
    ),
    GoRoute(
      name: 'mainPage',
      path: AppRoutes.mainPage,
      builder: (context, state) => MainPage(
        userCode: '',
        salesCode: '',
      ),
    ),
    GoRoute(
      name: 'loginPage',
      path: AppRoutes.loginPage,
      builder: (context, state) => LoginPage(),
    ),
  ],
);
