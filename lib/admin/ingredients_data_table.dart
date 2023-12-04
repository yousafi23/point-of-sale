import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_ingredient_form.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/ingredient_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';

class IngredientsDataTable extends StatefulWidget {
  const IngredientsDataTable({super.key});

  @override
  _IngredientsDataTableState createState() => _IngredientsDataTableState();
}

class _IngredientsDataTableState extends State<IngredientsDataTable> {
  List<Map<String, dynamic>> ingredientsTableData = [];
  int counter = 1;

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
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.purple.shade400),
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Unit Cost')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: ingredientsTableData.map<DataRow>((Map<String, dynamic> row) {
            IngredientModel ingredientModel = IngredientModel.fromMap(row);
            counter++;
            return DataRow(
              color: counter.isEven
                  ? MaterialStateProperty.resolveWith((states) => Colors.white)
                  : MaterialStateProperty.resolveWith(
                      (states) => Colors.purple[100]),
              cells: [
                DataCell(Text(ingredientModel.ingredientId.toString())),
                DataCell(Text(ingredientModel.name)),
                DataCell(Text(ingredientModel.unitCost.toString())),
                DataCell(Text(ingredientModel.companyName)),
                DataCell(Text(ingredientModel.supplierName)),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.edit),
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => AddIngredient(
                                  isUpdate: true,
                                  ingredientModel: IngredientModel.fromMap(row),
                                  ingredientId: ingredientModel.ingredientId,
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
                          id: ingredientModel.ingredientId!,
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
