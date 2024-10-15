class BuyerModel {
  BuyerModel({
    required this.buyerId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });

  String buyerId;
  String fullName;
  String email;
  String phoneNumber;
  String address;

  factory BuyerModel.fromJson(Map<String, dynamic> json) => BuyerModel(
        buyerId: json['buyerId'],
        fullName: json['fullName'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        address: json['address'],
      );

  Map<String, dynamic> toJson() => {
        'buyerId': buyerId,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
      };
}
