import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // SignUp User
  Future<String> signupUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        // Register user in Firebase Authentication
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (cred.user != null) {
          print("Utilisateur créé avec UID: ${cred.user!.uid}");

          // Add user to Firestore database
          await _firestore.collection("users").doc(cred.user!.uid).set({
            'name': name,
            'uid': cred.user!.uid,
            'email': email,
          });

          print("Utilisateur ajouté à Firestore ✅");
          res = "success";
        } else {
          res = "Erreur : L'utilisateur est null après inscription ❌";
        }
      } else {
        res = "Veuillez remplir tous les champs";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        res = "Cet e-mail est déjà utilisé.";
      } else if (e.code == 'weak-password') {
        res = "Le mot de passe est trop faible.";
      } else {
        res = e.message ?? "Une erreur s'est produite.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // LogIn User
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Log in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Veuillez remplir tous les champs";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = "Aucun utilisateur trouvé avec cet e-mail.";
      } else if (e.code == 'wrong-password') {
        res = "Mot de passe incorrect.";
      } else {
        res = e.message ?? "Une erreur s'est produite.";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
