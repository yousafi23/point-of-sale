import 'package:flutter/material.dart';
import 'package:point_of_sale_app/admin/add_ingredient_form.dart';
import 'package:point_of_sale_app/admin/ingredients_data_table.dart';
import 'package:point_of_sale_app/general/drawer.dart';
import 'package:point_of_sale_app/general/my_custom_appbar.dart';

class IngredientsScreen extends StatefulWidget {
  const IngredientsScreen({Key? key}) : super(key: key);

  @override
  State<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends State<IngredientsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ReusableDrawer(
        title: 'Ingredients',
        currentPage: IngredientsScreen(),
      ),
      appBar: myCustomAppBar(
        "Ingredients",
        const Color.fromARGB(255, 116, 2, 122),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height - 200,
                child:
                    const SingleChildScrollView(child: IngredientsDataTable())),
            FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AddIngredient()),
                );
              },
              label: const Text("Add"),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
