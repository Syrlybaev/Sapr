part of 'pre_bloc.dart';


/// Enum для режимов опор
enum SupportMode {
  none,  // Без опор
  left,  // Опора только слева (первый узел)
  right, // Опора только справа (последний узел)
  both,  // Опоры с обеих сторон (первый и последний узлы)
}


sealed class PreEvent extends Equatable {}


final class PreLoadEvent extends PreEvent {
  @override
  List<Object?> get props => [];
}


final class PrePlusEvent extends PreEvent {
  @override
  List<Object?> get props => [];
}


final class PreSaveEvent extends PreEvent {
  final List<NodeModel> nodes;
  final List<ElementModel> elements;


  PreSaveEvent({List<NodeModel>? nodes, List<ElementModel>? elements})
    : nodes = nodes ?? [],
      elements = elements ?? [];


  @override
  List<Object?> get props => [];
}


final class PreDeleteEvent extends PreEvent {
  @override
  List<Object?> get props => [];
}


/// Новое событие: установить опоры (граничные условия)
final class PreSetSupportsEvent extends PreEvent {
  final SupportMode supportMode;


  PreSetSupportsEvent({required this.supportMode});


  @override
  List<Object?> get props => [supportMode];
}
