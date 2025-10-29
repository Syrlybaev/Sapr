import 'package:equatable/equatable.dart';

import 'package:uuid/uuid.dart';

/// Стержень (элемент конструкции)
class Element extends Equatable {
  final String id;
  final String nodeStartId;
  final String nodeEndId;
  final double q; // [Н/м]
  final double allowableStress; // допускаемое напряжение
  final double E; // модуль упругости
  final double A; // площадь сечения

  Element({
    String? id,
    required this.nodeStartId,
    required this.nodeEndId,
    double? q,
    double? E,
    double? A,
    double? allowableStress,
  }) : id = id ?? Uuid().v4(),
       q = q ?? 0.0,
       E = E ?? 0.0,
       A = A ?? 0.0,
       allowableStress = allowableStress ?? 0.0;

  Element copyWith({
    String? nodeStartId,
    String? nodeEndId,
    double? E,
    double? A,
    double? allowableStress,
  }) {
    return Element(
      id: id,
      nodeStartId: nodeStartId ?? this.nodeStartId,
      nodeEndId: nodeEndId ?? this.nodeEndId,
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
    E,
    A,
    allowableStress,
  ];
}


 