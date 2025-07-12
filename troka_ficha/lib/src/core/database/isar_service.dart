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
    try {
      if (Isar.instanceNames.isEmpty) {
        print('IsarService: Abrindo novo banco de dados Isar...');
        final dir = await getApplicationDocumentsDirectory();
        final isarInstance = await Isar.open(
          [SaleTicketSchema, ProductSchema],
          directory: dir.path,
          inspector: true,
        );
        print('IsarService: Banco de dados Isar aberto com sucesso.');
        return isarInstance;
      }
      print('IsarService: Retornando instância Isar existente.');
      return Future.value(Isar.getInstance());
    } catch (e) {
      print('IsarService ERROR: Erro ao abrir ou inicializar o banco de dados Isar: $e');
      rethrow;
    }
  }

  Future<void> addSaleTicket(SaleTicket ticket) async {
    final isar = await db;
    try {
      await isar.writeTxn(() async {
        await isar.saleTickets.put(ticket);
        print('IsarService: Ficha de venda adicionada/atualizada: ${ticket.productName}');
      });
    } catch (e) {
      print('IsarService ERROR: Erro ao adicionar/atualizar ficha de venda: $e');
    }
  }

  Future<List<SaleTicket>> getAllSaleTickets() async {
    final isar = await db;
    try {
      final tickets = await isar.saleTickets.where().findAll();
      print('IsarService: ${tickets.length} fichas de venda carregadas.');
      return tickets;
    } catch (e) {
      print('IsarService ERROR: Erro ao carregar fichas de venda: $e');
      return [];
    }
  }

  Future<void> addProduct(Product product) async {
    final isar = await db;
    try {
      await isar.writeTxn(() async {
        await isar.products.put(product);
        print('IsarService: Produto adicionado/atualizado: ${product.name}');
      });
    } catch (e) {
      print('IsarService ERROR: Erro ao adicionar/atualizar produto: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    final isar = await db;
    try {
      final products = await isar.products.where().findAll();
      print('IsarService: ${products.length} produtos carregados.');
      return products;
    } catch (e) {
      print('IsarService ERROR: Erro ao carregar produtos: $e');
      return [];
    }
  }

  Future<void> deleteProduct(int productId) async {
    final isar = await db;
    try {
      await isar.writeTxn(() async {
        final success = await isar.products.delete(productId);
        if (success) {
          print('IsarService: Produto com ID $productId excluído com sucesso.');
        } else {
          print('IsarService WARNING: Produto com ID $productId não encontrado para exclusão.');
        }
      });
    } catch (e) {
      print('IsarService ERROR: Erro ao excluir produto com ID $productId: $e');
    }
  }

  Future<void> cleanDb() async {
    final isar = await db;
    try {
      await isar.writeTxn(() => isar.clear());
      print('IsarService: Banco de dados limpo.');
    } catch (e) {
      print('IsarService ERROR: Erro ao limpar banco de dados: $e');
    }
  }
}
