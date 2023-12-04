// ignore_for_file: use_build_context_synchronously, must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/order_item_model.dart';
import 'package:point_of_sale_app/database/product_model.dart';
import 'package:point_of_sale_app/database/size_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

class PosTableWidget extends StatefulWidget {
  PosTableWidget({
    super.key,
    required this.productsData,
    required this.reloadCallback,
  });

  final Function reloadCallback;
  List<Map<String, dynamic>> productsData;

  @override
  _PosTableWidgetState createState() => _PosTableWidgetState();
}

class _PosTableWidgetState extends State<PosTableWidget> {
  late List<String> categories;

  @override
  void initState() {
    super.initState();
    categories = [];
    _loadData();
  }

  Future<void> _loadData() async {
    final database = await DatabaseHelper.instance.database;
    final result = await database?.query('Products');
    setState(() {
      widget.productsData = result!;
      categories = getUniqueCategories();
      // print(categories);
    });
  }

  List<String> getUniqueCategories() {
    List<String> uniqueCategories = widget.productsData
        .map<String>((product) => product['category'] as String)
        .toSet()
        .toList();

    // uniqueCategories.sort();
    return uniqueCategories;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * .45,
      child: Column(
        children: List.generate(
          categories.length,
          (index) {
            final category = categories[index];
            final categoryProducts = widget.productsData
                .where((product) => product['category'] == category)
                .toList();

            return CategoryWidget(
              categoryName: category,
              products: categoryProducts,
              reloadCallback: widget.reloadCallback,
            );
          },
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  const CategoryWidget({
    super.key,
    required this.categoryName,
    required this.products,
    required this.reloadCallback,
  });

  final String categoryName;
  final List<Map<String, dynamic>> products;
  final Function reloadCallback;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      expandedAlignment: Alignment.topLeft,
      textColor: Colors.green.shade800,
      iconColor: Colors.green.shade800,
      shape: const Border(),
      initiallyExpanded: true,
      title: Container(
        color: Colors.green.shade100,
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      children: [
        PosTableCategory(
          categoryProducts: products,
          reloadCallback: reloadCallback,
        ),
      ],
    );
  }
}

class PosTableCategory extends StatelessWidget {
  const PosTableCategory({
    super.key,
    required this.categoryProducts,
    required this.reloadCallback,
  });

  final List<Map<String, dynamic>> categoryProducts;
  final Function reloadCallback;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columnSpacing: 30.0,
      columns: const [
        DataColumn(label: Text('ID')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Barcode')),
        DataColumn(label: Text('Stock')),
        DataColumn(label: Text('Price')),
        DataColumn(label: Text('')),
      ],
      rows: categoryProducts.map<DataRow>((Map<String, dynamic> row) {
        ProductModel productModel = ProductModel.fromMap(row);
        return DataRow(
          cells: [
            DataCell(Text(productModel.productId.toString())),
            DataCell(SizedBox(
                width: 100,
                child: Text(
                  productModel.prodName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ))),
            DataCell(Text(productModel.barCode.toString())),
            DataCell(Text(productModel.stock.toString())),
            DataCell(Text(productModel.unitPrice.toString())),
            DataCell(
              GestureDetector(
                  child: _buildAddButton(row['productId']),
                  onTap: () =>
                      productSelected(context, productModel, reloadCallback)),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAddButton(int productId) {
    return FutureBuilder<List<SizeModel>>(
      future: DatabaseHelper.instance.getProductSizes(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          // If sizes are available, display SizeWidget
          return SizeWidget(
              sizes: snapshot.data!, reloadCallback: reloadCallback);
        } else {
          // If no sizes, display the add button
          return const Icon(
            Icons.add,
          );
        }
      },
    );
  }
}

class SizeWidget extends StatelessWidget {
  const SizeWidget(
      {super.key, required this.sizes, required this.reloadCallback});

  final List<SizeModel> sizes;
  final Function reloadCallback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: sizes.map((size) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
          child: ElevatedButton(
            onPressed: () async {
              var prod = await DatabaseHelper.instance
                  .getRecord('Products', 'productId = ?', size.productId);

              ProductModel productModel = ProductModel.fromMap(prod!.first);

              ProductModel newProductModel = productModel.copyWith(
                  prodName: '${productModel.prodName} - ${size.size}',
                  unitPrice: size.unitCost);

              productSelected(context, newProductModel, reloadCallback);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade300,
              minimumSize: Size.zero,
              padding: const EdgeInsets.all(5),
              textStyle: const TextStyle(fontSize: 11),
            ),
            child: Text(
              '${size.size}\n${size.unitCost}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }).toList(),
    );
  }
}

Future<void Function()?> productSelected(BuildContext context,
    ProductModel productModel, Function reloadCallback) async {
  OrderItemModel orderItemModel = OrderItemModel(
    productId: productModel.productId!,
    prodName: productModel.prodName,
    price: productModel.unitPrice!,
    quantity: 1,
  );

  int? productCount =
      await DatabaseHelper.instance.productCount(productModel.prodName);

  if (productCount! < 1) {
    await DatabaseHelper.instance
        .insertRecord('OrderItems', orderItemModel.toMap());

    await DatabaseHelper.instance.updateStock(productModel.productId!, true);

    reloadCallback(); // Trigger reload

    myCustomSnackBar(
        message: 'Added:\t\t\t${productModel.prodName} ',
        warning: false,
        context: context);
  } else {
    myCustomSnackBar(
        message: 'Product Already in Order List!',
        warning: true,
        context: context);
  }
  return null;
}
