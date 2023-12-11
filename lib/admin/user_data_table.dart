// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_user_form.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/user_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';

class UserDataTable extends StatefulWidget {
  const UserDataTable({super.key});

  @override
  _UserDataTableState createState() => _UserDataTableState();
}

class _UserDataTableState extends State<UserDataTable> {
  List<Map<String, dynamic>> usersTableData = [];
  int counter = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Users');

    setState(() {
      usersTableData = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.purple.shade400),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('UserName')),
            DataColumn(label: Text('Is Admin')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: usersTableData.map<DataRow>((Map<String, dynamic> row) {
            UserModel userModel = UserModel.fromMap(row);
            counter++;

            return DataRow(
              color: counter.isEven
                  ? MaterialStateProperty.resolveWith((states) => Colors.white)
                  : MaterialStateProperty.resolveWith(
                      (states) => Colors.purple[100]),
              cells: [
                DataCell(Text(userModel.userId.toString())),
                DataCell(Text(userModel.name)),
                DataCell(Text(userModel.userName)),
                DataCell(Text(userModel.isAdmin.toString())),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.edit),
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AddUser(
                                isUpdate: true,
                                userModel: UserModel.fromMap(row),
                                userId: row['userId'],
                              )));
                    },
                  ),
                ),
                DataCell(
                  GestureDetector(
                    child: const Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 255, 0, 0),
                    ),
                    onTap: () async {
                      final bool confirmed =
                          await showDeleteConfirmationDialog(context);
                      if (confirmed) {
                        final databaseHelper = DatabaseHelper.instance;
                        await databaseHelper.deleteRecord(
                          dbTable: 'Users',
                          where: 'userId=?',
                          id: row['userId'],
                        );
                        await _loadData();
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
