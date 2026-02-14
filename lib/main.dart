import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/logic/products_cubit.dart';
import 'package:the_full_feature_flutterfire_app/features/home/products/show_products.dart';

import 'features/auth/logic/auth_cubit.dart';
import 'features/home/home.dart';
import 'features/home/notifications/logic/notifications_cubit.dart';
import 'features/home/notifications/notifications_page.dart';
import 'firebase_options.dart';
import 'features/auth/login/login.dart';
import 'features/auth/signin/signin.dart';
import 'features/auth/reset_password/reset_password.dart';
import 'features/home/products/add_products.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // تهيئة الفلاتر قبل أي async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // تهيئة Firebase

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit(),
        ),
        BlocProvider<ProductsCubit>(
          create: (_) => ProductsCubit(),
        ),      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'متجر FlutterFire',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      routes: {
        '/login': (_) =>  LoginScreen(),
        '/register': (_) =>  RegisterScreen(),
        '/reset_password': (_) =>  ResetPasswordScreen(),
        '/home': (_) => const HomeProductsPage(),
        '/notifications': (_) => const NotificationsTab(),
        '/show_products': (_) =>  const ProductsTab(),
        '/add_products': (_) => const AddProductPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // مراقبة حالة الدخول
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // أثناء التحميل
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = snapshot.data;

          if (user != null && user.emailVerified) {
            // إذا المستخدم مسجل دخول و البريد الإلكتروني مفعل
            return const HomeProductsPage(); // الصفحة الرئيسية مع التبويبين
          }

          return LoginScreen(); // إذا لم يسجل دخول
        },
      ),
    );
  }
}