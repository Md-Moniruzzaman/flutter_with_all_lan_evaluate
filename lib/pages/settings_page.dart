import 'package:flutter/material.dart';
import 'package:flutter_evaluate/services/remote_script_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scriptService = RemoteScriptService();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear Script Cache'),
            subtitle: const Text('Force re-download of business logic on next invoice.'),
            onTap: () async {
              await scriptService.clearCache();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Script cache cleared!')));
              }
            },
          ),
        ],
      ),
    );
  }
}
