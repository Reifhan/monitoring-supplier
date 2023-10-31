import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_bulan_mqc.dart';

class HalamanTahunMQC extends StatefulWidget {
  final String? documentIdSupplier;
  final String? documentIdPart;

  const HalamanTahunMQC({super.key, required this.documentIdSupplier, required this.documentIdPart});

  @override
  State<StatefulWidget> createState() => _HalamanTahunMQCState();
}

class _HalamanTahunMQCState extends State<HalamanTahunMQC> {
  // Text fields controllers
  final TextEditingController _searchTextTahunController = TextEditingController();

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
                    ],
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
                .orderBy("tahun", descending: true)
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
                  return element.get("tahun").toString().toLowerCase().contains(searchTextTahun.toLowerCase());
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
                                builder: (context) => HalamanBulanMQC(
                                  documentIdSupplier: widget.documentIdSupplier,
                                  documentIdPart: widget.documentIdPart,
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
