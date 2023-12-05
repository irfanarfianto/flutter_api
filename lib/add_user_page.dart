import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';

class AddUserPage extends StatelessWidget {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController prodiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final ApiManager apiManager =
        Provider.of<ApiManager>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: namaController,
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextFormField(
              controller: prodiController,
              decoration: InputDecoration(
                labelText: 'Program Studi',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final String nama = namaController.text;
                final String prodi = prodiController.text;

                try {
                  await apiManager.addUser(nama, prodi);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('User added successfully!'),
                  ));
                  Navigator.pop(context);
                } catch (e) {
                  print('Failed to add user: $e');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to add user: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Add User'),
            ),
          ],
        ),
      ),
    );
  }
}
