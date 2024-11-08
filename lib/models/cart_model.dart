class CartModel {
  final String idCart;
  final int idClass;
  final String userId;

  CartModel({
    required this.idCart,
    required this.idClass,
    required this.userId,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      idCart: json['idCart'] as String,
      idClass: int.tryParse(json['idClass'].toString()) ?? json['idClass'],
      userId: json['userId'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCart': idCart,
      'idClass': idClass,
      'userId': userId,
    };
  }
}