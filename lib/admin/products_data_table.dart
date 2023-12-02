// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_products_form.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/product_model.dart';
import 'package:point_of_sale_app/database/size_model.dart';
import 'package:point_of_sale_app/general/confirmation_alert.dart';

class ProductsDataTable extends StatefulWidget {
  const ProductsDataTable({Key? key}) : super(key: key);

  @override
  _ProductsDataTableState createState() => _ProductsDataTableState();
}

class _ProductsDataTableState extends State<ProductsDataTable> {
  List<Map<String, dynamic>> productsTableData = [];
  List<Map<String, dynamic>> sizeTableData = [];
  int counter = 1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Products');

    setState(() {
      productsTableData = result!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DataTable(
          headingRowColor: MaterialStateColor.resolveWith(
              (states) => Colors.purple.shade400),
          columnSpacing: 30.0,
          columns: const [
            DataColumn(label: Text('ID')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Barcode')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Unit Cost')),
            DataColumn(label: Text('Unit Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Supplier')),
            DataColumn(label: Text('')),
            DataColumn(label: Text('')),
          ],
          rows: productsTableData.map<DataRow>((Map<String, dynamic> row) {
            ProductModel productModel = ProductModel.fromMap(row);
            counter++;
            return DataRow(
              color: counter.isEven
                  ? MaterialStateProperty.resolveWith((states) => Colors.white)
                  : MaterialStateProperty.resolveWith(
                      (states) => Colors.purple[100]),
              cells: [
                DataCell(Text(productModel.productId.toString())),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(
                      productModel.prodName,
                      maxLines: 2,
                    ))),
                DataCell(Text(productModel.barCode)),
                DataCell(Text(productModel.category)),
                DataCell(Text(productModel.unitCost.toString())),
                DataCell(Text(productModel.unitPrice.toString())),
                DataCell(Text(productModel.stock.toString())),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(
                      productModel.companyName,
                      maxLines: 2,
                    ))),
                DataCell(SizedBox(
                    width: 100,
                    child: Text(
                      productModel.supplierName,
                      maxLines: 2,
                    ))),
                DataCell(
                  GestureDetector(
                    child: const Icon(Icons.edit),
                    onTap: () async {
                      var sizes = await DatabaseHelper.instance
                          .getRecord('Size', 'productId=?', row['productId']);
                      List<SizeModel> sizeModels =
                          sizes!.map((map) => SizeModel.fromMap(map)).toList();

                      List<Object?> sizeIds =
                          sizes.map((size) => size['sizeId']).toList();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AddProduct(
                            isUpdate: true,
                            sizeModels: sizeModels,
                            sizeIds: sizeIds,
                            productModel: ProductModel.fromMap(row),
                            prodId: row['productId'],
                          ),
                        ),
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
                          dbTable: 'Products',
                          where: 'productId=?',
                          id: row['productId'],
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
