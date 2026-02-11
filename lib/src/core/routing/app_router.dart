import 'package:go_router/go_router.dart';
import 'package:web_ordering/src/features/home/presentation/menu_screen.dart';
import 'package:web_ordering/src/features/home/presentation/welcome_screen.dart';
import 'package:web_ordering/src/features/home/presentation/item_details_screen.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: '/menu', builder: (context, state) => const MenuScreen()),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) {
        final item = state.extra as ItemModel;
        return ItemDetailsScreen(item: item);
      },
    ),
  ],
);
