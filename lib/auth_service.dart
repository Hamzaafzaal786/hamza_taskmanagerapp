import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<User?> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      User? user = userCredential.user;
      
      if (user != null) {
        // Create complete user profile
        UserModel newUser = UserModel(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        print('User created successfully: ${user.email}');
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('email-already-in-use');
        case 'invalid-email':
          throw Exception('invalid-email');
        case 'weak-password':
          throw Exception('weak-password');
        default:
          throw Exception(e.message);
      }
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Network error. Please check your connection.');
    }
  }

  // Login with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      print('User logged in: ${userCredential.user?.email}');
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Login error: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'user-not-found':
          throw Exception('user-not-found');
        case 'wrong-password':
          throw Exception('wrong-password');
        case 'invalid-email':
          throw Exception('invalid-email');
        default:
          throw Exception(e.message);
      }
    } catch (e) {
      print('Login unexpected error: $e');
      throw Exception('Login failed. Please try again.');
    }
  }

  // Get current user data from Firestore
  Future<UserModel?> getCurrentUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return UserModel.fromMap(user.uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Get user data error: $e');
      return null;
    }
  }

  // Update user profile - ADD THIS METHOD
  Future<bool> updateUserProfile({
    required String name,
    String phone = '',
    String address = '',
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      Map<String, dynamic> updateData = {
        'name': name,
        'phone': phone,
        'address': address,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      
      await _firestore.collection('users').doc(user.uid).update(updateData);
      
      print('User profile updated successfully');
      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Get user profile image URL (for future feature)
  Future<String?> getUserProfileImage() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;
      
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return (doc.data() as Map<String, dynamic>)['profileImageUrl'] ?? '';
      }
      return null;
    } catch (e) {
      print('Get profile image error: $e');
      return null;
    }
  }

  // Update profile image URL (for future feature)
  Future<bool> updateProfileImage(String imageUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;
      
      await _firestore.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      return true;
    } catch (e) {
      print('Update profile image error: $e');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('User signed out');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
  
  // Check if user is logged in
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }
}