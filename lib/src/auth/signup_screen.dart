import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import '../blocs/auth/signup_cubit.dart';
import '../components/custom_text_field.dart';
import '../components/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.signupCreateAccountTitle)),
      body: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.status == SignupStatus.error) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          } else if (state.status == SignupStatus.success) {
            // Router will handle redirect automatically once auth state changes
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppLocalizations.of(context)!.signupJoinUs,
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.signupSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  CustomTextField(
                    controller: _nameController,
                    labelText: AppLocalizations.of(context)!.signupNameLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
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
                  if (state.status == SignupStatus.submitting)
                    const Center(child: CircularProgressIndicator())
                  else
                    CustomButton(
                      text: AppLocalizations.of(context)!.signupButton,
                      onPressed: () {
                        context.read<SignupCubit>().signupWithCredentials(
                          name: _nameController.text,
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
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
