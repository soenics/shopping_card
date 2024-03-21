class ItemModel {
  String id;
  String img;
  String title;
  double price;
  int count;

  ItemModel(
      {required this.id,
      required this.img,
      required this.title,
      required this.price,
      required this.count});

  Map<String, dynamic> toJson() {
    return {
      "id": this.id,
      "image": this.img,
      "title": this.title,
      "price": this.price,
      "count": this.count,
    };
  }

  factory ItemModel.fromJson(Map json) {
    return ItemModel(
        id: json["id"],
        img: json["image"],
        title: json["title"],
        price: json["price"],
        count: json["count"]);
  }
}
