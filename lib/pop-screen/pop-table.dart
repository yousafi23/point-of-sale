// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/ingredient_model.dart';
import 'package:point_of_sale_app/database/purhcase_item_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class PopTableWidget extends StatefulWidget {
  const PopTableWidget({
    super.key,
    required this.reloadCallback,
  });
  final Function reloadCallback;

  @override
  _PopTableWidgetState createState() => _PopTableWidgetState();
}

class _PopTableWidgetState extends State<PopTableWidget> {
  List<Map<String, dynamic>> productsData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Ingredients');
    setState(() {
      productsData = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: DataTable(
            columnSpacing: 15.0,
            columns: const [
              DataColumn(label: Text('ID')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('stock')),
              DataColumn(label: Text('Unit Cost')),
              DataColumn(label: Text('companyName')),
              DataColumn(label: Text('supplierName')),
              DataColumn(label: Text('')),
            ],
            rows: productsData.map<DataRow>((Map<String, dynamic> row) {
              IngredientModel ingredientModel = IngredientModel.fromMap(row);

              return DataRow(
                cells: [
                  DataCell(Text(ingredientModel.ingredientId.toString())),
                  DataCell(SizedBox(
                      width: 100,
                      child: Text(
                        ingredientModel.name,
                        maxLines: 2,
                      ))),
                  DataCell(Text(ingredientModel.stock.toString())),
                  DataCell(Text(ingredientModel.unitCost.toString())),
                  DataCell(Text(ingredientModel.companyName)),
                  DataCell(Text(ingredientModel.supplierName)),
                  DataCell(
                    GestureDetector(
                      child: const Icon(Icons.add),
                      onTap: () async {
                        PurchaseItemModel purchaseItemModel = PurchaseItemModel(
                            name: ingredientModel.name,
                            price: ingredientModel.unitCost,
                            quantity: 1,
                            ingredientId: ingredientModel.ingredientId!);

                        int? ingredientCount = await DatabaseHelper.instance
                            .ingredientCount(ingredientModel.ingredientId!);

                        if (ingredientCount! < 1) {
                          await DatabaseHelper.instance.insertRecord(
                              'PurchaseItems', purchaseItemModel.toMap());

                          widget.reloadCallback();

                          myCustomSnackBar(
                              message: '${ingredientModel.name} Added',
                              warning: false,
                              context: context);
                        } else {
                          myCustomSnackBar(
                              message: 'Ingredient Already in Purchase List!',
                              warning: true,
                              context: context);
                        }
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
