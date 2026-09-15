import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ai_project/l10n/app_localizations.dart';
import '../blocs/theme/theme_cubit.dart';
import '../blocs/locale/locale_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.drawerSettings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(AppLocalizations.of(context)!.settingsDarkTheme),
            trailing: Switch(
              value: isDark,
              onChanged: (value) {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),
          ExpansionTile(
            leading: const Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.settingsLanguage),
            subtitle: Text(
              AppLocalizations.of(context)!.settingsLanguageCurrent,
            ),
            children: [
              RadioGroup(
                groupValue: context.watch<LocaleCubit>().state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LocaleCubit>().setLocale(Locale(value));
                  }
                },
                child: RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                ),
              ),
              RadioGroup(
                groupValue: context.watch<LocaleCubit>().state.languageCode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<LocaleCubit>().setLocale(Locale(value));
                  }
                },
                child: RadioListTile<String>(
                  title: const Text('العربية'),
                  value: 'ar',
                ),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              AppLocalizations.of(context)!.settingsSignOut,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Sign out logic
              context.go('/auth');
            },
          ),
        ],
      ),
    );
  }
}
