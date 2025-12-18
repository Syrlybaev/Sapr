import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saprbar_desktop/core/models/element_model.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';
import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/core/repository/project_repository.dart';

part 'pre_event.dart';
part 'pre_state.dart';

class PreBloc extends Bloc<PreEvent, PreState> {
  final ProjectRepository repository;

  PreBloc(this.repository) : super(PreInitialState()) {
    on<PreLoadEvent>(_onLoad);
    on<PreDeleteEvent>(_onDelete);
    on<PreSaveEvent>(_onSave);
    on<PrePlusEvent>(_onAdd);
    on<PreSetSupportsEvent>(_onSetSupports);
  }

  /// Загружаем проект (если уже открыт)
  Future<void> _onLoad(PreLoadEvent event, Emitter<PreState> emit) async {
    emit(PreLoadingState());

    try {
      ProjectModel? curProject = repository.currentProject;

      if (curProject == null) {
        emit(PreFailureState(message: 'Проект не загружен'));
        return;
      }

      // ВАЖНО: Гарантируем минимальный проект (1 узел если пуст)
      if (curProject.nodes.isEmpty) {
        curProject = curProject.copyWith(
          nodes: [NodeModel(id: 1, x: 0)],
          elements: [],
        );
        await repository.updateProject(curProject);
      }

      emit(PreLoadedState(project: curProject));
    } catch (e) {
      emit(PreFailureState(message: e.toString()));
    }
  }

  //  Сохранение проекта (узлов и/или элементов)
  Future<void> _onSave(PreSaveEvent event, Emitter<PreState> emit) async {
    final curState = state;
    if (curState is! PreLoadedState) {
      emit(PreFailureState(message: 'Проект не загружен'));
      return;
    }
    final curProject = curState.project;

    try {
      final newNodes = event.nodes.isNotEmpty ? event.nodes : curProject.nodes;
      final newElements =
          event.elements.isNotEmpty ? event.elements : curProject.elements;

      final ProjectModel project = ProjectModel(
        name: curProject.name,
        nodes: newNodes,
        elements: newElements,
        fixLeft: curProject.fixLeft,
        fixRight: curProject.fixRight,
      );

      // Эмитим ПЕРЕД сохранением в репозиторий
      emit(PreLoadedState(project: project));

      // Сохраняем в репозиторий асинхронно
      await repository.updateProject(project);
    } catch (e) {
      emit(PreFailureState(message: e.toString()));
    }
  }

  /// Удаление последнего узла
  Future<void> _onDelete(PreDeleteEvent event, Emitter<PreState> emit) async {
    emit(PreLoadingState());
    try {
      final curProject = repository.currentProject;

      if (curProject == null || curProject.nodes.length <= 1) {
        curProject!.deleteLastNode();
        emit(PreFailureState(message: 'Нельзя удалить последний узел'));
        return;
      }

      final updatedProject = curProject.deleteLastNode();
      await repository.updateProject(updatedProject);
      emit(PreLoadedState(project: updatedProject));
    } catch (e) {
      emit(PreFailureState(message: e.toString()));
    }
  }

  /// Добавление нового узла
  /// ВАЖНО: Сохраняем ВСЕ старые элементы и добавляем ТОЛЬКО новый стержень!
  Future<void> _onAdd(PrePlusEvent event, Emitter<PreState> emit) async {
    try {
      final curProject = repository.currentProject;

      if (curProject == null) {
        emit(PreFailureState(message: 'Проект не загружен'));
        return;
      }

      late final double newX;
      late final int newId;

      if (curProject.nodes.isEmpty) {
        newX = 0;
        newId = 1;
      } else {
        newX = curProject.nodes.last.x + 1;
        newId = curProject.nodes.last.id + 1;
      }

      final newNode = NodeModel(id: newId, x: newX);
      final newNodes = [...curProject.nodes, newNode];

      // ✅ КЛЮЧЕВОЕ: Сохраняем ВСЕ старые элементы
      // и добавляем ТОЛЬКО новый стержень (от предпоследнего к новому узлу)
      final newElements = <ElementModel>[...curProject.elements];

      // Если есть узлы для создания стержня
      if (newNodes.length >= 2) {
        final newElemId = (newElements.isEmpty ? 1 : newElements.last.id + 1);
        newElements.add(
          ElementModel(
            id: newElemId,
            nodeStartId: newNodes[newNodes.length - 2].id,
            nodeEndId: newNodes[newNodes.length - 1].id,
            E: 1,
            A: 1,
          ),
        );
      }

      final newProject = curProject.copyWith(
        nodes: newNodes,
        elements: newElements,
      );

      await repository.updateProject(newProject);
      emit(PreLoadedState(project: newProject));
    } catch (e) {
      emit(PreFailureState(message: e.toString()));
    }
  }

  /// Установка граничных условий (опор)
  /// Варианты: none, left, right, both
  Future<void> _onSetSupports(
    PreSetSupportsEvent event,
    Emitter<PreState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PreLoadedState) {
      emit(PreFailureState(message: 'Проект не загружен'));
      return;
    }

    try {
      final project = currentState.project;

      late bool newFixLeft;
      late bool newFixRight;

      switch (event.supportMode) {
        case SupportMode.none:
          newFixLeft = false;
          newFixRight = false;
          break;
        case SupportMode.left:
          newFixLeft = true;
          newFixRight = false;
          break;
        case SupportMode.right:
          newFixLeft = false;
          newFixRight = true;
          break;
        case SupportMode.both:
          newFixLeft = true;
          newFixRight = true;
          break;
      }

      final newProject = project.copyWith(
        fixLeft: newFixLeft,
        fixRight: newFixRight,
      );

      await repository.updateProject(newProject);
      emit(PreLoadedState(project: newProject));
    } catch (e) {
      emit(PreFailureState(message: e.toString()));
    }
  }
}
