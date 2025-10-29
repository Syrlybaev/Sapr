import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';


/// Узел конструкции
class Node extends Equatable {
  final String id;
  final double x; // корды
  final double y;// корды
  final double loadX; // [Н]
  final double loadY; // [Н]
  final bool fixX; // запрещено перемещение по X
  final bool fixY; // запрещено перемещение по Y
  final bool fixZ; // запрещёно перемещение по Z

  Node({
    String? id,
    required this.x,
    required this.y,
    double? loadX,
    double? loadY,
    bool? fixX,
    bool? fixY,
    bool? fixZ,
  })  : id = id ?? Uuid().v4(),
        loadX = loadX ?? 0.0,
        loadY = loadY ?? 0.0,
        fixX = fixX ?? false,
        fixY = fixY ?? false,
        fixZ = fixZ ?? false;

  Node copyWith({
    String? id,
    double? x,
    double? y,
    double? loadX,
    double? loadY,
    bool? fixX,
    bool? fixY, 
    bool? fixZ,
  }) {
    return Node(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      loadX: loadX ?? this.loadX,
      loadY: loadY ?? this.loadY,
      fixX: fixX ?? this.fixX,
      fixY: fixY ?? this.fixY,
      fixZ: fixZ ?? this.fixZ,
    );
  }

  @override
  List<Object?> get props => [id, x, y, loadX, loadY, fixX, fixY, fixZ];
}





  // Map<String, dynamic> toJson() => {
  //       'id': id,
  //       'x': x,
  //       'y': y,
  //       'LoadX': LoadX,
  //       'LoadY': LoadY,
  //       'fixX': fixX,
  //       'fixY': fixY,
  //       'fixRotation': fixRotation,
  //     };
      
  // factory Node.fromJson(Map<String, dynamic> j) => Node(
  //       id: j['id'],
  //       x: (j['x'] as num).toDouble(),
  //       y: (j['y'] as num).toDouble(),
  //       support: j['support'] != null
  //           ? SupportModel.fromJson(Map<String, dynamic>.from(j['support']))
  //           : const SupportModel(),
  //       pointLoad: j['pointLoad'] != null
  //           ? PointLoadModel.fromJson(Map<String, dynamic>.from(j['pointLoad']))
  //           : null,
  //     );

  // double distanceTo(Node other) =>
  //     math.sqrt(math.pow(x - other.x, 2) + math.pow(y - other.y, 2));
