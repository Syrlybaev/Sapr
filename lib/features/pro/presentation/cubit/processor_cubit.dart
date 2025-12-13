import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/pro/data/repositories/processor_repository.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

part 'processor_state.dart';

class ProcessorCubit extends Cubit<ProcessorState> {
  final ProcessorRepository proRepository;
  
  // 🔴 НОВОЕ: Сохраняем проект для передачи в постпроцессор
  ProjectModel? _currentProject;
  ProjectModel? get currentProject => _currentProject;

  ProcessorCubit({required this.proRepository})
      : super(const ProcessorInitialState());

  /// Выполнить расчёт конструкции
  Future<void> calculateStructure(ProjectModel project) async {
    try {
      // 🔴 Сохранить проект
      _currentProject = project;
      
      emit(const ProcessorLoadingState());
      final result = await proRepository.calculateStructure(project);
      emit(ProcessorLoadedState(result: result, project: project));
    } catch (e) {
      emit(ProcessorErrorState('Ошибка расчёта: ${e.toString()}'));
    }
  }
}
