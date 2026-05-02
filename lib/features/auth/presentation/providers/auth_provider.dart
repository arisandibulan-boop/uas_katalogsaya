import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _errorMessage;

  // ===================== GETTERS =====================
  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  // ===================== INIT =====================
  Future<void> initializeAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      _firebaseUser = _auth.currentUser;
      if (_firebaseUser != null) {
        // Cek apakah email sudah diverifikasi jika ingin ketat
        if (_firebaseUser!.emailVerified) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.emailNotVerified;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ===================== REGISTER =====================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(); // Set status ke loading saat mulai proses
    try {
      // Proses pendaftaran dengan Firebase
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      if (_firebaseUser != null) {
        // Update display name di Firebase
        await _firebaseUser!.updateDisplayName(name);

        // Kirim email verifikasi tapi tidak kita paksa di awal biar demo lancar
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code)); // Map error Firebase ke pesan yang lebih user-friendly
      return false;
    } catch (e) {
      _setError('Gagal mendaftar sistem.');
      return false;
    }
  }

  // ===================== LOGIN EMAIL =====================
  Future<bool> loginWithEmail({required String email, required String password}) async {
    _setLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    }
  }

  // ===================== LOGIN GOOGLE =====================
  // Ini untuk menghilangkan error di login_page.dart
  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Gagal login dengan Google.');
      return false;
    }
  }

  // ===================== LOGOUT =====================
  // Ini untuk menghilangkan error di dashboard_page.dart
  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _firebaseUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ===================== HELPERS =====================
  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Email sudah terdaftar.';
      case 'weak-password': return 'Password minimal 6 karakter.';
      case 'user-not-found': return 'Akun tidak ditemukan.';
      case 'wrong-password': return 'Password salah.';
      default: return 'Kesalahan: $code';
    }
  }
}// Logic Login
