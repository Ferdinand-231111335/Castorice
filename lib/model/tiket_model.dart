class Ticket {
  final int? id;
  final String hadiah;
  final int poin;
  final String tanggal;

  Ticket({
    this.id,
    required this.hadiah,
    required this.poin,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hadiah': hadiah,
      'poin': poin,
      'tanggal': tanggal,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      hadiah: map['hadiah'],
      poin: map['poin'],
      tanggal: map['tanggal'],
    );
  }
}