import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/products_screen.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/size_model.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/database/product_model.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

// ignore: must_be_immutable
class AddProduct extends StatefulWidget {
  AddProduct(
      {this.isUpdate,
      this.productModel,
      this.sizeModels,
      this.sizeIds,
      this.prodId,
      super.key});
  bool? isUpdate;
  List<SizeModel>? sizeModels;
  List<Object?>? sizeIds;
  ProductModel? productModel;
  int? prodId;

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final nameCont = TextEditingController();
  final barcodeCont = TextEditingController();
  final unitcostCont = TextEditingController();
  final unitpriceCont = TextEditingController();
  final stockCont = TextEditingController();
  final companyCont = TextEditingController();
  final supplierCont = TextEditingController();
  final categoryCont = TextEditingController();

  List<TextEditingController> sizesController = [];
  List<TextEditingController> pricesController = [];

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate == true && widget.productModel != null) {
      // print('size==${widget.sizeModels}');
      // print('sizeids==${widget.sizeIds}');

      widget.sizeModels?.forEach((sizeModel) {
        // print(sizeModel.unitCost);
        sizesController.add(TextEditingController(text: sizeModel.size));
        pricesController
            .add(TextEditingController(text: sizeModel.unitCost.toString()));
      });
      nameCont.text = widget.productModel!.prodName;
      barcodeCont.text = widget.productModel!.barCode;
      categoryCont.text = widget.productModel!.category;
      unitcostCont.text = widget.productModel!.unitCost.toString();
      unitpriceCont.text = widget.productModel!.unitPrice.toString();
      stockCont.text = widget.productModel!.stock.toString();
      companyCont.text = widget.productModel!.companyName;
      supplierCont.text = widget.productModel!.supplierName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myCustomAppBar(
        "Add Products",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 25.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        controller: nameCont,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Barcode',
                        ),
                        controller: barcodeCont,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Unit Cost',
                        ),
                        controller: unitcostCont,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Unit Price',
                        ),
                        controller: unitpriceCont,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        controller: categoryCont,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                        ),
                        controller: stockCont,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Company',
                        ),
                        controller: companyCont,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Supplier',
                        ),
                        controller: supplierCont,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: sizesController.length,
                        itemBuilder: (context, index) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Size',
                                  constraints: BoxConstraints(maxWidth: 120),
                                ),
                                controller: sizesController[index],
                              ),
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Cost',
                                  constraints: BoxConstraints(maxWidth: 120),
                                ),
                                controller: pricesController[index],
                              ),
                            ],
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                          ),
                          onTap: () {
                            setState(() {
                              sizesController.add(TextEditingController());
                              pricesController.add(TextEditingController());
                            });
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 45),
            FloatingActionButton.extended(
              onPressed: () async {
                ProductModel productModel = ProductModel(
                    prodName: nameCont.text.trim(),
                    category: categoryCont.text.trim(),
                    barCode: barcodeCont.text.trim(),
                    unitCost: int.tryParse(unitcostCont.text.trim()),
                    unitPrice: int.tryParse(unitpriceCont.text.trim()),
                    stock: int.tryParse(stockCont.text.trim()) ?? 0,
                    companyName: companyCont.text.trim(),
                    supplierName: supplierCont.text.trim());

                if (widget.isUpdate == true) {
                  // print('Size Cont = ${sizesController}');
                  // print('Price Cont = $pricesController');

                  await DatabaseHelper.instance.updateRecord('Products',
                      productModel.toMap(), "productId=?", widget.prodId!);

                  for (int i = 0; i < sizesController.length; i++) {
                    // print('....i=$i');
                    // print('${sizesController[i].text.trim()}');
                    // print('${pricesController[i].text.trim()}');

                    SizeModel sizeModel = SizeModel(
                      productId: widget.prodId!,
                      size: sizesController[i].text.trim(),
                      unitCost:
                          int.tryParse(pricesController[i].text.trim()) ?? 0,
                    );

                    await DatabaseHelper.instance.updateRecord(
                        'Size',
                        sizeModel.toMap(),
                        "sizeId=?",
                        widget.sizeIds![i] as int);
                    // print('Final= ${sizeModel.toString()}');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    myCustomSnackBar(
                      message: 'Product Updated: ${productModel.prodName}',
                      warning: false,
                    ),
                  );
                } else {
                  var prodId = await DatabaseHelper.instance
                      .insertRecord('Products', productModel.toMap());

                  for (int i = 0; i < sizesController.length; i++) {
                    SizeModel sizeModel = SizeModel(
                      productId: prodId,
                      size: sizesController[i].text.trim(),
                      unitCost:
                          int.tryParse(pricesController[i].text.trim()) ?? 0,
                    );

                    await DatabaseHelper.instance
                        .insertRecord('Size', sizeModel.toMap());
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    myCustomSnackBar(
                      message: 'Product Added: ${productModel.prodName}',
                      warning: false,
                    ),
                  );
                }

                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ProductsScreen()));
              },
              label: const Text("Submit"),
            ),
            const SizedBox(height: 45),
            // TextButton(
            //     onPressed: () async {
            //       var dbquery =
            //           await DatabaseHelper.instance.queryDatabase('Products');
            //       print(dbquery);
            //     },
            //     child: const Text("Print DB"),
            // ),
          ],
        ),
      ),
    );
  }
}
