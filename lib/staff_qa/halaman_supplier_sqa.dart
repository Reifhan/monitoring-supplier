import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HalamanSupplierSQA extends StatefulWidget {
  const HalamanSupplierSQA({super.key});

  @override
  State<StatefulWidget> createState() => _HalamanSupplierSQAState();
}

class _HalamanSupplierSQAState extends State<HalamanSupplierSQA> {
  final _formKey = GlobalKey<FormState>();

  // Text fields controllers
  final TextEditingController _searchTextNamaSupplierController =
      TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();

  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchTextNamaSupplier = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaSupplierController.text = documentSnapshot["namaSupplier"];
    }

    await showModalBottomSheet(
      enableDrag: true,
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama Supplier tidak boleh kosong!';
                          }
                          return null;
                        },
                        controller: _namaSupplierController,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          labelText: "Nama Supplier",
                          hintText: "Masukkan Nama Supplier",
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: 130,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          icon: Icon(
                            action == "create" ? Icons.add : Icons.edit,
                          ),
                          label: Text(
                            action == "create" ? "Tambah" : "Edit",
                            style: TextStyle(
                              color: action == "create"
                                  ? Colors.black
                                  : Colors.purple,
                            ),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final String namaSupplier =
                                  _namaSupplierController.text;

                              if (action == "create") {
                                // Persist a new product to Firestore
                                await FirebaseFirestore.instance
                                    .collection("nama_supplier")
                                    .add({
                                  "namaSupplier": namaSupplier,
                                });
                              }

                              if (action == "update") {
                                // Update the product
                                await FirebaseFirestore.instance
                                    .collection("nama_supplier")
                                    .doc(documentSnapshot?.id)
                                    .set({
                                  "namaSupplier": namaSupplier,
                                });
                              }

                              // Show a snackbar
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: action == "create"
                                      ? Colors.black
                                      : Colors.brown,
                                  content: Text(
                                    action == "create"
                                        ? "Successfully create data!"
                                        : "Successfully update data!",
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );

                              // Clear the text fields
                              _namaSupplierController.text = "";

                              if (!mounted) return;
                              // Hide the bottom sheet
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    await FirebaseFirestore.instance
        .collection("nama_supplier")
        .doc(productId)
        .delete();

    if (!mounted) return;
    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Successfully delete data!",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 140,
        flexibleSpace: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextField(
                    controller: _searchTextNamaSupplierController,
                    onChanged: (value) {
                      setState(() {
                        searchTextNamaSupplier = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Cari Supplier",
                      prefixIcon: Icon(
                        Icons.search,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios,
                    ),
                    label: const Text('Back'),
                  ),
                  const Text(
                    'List Supplier',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Tambah Supplier'),
        onPressed: () {
          _namaSupplierController.text = "";
          _createOrUpdate();
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("nama_supplier")
            .orderBy("namaSupplier", descending: false)
            .snapshots(),
        builder: (ctx, streamSnapshot) {
          if (streamSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          }

          documents = streamSnapshot.data!.docs;
          // ToDo Documents list added to filterTitle

          if (searchTextNamaSupplier.isNotEmpty) {
            documents = documents.where((element) {
              return element
                  .get("namaSupplier")
                  .toString()
                  .toLowerCase()
                  .contains(searchTextNamaSupplier.toLowerCase());
            }).toList();
          }

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final documentSnapshot = documents[index];

              return Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.black),
                      ),
                      tileColor: Colors.amber,
                      hoverColor: Colors.blue,
                      title: Text(
                        "Nama Supplier: ${documentSnapshot["namaSupplier"]}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            width: 250,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Press this button to edit a single product
                                  ElevatedButton.icon(
                                    label: const Text("Update"),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      color: Colors.orange,
                                    ),
                                    onPressed: () =>
                                        _createOrUpdate(documentSnapshot),
                                  ),
                                  // This icon button is used to delete a single product
                                  ElevatedButton.icon(
                                    label: const Text("Delete"),
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Create a delete confirmation dialog
                                      AlertDialog delete = AlertDialog(
                                        title: const Text(
                                          "Peringatan!",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        content: SizedBox(
                                          height: 200,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Yakin ingin menghapus data *${documentSnapshot["namaSupplier"]}* ?",
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _deleteProduct(
                                                  documentSnapshot.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              "Ya",
                                            ),
                                          ),
                                          TextButton(
                                            child: const Text(
                                              "Tidak",
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (context) => delete,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
