import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LihatPart extends StatefulWidget {
  const LihatPart({super.key});

  @override
  State<StatefulWidget> createState() => _LihatPartState();
}

class _LihatPartState extends State<LihatPart> {
  // Text fields controllers
  final TextEditingController _searchTextNamaPartController =
      TextEditingController();
  final TextEditingController _searchTextKodePartController =
      TextEditingController();
  final TextEditingController _searchTextJenisPartController =
      TextEditingController();
  final TextEditingController _searchTextNamaSupplierController =
      TextEditingController();

  // Firestore collection reference
  final CollectionReference _part =
      FirebaseFirestore.instance.collection("part");
  List<DocumentSnapshot> documents = [];

  // Search text variable
  String searchTextNamaPart = "";
  String searchTextKodePart = "";
  String searchTextJenisPart = "";
  String searchTextNamaSupplier = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
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
                'List Part',
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
                  return element
                      .get("namaPart")
                      .toString()
                      .toLowerCase()
                      .contains(searchTextNamaPart.toLowerCase());
                }).toList();
              }

              if (searchTextKodePart.isNotEmpty) {
                documents = documents.where((element) {
                  return element
                      .get("kodePart")
                      .toString()
                      .toLowerCase()
                      .contains(searchTextKodePart.toLowerCase());
                }).toList();
              }

              if (searchTextJenisPart.isNotEmpty) {
                documents = documents.where((element) {
                  return element
                      .get("jenisPart")
                      .toString()
                      .toLowerCase()
                      .contains(searchTextJenisPart.toLowerCase());
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
