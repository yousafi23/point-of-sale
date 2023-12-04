// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/ingredients_screen.dart';
import 'package:point_of_sale_app/database/db_helper.dart';
import 'package:point_of_sale_app/database/ingredient_model.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';
import 'package:point_of_sale_app/general/my_custom_snackbar.dart';

// ignore: must_be_immutable
class AddIngredient extends StatefulWidget {
  AddIngredient(
      {this.isUpdate, this.ingredientModel, this.ingredientId, super.key});
  bool? isUpdate;
  IngredientModel? ingredientModel;
  int? ingredientId;

  @override
  State<AddIngredient> createState() => _AddIngredientState();
}

class _AddIngredientState extends State<AddIngredient> {
  final nameCont = TextEditingController();
  final unitCostCont = TextEditingController();
  final companyNameCont = TextEditingController();
  final supplierNameCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate == true && widget.ingredientModel != null) {
      nameCont.text = widget.ingredientModel!.name;
      unitCostCont.text = widget.ingredientModel!.unitCost.toString();
      companyNameCont.text = widget.ingredientModel!.companyName;
      supplierNameCont.text = widget.ingredientModel!.supplierName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myCustomAppBar(
        'Add Ingredient',
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
                labelText: 'Unit Cost',
              ),
              controller: unitCostCont,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company',
              ),
              controller: companyNameCont,
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Supplier',
              ),
              controller: supplierNameCont,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  IngredientModel ingredientModel = IngredientModel(
                      name: nameCont.text.trim(),
                      unitCost: int.tryParse(unitCostCont.text.trim()) ?? 0,
                      companyName: companyNameCont.text.trim(),
                      supplierName: supplierNameCont.text.trim());

                  if (widget.isUpdate == true) {
                    await DatabaseHelper.instance.updateRecord(
                        'Ingredients',
                        ingredientModel.toMap(),
                        'ingredientId=?',
                        widget.ingredientId!);

                    myCustomSnackBar(
                        message: 'Ingredient Updated: ${ingredientModel.name}',
                        warning: false,
                        context: context);
                  } else {
                    await DatabaseHelper.instance
                        .insertRecord('Ingredients', ingredientModel.toMap());

                    myCustomSnackBar(
                        message: 'Ingredient Added: ${ingredientModel.name}',
                        warning: false,
                        context: context);
                  }

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const IngredientsScreen()));
                },
                label: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
