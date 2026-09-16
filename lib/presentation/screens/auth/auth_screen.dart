import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/presentation/controller/auth/login_cubit.dart';
import 'package:ai_project/presentation/components/custom_text_field.dart';
import 'package:ai_project/presentation/components/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.status == LoginStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          } else if (state.status == LoginStatus.success) {
            // Router will handle redirect, but we can also manually push if needed.
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.authWelcomeBack,
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.authSignInSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _emailController,
                    labelText: AppLocalizations.of(context)!.authEmailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    controller: _passwordController,
                    labelText: AppLocalizations.of(context)!.authPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  if (state.status == LoginStatus.submitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomButton(
                      text: AppLocalizations.of(context)!.authSignInButton,
                      onPressed: () {
                        context.read<LoginCubit>().loginWithCredentials(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                      },
                    ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    child: Text(AppLocalizations.of(context)!.authSignUpPrompt),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
