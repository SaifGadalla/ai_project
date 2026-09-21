import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<User?> signUp({
    required String email,
    required String password,
    String? name,
  });

  Future<User?> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
