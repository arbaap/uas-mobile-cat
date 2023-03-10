import 'dart:async';
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

  Future<List<TransactionWithCategory>> getAllTransaction(int month) async {
    List<TransactionWithCategory> listData = List.empty(growable: true);
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ]));

    List<TypedResult> data = await query.get();
    if (data.isNotEmpty) {
      for (var d in data) {
        if (d.readTable(transactions).transaction_date.month == month) {
          listData.add(
            TransactionWithCategory(
              d.readTable(transactions),
              d.readTable(categories),
            ),
          );
        }
      }
    }
    return listData;
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
