import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KelolaPart extends StatefulWidget {
  const KelolaPart({super.key});

  @override
  State<StatefulWidget> createState() => _KelolaPartState();
}

class _KelolaPartState extends State<KelolaPart> {
  var itemsJenisPart = [
    "Metal Part",
    "Plastic Part",
    "General Part",
    "Electric Part",
  ];

  final _formKey = GlobalKey<FormState>();

  // Text fields controllers
  final TextEditingController _searchTextNamaPartController = TextEditingController();
  final TextEditingController _searchTextKodePartController = TextEditingController();
  final TextEditingController _searchTextJenisPartController = TextEditingController();
  final TextEditingController _searchTextNamaSupplierController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _kodePartController = TextEditingController();
  final TextEditingController _jenisPartController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _part = FirebaseFirestore.instance.collection("part");
  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchTextNamaPart = "";
  String searchTextKodePart = "";
  String searchTextJenisPart = "";
  String searchTextNamaSupplier = "";

  // This function is triggered when floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null the update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
      _kodePartController.text = documentSnapshot["kodePart"];
      _jenisPartController.text = documentSnapshot["jenisPart"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
    }

    await showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext ctx) {
        return Material(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
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
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 30,
                        ),
                        tooltip: "Tutup",
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      Center(
                        child: Text(
                          action == "create" ? "Tambah Data" : "Update Data",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: action == "create" ? Colors.brown : Colors.pink,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama Part tidak boleh kosong!';
                                  }
                                  return null;
                                },
                                controller: _namaPartController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  labelText: "Nama Part",
                                  hintText: "Masukkan Nama Part",
                                  prefixIcon: IconButton(
                                    onPressed: _namaPartController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kode Part tidak boleh kosong!';
                                  }
                                  return null;
                                },
                                controller: _kodePartController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  labelText: "Kode Part",
                                  hintText: "Masukkan Kode Part",
                                  prefixIcon: IconButton(
                                    onPressed: _kodePartController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                readOnly: true,
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Jenis Part tidak boleh kosong!';
                                  }
                                  return null;
                                },
                                controller: _jenisPartController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  labelText: "Jenis Part",
                                  hintText: "Masukkan Jenis Part",
                                  prefixIcon: IconButton(
                                    onPressed: _jenisPartController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
                                  suffixIcon: PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                    ),
                                    tooltip: "Pilih",
                                    onSelected: (String value) {
                                      _jenisPartController.text = value;
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return itemsJenisPart.map<PopupMenuItem<String>>((String value) {
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
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: TextFormField(
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Nama Supplier tidak boleh kosong!';
                                  }
                                  return null;
                                },
                                controller: _namaSupplierController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(10),
                                  labelText: "Nama Supplier",
                                  hintText: "Masukkan Nama Supplier",
                                  prefixIcon: IconButton(
                                    onPressed: _namaSupplierController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              width: 130,
                              height: 50,
                              child: OutlinedButton.icon(
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
                                    color: action == "create" ? Colors.black : Colors.purple,
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    HapticFeedback.vibrate();
                                    final String namaPart = _namaPartController.text;
                                    final String kodePart = _kodePartController.text;
                                    final String jenisPart = _jenisPartController.text;
                                    final String namaSupplier = _namaSupplierController.text;

                                    if (action == "create") {
                                      // Persist a new product to Firestore
                                      await _part.add({
                                        "namaPart": namaPart,
                                        "kodePart": kodePart,
                                        "jenisPart": jenisPart,
                                        "namaSupplier": namaSupplier,
                                      });
                                    }

                                    if (action == "update") {
                                      // Update the product
                                      await _part.doc(documentSnapshot!.id).set({
                                        "namaPart": namaPart,
                                        "kodePart": kodePart,
                                        "jenisPart": jenisPart,
                                        "namaSupplier": namaSupplier,
                                      });
                                    }

                                    // Show a snackbar
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: action == "create" ? Colors.yellow : Colors.grey,
                                        content: Text(
                                          action == "create"
                                              ? "Successfully create data!"
                                              : "Successfully update data!",
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    );

                                    // Clear the text fields
                                    _namaPartController.text = "";
                                    _kodePartController.text = "";
                                    _jenisPartController.text = "";
                                    _namaSupplierController.text = "";

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
              ),
            ),
          ),
        );
      },
    );
  }

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    await _part.doc(productId).delete();

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
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _namaPartController.text = "";
                _kodePartController.text = "";
                _jenisPartController.text = "";
                _namaSupplierController.text = "";
                _createOrUpdate();
              },
              icon: const Icon(
                Icons.add,
                color: Colors.black,
              ),
              label: const Text('Tambah'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                label: const Text('Cari Data'),
                icon: const Icon(
                  Icons.search,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        flexibleSpace: Container(
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
                'Kelola Part',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.cyan,
                Color.fromARGB(
                  200,
                  30,
                  220,
                  190,
                ),
              ],
            ),
          ),
          child: ListView(
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black,
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.teal,
                            Color.fromARGB(
                              200,
                              30,
                              220,
                              190,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize: 20,
                                    ),
                                    "Cari data berdasarkan:",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Nama Part",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Kode Part",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Jenis Part",
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    "• Nama Supplier",
                                  ),
                                ],
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _searchTextNamaPartController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextNamaPart = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Masukkan Nama Part",
                                    labelText: "Nama Part",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _searchTextKodePartController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextKodePart = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Masukkan Kode Part",
                                    labelText: "Kode Part",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              color: Colors.white70,
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: TextField(
                                  controller: _searchTextJenisPartController,
                                  onChanged: (value) {
                                    setState(() {
                                      searchTextJenisPart = value;
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Masukkan Jenis Part",
                                    labelText: "Jenis Part",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Card(
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
                                    hintText: "Masukkan Nama Supplier",
                                    labelText: "Nama Supplier",
                                    prefixIcon: Icon(
                                      Icons.search,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
            stream: _part.orderBy("namaPart", descending: false).snapshots(),
            builder: (ctx, streamSnapshot) {
              if (streamSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              }

              documents = (streamSnapshot.data!).docs;
              // ToDo Documents list added to filterTitle
              if (searchTextNamaPart.isNotEmpty) {
                documents = documents.where((element) {
                  return element.get("namaPart").toString().toLowerCase().contains(searchTextNamaPart.toLowerCase());
                }).toList();
              }

              if (searchTextKodePart.isNotEmpty) {
                documents = documents.where((element) {
                  return element.get("kodePart").toString().toLowerCase().contains(searchTextKodePart.toLowerCase());
                }).toList();
              }

              if (searchTextJenisPart.isNotEmpty) {
                documents = documents.where((element) {
                  return element.get("jenisPart").toString().toLowerCase().contains(searchTextJenisPart.toLowerCase());
                }).toList();
              }

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
                  final DocumentSnapshot documentSnapshot = documents[index];

                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blueAccent,
                        ),
                        gradient: const LinearGradient(
                          colors: [
                            Colors.green,
                            Color.fromARGB(
                              200,
                              30,
                              220,
                              190,
                            ),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                "Nama Part: ${documentSnapshot["namaPart"]}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Nama Supplier: ${documentSnapshot["namaSupplier"]}",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              trailing: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white70,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      width: 250,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Press this button to edit a single product
                                            ElevatedButton.icon(
                                              label: const Text("Update"),
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Colors.orange,
                                              ),
                                              onPressed: () => _createOrUpdate(documentSnapshot),
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
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          "Yakin ingin menghapus data *${documentSnapshot["namaPart"]}* ?",
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        _deleteProduct(documentSnapshot.id);
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
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Kode Part: ${documentSnapshot["kodePart"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Jenis Part: ${documentSnapshot["jenisPart"]}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Color.fromARGB(
                                              200,
                                              30,
                                              220,
                                              190,
                                            ),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
