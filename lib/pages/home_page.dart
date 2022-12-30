import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:uas_mobile/models/database.dart';
import 'package:uas_mobile/models/transaction_with_category.dart';
import 'package:uas_mobile/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();
  int totalPengeluaranBulanan = 0;
  int totalPemasukanBulanan = 0;
  int totalTransaksiBulanan = 0;
  var nowMonth = DateFormat.yMMMM('id').format(DateTime.now());
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    log("asdasdasdas");
    setTotalSatuBulan();
  }

  void setTotalSatuBulan() {
    database.getAllTransaction(DateTime.now().month).then((value) {
      log('le: $value');
      for (var v in value) {
        TransactionWithCategory transt = v;
        log('cate: ${transt.category}');
        if (transt.category.type == 2) {
          totalPengeluaranBulanan += transt.transaction.amount;
        } else if (transt.category.type == 1) {
          totalPemasukanBulanan += transt.transaction.amount;
        }
      }
      totalTransaksiBulanan = totalPemasukanBulanan - totalPengeluaranBulanan;
      log('total keluar ${totalPengeluaranBulanan}');
      log('total masuk ${totalPemasukanBulanan}');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TransactionPage(
                transactionWithCategory: null,
              ),
            ),
          );
          setTotalSatuBulan();
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pengeluaran $nowMonth",
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Rp${totalPengeluaranBulanan}',
                      style: GoogleFonts.montserrat(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.download,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Pemasukan",
                                  style: GoogleFonts.montserrat(
                                      color: Colors.grey[800], fontSize: 12),
                                ),
                                Text(
                                  "Rp${totalPemasukanBulanan}",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.insert_chart_outlined_outlined,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total transaksi",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[800],
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Rp$totalTransaksiBulanan",
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey[800],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              // Konten Transaksi
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Transaksi",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder<List<TransactionWithCategory>>(
                stream: database.getTransactionByDateRepo(widget.selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData) {
                      if (snapshot.data!.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 10,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () async {
                                          await database.deleteTransactionRepo(
                                              snapshot
                                                  .data![index].transaction.id);
                                          setState(() {});
                                        },
                                      ),
                                      const SizedBox(width: 10),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionPage(
                                                transactionWithCategory:
                                                    snapshot.data![index],
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  title: Text(
                                    'Rp${snapshot.data![index].transaction.amount.toString()}',
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data![index].category.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        snapshot.data![index].transaction.name,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    ],
                                  ),
                                  leading: Container(
                                    child:
                                        (snapshot.data![index].category.type ==
                                                2)
                                            ? const Icon(
                                                Icons.upload,
                                                color: Colors.red,
                                              )
                                            : const Icon(
                                                Icons.download,
                                                color: Colors.green,
                                              ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text("Data Kosong"));
                      }
                    } else {
                      return const Center(child: Text("Tidak ada data"));
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
