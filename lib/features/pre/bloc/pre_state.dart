part of 'pre_bloc.dart';


sealed class PreState extends Equatable {}


final class PreInitialState extends PreState {
  @override
  List<Object?> get props => [];
}


final class PreLoadingState extends PreState {
  @override
  List<Object?> get props => [];
}


final class PreLoadedState extends PreState {
  final ProjectModel project;


  PreLoadedState({required this.project});


  @override
  List<Object?> get props => [project];
}


final class PreFailureState extends PreState {
  final String message;


  PreFailureState({required this.message});


  @override
  List<Object?> get props => [message];
}
