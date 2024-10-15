class VendorModel {
  VendorModel({
    required this.vendorId,
    required this.approved,
    required this.businessName,
    required this.city,
    required this.state,
    required this.country,
    required this.email,
    required this.phoneNumber,
    required this.imageUrl,
    required this.rnc,
    required this.tax,
  });

  String vendorId;
  bool approved;
  String businessName;
  String city;
  String state;
  String country;
  String email;
  String phoneNumber;
  String imageUrl;
  String rnc;
  String tax;

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
        vendorId: json['vendorId'],
        approved: json['approved'],
        businessName: json['businessName'],
        city: json['city'],
        state: json['state'],
        country: json['country'],
        email: json['email'],
        phoneNumber: json['phoneNumber'],
        imageUrl: json['imageUrl'],
        rnc: json['rnc'],
        tax: json['tax'],
      );

  Map<String, dynamic> toJson() => {
        'vendorId': vendorId,
        'approved': approved,
        'businessName': businessName,
        'city': city,
        'state': state,
        'country': country,
        'email': email,
        'phoneNumber': phoneNumber,
        'imageUrl': imageUrl,
        'rnc': rnc,
        'tax': tax,
      };
}
