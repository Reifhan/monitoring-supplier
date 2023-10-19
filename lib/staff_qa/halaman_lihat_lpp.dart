import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:html' as html;

import 'package:printing/printing.dart';

class PDFScreen extends StatelessWidget {
  final Uint8List pdfBytes;

  const PDFScreen(this.pdfBytes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final blob = html.Blob([pdfBytes]);
            final url = html.Url.createObjectUrlFromBlob(blob);
            html.AnchorElement(href: url)
              ..target = '_blank'
              ..download = 'example.pdf'
              ..click();
            html.Url.revokeObjectUrl(url);
          },
          child: const Text('Download PDF'),
        ),
      ),
    );
  }
}

class HalamanLihatLPP extends StatefulWidget {
  const HalamanLihatLPP({super.key});

  @override
  State<HalamanLihatLPP> createState() => _HalamanLihatLPPState();
}

class _HalamanLihatLPPState extends State<HalamanLihatLPP> {
// Fungsi untuk mengambil data berdasarkan documentId
  Future<DocumentSnapshot> fetchDataById(String documentId) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('lpp')
        .doc(documentId)
        .get();
    return documentSnapshot;
  }

// Fungsi untuk membuat PDF dari data dokumen
  Future<Uint8List> createPDF(DocumentSnapshot document) async {
    final pdf = pw.Document();

    final namaSupplier = document['namaSupplier'].toString();
    final namaPart = document['namaPart'].toString();
    final kodePart = document['kodePart'].toString();
    final modelPart = document['modelPart'].toString();
    final jumlahPart = document['jumlahPart'].toString();
    final waktuDitemukan = document['bulanTahunDitemukan'].toString();
    final keteranganDefect = document['keteranganDefect'].toString();
    final request = document['request'].toString();

    final ByteData data = await rootBundle.load('assets/images/wima-logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final imageLocal = pw.MemoryImage(bytes);

    final ilustrasi = document['ilustrasi'].toString();
    // Mendownload gambar dan menyimpannya di cache sementara
    final file = await DefaultCacheManager().getSingleFile(ilustrasi);

    if (await file.exists()) {
      final ilustrasi = pw.MemoryImage(file.readAsBytesSync());

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Image(imageLocal, height: 50),
                pw.SizedBox(
                  height: 30,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Nama Supplier',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Nama Part',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(
                            'Kode Part',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Model Part',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(namaSupplier),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(namaPart),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(kodePart),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(modelPart),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Jumlah Part',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Waktu Ditemukan',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Keterangan Defect',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Request',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(jumlahPart),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(waktuDitemukan),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(keteranganDefect),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text(request),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(
                  height: 10,
                ),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Text('Ilustrasi',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              )),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8.0),
                          child: pw.Image(ilustrasi, height: 200),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }

  // Text fields controllers
  final TextEditingController _searchTextBulanTahunDitemukanController =
      TextEditingController();

  // Search text variable
  String searchTextBulanTahunDitemukan = "";

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _timestampController = TextEditingController();
  final TextEditingController _namaSupplierController = TextEditingController();
  final TextEditingController _namaPartController = TextEditingController();
  final TextEditingController _kodePartController = TextEditingController();
  final TextEditingController _modelPartController = TextEditingController();
  final TextEditingController _jumlahPartController = TextEditingController();
  final TextEditingController _bulanTahunDitemukanController =
      TextEditingController();
  final TextEditingController _keteranganDefectController =
      TextEditingController();
  final TextEditingController _ilustrasiController = TextEditingController();
  final TextEditingController _requestController = TextEditingController();
  final TextEditingController _statusValidasiController =
      TextEditingController();

  List<DocumentSnapshot> documents = [];

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    String action = "create";
    if (documentSnapshot != null) {
      action = "update";
      _timestampController.text = documentSnapshot["timeStamp"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
      _namaPartController.text = documentSnapshot["namaPart"];
      _kodePartController.text = documentSnapshot["kodePart"];
      _modelPartController.text = documentSnapshot["modelPart"];
      _jumlahPartController.text = documentSnapshot["jumlahPart"].toString();
      _bulanTahunDitemukanController.text =
          documentSnapshot["bulanTahunDitemukan"];
      _keteranganDefectController.text = documentSnapshot["keteranganDefect"];
      _ilustrasiController.text = documentSnapshot["ilustrasi"];
      _requestController.text = documentSnapshot["request"];
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
                        'Validasi Laporan Penyimpangan Part',
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
                                'Nama Supplier',
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
                            controller: _namaSupplierController,
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
                              hintText: 'Nama Supplier',
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
                                'Kode Part',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _kodePartController,
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
                              hintText: 'Kode Part',
                            ),
                            readOnly: true,
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
                                'Model Part',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _modelPartController,
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
                              hintText: 'Model Part',
                            ),
                            readOnly: true,
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
                                'Jumlah Part',
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
                            controller: _jumlahPartController,
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
                              hintText: 'Jumlah Part',
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
                                'Tahun-Bulan Ditemukan',
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
                            controller: _bulanTahunDitemukanController,
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
                              hintText: 'Tahun-Bulan Ditemukan',
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
                                'Keterangan Defect',
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
                            controller: _keteranganDefectController,
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
                              hintText: 'Keterangan Defect',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Ilustrasi',
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _ilustrasiController.text
                              .isEmpty, // Tampilkan teks jika _urlController kosong
                          replacement: InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.1,
                            maxScale: 1.6,
                            child: Image.network(
                              _ilustrasiController.text,
                              height: 400,
                            ),
                          ), // Ganti dengan widget kosong jika _urlController tidak kosong
                          child: const Text('Belum ada gambar di upload'),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Ilustrasi',
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
                            controller: _ilustrasiController,
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
                              hintText: 'URL',
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
                                'Request',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _requestController,
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
                              hintText: 'Request',
                            ),
                            readOnly: true,
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
                                      final String timeStamp =
                                          _timestampController.text;
                                      final String namaSupplier =
                                          _namaSupplierController.text;
                                      final String namaPart =
                                          _namaPartController.text;
                                      final String kodePart =
                                          _kodePartController.text;
                                      final String modelPart =
                                          _modelPartController.text;
                                      final num? jumlahPart = num.tryParse(
                                          _jumlahPartController.text);
                                      final String bulanTahunDitemukan =
                                          _bulanTahunDitemukanController.text;
                                      final String keteranganDefect =
                                          _keteranganDefectController.text;
                                      final String ilustrasi =
                                          _ilustrasiController.text;
                                      final String request =
                                          _requestController.text;

                                      if (action == "update") {
                                        await FirebaseFirestore.instance
                                            .collection('lpp')
                                            .doc(documentSnapshot?.id)
                                            .set({
                                          "timeStamp": timeStamp,
                                          "namaSupplier": namaSupplier,
                                          "namaPart": namaPart,
                                          "kodePart": kodePart,
                                          "modelPart": modelPart,
                                          "jumlahPart": jumlahPart,
                                          "bulanTahunDitemukan":
                                              bulanTahunDitemukan,
                                          "keteranganDefect": keteranganDefect,
                                          "ilustrasi": ilustrasi,
                                          "request": request,
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

  Future<void> _detail([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _timestampController.text = documentSnapshot["timeStamp"];
      _namaSupplierController.text = documentSnapshot["namaSupplier"];
      _namaPartController.text = documentSnapshot["namaPart"];
      _kodePartController.text = documentSnapshot["kodePart"];
      _modelPartController.text = documentSnapshot["modelPart"];
      _jumlahPartController.text = documentSnapshot["jumlahPart"].toString();
      _bulanTahunDitemukanController.text =
          documentSnapshot["bulanTahunDitemukan"];
      _keteranganDefectController.text = documentSnapshot["keteranganDefect"];
      _ilustrasiController.text = documentSnapshot["ilustrasi"];
      _requestController.text = documentSnapshot["request"];
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
                        'Detail Laporan Penyimpangan Part',
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
                                'Time Stamp',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _timestampController,
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
                              hintText: 'TimeStamp',
                            ),
                            readOnly: true,
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
                                'Nama Supplier',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _namaSupplierController,
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
                              hintText: 'Nama Supplier',
                            ),
                            readOnly: true,
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
                            readOnly: true,
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
                                'Kode Part',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _kodePartController,
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
                              hintText: 'Kode Part',
                            ),
                            readOnly: true,
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
                                'Model Part',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _modelPartController,
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
                              hintText: 'Model Part',
                            ),
                            readOnly: true,
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
                                'Jumlah Part',
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
                            controller: _jumlahPartController,
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
                              hintText: 'Jumlah Part',
                            ),
                            readOnly: true,
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
                                'Tahun-Bulan Ditemukan',
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
                            controller: _bulanTahunDitemukanController,
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
                              hintText: 'Tahun-Bulan Ditemukan',
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
                                'Keterangan Defect',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _keteranganDefectController,
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
                              hintText: 'Keterangan Defect',
                            ),
                            readOnly: true,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'Ilustrasi',
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _ilustrasiController.text
                              .isEmpty, // Tampilkan teks jika _urlController kosong
                          replacement: InteractiveViewer(
                            boundaryMargin: const EdgeInsets.all(20),
                            minScale: 0.1,
                            maxScale: 1.6,
                            child: Image.network(
                              _ilustrasiController.text,
                              height: 400,
                            ),
                          ), // Ganti dengan widget kosong jika _urlController tidak kosong
                          child: const Text('Belum ada gambar di upload'),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Ilustrasi',
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
                            controller: _ilustrasiController,
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
                              hintText: 'URL',
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
                                'Request',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _requestController,
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
                              hintText: 'Request',
                            ),
                            readOnly: true,
                          ),
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white70,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          controller: _searchTextBulanTahunDitemukanController,
                          onChanged: (value) {
                            setState(() {
                              searchTextBulanTahunDitemukan = value;
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: "yyyy-MM",
                            labelText: "Cari Tahun-Bulan",
                            prefixIcon: Icon(
                              Icons.search,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8, right: 400),
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
                          'Laporan Penyimpangan Part',
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
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 175,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            color: Colors.lightGreen,
                          ),
                          child: SizedBox(
                            width: 1000,
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
                                  2: FlexColumnWidth(1),
                                  3: FlexColumnWidth(2),
                                  4: FlexColumnWidth(2),
                                  5: FlexColumnWidth(3),
                                  6: FlexColumnWidth(2),
                                },
                                border: TableBorder.all(color: Colors.black),
                                children: const [
                                  TableRow(children: [
                                    Text(
                                      'Nama Supplier',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Nama Part',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Jumlah Part',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Tahun-Bulan Ditemukan',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Keterangan Defect',
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
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 175,
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.lightGreen,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SizedBox(
                            height: 400,
                            width: 1000,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 9,
                                right: 9,
                                bottom: 9,
                              ),
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('lpp')
                                    .orderBy("timeStamp", descending: true)
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
                                  documents = streamSnapshot.data!.docs;
                                  // ToDo Documents list added to filterTitle

                                  if (searchTextBulanTahunDitemukan
                                      .isNotEmpty) {
                                    documents = documents.where((element) {
                                      return element
                                          .get("bulanTahunDitemukan")
                                          .toString()
                                          .toLowerCase()
                                          .contains(
                                              searchTextBulanTahunDitemukan
                                                  .toLowerCase());
                                    }).toList();
                                  }
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
                                            2: FlexColumnWidth(1),
                                            3: FlexColumnWidth(2),
                                            4: FlexColumnWidth(2),
                                            5: FlexColumnWidth(3),
                                            6: FlexColumnWidth(2),
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
                                                    documentSnapshot[
                                                        "namaSupplier"],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    documentSnapshot[
                                                        "namaPart"],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    documentSnapshot[
                                                            "jumlahPart"]
                                                        .toString(),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    documentSnapshot[
                                                        "bulanTahunDitemukan"],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    documentSnapshot[
                                                        "keteranganDefect"],
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
                                                          const EdgeInsets.all(
                                                              4),
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
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Column(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        final documentId =
                                                            documentSnapshot
                                                                .id; // Ganti dengan documentId yang sesuai
                                                        final document =
                                                            await fetchDataById(
                                                                documentId);
                                                        final pdfBytes =
                                                            await createPDF(
                                                                document);
                                                        await Printing
                                                            .layoutPdf(
                                                          onLayout: (PdfPageFormat
                                                                  format) async =>
                                                              pdfBytes,
                                                        );
                                                        if (!mounted) return;
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                PDFScreen(
                                                                    pdfBytes),
                                                          ),
                                                        );
                                                      },
                                                      child: const Text(
                                                          'Generate PDF'),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child:
                                                          ElevatedButton.icon(
                                                        onPressed: () {
                                                          _detail(
                                                              documentSnapshot);
                                                        },
                                                        icon: const Icon(
                                                          Icons.remove_red_eye,
                                                          color: Colors.blue,
                                                        ),
                                                        label: const Text(
                                                          'Detail',
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child:
                                                          ElevatedButton.icon(
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
}
