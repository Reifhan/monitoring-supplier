import 'dart:async';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreenOperatorQC extends StatefulWidget {
  final String? documentIdSupplier;
  final String? documentIdPart;
  final String? documentIdTahun;
  final String? documentIdBulan;

  const HomeScreenOperatorQC(
      {super.key,
      required this.documentIdSupplier,
      required this.documentIdPart,
      required this.documentIdTahun,
      required this.documentIdBulan});

  @override
  State<HomeScreenOperatorQC> createState() => _HomeScreenOperatorQCState();
}

class _HomeScreenOperatorQCState extends State<HomeScreenOperatorQC> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        // Mengambil tanggal dari tanggal yang dipilih dan menambahkan nama hari
        _tanggalPengecekanController.text = "${"${picked.toLocal()}".split(' ')[0]} (${_getDayName(picked.weekday)})";
      });
    }
  }

  String _getDayName(int day) {
    switch (day) {
      case DateTime.sunday:
        return 'Minggu';
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      default:
        return '';
    }
  }

  late Stream<DateTime> timerStream;
  late StreamSubscription<DateTime> timerSubscription;
  DateTime currentDateTime = DateTime.now();

  Stream<QuerySnapshot> getData() {
    return FirebaseFirestore.instance.collection('part').snapshots();
  }

  void calculateSum() {
    final num jumlahPartGood = num.tryParse(_jumlahPartGoodController.text) ?? 0;
    final num jumlahPartDefect = num.tryParse(_jumlahPartDefectController.text) ?? 0;
    final num jumlahTotalKedatangan = jumlahPartGood + jumlahPartDefect;
    _jumlahTotalKedatanganController.text = jumlahTotalKedatangan.toString();
  }

  void calculateAverage() {
    final double jumlahPartDefect = double.tryParse(_jumlahPartDefectController.text) ?? 0;
    final double jumlahTotalKedatangan = double.tryParse(_jumlahTotalKedatanganController.text) ?? 0;
    final double persentasePartDefect = jumlahPartDefect / jumlahTotalKedatangan * 100;
    _persentasePartDefectController.text = persentasePartDefect.toString();
  }

  @override
  void initState() {
    super.initState();

    // Create a Stream that emits a DateTime every second
    timerStream = Stream.periodic(const Duration(seconds: 30), (count) {
      currentDateTime = DateTime.now();
      return currentDateTime;
    });

    // Subscribe to the timerStream
    timerSubscription = timerStream.listen((dateTime) {
      setState(() {
        currentDateTime = dateTime;
      });
    });

    _jumlahPartGoodController.addListener(calculateSum);
    _jumlahPartDefectController.addListener(calculateSum);

    _jumlahPartDefectController.addListener(calculateAverage);
    _jumlahTotalKedatanganController.addListener(calculateAverage);
  }

  @override
  void dispose() {
    timerSubscription.cancel();
    _jumlahPartGoodController.dispose();
    _jumlahPartDefectController.dispose();
    _jumlahTotalKedatanganController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tanggalPengecekanController = TextEditingController();
  final TextEditingController _jumlahPartGoodController = TextEditingController();
  final TextEditingController _jumlahPartDefectController = TextEditingController();
  final TextEditingController _jumlahTotalKedatanganController = TextEditingController();
  final TextEditingController _persentasePartDefectController = TextEditingController();
  final TextEditingController _statusValidasiController = TextEditingController();
  final TextEditingController _notifController = TextEditingController();
  final TextEditingController _timestampController = TextEditingController();

  List<DocumentSnapshot> documents = [];

  Future<void> _create() async {
    String action = "create";

    await showGeneralDialog(
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      barrierColor: Colors.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, Widget AnimatedBuilder) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Tambah Data Pengecekan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40,
                ),
              ),
              content: Material(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: 600, // Dialog width
                    height: 500, // Dialog height
                    child: SingleChildScrollView(
                      child: Form(
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
                                    'Tanggal Pengecekan',
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
                                onTap: () => _selectDate(context),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required!';
                                  }
                                  return null;
                                },
                                controller: _tanggalPengecekanController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(20),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  hintText: 'Tanggal Pengecekan',
                                  prefixIcon: IconButton(
                                    onPressed: _tanggalPengecekanController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
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
                                    'Jumlah Part Good',
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
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required!';
                                  }
                                  return null;
                                },
                                controller: _jumlahPartGoodController,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(20),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  hintText: 'Jumlah Part Good',
                                  prefixIcon: IconButton(
                                    onPressed: _jumlahPartGoodController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
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
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(20),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.green,
                                      width: 2,
                                    ),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  hintText: 'Jumlah Part Defect',
                                  prefixIcon: IconButton(
                                    onPressed: _jumlahPartDefectController.clear,
                                    icon: const Icon(Icons.clear),
                                  ),
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
                                          style: TextStyle(color: Colors.red),
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
                                        Icons.add,
                                      ),
                                      label: const Text(
                                        "Tambah",
                                        style: TextStyle(
                                          color: Colors.green,
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final String tanggalPengecekan = _tanggalPengecekanController.text;
                                          final num? jumlahPartGood = num.tryParse(_jumlahPartGoodController.text);
                                          final num? jumlahPartDefect = num.tryParse(_jumlahPartDefectController.text);
                                          final num? jumlahTotalKedatangan =
                                              num.tryParse(_jumlahTotalKedatanganController.text);
                                          final num? persentasePartDefect =
                                              num.tryParse(_persentasePartDefectController.text);
                                          final String statusValidasi = _statusValidasiController.text;
                                          final String notif = _notifController.text;
                                          final String timeStamp = _timestampController.text;

                                          if (action == "create") {
                                            await FirebaseFirestore.instance
                                                .collection('nama_supplier')
                                                .doc(widget.documentIdSupplier)
                                                .collection('part')
                                                .doc(widget.documentIdPart)
                                                .collection('tahun')
                                                .doc(widget.documentIdTahun)
                                                .collection('bulan')
                                                .doc(widget.documentIdBulan)
                                                .collection('data_pengecekan')
                                                .add({
                                              "tanggalPengecekan": tanggalPengecekan,
                                              "jumlahPartGood": jumlahPartGood,
                                              "jumlahPartDefect": jumlahPartDefect,
                                              "jumlahTotalKedatangan": jumlahTotalKedatangan,
                                              "persentasePartDefect": persentasePartDefect,
                                              "statusValidasi": statusValidasi,
                                            });

                                            await FirebaseFirestore.instance.collection('notifikasi').add({
                                              "timeStamp": timeStamp,
                                              "notif": notif,
                                              "markAsRead": "false",
                                            });
                                          }

                                          // Clear the text fields
                                          _timestampController.text = "";
                                          _tanggalPengecekanController.text = "";
                                          _jumlahPartGoodController.text = "";
                                          _jumlahPartDefectController.text = "";
                                          _jumlahTotalKedatanganController.text = "";
                                          _persentasePartDefectController.text = "";

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
                    ),
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
  Future<void> _delete(String productId) async {
    await FirebaseFirestore.instance
        .collection('nama_supplier')
        .doc(widget.documentIdSupplier)
        .collection('part')
        .doc(widget.documentIdPart)
        .collection('tahun')
        .doc(widget.documentIdTahun)
        .collection('bulan')
        .doc(widget.documentIdBulan)
        .collection('data_pengecekan')
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
    final timestamp = currentDateTime;
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
                            const Text(' > '),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('nama_supplier')
                                  .doc(widget.documentIdSupplier)
                                  .collection('part')
                                  .doc(widget.documentIdPart)
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
                          'Data Pengecekan Part Harian',
                          style: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 100,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("nama_supplier")
                                .doc(widget.documentIdSupplier)
                                .snapshots(),
                            builder: (context, snapshot) {
                              var document = snapshot.data;
                              return ElevatedButton.icon(
                                onPressed: () {
                                  // Clear the text fields
                                  _tanggalPengecekanController.text = "";
                                  _jumlahPartGoodController.text = "";
                                  _jumlahPartDefectController.text = "";
                                  _jumlahTotalKedatanganController.text = "";
                                  _statusValidasiController.text = "Belum Divalidasi";
                                  _notifController.text = "Data ditambahkan: ${document?["namaSupplier"]}";
                                  _timestampController.text = "$timestamp";
                                  _create();
                                },
                                icon: const Icon(Icons.add),
                                label: const Text("Tambah Data Pengecekan"),
                              );
                            },
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            height: 550,
                            width: 1100,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 8,
                                right: 8,
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
                                    .doc(widget.documentIdBulan)
                                    .collection('data_pengecekan')
                                    .orderBy("tanggalPengecekan", descending: true)
                                    .snapshots(),
                                builder: (ctx, streamSnapshot) {
                                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      ),
                                    );
                                  }

                                  documents = (streamSnapshot.data!).docs;

                                  return ListView.builder(
                                    itemCount: documents.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final DocumentSnapshot documentSnapshot = documents[index];

                                      Map<String, double> dataMap = {
                                        "Part Good": documentSnapshot["jumlahPartGood"].toDouble(),
                                        "Part Defect": documentSnapshot["jumlahPartDefect"].toDouble(),
                                      };
                                      final colorList = <Color>[
                                        Colors.blue,
                                        Colors.red,
                                      ];

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
                                                    "Tanggal Pengecekan: ${documentSnapshot["tanggalPengecekan"]}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    "Total Kedatangan: ${documentSnapshot["jumlahTotalKedatangan"]}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  trailing: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white70,
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: SizedBox(
                                                      width: 130,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
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
                                                                  content: const SizedBox(
                                                                    height: 200,
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(
                                                                          "Hapus Data Ini ?",
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      onPressed: () {
                                                                        _delete(documentSnapshot.id);
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
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                Text(
                                                                  "Jumlah Part Good: ${documentSnapshot["jumlahPartGood"]}",
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "Jumlah Part Defect: ${documentSnapshot["jumlahPartDefect"]}",
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: 100,
                                                              width: 500,
                                                              child: Padding(
                                                                padding: const EdgeInsets.all(8),
                                                                child: PieChart(
                                                                  dataMap: dataMap,
                                                                  colorList: colorList,
                                                                  animationDuration: const Duration(
                                                                    milliseconds: 3200,
                                                                  ),
                                                                  chartLegendSpacing: 16,
                                                                  chartRadius: MediaQuery.of(context).size.width / 1.6,
                                                                  initialAngleInDegree: 0,
                                                                  chartType: ChartType.disc,
                                                                  ringStrokeWidth: 16,
                                                                  legendOptions: const LegendOptions(
                                                                    showLegendsInRow: true,
                                                                    legendPosition: LegendPosition.right,
                                                                    showLegends: true,
                                                                    legendShape: BoxShape.circle,
                                                                    legendTextStyle: TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                  chartValuesOptions: const ChartValuesOptions(
                                                                    showChartValueBackground: true,
                                                                    showChartValues: true,
                                                                    showChartValuesInPercentage: true,
                                                                    showChartValuesOutside: true,
                                                                    decimalPlaces: 2,
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
                        ),
                      ],
                    ),
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
}
