part of 'processor_cubit.dart';

/// Состояния процессора
sealed class ProcessorState extends Equatable {
  const ProcessorState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
final class ProcessorInitialState extends ProcessorState {
  const ProcessorInitialState();
}

/// Загрузка (расчет выполняется)
final class ProcessorLoadingState extends ProcessorState {
  const ProcessorLoadingState();
}

/// Расчет завершен - результаты готовы
/// 🔴 ИСПРАВЛЕНО: Добавлено поле project
final class ProcessorLoadedState extends ProcessorState {
  final CalculationResultModel result;
  final ProjectModel project; // 🔴 НОВОЕ: Передаем проект в постпроцессор

  const ProcessorLoadedState({
    required this.result,
    required this.project,
  });

  @override
  List<Object?> get props => [result, project];
}

/// Ошибка при расчете
final class ProcessorErrorState extends ProcessorState {
  final String message;

  const ProcessorErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
