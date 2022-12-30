import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uas_mobile/models/category.dart';
import 'package:uas_mobile/models/transaction.dart';
import 'package:uas_mobile/models/transaction_with_category.dart';

part 'database.g.dart';

@DriftDatabase(
    // relative import for the drift file. Drift also supports `package:`
    // imports
    tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD category

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  Future deleteCategoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // TRANSACTION

  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  Stream<List<TransactionWithCategory>> getAllTransaction() {
    // final query = (select(transactions).join([
    //   innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    // ]));
    // log('query:: ${query.constructQuery().sql}');
    // log('ge:: ${((await query.get()) as List<TypedResult>).toString()}');

    List<TransactionWithCategory> listData = List.empty(growable: true);

    // query.watch().map((rows) {
    //   log('rows');
    //   log('rows ' + rows.toString());
    // });
    // log('list data ' + listData.toString());
    // return listData;
    // // log('transa:: ${(await query.watch().map((event) => event.toString()).toList()).toString()}');
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ]));
    // query.watch().map((rows) {
    //   rows.map((row) {
    //     listData.add(TransactionWithCategory(
    //         row.readTable(transactions), row.readTable(categories)));
    //   });
    // });
    // return query.watch().listen(
    //   (event) {
    //     log('eleng : ${event.length}');
    //     return TransactionWithCategory(
    //         event.readTable(transactions), event.readTable(categories));
    //   },
    // );

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions), row.readTable(categories));
      }).toList();
    });

    // map((rows) {
    //   rows.map((row) {
    //     listData.add(TransactionWithCategory(
    //         row.readTable(transactions), row.readTable(categories)));
    //   });
    // });
    // return listData;
  }

  Future updateTransactionRepo(int id, int amount, int categoryId,
      DateTime transacationDate, String nameDetail) {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
        TransactionsCompanion(
            name: Value(nameDetail),
            amount: Value(amount),
            category_id: Value(categoryId),
            transaction_date: Value(transacationDate)));
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    // final dbFolder = await getApplicationDocumentsDirectory();
    final dbFolder = await getExternalStorageDirectory();
    final file = File(p.join(dbFolder!.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
