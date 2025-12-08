part of 'file_bloc.dart';

sealed class FileState extends Equatable {
  @override
  List<Object> get props => [];
}

final class FileInitialState extends FileState {}

final class FileNoneState extends FileState {}

final class FileLoadedState extends FileState {
  final String name;

  FileLoadedState({required this.name});

  @override
  List<Object> get props => [name];
}

final class FileFailureState extends FileState {
  final String message;

  FileFailureState({required this.message});

  @override
  List<Object> get props => [message];
}
