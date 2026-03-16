class SlotModel {
  final int? id;
  final String? slotDate;
  final int? shift;
  final String? shiftName;
  final String? cutoffTime;
  final String? createdAt;
  final String? updatedAt;
  final int? status;
  final int? unionId;

  SlotModel({
    this.id,
    this.slotDate,
    this.shift,
    this.shiftName,
    this.cutoffTime,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.unionId,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as int?,
      slotDate: json['slot_date']?.toString(),
      shift: json['shift'] as int?,
      shiftName: json['shift_name']?.toString(),
      cutoffTime: json['cutoff_time']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      status: json['status'] as int?,
      unionId: json['union_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slot_date': slotDate,
      'shift': shift,
      'shift_name': shiftName,
      'cutoff_time': cutoffTime,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'status': status,
      'union_id': unionId,
    };
  }
}