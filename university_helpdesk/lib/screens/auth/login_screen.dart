// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
// import '../admin/admin_dashboard.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final AuthService _auth = AuthService();
//   final _formKey = GlobalKey<FormState>();

//   // Text Controllers
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _confirmPassController = TextEditingController();

//   // State Variables
//   bool isRegistering = false;
//   bool isLoading = false;
//   String errorMessage = '';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // 1. App Logo
//                 const Icon(Icons.school, size: 80, color: Colors.blueAccent),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'UniHelp Desk',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 30),

//                 // 2. Email Input
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'University Email',
//                     prefixIcon: Icon(Icons.email),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (val) => val!.isEmpty ? 'Enter an email' : null,
//                 ),
//                 const SizedBox(height: 15),

//                 // 3. Password Input
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'Password',
//                     prefixIcon: Icon(Icons.lock),
//                     border: OutlineInputBorder(),
//                   ),
//                   validator: (val) =>
//                       val!.length < 6 ? 'Password too short' : null,
//                 ),
//                 const SizedBox(height: 15),

//                 // 4. Confirm Password (Registration Only)
//                 if (isRegistering)
//                   TextFormField(
//                     controller: _confirmPassController,
//                     obscureText: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Confirm Password',
//                       prefixIcon: Icon(Icons.lock_outline),
//                       border: OutlineInputBorder(),
//                     ),
//                     validator: (val) {
//                       if (val != _passwordController.text) {
//                         return 'Passwords do not match';
//                       }
//                       return null;
//                     },
//                   ),

//                 // 5. Role Indicator (Fixed for Student Registration)
//                 if (isRegistering)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: Container(
//                       padding: const EdgeInsets.all(10),
//                       color: Colors.blue.shade50,
//                       child: const Row(
//                         children: [
//                           Icon(Icons.person, color: Colors.blue),
//                           SizedBox(width: 10),
//                           Text("Registering as: Student"),
//                         ],
//                       ),
//                     ),
//                   ),

//                 // Error Message Display
//                 if (errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: Text(
//                       errorMessage,
//                       style: const TextStyle(color: Colors.red),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),

//                 const SizedBox(height: 20),

//                 // 6. Login/Register Button
//                 isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 15),
//                         ),
//                         onPressed: () async {
//                           if (_formKey.currentState!.validate()) {
//                             setState(() {
//                               isLoading = true;
//                               errorMessage = '';
//                             });

//                             dynamic result;
//                             if (isRegistering) {
//                               result = await _auth.register(
//                                 _emailController.text,
//                                 _passwordController.text,
//                                 displayName: _emailController.text.split(
//                                   '@',
//                                 )[0],
//                               );
//                             } else {
//                               result = await _auth.signIn(
//                                 _emailController.text,
//                                 _passwordController.text,
//                               );
//                             }

//                             setState(() {
//                               isLoading = false;
//                             });

//                             if (result == null) {
//                               setState(() {
//                                 errorMessage =
//                                     'Authentication failed. Please check credentials.';
//                               });
//                             } else {
//                               // Success is handled by AuthWrapper in main.dart
//                               print("Login Success: ${result.uid}");
//                             }
//                           }
//                         },
//                         child: Text(isRegistering ? 'Register' : 'Login'),
//                       ),

//                 const SizedBox(height: 10),

//                 // 7. Admin Backdoor Button
//                 TextButton(
//                   onPressed: () async {
//                     try {
//                       // Sign in Anonymously
//                       await FirebaseAuth.instance.signInAnonymously();
//                       // Navigation is handled by AuthWrapper, but we force push just in case
//                       if (context.mounted) {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const AdminDashboard(),
//                           ),
//                         );
//                       }
//                     } catch (e) {
//                       print("Admin login error: $e");
//                       if (context.mounted) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Could not sign in: $e")),
//                         );
//                       }
//                     }
//                   },
//                   child: const Text(
//                     "Enter as Admin (Staff Only)",
//                     style: TextStyle(color: Colors.indigo),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // 8. Toggle between Login and Register
//                 TextButton(
//                   onPressed: () {
//                     setState(() {
//                       isRegistering = !isRegistering;
//                       errorMessage = '';
//                     });
//                   },
//                   child: Text(
//                     isRegistering
//                         ? 'Already have an account? Login'
//                         : 'Create a Student Account',
//                   ),
//                 ),

//                 // 9. Forgot Password Link
//                 if (!isRegistering)
//                   TextButton(
//                     onPressed: () => _showPasswordResetDialog(),
//                     child: const Text(
//                       'Forgot Password?',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPasswordResetDialog() {
//     final emailController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reset Password'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Enter your email address and we\'ll send you a password reset link.',
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(
//                 labelText: 'Email',
//                 prefixIcon: Icon(Icons.email),
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               if (emailController.text.trim().isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Please enter your email')),
//                 );
//                 return;
//               }

//               final success = await _auth.resetPassword(
//                 emailController.text.trim(),
//               );
//               if (context.mounted) {
//                 Navigator.pop(context);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text(
//                       success
//                           ? 'Password reset email sent! Check your inbox.'
//                           : 'Failed to send reset email. Please check your email address.',
//                     ),
//                     backgroundColor: success ? Colors.green : Colors.red,
//                   ),
//                 );
//               }
//             },
//             child: const Text('Send Reset Link'),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  // State Variables
  bool isRegistering = false;
  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. App Logo
                const Icon(Icons.school, size: 80, color: Colors.blueAccent),
                const SizedBox(height: 10),
                const Text(
                  'UniHelp Desk',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // 2. Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'University Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                ),
                const SizedBox(height: 15),

                // 3. Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) =>
                      val!.length < 6 ? 'Password too short' : null,
                ),
                const SizedBox(height: 15),

                // 4. Confirm Password (Registration Only)
                if (isRegistering)
                  TextFormField(
                    controller: _confirmPassController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                // Error Message Display
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 20),

                // 6. Login/Register Button
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });

                            dynamic result;
                            try {
                              if (isRegistering) {
                                result = await _auth
                                    .register(
                                      _emailController.text,
                                      _passwordController.text,
                                      displayName: _emailController.text.split(
                                        '@',
                                      )[0],
                                    )
                                    .then((value) {
                                      if (mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    });
                              } else {
                                result = await _auth
                                    .signIn(
                                      _emailController.text,
                                      _passwordController.text,
                                    )
                                    .then((value) {
                                      if (mounted) {
                                        setState(() {
                                          isLoading = false;
                                        });
                                      }
                                    });
                                ;
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                });
                              }
                            }

                            if (result == null && mounted) {
                              setState(() {
                                errorMessage =
                                    'Authentication failed. Please check credentials.';
                              });
                            } else {
                              // Success is handled by AuthWrapper in main.dart
                              print("Login Success");
                            }
                          }
                        },
                        child: Text(isRegistering ? 'Register' : 'Login'),
                      ),

                const SizedBox(height: 10),

                // 8. Toggle between Login and Register
                TextButton(
                  onPressed: () {
                    setState(() {
                      isRegistering = !isRegistering;
                      errorMessage = '';
                    });
                  },
                  child: Text(
                    isRegistering
                        ? 'Already have an account? Login'
                        : 'Create an Account',
                  ),
                ),

                // 9. Forgot Password Link
                if (!isRegistering)
                  TextButton(
                    onPressed: () => _showPasswordResetDialog(),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordResetDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your email address and we\'ll send you a password reset link.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter your email')),
                );
                return;
              }

              final success = await _auth.resetPassword(
                emailController.text.trim(),
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Password reset email sent! Check your inbox.'
                          : 'Failed to send reset email. Please check your email address.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }
}