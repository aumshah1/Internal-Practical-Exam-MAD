class MembershipPlan {
  final String id;
  final String name;
  final double price; // price per billing cycle
  final int durationMonths; // 1 = monthly, 12 = yearly

  MembershipPlan({required this.id, required this.name, required this.price, required this.durationMonths});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price, 'durationMonths': durationMonths};

  factory MembershipPlan.fromJson(Map<String, dynamic> json) => MembershipPlan(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        durationMonths: json['durationMonths'] as int,
      );
}
