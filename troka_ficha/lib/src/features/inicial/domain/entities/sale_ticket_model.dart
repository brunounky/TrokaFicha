//modelagem do banco de dados

import 'package:isar/isar.dart';

part 'sale_ticket_model.g.dart'; 

@collection
class SaleTicket {
  Id id = Isar.autoIncrement; 

  String eventName;
  String productName;
  double unitValue;
  int quantity;
  double totalValue;
  String paymentMethod;
  DateTime saleDate; 

  SaleTicket({
    required this.eventName,
    required this.productName,
    required this.unitValue,
    this.quantity = 1,
    required this.totalValue,
    required this.paymentMethod,
    required this.saleDate,
  });
}
