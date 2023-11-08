import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/users_screen.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/user_model.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

// ignore: must_be_immutable
class AddUser extends StatefulWidget {
  AddUser({this.isUpdate, this.userModel, this.userId, super.key});
  bool? isUpdate;
  UserModel? userModel;
  int? userId;

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final nameCont = TextEditingController();
  final userNameCont = TextEditingController();
  final passCont = TextEditingController();
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate == true && widget.userModel != null) {
      nameCont.text = widget.userModel!.name;
      userNameCont.text = widget.userModel!.userName;
      passCont.text = widget.userModel!.password;
      isAdmin = widget.userModel!.isAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myCustomAppBar(
        'Add User',
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Container(
        margin: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              controller: nameCont,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'User Name',
              ),
              controller: userNameCont,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
              controller: passCont,
            ),
            Row(
              children: [
                const Text('Is Admin:'),
                Switch(
                  value: isAdmin,
                  onChanged: (value) {
                    setState(() {
                      isAdmin = value;
                    });
                  },
                ),
              ],
            ),
            FloatingActionButton.extended(
              onPressed: () async {
                UserModel userModel = UserModel(
                    name: nameCont.text.trim(),
                    userName: userNameCont.text.trim(),
                    password: passCont.text.trim(),
                    isAdmin: isAdmin);

                if (widget.isUpdate == true) {
                  await DatabaseHelper.instance.updateRecord(
                      'Users', userModel.toMap(), 'userId=?', widget.userId!);
                } else {
                  print('scscs');
                  await DatabaseHelper.instance
                      .insertRecord('Users', userModel.toMap());
                }

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const UsersScreen()));
              },
              label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
