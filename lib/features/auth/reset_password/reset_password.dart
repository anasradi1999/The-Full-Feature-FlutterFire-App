import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class ResetPasswordScreen extends StatelessWidget {
  ResetPasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthEmailVerificationSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('إذا كان البريد مسجّلًا، تم إرسال رابط إعادة التعيين'),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.lock_open, size: 80, color: Colors.amber),
                  const SizedBox(height: 24),
                  const Text(
                    'سنرسل رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (value) => (value == null || value.isEmpty) ? 'ادخل البريد الإلكتروني' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (formKey.currentState!.validate()) {
                        context.read<AuthCubit>().resetPassword(email: emailController.text.trim());
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('إرسال رابط إعادة تعيين', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}