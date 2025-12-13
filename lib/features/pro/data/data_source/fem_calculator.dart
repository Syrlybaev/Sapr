// ignore_for_file: public_member_api_docs, sort_constructors_first
// lib/features/processor/data/datasources/fem_calculator.dart

import 'dart:math' as math;

import 'package:saprbar_desktop/core/models/element_model.dart';
import 'package:saprbar_desktop/core/models/node_model.dart';

/// Основной класс для расчётов методом конечных элементов
/// Расчитывает матрицу жёсткости, решает систему уравнений
class FemCalculator {
  final List<NodeModel> nodes;
  final List<ElementModel> elements;
  final bool fixLeft;
  final bool fixRight;

  FemCalculator({
    required this.nodes,
    required this.elements,
    bool? fixLeft,
    bool? fixRight,
  }) : fixLeft = fixLeft ?? false,
       fixRight = fixRight ?? false;

  /// ОСНОВНОЙ АЛГОРИТМ РАСЧЁТА
  /// Возвращает перемещения узлов
  Map<String, dynamic> calculate() {
    try {
      // 1. Проверки
      _validateInput();

      // 2. Найти зафиксированные узлы
      final fixedNodes = _findFixedNodes();

      // 3. Собрать глобальную матрицу жёсткости
      final globalK = _assembleGlobalStiffnessMatrix();

      // 4. Собрать вектор нагрузок
      final loadVector = _assembleLoadVector();

      // 5. Применить граничные условия
      final reducedK = _applyBoundaryConditions(globalK, fixedNodes);
      final reducedF = _reduceLoadVector(loadVector, fixedNodes);

      // 6. Решить систему Гаусса: K * Δ = F
      final displacements = _solveGauss(reducedK, reducedF, fixedNodes);

      // 7. Проверить на изменяемость
      if (displacements == null) {
        throw Exception('Система изменяемая! Добавьте опоры.');
      }

      // 8. Вычислить внутренние силы и напряжения
      final elementResults = _calculateElementForces(displacements);

      return {
        'success': true,
        'displacements': displacements,
        'elementResults': elementResults,
      };
    } catch (e) {
      throw (e.toString());
    }
  }

  /// 1. ПРОВЕРКА КОРРЕКТНОСТИ ВХОДНЫХ ДАННЫХ
  void _validateInput() {
    if (nodes.isEmpty || elements.isEmpty) {
      throw Exception('Нет узлов или стержней в проекте');
    }

    // Проверить, что каждый стержень ссылается на существующие узлы
    for (var elem in elements) {
      final startNodeExists = nodes.any((n) => n.id == elem.nodeStartId);
      final endNodeExists = nodes.any((n) => n.id == elem.nodeEndId);

      if (!startNodeExists || !endNodeExists) {
        throw Exception('Стержень ${elem.id}: узел не найден');
      }

      // Проверить уникальность стержня
      if (elem.nodeStartId == elem.nodeEndId) {
        throw Exception('Стержень ${elem.id}: начало и конец совпадают');
      }

      // Проверить материальные характеристики
      if (elem.E <= 0 || elem.A <= 0) {
        throw Exception('Стержень ${elem.id}: E и A должны быть > 0');
      }
    }
  }

  /// 2. НАЙТИ ЗАФИКСИРОВАННЫЕ УЗЛЫ
  List<int> _findFixedNodes() {
    if (fixLeft && fixRight) return [nodes.first.id, nodes.last.id];
    if (fixLeft) return [nodes.first.id];
    if (fixRight) return [nodes.last.id];
    throw Exception('Хотя бы одна опора должна быть зафиксирована');
  }

