
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Register a new user with email and password.
  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign in an existing user.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Sign out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update the signed-in user's password.
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please sign in before changing your password.',
      );
    }

    await user.updatePassword(newPassword);
  }

  // Return the currently signed-in user.
  User? get currentUser => _auth.currentUser;

  // Notify the app whenever authentication state changes.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Reauthenticate when Firebase requires a recent login.
  Future<void> reauthenticate(String currentPassword) async {
    final user = _auth.currentUser;

    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'Please sign in again.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
  }
}
