import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class HalamanBuatLPP extends StatefulWidget {
  const HalamanBuatLPP({super.key});

  @override
  State<HalamanBuatLPP> createState() => _HalamanBuatLPPState();
}

class _HalamanBuatLPPState extends State<HalamanBuatLPP> {
  late Stream<DateTime> timerStream;
  late StreamSubscription<DateTime> timerSubscription;
  DateTime currentDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    // Create a Stream that emits a DateTime every second
    timerStream = Stream.periodic(const Duration(seconds: 1), (count) {
      currentDateTime = DateTime.now();
      return currentDateTime;
    });

    // Subscribe to the timerStream
    timerSubscription = timerStream.listen((dateTime) {
      setState(() {
        currentDateTime = dateTime;
      });
    });
  }

  @override
  void dispose() {
    timerSubscription.cancel();
    _bulanTahunDitemukanController.dispose();
    super.dispose();
  }

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();
  File? _image;
  final _filePath = '';

  Future<void> _pickImage() async {
    if (kIsWeb) {
      _uploadFile(_filePath);
    } else {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _uploadImage(_image);
      }
    }
  }

  Future<void> _uploadFile(String filePath) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      final fileName = result.files.first.name;
      UploadTask uploadTask =
          FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes!);

      await uploadTask;

      if (uploadTask.snapshot.state == TaskState.success) {
        final String downloadURL = await FirebaseStorage.instance
            .ref('uploads/$fileName')
            .getDownloadURL();
        setState(() {
          _ilustrasiController.text = downloadURL;
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upload file'),
          ),
        );
      }
    }
  }

  Future<void> _uploadImage(File? imageFile) async {
    if (imageFile == null) return;

    final Reference storageReference =
        _storage.ref().child('images/${DateTime.now()}.jpg');
    UploadTask uploadTask = storageReference.putFile(imageFile);

    await uploadTask;

    if (uploadTask.snapshot.state == TaskState.success) {
      final String downloadURL = await storageReference.getDownloadURL();
      setState(() {
        _ilustrasiController.text = downloadURL;
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image'),
        ),
      );
    }
  }

  // Text fields controllers
  final TextEditingController _searchTextBulanTahunDitemukanController =
      TextEditingController();

  // Search text variable
  String searchTextBulanTahunDitemukan = "";

  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showMonthPicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _updateDateTextField();
      });
    }
  }

  void _updateDateTextField() {
    String formattedDate = "${selectedDate.year}-${selectedDate.month}";
    _bulanTahunDitemukanController.text = formattedDate;
  }

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

  Future<void> _create() async {
    String action = "create";

    await showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Material(
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
                child: Column(
                  children: [
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Tambah Laporan Penyimpangan Part',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required!';
                                }
                                return null;
                              },
                              controller: _namaSupplierController,
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
                                hintText: 'Nama Supplier',
                                prefixIcon: IconButton(
                                  onPressed: _namaSupplierController.clear,
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
                                hintText: 'Nama Part',
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
                                hintText: 'Kode Part',
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
                                hintText: 'Model Part',
                                prefixIcon: IconButton(
                                  onPressed: _modelPartController.clear,
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
                                hintText: 'Jumlah Part',
                                prefixIcon: IconButton(
                                  onPressed: _jumlahPartController.clear,
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
                              onTap: () {
                                _selectDate(context);
                              },
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required!';
                                }
                                return null;
                              },
                              controller: _bulanTahunDitemukanController,
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
                                hintText: 'Tahun-Bulan Ditemukan',
                                prefixIcon: IconButton(
                                  onPressed:
                                      _bulanTahunDitemukanController.clear,
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
                                hintText: 'Keterangan Defect',
                                prefixIcon: IconButton(
                                  onPressed: _keteranganDefectController.clear,
                                  icon: const Icon(Icons.clear),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('Pick an Image'),
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
                                hintText: 'URL',
                                prefixIcon: IconButton(
                                  onPressed: _ilustrasiController.clear,
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
                                hintText: 'Request',
                                prefixIcon: IconButton(
                                  onPressed: _requestController.clear,
                                  icon: const Icon(Icons.clear),
                                ),
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
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                                        final String statusValidasi =
                                            _statusValidasiController.text;

                                        if (action == "create") {
                                          await FirebaseFirestore.instance
                                              .collection('lpp')
                                              .add({
                                            "timeStamp": timeStamp,
                                            "namaSupplier": namaSupplier,
                                            "namaPart": namaPart,
                                            "kodePart": kodePart,
                                            "modelPart": modelPart,
                                            "jumlahPart": jumlahPart,
                                            "bulanTahunDitemukan":
                                                bulanTahunDitemukan,
                                            "keteranganDefect":
                                                keteranganDefect,
                                            "ilustrasi": ilustrasi,
                                            "request": request,
                                            "statusValidasi": statusValidasi,
                                          });
                                        }

                                        // Clear the text fields
                                        _timestampController.text = "";
                                        _namaSupplierController.text = "";
                                        _namaPartController.text = "";
                                        _kodePartController.text = "";
                                        _modelPartController.text = "";
                                        _jumlahPartController.text = "";
                                        _bulanTahunDitemukanController.text =
                                            "";
                                        _keteranganDefectController.text = "";
                                        _ilustrasiController.text = "";
                                        _requestController.text = "";

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
          ),
        );
      },
    );
  }

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
                        'Ubah Laporan Penyimpangan Part',
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _namaSupplierController,
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
                              hintText: 'Nama Supplier',
                              prefixIcon: IconButton(
                                onPressed: _namaSupplierController.clear,
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
                              hintText: 'Nama Part',
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
                              hintText: 'Kode Part',
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
                              hintText: 'Model Part',
                              prefixIcon: IconButton(
                                onPressed: _modelPartController.clear,
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
                              hintText: 'Jumlah Part',
                              prefixIcon: IconButton(
                                onPressed: _jumlahPartController.clear,
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
                            onTap: () {
                              _selectDate(context);
                            },
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required!';
                              }
                              return null;
                            },
                            controller: _bulanTahunDitemukanController,
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
                              hintText: 'Tahun-Bulan Ditemukan',
                              prefixIcon: IconButton(
                                onPressed: _bulanTahunDitemukanController.clear,
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
                              hintText: 'Keterangan Defect',
                              prefixIcon: IconButton(
                                onPressed: _keteranganDefectController.clear,
                                icon: const Icon(Icons.clear),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick an Image'),
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
                              hintText: 'URL',
                              prefixIcon: IconButton(
                                onPressed: _ilustrasiController.clear,
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
                              hintText: 'Request',
                              prefixIcon: IconButton(
                                onPressed: _requestController.clear,
                                icon: const Icon(Icons.clear),
                              ),
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
                                    Icons.edit,
                                  ),
                                  label: const Text(
                                    "Ubah",
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
                                      final String statusValidasi =
                                          _statusValidasiController.text;

                                      if (action == "create") {
                                        await FirebaseFirestore.instance
                                            .collection('lpp')
                                            .doc(documentSnapshot!.id)
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
                                          "statusValidasi": statusValidasi,
                                        });
                                      }

                                      // Clear the text fields
                                      _timestampController.text = "";
                                      _namaSupplierController.text = "";
                                      _namaPartController.text = "";
                                      _kodePartController.text = "";
                                      _modelPartController.text = "";
                                      _jumlahPartController.text = "";
                                      _bulanTahunDitemukanController.text = "";
                                      _keteranganDefectController.text = "";
                                      _ilustrasiController.text = "";
                                      _requestController.text = "";

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

  // Deleting a product by id
  Future<void> _delete(String productId) async {
    await FirebaseFirestore.instance.collection('lpp').doc(productId).delete();

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
                    margin: const EdgeInsets.only(left: 8, right: 350),
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
                  Container(
                    margin: const EdgeInsets.only(
                      right: 100,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 120,
                            child: Material(
                              color: const Color.fromARGB(209, 240, 236, 12),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  // Clear the text fields
                                  _timestampController.text = "$timestamp";
                                  _namaSupplierController.text = "";
                                  _namaPartController.text = "";
                                  _kodePartController.text = "";
                                  _modelPartController.text = "";
                                  _jumlahPartController.text = "";
                                  _bulanTahunDitemukanController.text = "";
                                  _keteranganDefectController.text = "";
                                  _ilustrasiController.text = "";
                                  _requestController.text = "";
                                  _statusValidasiController.text =
                                      "Belum Divalidasi";
                                  _create();
                                },
                                child: const Row(
                                  children: [
                                    Icon(Icons.add),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Tambah LPP",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
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
                      Container(
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

                                if (searchTextBulanTahunDitemukan.isNotEmpty) {
                                  documents = documents.where((element) {
                                    return element
                                        .get("bulanTahunDitemukan")
                                        .toString()
                                        .toLowerCase()
                                        .contains(searchTextBulanTahunDitemukan
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
                                                  documentSnapshot["namaPart"],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                  documentSnapshot["jumlahPart"]
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
                                              Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: ElevatedButton.icon(
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
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        _update(
                                                            documentSnapshot);
                                                      },
                                                      icon: const Icon(
                                                        Icons.note_alt,
                                                        color: Colors.yellow,
                                                      ),
                                                      label: const Text(
                                                        'Ubah',
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        AlertDialog delete =
                                                            AlertDialog(
                                                          title: const Text(
                                                            "Peringatan!",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          content: SizedBox(
                                                            height: 200,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
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
                                                                _delete(
                                                                    documentSnapshot
                                                                        .id);
                                                                Navigator.pop(
                                                                    context);
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
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              delete,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons
                                                            .restore_from_trash_outlined,
                                                        color: Colors.red,
                                                      ),
                                                      label: const Text(
                                                        'Buang',
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