  /// 3. СОБРАТЬ ГЛОБАЛЬНУЮ МАТРИЦУ ЖЁСТКОСТИ
  /// K_global = sum(K_local для каждого стержня)
  List<List<double>> _assembleGlobalStiffnessMatrix() {
    final n = nodes.length;
    final K = List<List<double>>.generate(
      n,
      (i) => List<double>.filled(n, 0.0),
    );

    for (var elem in elements) {
      // Получить узлы стержня
      final nodeStart = nodes.firstWhere((n) => n.id == elem.nodeStartId);
      final nodeEnd = nodes.firstWhere((n) => n.id == elem.nodeEndId);

      // Глобальные индексы узлов
      final i = nodes.indexOf(nodeStart);
      final j = nodes.indexOf(nodeEnd);

      // Длина стержня
      final dx = nodeEnd.x - nodeStart.x;
      final dy = nodeEnd.y - nodeStart.y;
      final length = math.sqrt(dx * dx + dy * dy);

      if (length <= 0) {
        throw Exception('Стержень ${elem.id}: нулевая длина');
      }

      // Жёсткость стержня
      final stiffness = elem.E * elem.A / length;

      // Локальная матрица 2x2: [[1, -1], [-1, 1]] * stiffness
      // Ассемблировать в глобальную матрицу
      K[i][i] += stiffness;
      K[i][j] -= stiffness;
      K[j][i] -= stiffness;
      K[j][j] += stiffness;
    }

    return K;
  }

  /// 4. СОБРАТЬ ВЕКТОР НАГРУЗОК
  /// F = [сосредоточенные нагрузки] + [эквивалентные от погонных нагрузок]
  List<double> _assembleLoadVector() {
    final n = nodes.length;
    final F = List<double>.filled(n, 0.0);

    // Добавить сосредоточенные нагрузки
    for (var node in nodes) {
      final idx = nodes.indexOf(node);
      F[idx] += node.loadX; // Продольная нагрузка
      // F[idx] += node.loadY; // Поперечная нагрузка (если нужна)
    }

    // Добавить эквивалентные нагрузки от погонных нагрузок
    for (var elem in elements) {
      if (elem.qx == 0 && elem.qy == 0) continue;

      final nodeStart = nodes.firstWhere((n) => n.id == elem.nodeStartId);
      final nodeEnd = nodes.firstWhere((n) => n.id == elem.nodeEndId);

      final iStart = nodes.indexOf(nodeStart);
      final iEnd = nodes.indexOf(nodeEnd);

      // Длина стержня
      final dx = nodeEnd.x - nodeStart.x;
      final dy = nodeEnd.y - nodeStart.y;
      final length = math.sqrt(dx * dx + dy * dy);

      // Эквивалентные силы от погонной нагрузки
      // Для равномерной нагрузки: половина в каждый узел
      final eqForceStart = elem.qx * length / 2;
      final eqForceEnd = elem.qx * length / 2;

      F[iStart] += eqForceStart;
      F[iEnd] += eqForceEnd;
    }

    return F;
  }

  /// 5. ПРИМЕНИТЬ ГРАНИЧНЫЕ УСЛОВИЯ
  /// Удалить строки и столбцы для зафиксированных узлов
  List<List<double>> _applyBoundaryConditions(
    List<List<double>> K,
    List<int> fixedNodes,
  ) {
    final activeIndices = <int>[];
    for (int i = 0; i < nodes.length; i++) {
      if (!fixedNodes.contains(nodes[i].id)) {
        activeIndices.add(i);
      }
    }

    final reducedSize = activeIndices.length;
    final reducedK = List<List<double>>.generate(
      reducedSize,
      (i) => List<double>.filled(reducedSize, 0.0),
    );

    for (int i = 0; i < reducedSize; i++) {
      for (int j = 0; j < reducedSize; j++) {
        reducedK[i][j] = K[activeIndices[i]][activeIndices[j]];
      }
    }

    return reducedK;
  }

  /// Сократить вектор нагрузок для активных узлов
  List<double> _reduceLoadVector(List<double> F, List<int> fixedNodes) {
    final activeIndices = <int>[];
    for (int i = 0; i < nodes.length; i++) {
      if (!fixedNodes.contains(nodes[i].id)) {
        activeIndices.add(i);
      }
    }

    return [for (int i in activeIndices) F[i]];
  }

