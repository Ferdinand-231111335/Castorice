class Poin {
  final int? id;
  final int total;

  Poin({this.id, required this.total});

  Map<String, dynamic> toMap() {
    return {"id": id, "total": total};
  }

  factory Poin.fromMap(Map<String, dynamic> map) {
    return Poin(
      id: map["id"],
      total: map["total"],
    );
  }
}
