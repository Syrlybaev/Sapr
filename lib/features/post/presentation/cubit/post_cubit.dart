// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:saprbar_desktop/core/models/project_model.dart';
import 'package:saprbar_desktop/features/post/data/models/diagram_model.dart';
import 'package:saprbar_desktop/features/post/data/repositories/post_calculator.dart';
import 'package:saprbar_desktop/features/post/domain/entities/stress_analysis.dart';
import 'package:saprbar_desktop/features/pro/data/models/calculation_result_model.dart';

part 'post_state.dart';

/// PostCubit - управляет состоянием постпроцессора
///
/// Получает результаты расчета от ProcessorCubit и строит эпюры
class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitialState());

  /// ГЛАВНЫЙ МЕТОД: Обработать результаты расчета
  ///
  /// Вызывается из PostPanel когда ProcessorCubit завершит расчет
  /// 🔴 ИСПРАВЛЕНО: Теперь принимает project
  Future<void> processCalculationResults({
    required CalculationResultModel calculationResult,
    required ProjectModel project, // 🔴 НОВОЕ: Получаем проект
  }) async {
    try {
      debugPrint('🔄 PostCubit: Начало обработки результатов...');
      emit(const PostLoadingState());

      // 🔴 ИСПРАВЛЕНО: Создать калькулятор с проектом
      final calculator = PostCalculator(
        calculationResult: calculationResult,
        project: project, // 🔴 Передаем проект
      );

      // Построить диаграммы
      debugPrint('📊 PostCubit: Построение эпюр...');
      final diagrams = calculator.buildAllDiagrams();

      // Получить анализ прочности
      debugPrint('✅ PostCubit: Анализ прочности...');
      final analysis = calculator.analyzeStress();

      debugPrint('✅ PostCubit: Результаты готовы!');
      debugPrint('   Эпюра Nx: ${diagrams.internalForces.points.length} точек');
      debugPrint('   Эпюра σx: ${diagrams.stresses.points.length} точек');
      debugPrint('   Эпюра Δ: ${diagrams.displacements.points.length} точек');
      debugPrint('   Эпюра ε: ${diagrams.strains.points.length} точек');
      debugPrint('   Анализ: ${analysis.length} стержней');

      // Эмитить состояние с результатами
      emit(PostLoadedState(
        internalForces: diagrams.internalForces,
        stresses: diagrams.stresses,
        displacements: diagrams.displacements,
        strains: diagrams.strains,
        analysis: analysis,
      ));
    } catch (e) {
      debugPrint('❌ PostCubit Error: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
      emit(PostErrorState('Ошибка обработки результатов: ${e.toString()}'));
    }
  }
}
