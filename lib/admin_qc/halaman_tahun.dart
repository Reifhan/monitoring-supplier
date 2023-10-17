import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/admin_qc/halaman_bulan.dart';

class HalamanTahun extends StatefulWidget {
  final String? documentIdSupplier;

  const HalamanTahun({super.key, required this.documentIdSupplier});

  @override
  State<StatefulWidget> createState() => _HalamanTahunState();
}

class _HalamanTahunState extends State<HalamanTahun> {
  final _formKey = GlobalKey<FormState>();

  var year = [
    "2018",
    "2019",
    "2020",
    "2021",
    "2022",
    "2023",
    "2024",
    "2025",
    "2026",
    "2027",
    "2028",
    "2029",
    "2030",
    "2031",
    "2032",
    "2033",
    "2034",
    "2035",
    "2036",
    "2037",
    "2038",
    "2039",
    "2040",
    "2041",
    "2042",
    "2043",
    "2044",
    "2045",
    "2046",
    "2047",
    "2048",
    "2049",
    "2050"
  ];

  // Text fields controllers
  final TextEditingController _searchTextTahunController =
      TextEditingController();
  final TextEditingController _tahunController = TextEditingController();

  late int selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedYear = now.year;
  }

  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchTextTahun = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _tahunController.text = documentSnapshot["tahun"];
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
                        readOnly: true,
                        // The validator receives the text that the user has entered.
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tahun tidak boleh kosong!';
                          }
                          return null;
                        },
                        controller: _tahunController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          labelText: "Tahun",
                          hintText: "Masukkan Tahun",
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.calendar_today,
                            ),
                            tooltip: "Pilih",
                            onSelected: (String value) {
                              _tahunController.text = value;
                            },
                            itemBuilder: (BuildContext context) {
                              return year
                                  .map<PopupMenuItem<String>>((String value) {
                                return PopupMenuItem(
                                  value: value,
                                  child: Text(
                                    value,
                                  ),
                                );
                              }).toList();
                            },
                          ),
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
                              final String tahun = _tahunController.text;

                              if (action == "create") {
                                // Persist a new product to Firestore
                                await FirebaseFirestore.instance
                                    .collection('nama_supplier')
                                    .doc(widget.documentIdSupplier)
                                    .collection('tahun')
                                    .add({
                                  "tahun": tahun,
                                });
                              }

                              if (action == "update") {
                                // Update the product
                                await FirebaseFirestore.instance
                                    .collection('nama_supplier')
                                    .doc(widget.documentIdSupplier)
                                    .collection('tahun')
                                    .doc(documentSnapshot?.id)
                                    .set({
                                  "tahun": tahun,
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
                              _tahunController.text = "";

                              if (!mounted) return;
                              // Hide the bottom sheet
                              Navigator.of(context).pop();
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
        .collection('nama_supplier')
        .doc(widget.documentIdSupplier)
        .collection('tahun')
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
                    controller: _searchTextTahunController,
                    onChanged: (value) {
                      setState(() {
                        searchTextTahun = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Cari Tahun",
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
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('nama_supplier')
                        .doc(widget.documentIdSupplier)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      var document = snapshot.data!;
                      return Text(
                        document["namaSupplier"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                  const Text(
                    'List Tahun',
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
        label: const Text('Tambah Tahun'),
        onPressed: () {
          _tahunController.text = "";
          _createOrUpdate();
        },
      ),
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color.fromARGB(40, 216, 60, 60),
                Color.fromARGB(42, 99, 127, 134),
                Color.fromARGB(72, 197, 189, 147),
                Color.fromARGB(53, 128, 212, 205),
                Color.fromARGB(255, 198, 236, 233),
                Color.fromARGB(118, 69, 87, 81),
                Color.fromARGB(139, 45, 218, 122),
                Color.fromARGB(162, 141, 212, 200),
              ],
              // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('nama_supplier')
                .doc(widget.documentIdSupplier)
                .collection('tahun')
                .orderBy("tahun", descending: false)
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

              if (searchTextTahun.isNotEmpty) {
                documents = documents.where((element) {
                  return element
                      .get("tahun")
                      .toString()
                      .toLowerCase()
                      .contains(searchTextTahun.toLowerCase());
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
                          onTap: () {
                            // Navigate to the nested collection
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HalamanBulan(
                                  documentIdSupplier: widget.documentIdSupplier,
                                  documentIdTahun: documentSnapshot.id,
                                ),
                              ),
                            );
                          },
                          title: Text(
                            "Tahun: ${documentSnapshot["tahun"]}",
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
                                                    "Yakin ingin menghapus data *${documentSnapshot["tahun"]}* ?",
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
        ),
      ),
    );
  }
}
