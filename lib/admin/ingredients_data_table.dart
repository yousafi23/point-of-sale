import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_ingredient_form.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/ingredient_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';

class IngredientsDataTable extends StatefulWidget {
  const IngredientsDataTable({Key? key}) : super(key: key);

  @override
  _IngredientsDataTableState createState() => _IngredientsDataTableState();
}

class _IngredientsDataTableState extends State<IngredientsDataTable> {
  List<Map<String, dynamic>> ingredientsTableData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Ingredients');

    setState(() {
      ingredientsTableData = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DataTable(
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Unit Cost')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: ingredientsTableData.map<DataRow>((Map<String, dynamic> row) {
            return DataRow(
              cells: [
                DataCell(Text(row['ingredientId'].toString())),
                DataCell(Text(row['name'])),
                DataCell(Text(row['unitCost'].toString())),
                DataCell(Text(row['stock'].toString())),
                DataCell(Text(row['companyName'])),
                DataCell(Text(row['supplierName'])),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.edit),
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AddIngredient(
                                  isUpdate: true,
                                  ingredientModel: IngredientModel.fromMap(row),
                                  ingredientId: row['ingredientId'],
                                )),
                      );
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
                          dbTable: 'Ingredients',
                          where: 'ingredientId=?',
                          id: row['ingredientId'],
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