  /// 6. РЕШИТЬ СИСТЕМУ МЕТОДОМ ГАУССА
  /// K * Δ = F  =>  Δ = K^(-1) * F
  List<double>? _solveGauss(
    List<List<double>> K,
    List<double> F,
    List<int> fixedNodes,
  ) {
    final n = K.length;

    // if (n == 0) {
    //   throw Exception('Нет активных степеней свободы');
    // }

    // Расширенная матрица [K | F]
    final augmented = <List<double>>[];
    for (int i = 0; i < n; i++) {
      augmented.add([...K[i], F[i]]);
    }

    // Прямой ход Гаусса (приведение к верхней треугольной матрице)
    for (int col = 0; col < n; col++) {
      // Найти опорный элемент (pivoting)
      int pivotRow = col;
      double maxVal = augmented[col][col].abs();

      for (int row = col + 1; row < n; row++) {
        if (augmented[row][col].abs() > maxVal) {
          maxVal = augmented[row][col].abs();
          pivotRow = row;
        }
      }

      // Проверка на сингулярность (нулевой диагональный элемент)
      if (augmented[pivotRow][col].abs() < 1e-12) {
        return null; // Система не решаема
      }

      // Поменять строки
      final temp = augmented[col];
      augmented[col] = augmented[pivotRow];
      augmented[pivotRow] = temp;

      // Исключение
      for (int row = col + 1; row < n; row++) {
        final factor = augmented[row][col] / augmented[col][col];
        for (int j = col; j <= n; j++) {
          augmented[row][j] -= factor * augmented[col][j];
        }
      }
    }

    // Обратный ход (нахождение неизвестных)
    final solution = List<double>.filled(n, 0.0);
    for (int i = n - 1; i >= 0; i--) {
      solution[i] = augmented[i][n];
      for (int j = i + 1; j < n; j++) {
        solution[i] -= augmented[i][j] * solution[j];
      }
      solution[i] /= augmented[i][i];
    }

    // Восстановить полный вектор перемещений (включая зафиксированные = 0)
    final fullDisplacements = List<double>.filled(nodes.length, 0.0);
    int activeIndex = 0;
    for (int i = 0; i < nodes.length; i++) {
      if (!fixedNodes.contains(nodes[i].id)) {
        fullDisplacements[i] = solution[activeIndex];
        activeIndex++;
      }
    }

    return fullDisplacements;
  }

  /// 7. ВЫЧИСЛИТЬ ВНУТРЕННИЕ СИЛЫ И НАПРЯЖЕНИЯ
  Map<int, Map<String, double>> _calculateElementForces(
    List<double> displacements,
  ) {
    final results = <int, Map<String, double>>{};

    for (var elem in elements) {
      final nodeStart = nodes.firstWhere((n) => n.id == elem.nodeStartId);
      final nodeEnd = nodes.firstWhere((n) => n.id == elem.nodeEndId);

      final iStart = nodes.indexOf(nodeStart);
      final iEnd = nodes.indexOf(nodeEnd);

      // Перемещения узлов
      final uStart = displacements[iStart];
      final uEnd = displacements[iEnd];

      // Длина стержня
      final dx = nodeEnd.x - nodeStart.x;
      final dy = nodeEnd.y - nodeStart.y;
      final length = math.sqrt(dx * dx + dy * dy);

      // Внутренняя продольная сила: N = (E*A/L) * (u_end - u_start)
      final internalForce = (elem.E * elem.A / length) * (uEnd - uStart);

      // Напряжение: σ = N / A [МПа]
      final stress = internalForce / elem.A;

      // Деформация: ε = (u_end - u_start) / L
      final strain = (uEnd - uStart) / length;

      results[elem.id] = {
        'internalForce': internalForce,
        'stress': stress,
        'strain': strain,
        'length': length,
      };
    }

    return results;
  }
}
