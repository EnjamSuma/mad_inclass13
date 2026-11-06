import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signOut();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage('Sign out failed: ${e.message ?? e.code}');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Unable to sign out. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _changePassword() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    bool isUpdating = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Text('Change Password'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Current Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your current password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Use at least 6 characters';
                            }
                            if (value == currentPasswordController.text) {
                              return 'Choose a different password';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isUpdating
                        ? null
                        : () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              isUpdating = true;
                            });

                            try {
                              // Verify the current password first.
                              await _authService.reauthenticate(
                                currentPasswordController.text,
                              );

                              // Update the Firebase password.
                              await _authService.updatePassword(
                                newPasswordController.text,
                              );

                              if (!dialogContext.mounted) return;

                              Navigator.pop(dialogContext);

                              if (mounted) {
                                _showMessage(
                                  'Password updated successfully!',
                                  success: true,
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              if (!mounted) return;

                              String message;
                              switch (e.code) {
                                case 'wrong-password':
                                case 'invalid-credential':
                                  message = 'Current password is incorrect.';
                                  break;
                                case 'weak-password':
                                  message = 'Choose a stronger password.';
                                  break;
                                case 'requires-recent-login':
                                  message =
                                      'Please sign out and sign in again.';
                                  break;
                                case 'network-request-failed':
                                  message = 'Check your internet connection.';
                                  break;
                                default:
                                  message =
                                      e.message ?? 'Unable to update password.';
                              }

                              _showMessage(message);
                            } catch (_) {
                              if (mounted) {
                                _showMessage(
                                  'Something went wrong. Try again.',
                                );
                              }
                            } finally {
                              if (dialogContext.mounted) {
                                setDialogState(() {
                                  isUpdating = false;
                                });
                              }
                            }
                          },
                    child: isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      // Wait until the dialog is fully removed before disposal.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        currentPasswordController.dispose();
        newPasswordController.dispose();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 100, color: Colors.teal),
              const SizedBox(height: 20),
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Signed in as:'),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'No email available',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _changePassword,
                  icon: const Icon(Icons.lock_reset),
                  label: const Text('Change Password'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signOut,
                  icon: const Icon(Icons.logout),
                  label: _isLoading
                      ? const Text('Signing out...')
                      : const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
