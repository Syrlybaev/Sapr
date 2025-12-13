part of 'post_cubit.dart';

/// Состояния постпроцессора
sealed class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние - данные не загружены
final class PostInitialState extends PostState {
  const PostInitialState();
}

/// Загрузка данных
final class PostLoadingState extends PostState {
  const PostLoadingState();
}

/// Успешная загрузка - результаты готовы
final class PostLoadedState extends PostState {
  final DiagramModel internalForces; // Nx
  final DiagramModel stresses; // σx
  final DiagramModel displacements; // Δ
  final DiagramModel strains; // ε
  final List<ElementStressAnalysis> analysis; // Анализ прочности

  const PostLoadedState({
    required this.internalForces,
    required this.stresses,
    required this.displacements,
    required this.strains,
    required this.analysis,
  });

  @override
  List<Object?> get props =>
      [internalForces, stresses, displacements, strains, analysis];
}

/// Ошибка при обработке
final class PostErrorState extends PostState {
  final String message;

  const PostErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
