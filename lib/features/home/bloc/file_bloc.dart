import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saprbar_desktop/core/repository/project_repository.dart';

part 'file_event.dart';
part 'file_state.dart';

class FileBloc extends Bloc<FileEvent, FileState> {
  final ProjectRepository repository;

  FileBloc(this.repository) : super(FileInitialState()) {
    on<FileCreateEvent>(_onCreateProject);
    on<FileLoadEvent>(_onLoadFile);
  }

  Future<void> _onCreateProject(
    FileCreateEvent event,
    Emitter<FileState> emit,
  ) async {
    try {
      await repository.createProject(name: event.name);
      emit(FileLoadedState(name: event.name));
    } catch (e) {
      emit(FileFailureState(message: e.toString()));
    }
  }

  Future<void> _onLoadFile(FileLoadEvent event, Emitter<FileState> emit) async {
    try {
      await repository.loadProject(name: event.name);
      emit(FileLoadedState(name: event.name));
    } catch (e) {
      emit(FileFailureState(message: e.toString()));
    }
  }
}
