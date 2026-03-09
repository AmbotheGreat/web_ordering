import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:web_ordering/src/core/routing/app_router.dart';
import 'package:web_ordering/src/features/menu/data/repositories/menu_repository.dart';
import 'package:web_ordering/src/features/menu/presentation/bloc/master_bloc.dart';
import 'package:web_ordering/src/features/menu/presentation/bloc/product_customization_bloc.dart';
import 'package:web_ordering/src/features/cart/providers/cart_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MasterBloc(MenuRepository())
                ..add(FetchMasterData(branchId: int.tryParse(dotenv.env['BRANCH_ID'] ?? '1') ?? 1)),
        ),
        BlocProvider(
          create: (context) => ProductCustomizationBloc(MenuRepository()),
        ),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        // ignore: deprecated_member_use
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        routerConfig: goRouter,
      ),
    );
  }
}
