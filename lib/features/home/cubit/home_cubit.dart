import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/core/repository/project_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ProjectRepository projectRepository;

  HomeCubit({
    // ← ОБНОВИТЬ
    required this.projectRepository,
  }) : super(HomeState.preprocessor);

  // Getter для доступа из процессора
  ProjectModel? get currentProject => projectRepository.currentProject;

  void changeMode(HomeState mode) => emit(mode);
}
