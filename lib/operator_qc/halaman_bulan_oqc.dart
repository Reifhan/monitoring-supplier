import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/operator_qc/homescreen_oqc.dart';

class HalamanBulanOperator extends StatefulWidget {
  final String? documentIdSupplier;
  final String? documentIdPart;
  final String? documentIdTahun;

  const HalamanBulanOperator({
    super.key,
    required this.documentIdSupplier,
    required this.documentIdPart,
    required this.documentIdTahun,
  });

  @override
  State<StatefulWidget> createState() => _HalamanBulanOperatorState();
}

class _HalamanBulanOperatorState extends State<HalamanBulanOperator> {
  // Text fields controllers
  final TextEditingController _searchTextBulanController = TextEditingController();

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

  // Deleting a product by id

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
                            .collection('part')
                            .doc(widget.documentIdPart)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          var document = snapshot.data!;
                          return Text(
                            document["part"],
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
                            .collection('part')
                            .doc(widget.documentIdPart)
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
                .collection('part')
                .doc(widget.documentIdPart)
                .collection('tahun')
                .doc(widget.documentIdTahun)
                .collection('bulan')
                .orderBy("index", descending: false)
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
                  return element.get("bulan").toString().toLowerCase().contains(searchTextBulan.toLowerCase());
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
                                builder: (context) => HomeScreenOperatorQC(
                                  documentIdSupplier: widget.documentIdSupplier,
                                  documentIdPart: widget.documentIdPart,
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
