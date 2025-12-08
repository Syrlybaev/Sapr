import 'package:equatable/equatable.dart';

/// Стержень (элемент конструкции)
class ElementModel extends Equatable {
  final int id; // ID стержня
  final int nodeStartId; // ID узла начала
  final int nodeEndId; // ID узла конца
  final double qy; // [Н/м] поперечная погонная нагрузка (вдоль оси y)
  final double qx; // [Н/м] продольная погонная нагрузка (вдоль оси x)
  final double E; // модуль упругости
  final double A; // площадь сечения
  final double allowableStress; // допускаемое напряжение

  const ElementModel({
    required this.id,
    required this.nodeStartId,
    required this.nodeEndId,
    double? q,
    double? qx,
    double? E,
    double? A,
    double? allowableStress,
  }) : qy = q ?? 0.0,
       qx = qx ?? 0.0,
       E = E ?? 0.0,
       A = A ?? 0.0,
       allowableStress = allowableStress ?? 0.0;

  ElementModel copyWith({
    int? id,
    int? nodeStartId,
    int? nodeEndId,
    double? q,
    double? qx,
    double? E,
    double? A,
    double? allowableStress,
  }) {
    return ElementModel(
      id: id ?? this.id,
      nodeStartId: nodeStartId ?? this.nodeStartId,
      nodeEndId: nodeEndId ?? this.nodeEndId,
      q: q ?? this.qy,
      qx: qx ?? this.qx,
      E: E ?? this.E,
      A: A ?? this.A,
      allowableStress: allowableStress ?? this.allowableStress,
    );
  }

  @override
  List<Object?> get props => [
    id,
    nodeStartId,
    nodeEndId,
    qy,
    qx,
    E,
    A,
    allowableStress,
  ];

  factory ElementModel.fromJson(Map<String, dynamic> json) => ElementModel(
    id: json['id'] as int,
    nodeStartId: json['nodeStartId'] as int,
    nodeEndId: json['nodeEndId'] as int,
    q: (json['q'] as num?)?.toDouble() ?? 0.0,
    qx: (json['qx'] as num?)?.toDouble() ?? 0.0,
    E: (json['E'] as num?)?.toDouble() ?? 0.0,
    A: (json['A'] as num?)?.toDouble() ?? 0.0,
    allowableStress: (json['allowableStress'] as num?)?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nodeStartId': nodeStartId,
    'nodeEndId': nodeEndId,
    'q': qy,
    'qx': qx,
    'E': E,
    'A': A,
    'allowableStress': allowableStress,
  };
}
