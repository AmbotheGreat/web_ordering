import 'package:go_router/go_router.dart';
import 'package:web_ordering/src/features/home/presentation/menu_screen.dart';
import 'package:web_ordering/src/features/home/presentation/welcome_screen.dart';
import 'package:web_ordering/src/features/home/presentation/item_details_screen.dart';
import 'package:web_ordering/src/features/menu/domain/models/item.dart';
import 'package:web_ordering/src/features/cart/presentation/qr_screen.dart';
import 'package:web_ordering/src/features/cart/domain/models/cart_item.dart';

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
    GoRoute(
      path: '/qr',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final orderKey = extra['orderKey'] as String? ?? '';
        final items = extra['items'] as List<CartItem>? ?? [];
        return QrScreen(orderKey: orderKey, items: items);
      },
    ),
  ],
);
