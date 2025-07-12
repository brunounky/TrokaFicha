import 'package:isar/isar.dart';

part 'product_model.g.dart';

@collection
@Name("ProductCollection") 
class Product {
  Id id = Isar.autoIncrement;

  String name;
  double unitValue;
  String? eventName;

  Product({
    required this.name,
    required this.unitValue,
    this.eventName,
  });
}
