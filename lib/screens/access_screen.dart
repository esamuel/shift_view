import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AccessScreen extends StatefulWidget {
  const AccessScreen({Key? key}) : super(key: key);

  @override
  _AccessScreenState createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> {
  bool _isGoogleLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Shift View',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isGoogleLoading ? null : _signInWithGoogle,
              icon: _isGoogleLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.login),
              label: Text(
                _isGoogleLoading ? 'Signing in...' : 'Sign in with Google',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        try {
          final userCredential =
              await FirebaseAuth.instance.signInWithPopup(googleProvider);
          print(
              'Successfully signed in with popup: ${userCredential.user?.email}');
        } on FirebaseAuthException catch (e) {
          print('Firebase Auth Error: ${e.code} - ${e.message}');
          await FirebaseAuth.instance.signInWithRedirect(googleProvider);
          final userCredential =
              await FirebaseAuth.instance.getRedirectResult();
          print(
              'Successfully signed in with redirect: ${userCredential.user?.email}');
        }
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (error) {
      print('Error during Google sign in: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign In Error: ${error.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }
}
