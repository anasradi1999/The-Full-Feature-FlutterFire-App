import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthCubit() : super(AuthInitial());

  // تسجيل الدخول بواسطة البريد + كلمة المرور
  Future<void> login({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.reload(); // تحديث حالة البريد

      if (credential.user!.emailVerified) {
        emit(AuthAuthenticated(userId: credential.user!.uid, email: credential.user!.email!));
      } else {
        await credential.user!.sendEmailVerification();
        emit(AuthEmailVerificationSent());
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "حدث خطأ"));
    }
  }

  // تسجيل الدخول بواسطة Google
  Future<void> loginWithGoogle() async {
    emit(AuthLoading());
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      emit(AuthAuthenticated(
        userId: userCredential.user!.uid,
        email: userCredential.user!.email!,
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  // تسجيل الخروج
  Future<void> logout() async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  // تسجيل مستخدم جديد
  Future<void> register({required String email, required String password}) async {
    emit(AuthLoading());
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user!.sendEmailVerification();
      emit(AuthEmailVerificationSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "حدث خطأ"));
    }
  }

  // إعادة تعيين كلمة المرور
  Future<void> resetPassword({required String email}) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email);
      emit(AuthEmailVerificationSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? "حدث خطأ"));
    }
  }
}