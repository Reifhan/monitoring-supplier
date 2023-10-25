import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_buat_lpp.dart';
import 'package:monitoring_audit_supplier/manager_qc/halaman_supplier_mqc.dart';

class HalamanUtamaMQC extends StatefulWidget {
  const HalamanUtamaMQC({super.key});

  @override
  State<HalamanUtamaMQC> createState() => _HalamanUtamaMQCState();
}

class _HalamanUtamaMQCState extends State<HalamanUtamaMQC> {
  String formatTimestampToDisplay(String timestampString) {
    try {
      // Parse the timestamp string into a DateTime object.
      DateTime timestamp = DateTime.parse(timestampString);

      // Define the desired date and time format.
      final DateFormat formatter = DateFormat('d MMMM y HH:mm:ss:S');

      // Format the timestamp.
      String formattedTimestamp = formatter.format(timestamp);

      return formattedTimestamp;
    } catch (e) {
      return "Invalid Timestamp";
    }
  }

  List<DocumentSnapshot> documents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('notifikasi').orderBy("timeStamp", descending: true).snapshots(),
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
                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: documentSnapshot["markAsRead"] == "false" ? Colors.blue : Colors.white30,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          Text(
                            documentSnapshot["notif"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatTimestampToDisplay(documentSnapshot["timeStamp"]),
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Visibility(
                            visible: documentSnapshot["markAsRead"] == "false",
                            child: ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance.collection('notifikasi').doc(documentSnapshot.id).set({
                                  "notif": documentSnapshot["notif"],
                                  "timeStamp": documentSnapshot["timeStamp"],
                                  "markAsRead": "true",
                                });
                              },
                              child: const Text('OK'),
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
      appBar: AppBar(
        actions: [
          Builder(
            builder: (context) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.notifications_active),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                label: const Text("Notifikasi"),
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        flexibleSpace: Container(
          margin: const EdgeInsets.only(left: 8, right: 150),
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Hero(
                  tag: "wima-logo",
                  child: Image.asset(
                    'assets/images/wima-logo.png',
                    height: 300,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 50),
                child: Text(
                  'Selamat Datang Manager QC',
                  style: TextStyle(
                    fontSize: 30,
                  ),
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
