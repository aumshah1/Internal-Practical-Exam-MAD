class Payment {
  final String id;
  final String memberId;
  final double amount;
  final String method;
  final String paidAt; // ISO8601
  final String status;
  final String note;

  Payment({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.method,
    required this.paidAt,
    this.status = 'paid',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'amount': amount,
        'method': method,
        'paidAt': paidAt,
        'status': status,
        'note': note,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        amount: (json['amount'] as num).toDouble(),
        method: json['method'] as String,
        paidAt: json['paidAt'] as String,
        status: json['status'] as String? ?? 'paid',
        note: json['note'] as String? ?? '',
      );
}
