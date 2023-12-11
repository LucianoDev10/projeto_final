class Rota {
  String? distance;
  double? price; // Alteração aqui
  String? mapUrl;

  Rota({this.distance, this.price, this.mapUrl});

  Rota.fromJson(Map<String, dynamic> json) {
    distance = json['distance'];
    price = json['price']?.toDouble(); // Modificação aqui
    mapUrl = json['mapUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['distance'] = this.distance;
    data['price'] = this.price;
    data['mapUrl'] = this.mapUrl;
    return data;
  }
}
