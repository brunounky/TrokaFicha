import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:troka_ficha/src/features/inicial/domain/entities/sale_ticket_model.dart';
import 'package:troka_ficha/src/features/inicial/domain/entities/product_model.dart'; 

class IsarService {
  late Future<Isar> db;

  IsarService() {
    db = openDB();
  }

  Future<Isar> openDB() async {
    if (Isar.instanceNames.isEmpty) {
      final dir = await getApplicationDocumentsDirectory();
      return await Isar.open(
        [SaleTicketSchema, ProductSchema],
        directory: dir.path,
        inspector: true,
      );
    }
    return Future.value(Isar.getInstance());
  }

  Future<void> addSaleTicket(SaleTicket ticket) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.saleTickets.put(ticket);
    });
  }

  Future<List<SaleTicket>> getAllSaleTickets() async {
    final isar = await db;
    return await isar.saleTickets.where().findAll();
  }

  Future<void> addProduct(Product product) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.products.put(product);
    });
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    return await isar.products.where().findAll();
  }

  Future<void> cleanDb() async {
    final isar = await db;
    await isar.writeTxn(() => isar.clear());
  }
}
