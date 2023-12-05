import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_manager.dart';
import 'user_manager.dart';
import 'detail_user_page.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<Map<String, dynamic>> _users = [];
  // ignore: unused_field
  bool _isLoading = false;
  // ignore: unused_field
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final apiManager = Provider.of<ApiManager>(context);
    final userManager = Provider.of<UserManager>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('User List Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                              color: Color.fromARGB(255, 173, 173, 173)),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          userManager.setAuthToken(null);
                          Navigator.pushReplacementNamed(context, '/');
                        },
                        child: Text(
                          'Logout',
                          style:
                              TextStyle(color: Color.fromARGB(255, 253, 0, 0)),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _fetchUsers(apiManager),
                child: _buildUserList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addUser').then((_) {
            _fetchUsers(
                apiManager); // Mengambil ulang data setelah menambahkan pengguna baru
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _fetchUsers(ApiManager apiManager) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final users = await apiManager.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to get users. Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to fetch users. Error: $e';
      });
    }
  }

  Widget _buildUserList() {
    return _users.isEmpty
        ? Center(child: Text('No users available'))
        : ListView.builder(
            itemCount: _users.length,
            itemBuilder: (BuildContext context, int index) {
              final userData = _users[index];
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete User'),
                        content:
                            Text('Are you sure you want to delete this user?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  // Misalnya:
                  setState(() {
                    _users.removeAt(index);
                  });
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(userData['nama']),
                    subtitle: Text(userData['prodi']),
                    onTap: () {
                      // Navigasi ke halaman detail dengan membawa data pengguna
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserDetailsPage(userData: userData),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
  }
}
