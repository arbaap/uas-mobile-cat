import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uas_mobile/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final AppDb database = AppDb();

  bool isExpense = true;
  int type = 2;
  TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
            name: name, type: type, createdAt: now, updatedAt: now));
    print('Masuk : ' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int categoryId, String newName) async {
    return await database.updateCategoryRepo(categoryId, newName);
  }

  void openDialog(Category? category) {
    if (category != null) categoryNameController.text = category.name;
    showDialog(
      context: context,
      builder: (BuildContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  (isExpense)
                      ? "Tambah kategori pengeluaran"
                      : "Tambah kategori pemasukan",
                  style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: (isExpense) ? Colors.red : Colors.green),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: categoryNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Tulis nama kategori",
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (category == null) {
                      insert(categoryNameController.text, isExpense ? 2 : 1);
                    } else {
                      update(category.id, categoryNameController.text);
                    }
                    Navigator.of(context, rootNavigator: true).pop("dialog");
                    setState(() {});
                    categoryNameController.clear();
                  },
                  child: const Text("Simpan"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: isExpense,
                  onChanged: (bool value) {
                    setState(
                      () {
                        isExpense = value;
                        type = value ? 2 : 1;
                      },
                    );
                  },
                  inactiveTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                ),
                Text(
                  (isExpense) ? "Pengeluaran" : "Pemasukan",
                  style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: (isExpense) ? Colors.red : Colors.green),
                ),
                Expanded(child: Container()),
                IconButton(
                  onPressed: () {
                    openDialog(null);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          FutureBuilder<List<Category>>(
            future: getAllCategory(type),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (snapshot.hasData) {
                  if (snapshot.data!.length > 0) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 10,
                            child: ListTile(
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      database.deleteCategoryRepo(
                                          snapshot.data![index].id);
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      openDialog(snapshot.data![index]);
                                    },
                                  )
                                ],
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: (isExpense)
                                    ? Icon(
                                        Icons.upload,
                                        color: Colors.redAccent[400],
                                      )
                                    : Icon(
                                        Icons.download,
                                        color: Colors.greenAccent[400],
                                      ),
                              ),
                              title: Text(snapshot.data![index].name),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("Belum ada data"));
                  }
                } else {
                  return const Center(child: Text("Belum ada data"));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
