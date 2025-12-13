// lib/features/processor/data/datasources/fem_calculator_test_example.dart

// ПРИМЕР ИСПОЛЬЗОВАНИЯ И ТЕСТИРОВАНИЯ FemCalculator

import 'package:saprbar_desktop/core/models/element_model.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';
import 'package:saprbar_desktop/features/pro/data/data_source/fem_calculator.dart';


// Пример 1: ПРОСТАЯ СИСТЕМА ИЗ 2 УЗЛОВ И 1 СТЕРЖНЯ
// Конструкция: O---O    F = 1000 Н
//            1   2
// Узел 1 зафиксирован (левая опора)
// Узел 2 нагружен F_x = 1000 Н

void exampleSimpleTwoNodeSystem() {
  // Создать узлы
  final nodes = [
    NodeModel(id: 1, x: 0,  loadX: 0), // левая опора
    NodeModel(id: 2, x: 1000,  loadX: 1000), // нагружен 1000 Н
  ];

  // Создать стержень
  const elements = [
    ElementModel(
      id: 1,
      nodeStartId: 1,
      nodeEndId: 2,
      E: 2.1e5, // МПа (сталь)
      A: 10, // см² = 10e-4 м²
      // A: 10e-4, // если в м²
      qx: 0, // нет погонной нагрузки
    ),
  ];

  // Создать калькулятор и выполнить расчёт
  final calculator = FemCalculator(nodes: nodes, elements: elements, fixLeft: true);
  final result = calculator.calculate();

  if (result['success']) {
    print('✓ Расчёт успешен!');
    print('Перемещения: ${result['displacements']}');
    print('Результаты стержней: ${result['elementResults']}');
  } else {
    print('✗ Ошибка: ${result['error']}');
  }
}

// Пример 2: СИСТЕМА С ПОГОННОЙ НАГРУЗКОЙ
void exampleSystemWithDistributedLoad() {
  // Стержень с равномерной нагрузкой q = 100 Н/м
  // O---O    q = 100 Н/м
  // 1   2

  final nodes = [
    NodeModel(id: 1, x: 0,  loadX: 0),
    NodeModel(id: 2, x: 2000,  loadX: 0),
  ];

  const elements = [
    ElementModel(
      id: 1,
      nodeStartId: 1,
      nodeEndId: 2,
      E: 2.1e5,
      A: 20,
      qx: 100, // 100 Н/м погонная нагрузка
    ),
  ];

  final calculator = FemCalculator(nodes: nodes, elements: elements, fixRight: true);
  final result = calculator.calculate();

  print('\n--- СИСТЕМА С ПОГОННОЙ НАГРУЗКОЙ ---');
  if (result['success']) {
    print('✓ Расчёт успешен!');
    // Эквивалентные силы: q*L/2 = 100*2000/2 = 100000 Н в каждый узел
    print('Ожидаемые силы в узлах: 100000 Н');
  }
}

// Пример 3: СЛОЖНАЯ СИСТЕМА (ФЕРМА)
void exampleFarmStructure() {
  // Простая ферма из 3 узлов и 2 стержней
  //     3
  //    /|\
  //   / | \
  //  1  |  2
  //  F1=500  F2=500

  final nodes = [
    NodeModel(id: 1, x: 0,  loadX: 500, loadY: 0),
    NodeModel(id: 2, x: 1000,  loadX: 500, loadY: 0),
    NodeModel(id: 3, x: 500,  loadX: 0, loadY: -1000), // верхний узел
  ];

  const elements = [
    ElementModel(
      id: 1,
      nodeStartId: 1,
      nodeEndId: 3,
      E: 2.1e5,
      A: 15,
    ),
    ElementModel(
      id: 2,
      nodeStartId: 3,
      nodeEndId: 2,
      E: 2.1e5,
      A: 15,
    ),
  ];

  final calculator = FemCalculator(nodes: nodes, elements: elements, fixRight: true);
  final result = calculator.calculate();

  print('\n--- ФЕРМА ИЗ 3 УЗЛОВ ---');
  if (result['success']) {
    print('✓ Ферма рассчитана!');
  } else {
    print('✗ Ошибка фермы: ${result['error']}');
  }
}

// Пример 4: ПРОВЕРКА ЖЁСТКОСТИ И ДЕМОНСТРАЦИЯ АЛГОРИТМА
void examplePrintDetailedCalculation() {
  final nodes = [
    NodeModel(id: 1, x: 0,  loadX: 0),
    NodeModel(id: 2, x: 1000, loadX: 1000),
  ];

  const elements = [
    ElementModel(
      id: 1,
      nodeStartId: 1,
      nodeEndId: 2,
      E: 2.1e5, // МПа
      A: 10, // см²
      qx: 0,
    ),
  ];

  final calculator = FemCalculator(nodes: nodes, elements: elements, fixRight: true);
  
  print('\n=== ДЕТАЛЬНЫЙ РАСЧЁТ ===');
  print('\nДАННЫЕ:');
  print('  Длина стержня L = 1000 мм');
  print('  Модуль упругости E = 2.1e5 МПа');
  print('  Площадь сечения A = 10 см² = 10e-4 м²');
  print('  Нагрузка F = 1000 Н');
  
  print('\nШАГ 1: Жёсткость стержня');
  print('  k = E*A/L = 2.1e5 * 10e-4 / 1 = 210 Н/мм');
  
  print('\nШАГ 2: Матрица жёсткости (2x2)');
  print('  K = [  210  -210 ]');
  print('      [ -210   210 ]');
  
  print('\nШАГ 3: Вектор нагрузок');
  print('  F = [ 0, 1000 ]');
  
  print('\nШАГ 4: Граничные условия (узел 1 зафиксирован)');
  print('  Удалить строку/столбец 1');
  print('  Сокращённая система: K[1,1] = 210, F[1] = 1000');
  
  print('\nШАГ 5: Решение');
  print('  Δ = F/K = 1000/210 = 4.76 мм');
  
  print('\nШАГ 6: Внутренние силы');
  print('  N = k*(u_end - u_start) = 210*(4.76 - 0) = 1000 Н');
  
  print('\nШАГ 7: Напряжения');
  print('  σ = N/A = 1000/10 = 100 МПа');
  
  final result = calculator.calculate();
  print('\n--- РЕЗУЛЬТАТЫ РАСЧЁТА ---');
  if (result['success']) {
    final displacements = result['displacements'] as List<double>;
    print('✓ Перемещение узла 2: ${displacements[1].toStringAsFixed(4)} м');
    print('  (должно быть ~0.00476 м = 4.76 мм)');
  }
}

// Запуск всех примеров
void runAllExamples() {
  exampleSimpleTwoNodeSystem();
  exampleSystemWithDistributedLoad();
  exampleFarmStructure();
  examplePrintDetailedCalculation();
}
