import 'package:agro_bharat/provider/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings_tab),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context,
              "GENERAL"
              // AppLocalizations.of(context)!.general
          ),
          _buildListTile(
            context,
            icon: Icons.account_circle,
            title: "Account"//AppLocalizations.of(context)!.account,
          ),
          _buildListTile(
            context,
            icon: Icons.notifications,
            title:"Notifications"// AppLocalizations.of(context)!.notifications,
          ),
          _buildListTile(
            context,
            icon: Icons.card_giftcard,
            title: "Coupons"//AppLocalizations.of(context)!.coupons,
          ),
          _buildListTile(
            context,
            icon: Icons.logout,
            title: "Log Out"//AppLocalizations.of(context)!.logout,
          ),
          _buildListTile(
            context,
            icon: Icons.delete,
            title: "Delete Account"//AppLocalizations.of(context)!.delete_account,
          ),
          _buildSectionHeader(context,
              "PREFERENCES"
            // AppLocalizations.of(context)!.preferences
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text(AppLocalizations.of(context)!.change_language),
            onTap: () => _showLanguageDialog(context, localeProvider, currentLocale),
          ),
          _buildSectionHeader(context,"FEEDBACK"
              // AppLocalizations.of(context)!.feedback
          ),
          _buildListTile(
            context,
            icon: Icons.bug_report,
            title: "Report Bug"//AppLocalizations.of(context)!.report_bug,
          ),
          _buildListTile(
            context,
            icon: Icons.feedback,
            title: "Send Feedback"//AppLocalizations.of(context)!.send_feedback,
          ),

        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.subtitle2!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {},
    );
  }

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider, String currentLocale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          backgroundColor: Colors.white,
          title: Text(
            AppLocalizations.of(context)!.selectLanguage,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageOption(context, localeProvider, 'en', 'English', currentLocale),
              _languageOption(context, localeProvider, 'mr', 'मराठी', currentLocale),
              _languageOption(context, localeProvider, 'hi', 'हिंदी', currentLocale),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _languageOption(BuildContext context, LocaleProvider localeProvider, String langCode, String langName, String currentLocale) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
      title: Text(
        langName,
        style: TextStyle(
          fontSize: 16.0,
          color: currentLocale == langCode ? Colors.blueAccent : Colors.black87,
        ),
      ),
      trailing: currentLocale == langCode ? Icon(Icons.check, color: Colors.blueAccent) : null,
      onTap: () {
        localeProvider.setLocale(Locale(langCode));
        Navigator.of(context).pop();
      },
    );
  }

}
