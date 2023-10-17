import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/admin_qc/homescreen_adminqc.dart';

class HalamanBulan extends StatefulWidget {
  final String? documentIdSupplier;
  final String? documentIdTahun;

  const HalamanBulan({
    super.key,
    required this.documentIdSupplier,
    required this.documentIdTahun,
  });

  @override
  State<StatefulWidget> createState() => _HalamanBulanState();
}

class _HalamanBulanState extends State<HalamanBulan> {
  final _formKey = GlobalKey<FormState>();

  var month = [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  // Text fields controllers
  final TextEditingController _searchTextBulanController =
      TextEditingController();
  final TextEditingController _bulanController = TextEditingController();

  List<DocumentSnapshot> documents = [];

  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedMonth = now.month;
  }

  // Search text variable
  String searchTextBulan = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _bulanController.text = documentSnapshot["bulan"];
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
                            return 'Bulan tidak boleh kosong!';
                          }
                          return null;
                        },
                        controller: _bulanController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(10),
                          labelText: "Bulan",
                          hintText: "Masukkan Bulan",
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.calendar_month,
                            ),
                            tooltip: "Pilih",
                            onSelected: (String value) {
                              _bulanController.text = value;
                            },
                            itemBuilder: (BuildContext context) {
                              return month
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
                              final String bulan = _bulanController.text;

                              if (action == "create") {
                                // Persist a new product to Firestore
                                await FirebaseFirestore.instance
                                    .collection('nama_supplier')
                                    .doc(widget.documentIdSupplier)
                                    .collection('tahun')
                                    .doc(widget.documentIdTahun)
                                    .collection('bulan')
                                    .add({
                                  "bulan": bulan,
                                });
                              }

                              if (action == "update") {
                                // Update the product
                                await FirebaseFirestore.instance
                                    .collection('nama_supplier')
                                    .doc(widget.documentIdSupplier)
                                    .collection('tahun')
                                    .doc(widget.documentIdTahun)
                                    .collection('bulan')
                                    .doc(documentSnapshot?.id)
                                    .set({
                                  "bulan": bulan,
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
                              _bulanController.text = "";

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
        .collection('nama_supplier')
        .doc(widget.documentIdSupplier)
        .collection('tahun')
        .doc(widget.documentIdTahun)
        .collection('bulan')
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
                    controller: _searchTextBulanController,
                    onChanged: (value) {
                      setState(() {
                        searchTextBulan = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Cari Bulan",
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
                  Row(
                    children: [
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
                      const Text(' > '),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('nama_supplier')
                            .doc(widget.documentIdSupplier)
                            .collection('tahun')
                            .doc(widget.documentIdTahun)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var document = snapshot.data!;
                          return Text(
                            document["tahun"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Text(
                    'List Bulan',
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
        label: const Text('Tambah Bulan'),
        onPressed: () {
          _bulanController.text = "";
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
                .doc(widget.documentIdTahun)
                .collection('bulan')
                .orderBy("bulan", descending: false)
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

              if (searchTextBulan.isNotEmpty) {
                documents = documents.where((element) {
                  return element
                      .get("bulan")
                      .toString()
                      .toLowerCase()
                      .contains(searchTextBulan.toLowerCase());
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
                                builder: (context) => HomeScreenAdminQC(
                                  documentIdSupplier: widget.documentIdSupplier,
                                  documentIdTahun: widget.documentIdTahun,
                                  documentIdBulan: documentSnapshot.id,
                                ),
                              ),
                            );
                          },
                          title: Text(
                            "Bulan: ${documentSnapshot["bulan"]}",
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
                                                    "Yakin ingin menghapus data *${documentSnapshot["bulan"]}* ?",
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
