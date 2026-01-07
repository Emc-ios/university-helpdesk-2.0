// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'screens/auth/login_screen.dart';
// import 'screens/student/home_dashboard.dart';
// import 'screens/admin/admin_dashboard.dart';

// void main() async {
//   // 1. Ensure Flutter bindings are initialized before calling async code
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Initialize Firebase
//   // If you used the CLI (flutterfire configure), use:
//   // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   // If you manually placed google-services.json / GoogleService-Info.plist:
//   await Firebase.initializeApp();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'UniHelp Desk',
//       theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//       // 3. Auth Wrapper: Decides which screen to show based on login status
//       home: const AuthWrapper(),
//     );
//   }
// }

// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         // 1. Waiting for connection
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         // 2. Error
//         if (snapshot.hasError) {
//           return const Scaffold(
//             body: Center(child: Text("Something went wrong.")),
//           );
//         }

//         // 3. User is Logged In
//         if (snapshot.hasData) {
//           User? user = snapshot.data;

//           // CHECK: Is this the "Admin" (Anonymous) or a Student?
//           if (user != null && user.isAnonymous) {
//             return const AdminDashboard();
//           } else {
//             return const HomeDashboard();
//           }
//         }

//         // 4. User is Logged Out
//         return const LoginScreen();
//       },
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/home_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  // 1. Ensure Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  // If you used the CLI (flutterfire configure), use:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If you manually placed google-services.json / GoogleService-Info.plist:
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniHelp Desk',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // 3. Auth Wrapper: Decides which screen to show based on login status
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        // 1. Waiting for Auth connection
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Auth Error
        if (authSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Authentication Error")),
          );
        }

        // 3. User is Logged In -> NOW FETCH ROLE
        if (authSnapshot.hasData) {
          User user = authSnapshot.data!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .snapshots(),
            builder: (context, firestoreSnapshot) {
              // Waiting for Firestore data
              if (firestoreSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Firestore Error or Document doesn't exist
              if (firestoreSnapshot.hasError ||
                  !firestoreSnapshot.hasData ||
                  !firestoreSnapshot.data!.exists) {
                // If doc is missing, default to Home or show error
                return const HomeDashboard();
              }

              // Extract Role
              final userData =
                  firestoreSnapshot.data!.data() as Map<String, dynamic>;
              final String role = userData['role'] ?? 'Student';

              // CHECK ROLE
              if (role == 'Admin') {
                return const AdminDashboard();
              } else {
                return const HomeDashboard();
              }
            },
          );
        }

        // 4. User is Logged Out
        return const LoginScreen();
      },
    );
  }
}