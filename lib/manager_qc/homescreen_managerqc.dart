import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreenManagerQC extends StatefulWidget {
  final String? documentIdSupplier;
  final String? documentIdTahun;
  final String? documentIdBulan;

  const HomeScreenManagerQC(
      {super.key,
      required this.documentIdSupplier,
      required this.documentIdTahun,
      required this.documentIdBulan});

  @override
  State<HomeScreenManagerQC> createState() => _HomeScreenManagerQCState();
}

class _HomeScreenManagerQCState extends State<HomeScreenManagerQC> {
  void calculateSum() {
    final double jumlahPartDefect =
        double.tryParse(_jumlahPartDefectController.text) ?? 0;
    final double jumlahTotalKedatangan =
        double.tryParse(_jumlahTotalKedatanganController.text) ?? 0;
    final double persentasePartDefect =
        jumlahPartDefect / jumlahTotalKedatangan * 100;
    _persentasePartDefectController.text = persentasePartDefect.toString();
  }

  @override
  void initState() {
    super.initState();

    _jumlahPartDefectController.addListener(calculateSum);
    _jumlahTotalKedatanganController.addListener(calculateSum);
  }

  @override
  void dispose() {
    _jumlahPartDefectController.dispose();
    _jumlahTotalKedatanganController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _jumlahPartDefectController =
      TextEditingController();
  final TextEditingController _jumlahTotalKedatanganController =
      TextEditingController();
  final TextEditingController _persentasePartDefectController =
      TextEditingController();
  final TextEditingController _statusValidasiController =
      TextEditingController();

  List<DocumentSnapshot> documents = [];

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";

      _namaPartController.text = documentSnapshot["namaPart"];
      _jumlahPartDefectController.text =
          documentSnapshot["jumlahPartDefect"].toString();
      _jumlahTotalKedatanganController.text =
          documentSnapshot["jumlahTotalKedatangan"].toString();
      _persentasePartDefectController.text =
          documentSnapshot["persentasePartDefect"].toString();
      _statusValidasiController.text = documentSnapshot["statusValidasi"];
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Validasi Data Part Defect',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Nama Part',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _namaPartController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              hintText: 'Nama Part',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Jumlah Part Defect',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _jumlahPartDefectController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              hintText: 'Jumlah Part Defect',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Jumlah Total Kedatangan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _jumlahTotalKedatanganController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              hintText: 'Jumlah Total Kedatangan',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Persentase Part Defect',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            readOnly: true,
                            controller: _persentasePartDefectController,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(20),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.green,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              hintText: 'Persentase Part Defect',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.cancel,
                                    ),
                                    label: const Text(
                                      'Batal',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              height: 50,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  label: const Text(
                                    "Validasi",
                                    style: TextStyle(
                                      color: Colors.green,
                                    ),
                                  ),
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      final String namaPart =
                                          _namaPartController.text;
                                      final num? jumlahPartDefect =
                                          num.tryParse(
                                              _jumlahPartDefectController.text);
                                      final num? jumlahTotalKedatangan =
                                          num.tryParse(
                                              _jumlahTotalKedatanganController
                                                  .text);
                                      final num? persentasePartDefect =
                                          num.tryParse(
                                              _persentasePartDefectController
                                                  .text);

                                      if (action == "update") {
                                        await FirebaseFirestore.instance
                                            .collection('nama_supplier')
                                            .doc(widget.documentIdSupplier)
                                            .collection('tahun')
                                            .doc(widget.documentIdTahun)
                                            .collection('bulan')
                                            .doc(widget.documentIdBulan)
                                            .collection('data_part_defect')
                                            .doc(documentSnapshot?.id)
                                            .set({
                                          "namaPart": namaPart,
                                          "jumlahPartDefect": jumlahPartDefect,
                                          "jumlahTotalKedatangan":
                                              jumlahTotalKedatangan,
                                          "persentasePartDefect":
                                              persentasePartDefect,
                                          "statusValidasi": "Sudah Divalidasi",
                                        });
                                      }

                                      if (!mounted) return;
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: ListView(
            children: [
              Column(
                children: [
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
                            const Text(' > '),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('nama_supplier')
                                  .doc(widget.documentIdSupplier)
                                  .collection('tahun')
                                  .doc(widget.documentIdTahun)
                                  .collection('bulan')
                                  .doc(widget.documentIdBulan)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                var document = snapshot.data!;
                                return Text(
                                  document["bulan"],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text(
                          'Data Part Defect Bulanan',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          color: Colors.yellow,
                        ),
                        child: SizedBox(
                          width: 900,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 10,
                              right: 10,
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(2),
                                2: FlexColumnWidth(2),
                                3: FlexColumnWidth(2),
                                4: FlexColumnWidth(3),
                                5: FlexColumnWidth(2),
                              },
                              border: TableBorder.all(color: Colors.black),
                              children: const [
                                TableRow(children: [
                                  Text(
                                    'Nama Part',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Jumlah Part Defect',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Jumlah Total Part',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Persentase Part Defect',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Status',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Action',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.yellow,
                        ),
                        child: SizedBox(
                          height: 400,
                          width: 900,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 9,
                              right: 9,
                            ),
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('nama_supplier')
                                  .doc(widget.documentIdSupplier)
                                  .collection('tahun')
                                  .doc(widget.documentIdTahun)
                                  .collection('bulan')
                                  .doc(widget.documentIdBulan)
                                  .collection('data_part_defect')
                                  .orderBy("namaPart", descending: false)
                                  .snapshots(),
                              builder: (ctx, streamSnapshot) {
                                if (streamSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                                  );
                                }
                                documents = (streamSnapshot.data!).docs;
                                return ListView.builder(
                                  itemCount: documents.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final DocumentSnapshot documentSnapshot =
                                        documents[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(1),
                                      child: Table(
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(2),
                                          2: FlexColumnWidth(2),
                                          3: FlexColumnWidth(2),
                                          4: FlexColumnWidth(3),
                                          5: FlexColumnWidth(2),
                                        },
                                        border: TableBorder.all(
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TableRow(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  documentSnapshot["namaPart"],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  documentSnapshot[
                                                          "jumlahPartDefect"]
                                                      .toString(),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  documentSnapshot[
                                                          "jumlahTotalKedatangan"]
                                                      .toString(),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      documentSnapshot[
                                                              "persentasePartDefect"]
                                                          .toStringAsFixed(2),
                                                    ),
                                                    const Text(
                                                      '%',
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white70,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          documentSnapshot[
                                                                      "statusValidasi"] ==
                                                                  "Belum Divalidasi"
                                                              ? Icons
                                                                  .cancel_outlined
                                                              : Icons
                                                                  .check_circle_outlined,
                                                          color: documentSnapshot[
                                                                      "statusValidasi"] ==
                                                                  "Sudah Divalidasi"
                                                              ? Colors.red
                                                              : Colors.green,
                                                        ),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          documentSnapshot[
                                                              "statusValidasi"],
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    documentSnapshot[
                                                                "statusValidasi"] ==
                                                            "Sudah Divalidasi"
                                                        ? null
                                                        : _update(
                                                            documentSnapshot);
                                                  },
                                                  icon: Icon(
                                                    documentSnapshot[
                                                                "statusValidasi"] ==
                                                            "Sudah Divalidasi"
                                                        ? Icons.check
                                                        : Icons.check_box,
                                                  ),
                                                  label: Text(
                                                    documentSnapshot[
                                                                "statusValidasi"] ==
                                                            "Sudah Divalidasi"
                                                        ? "Selesai"
                                                        : "Validasi",
                                                    style: TextStyle(
                                                      color: documentSnapshot[
                                                                  "statusValidasi"] ==
                                                              "Sudah Divalidasi"
                                                          ? Colors.black
                                                          : Colors.purple,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
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
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                          color: Colors.yellow,
                        ),
                        child: SizedBox(
                          width: 900,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                              left: 10,
                              right: 10,
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(9),
                                1: FlexColumnWidth(4),
                              },
                              border: TableBorder.all(color: Colors.black),
                              children: [
                                TableRow(
                                  children: [
                                    FutureBuilder<QuerySnapshot>(
                                      future: FirebaseFirestore.instance
                                          .collection("nama_supplier")
                                          .doc(widget.documentIdSupplier)
                                          .collection('tahun')
                                          .doc(widget.documentIdTahun)
                                          .collection('bulan')
                                          .doc(widget.documentIdBulan)
                                          .collection('data_part_defect')
                                          .get(), // Fetch the documents in the collection
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const CircularProgressIndicator(); // Display a loading indicator while fetching data
                                        }
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        }
                                        if (!snapshot.hasData) {
                                          return const Text('No data found!');
                                        }

                                        int totalDocuments = snapshot.data!
                                            .size; // Get the total number of documents
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            "Total: $totalDocuments data",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    FutureBuilder<num>(
                                      future: _average(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<num> snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          // Menampilkan indikator loading ketika Future masih berjalan
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError) {
                                          // Menampilkan pesan error jika terjadi kesalahan
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                'Error: ${snapshot.error}'),
                                          );
                                        } else {
                                          // Menampilkan hasil rata-rata
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  'Rata-rata: ${snapshot.data!.toStringAsFixed(2)}',
                                                ),
                                                const Text(
                                                  '%',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
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
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<num> _average() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('nama_supplier')
        .doc(widget.documentIdSupplier)
        .collection('tahun')
        .doc(widget.documentIdTahun)
        .collection("bulan")
        .doc(widget.documentIdBulan)
        .collection("data_part_defect")
        .get();

    num average = 0.0;
    for (var element in querySnapshot.docs) {
      // here I want to sum
      num value = element["persentasePartDefect"];
      average += value;
    }

    return (average / querySnapshot.docs.length); // Hitung rata-rata
  }
}
