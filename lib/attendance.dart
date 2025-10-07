class AttendanceRecord {
  final String id;
  final String memberId;
  final String at; // ISO8601 date-time
  final String note;

  AttendanceRecord({required this.id, required this.memberId, required this.at, this.note = ''});

  Map<String, dynamic> toJson() => {'id': id, 'memberId': memberId, 'at': at, 'note': note};

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        id: json['id'] as String,
        memberId: json['memberId'] as String,
        at: json['at'] as String,
        note: json['note'] as String? ?? '',
      );
}
