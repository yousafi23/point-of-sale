// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool isEmpty = false;

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

  // String? isEmpty(value) {
  //   if (!(value.length > 5) && value.isNotEmpty) {
  //     return "Password should contain more than 5 characters";
  //   }
  //   return null;
  // }

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
                                onTapOutside: (value) {
                                  (sizesController[index].text.isEmpty)
                                      ? isEmpty = true
                                      : isEmpty = false;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Size',
                                  constraints: BoxConstraints(maxWidth: 120),
                                ),
                                controller: sizesController[index],
                              ),
                              TextFormField(
                                onTapOutside: (value) {
                                  (pricesController[index].text.isEmpty)
                                      ? isEmpty = true
                                      : isEmpty = false;
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Cost',
                                  constraints: BoxConstraints(maxWidth: 120),
                                ),
                                controller: pricesController[index],
                              ),
                              GestureDetector(
                                child: const Icon(
                                  Icons.minimize,
                                  color: Colors.redAccent,
                                ),
                                onTap: () {
                                  setState(() {
                                    sizesController.removeAt(index);
                                    pricesController.removeAt(index);

                                    if (widget.isUpdate == true) {
                                      if (index < widget.sizeIds!.length) {
                                        // If it's an update and if the sizeId is in sizeIds List (NOT new) then Delete.
                                        DatabaseHelper.instance.deleteRecord(
                                          dbTable: 'Size',
                                          where: 'sizeId = ?',
                                          id: widget.sizeIds![index] as int,
                                        );
                                      }
                                    }
                                  });
                                },
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
                            color: Color.fromARGB(255, 116, 2, 122),
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
                if (isEmpty != true) {
                  addProduct();
                } else {
                  myCustomSnackBar(
                      message: 'Fields are empty',
                      warning: true,
                      context: context);
                }
              },
              label: const Text("Submit"),
            ),
            const SizedBox(height: 45),
          ],
        ),
      ),
    );
  }

  Future<void> addProduct() async {
    ProductModel productModel = ProductModel(
        prodName: nameCont.text.trim(),
        category: categoryCont.text.trim(),
        barCode: barcodeCont.text.trim(),
        unitCost: int.tryParse(unitcostCont.text.trim()),
        unitPrice: int.tryParse(unitpriceCont.text.trim()),
        stock: int.tryParse(stockCont.text.trim()) ?? 0,
        companyName: companyCont.text.trim(),
        supplierName: supplierCont.text.trim(),
        productId: widget.prodId);

    if (widget.isUpdate == true) {
      // print('Size Cont = ${sizesController.length}');
      // print('Price Cont = ${pricesController.length}');
      // print('${productModel.toMap()}');

      await DatabaseHelper.instance.updateRecord(
          'Products', productModel.toMap(), "productId=?", widget.prodId!);

      for (int i = 0; i < sizesController.length; i++) {
        int? sizeId = (widget.sizeIds != null && widget.sizeIds!.length > i)
            ? widget.sizeIds![i] as int?
            : null;

        SizeModel sizeModel = SizeModel(
          productId: widget.prodId!,
          size: sizesController[i].text.trim(),
          unitCost: int.tryParse(pricesController[i].text.trim()) ?? 0,
        );

        if (sizeId != null) {
          await DatabaseHelper.instance
              .updateRecord('Size', sizeModel.toMap(), "sizeId=?", sizeId);
        } else {
          await DatabaseHelper.instance.insertRecord('Size', sizeModel.toMap());
        }
      }

      myCustomSnackBar(
          message: 'Product Updated: ${productModel.prodName}',
          warning: false,
          context: context);
    } else {
      var prodId = await DatabaseHelper.instance
          .insertRecord('Products', productModel.toMap());

      for (int i = 0; i < sizesController.length; i++) {
        SizeModel sizeModel = SizeModel(
          productId: prodId,
          size: sizesController[i].text.trim(),
          unitCost: int.tryParse(pricesController[i].text.trim()) ?? 0,
        );

        await DatabaseHelper.instance.insertRecord('Size', sizeModel.toMap());
      }

      myCustomSnackBar(
          message: 'Product Added: ${productModel.prodName}',
          warning: false,
          context: context);
    }

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ProductsScreen()));
  }
}
