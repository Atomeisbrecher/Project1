// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import "package:google_sign_in/google_sign_in.dart";
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shop/module%20auth/data/repository/auth/auth_repository_remote.dart';

// part '../ViewModel/auth_state.dart';

// class AuthCubit extends Cubit<AuthState> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   AuthCubit(
//     {required OAuthRepositoryRemote repository}
//     ) : 
//     super(AuthInitial());

//   Future<void> createAccountAndLinkGoogleAccount(
//     String email,
//     String password,
//     GoogleSignInAccount googleUser,
//     OAuthCredential credential
//     ) async {
//       emit(AuthLoading());

//       try {
//         await _auth.createUserWithEmailAndPassword(
//           email:googleUser.email,
//           password: password
//         );
//         await _auth.currentUser!.linkWithCredential(credential);
//         await _auth.currentUser!.updateDisplayName(googleUser.displayName);
//         await _auth.currentUser!.updatePhotoURL(googleUser.photoUrl);
//         emit(UserSignedUpAndLinkedWithGoogle());
//       } catch (e) {
//         emit(AuthError(e.toString()));
//       }
//     }

//   Future<void> resetPassword(String email) async {
//     emit(AuthLoading());
//     try {
//       await _auth.sendPasswordResetEmail(email: email);
//       emit(ResetPasswordSent());
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

//    Future<void> signInWithEmail(String email, String password) async {
//     emit(AuthLoading());
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       if (userCredential.user!.emailVerified) {
//         emit(UserSignedIn());
//       } else {
//         await _auth.signOut();
//         emit(AuthError('Email not verified. Please check your email.'));
//         emit(UserNotVerified());
//       }
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }

  // Future<void> signInWithEmailOAuth() async {
  //   emit(AuthLoading());
  //   try {
  //     await _repository.login();
  //   } catch (e) {
  //   } finally {

  //   }
  // }

  // Future<User?> signInWithGoogle() async {
  //   emit(AuthLoading());
  //   try {
  //     await GoogleSignIn.instance.initialize();
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email', 'profile']);

  //     if (googleUser == null) {
  //       emit(AuthError('Google Sign In Failed'));
  //       return null;
  //     }

  //     final GoogleSignInAuthentication googleAuth = googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken,);
      
  //     final UserCredential userCredential = await _auth.signInWithCredential(credential);
  //     final user = userCredential.user;

      
  //     emit(IsNewUser(googleUser: googleUser, credential: credential));
      
  //     return user;

  //   } on FirebaseAuthException catch (error) {
  //     emit(AuthError(error.message!));
  //     return null;
  //   } catch (e) {
  //     emit(AuthError('An exception occured'));
  //     return null;
  //   }
  // }

//   Future<void> signOut() async {
//     emit(AuthLoading());
//     await _auth.signOut();
//     emit(UserSignedOut());
//   }

//   Future<void> signUpWithEmail(
//       String name, String email, String password) async {
//     emit(AuthLoading());
//     try {
//       await _auth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       await _auth.currentUser!.updateDisplayName(name);
//       await _auth.currentUser!.sendEmailVerification();
//       await _auth.signOut();
//       emit(UserSignedUpButNotVerified());
//     } catch (e) {
//       emit(AuthError(e.toString()));
//     }
//   }
// }