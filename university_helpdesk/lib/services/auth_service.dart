import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign in with Email and Password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile if it doesn't exist
      await _ensureUserProfile(result.user!);

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with Email and Password
  Future<User?> register(
    String email,
    String password, {
    String? displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user profile in Firestore
      await _createUserProfile(result.user!, displayName: displayName);

      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Password Reset
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Password reset error: $e");
      return false;
    }
  }

  // Create user profile in Firestore
  Future<void> _createUserProfile(User user, {String? displayName}) async {
    try {
      await _db.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': displayName ?? user.email?.split('@')[0] ?? 'Student',
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
        'phoneNumber': null,
        'studentId': null,
      });
    } catch (e) {
      print("Error creating user profile: $e");
    }
  }

  // Ensure user profile exists (for existing users)
  Future<void> _ensureUserProfile(User user) async {
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _createUserProfile(user);
      }
    } catch (e) {
      print("Error ensuring user profile: $e");
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      print("Error getting user profile: $e");
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.collection('users').doc(uid).update(updates);
      return true;
    } catch (e) {
      print("Error updating user profile: $e");
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
