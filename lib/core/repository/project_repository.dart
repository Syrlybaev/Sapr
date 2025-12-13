// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';
import 'package:saprbar_desktop/core/models/project_model.dart';

/// Репозиторий для работы с проектами (узлы + стержни)
class ProjectRepository {
  final Directory projectsDir;
  ProjectModel? _currentProject;

  ProjectRepository({required this.projectsDir});

  /// Создать новый проект
  Future<void> createProject({required String name}) async {
    _currentProject = null;
    final filePath = '${projectsDir.path}/$name.json';
    final file = File(filePath);

    if (await file.exists()) {
      throw Exception('Проект с именем "$name" уже существует.');
    }

    final project = ProjectModel(name: name, nodes: [], elements: []);
    await file.writeAsString(jsonEncode(project.toJson));
    _currentProject = project;
  }

  /// Загрузить проект по имени
  Future<ProjectModel?> loadProject({required String name}) async {
    _currentProject = null;
    final file = File('${projectsDir.path}/$name.json');
    if (!await file.exists()) throw Exception('Такой проект не найден');

    final content = await file.readAsString();
    final data = jsonDecode(content);
    _currentProject = ProjectModel.fromJson(data);
    return _currentProject;
  }

  Future<void> updateProject(ProjectModel project) async {
    _currentProject = project;
    await _saveCurrentProject();
  }

  /// Сохранить текущий проект
  Future<void> _saveCurrentProject() async {
    if (_currentProject == null) {
      throw Exception('Сохранять нечего, проекта нету');
    }
    final file = File('${projectsDir.path}/${_currentProject!.name}.json');
    await file.writeAsString(jsonEncode(_currentProject!.toJson));
  }

  // Удалить последний узел
  void deleteNode() {
    _currentProject!.deleteLastNode();
  }

  /// Получить текущий проект
  ProjectModel? get currentProject => _currentProject;
}
