import 'package:flutter/material.dart';
import 'package:himtika_mobile_information/core/supabase_config.dart';

class RolesTestPage extends StatelessWidget {
  const RolesTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final future = SupabaseConfig.client.from('roles').select();

    return Scaffold(
      appBar: AppBar(title: const Text('Roles Testing')),
      body: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final roles = snapshot.data!;
          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              return ListTile(
                title: Text(role['name']),
                subtitle: Text('Group: ${role['group_name']}'),
              );
            },
          );
        },
      ),
    );
  }
}