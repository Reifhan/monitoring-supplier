import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_buat_lpp.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_lihat_part.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_supplier_mqc.dart';

class HalamanUtamaMQC extends StatefulWidget {
  const HalamanUtamaMQC({super.key});

  @override
  State<HalamanUtamaMQC> createState() => _HalamanUtamaMQCState();
}

class _HalamanUtamaMQCState extends State<HalamanUtamaMQC> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.logout,
                ),
                label: const Text('Logout'),
              ),
              const Text(
                'Selamat Datang Manager QC',
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SizedBox.expand(
        child: Material(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Material(
                    color: const Color.fromARGB(166, 7, 86, 176),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HalamanSupplierMQC(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Icon(
                              Icons.fire_truck_outlined,
                              size: 50,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              "Data Part Defect Bulanan",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Material(
                    color: const Color.fromARGB(166, 118, 223, 132),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const LihatPart(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Icon(
                              Icons.perm_data_setting_outlined,
                              size: 50,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              "List Part",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Material(
                    color: const Color.fromARGB(166, 202, 216, 231),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const HalamanBuatLPP(),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Icon(
                              Icons.document_scanner_outlined,
                              size: 50,
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              "Buat LPP",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
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
        ),
      ),
    );
  }
}
