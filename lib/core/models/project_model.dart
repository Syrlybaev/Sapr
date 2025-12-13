import 'package:equatable/equatable.dart';
import 'package:saprbar_desktop/core/models/element_model.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';

class ProjectModel extends Equatable {
  final String name;
  final List<NodeModel> nodes;
  final List<ElementModel> elements;
  final bool fixLeft;
  final bool fixRight;

  const ProjectModel({
    required this.name,
    required this.nodes,
    required this.elements,
    bool? fixLeft,
    bool? fixRight,
  }) : fixLeft = fixLeft ?? false,
       fixRight = fixRight ?? false;

  /// Удалить последний узел и связанные стержни
  /// Возвращает новый ProjectModel (не мутирует текущий)
  ProjectModel deleteLastNode() {
    if (nodes.isEmpty) return this;

    final List<NodeModel> newNodes = List.from(nodes)..removeLast();
    final int deletedNodeId = nodes.last.id;

    // Удаляем стержни, связанные с удалённым узлом
    final List<ElementModel> newElements =
        elements
            .where(
              (e) =>
                  e.nodeStartId != deletedNodeId &&
                  e.nodeEndId != deletedNodeId,
            )
            .toList();

    return copyWith(nodes: newNodes, elements: newElements);
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      name: json['name'] as String,
      nodes: (json['nodes'] as List).map((e) => NodeModel.fromJson(e)).toList(),
      elements:
          (json['elements'] as List)
              .map((e) => ElementModel.fromJson(e))
              .toList(),
      fixLeft: json['fixLeft'] as bool?,
      fixRight: json['fixRight'] as bool?,
    );
  }

  Map<String, dynamic> get toJson => {
    'name': name,
    'nodes': nodes.map((e) => e.toJson()).toList(),
    'elements': elements.map((e) => e.toJson()).toList(),
    'fixLeft': fixLeft,
    'fixRight': fixRight,
  };

  ProjectModel copyWith({
    String? name,
    List<NodeModel>? nodes,
    List<ElementModel>? elements,
    bool? fixLeft,
    bool? fixRight,
  }) {
    return ProjectModel(
      name: name ?? this.name,
      nodes: nodes ?? this.nodes,
      elements: elements ?? this.elements,
      fixLeft: fixLeft ?? this.fixLeft,
      fixRight: fixRight ?? this.fixRight,
    );
  }

  @override
  List<Object?> get props => [name, nodes, elements, fixLeft, fixRight];
}
