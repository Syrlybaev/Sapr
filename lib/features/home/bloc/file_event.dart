part of 'file_bloc.dart';

sealed class FileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

final class FileCreateEvent extends FileEvent {
  final String name;
  FileCreateEvent({required this.name});

  @override
  List<Object?> get props => [name];
}

final class FileLoadEvent extends FileEvent {
  final String name;
  FileLoadEvent({required this.name});

  @override
  List<Object?> get props => [name];
}
