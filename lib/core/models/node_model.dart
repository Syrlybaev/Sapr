import 'package:equatable/equatable.dart';

/// Узел конструкции
class NodeModel extends Equatable {
  final int id;
  final double x; // координата x
  final double y = 0.0; // координата y
  final double loadX; // [Н] сосредоточенная продольная сила (вдоль оси x)
  final double loadY; // [Н] сосредоточенная поперечная сила (вдоль оси y)

  const NodeModel({
    required this.id,
    required this.x,

    double? loadX,
    double? loadY,
    bool? fixX,
    bool? fixY,
  }) : loadX = loadX ?? 0.0,
       loadY = loadY ?? 0.0;

  NodeModel copyWith({
    int? id,
    double? x,
    double? y,
    double? loadX,
    double? loadY,
    bool? fixX,
    bool? fixY,
  }) {
    return NodeModel(
      id: id ?? this.id,
      x: x ?? this.x,
      loadX: loadX ?? this.loadX,
      loadY: loadY ?? this.loadY,
    );
  }

  factory NodeModel.fromJson(Map<String, dynamic> json) => NodeModel(
    id: json['id'] as int,
    x: (json['x'] as num).toDouble(),

    loadX: (json['loadX'] as num?)?.toDouble() ?? 0.0,
    loadY: (json['loadY'] as num?)?.toDouble() ?? 0.0,
    fixX: json['fixX'] ?? false,
    fixY: json['fixY'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'loadX': loadX,
    'loadY': loadY,
  };

  @override
  List<Object?> get props => [id, x, loadX, loadY];
}
