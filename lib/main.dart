// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers/auth_provider.dart';
// import 'providers/cart_provider.dart';
// import 'providers/product_provider.dart';
// import 'providers/invoice_provider.dart';
// import 'screens/billing/billing_screen.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => CartProvider()),
//         ChangeNotifierProvider(create: (_) => ProductProvider()),
//         ChangeNotifierProvider(create: (_) => InvoiceProvider()),
//       ],
//       child: const BillingApp(),
//     ),
//   );
// }

// class BillingApp extends StatelessWidget {
//   const BillingApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Billing App',
//       debugShowCheckedModeBanner: false,
//        locale: const Locale('en', 'IN'),
//       supportedLocales: const [
//         Locale('en', 'IN'),
//         Locale('ta', 'IN'),
//       ],
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF1565C0),
//         ),
//         useMaterial3: true,
//       ),
//       home: const BillingScreen(), // ← இது இருக்கிறதா?
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/invoice_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/billing/billing_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider()),
      ChangeNotifierProvider(create: (_) => InvoiceProvider()),
    ],
    child: const BillingApp(),
  ));
}

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Billing App',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'IN'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
        fontFamily: 'Roboto',
        iconTheme: const IconThemeData(
        size: 24,
      ),
      ),
      home: const _SplashRouter(),
    );
  }
}

class _SplashRouter extends StatefulWidget {
  const _SplashRouter();
  @override
  State<_SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<_SplashRouter> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();
    if (!mounted) return;
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              auth.isLoggedIn ? const BillingScreen() : const LoginScreen(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1565C0),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, color: Colors.white, size: 72),
          SizedBox(height: 20),
          Text('Billing App',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800)),
          SizedBox(height: 30),
          CircularProgressIndicator(color: Colors.white),
        ],
      )),
    );
  }
}
