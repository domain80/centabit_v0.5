import 'dart:math' as math;

/// Smart Budget Adherence Ratio (BAR) Calculator
///
/// Combines front-loaded spending curve with adaptive learning from historical data.
///
/// **BAR Interpretation:**
/// - BAR = 1.0: Spending at exactly the expected pace
/// - BAR < 1.0: Spending slower than expected (under budget)
/// - BAR > 1.0: Spending faster than expected (over budget)
///
/// **Key Features:**
/// 1. Front-loaded curve (expects more spending early in period - payday effect)
/// 2. Historical learning (adapts to user's actual spending patterns)
/// 3. Blended approach (70% historical, 30% front-loaded curve)
///
/// **Usage:**
/// ```dart
/// final calculator = SmartBudgetCalculator();
/// final result = calculator.calculate(
///   daysElapsed: 15,
///   totalDays: 30,
///   actualSpent: 800,
///   totalBudget: 1500,
///   historicalData: [], // Optional
/// );
/// print('BAR: ${result.bar} - ${result.message}');
/// ```
class SmartBudgetCalculator {
  /// How front-loaded the default spending curve is
  ///
  /// 1.2 means spending happens 20% faster early in the period.
  /// This reflects the "payday effect" where people spend more right after
  /// receiving income.
  static const double defaultFrontLoadFactor = 1.2;

  /// Minimum number of historical periods needed to enable learning
  ///
  /// If fewer periods are available, falls back to front-loaded curve only.
  static const int minHistoricalPeriods = 2;

  /// Calculate expected spending at a given point in time
  ///
  /// **Parameters:**
  /// - `daysElapsed`: Days since budget period started
  /// - `totalDays`: Total days in budget period
  /// - `totalBudget`: Total budget amount
  /// - `historicalData`: Optional list of past spending patterns for learning
  ///
  /// **Returns:** Expected amount to have spent by now
  ///
  /// **Example:**
  /// ```dart
  /// final expected = calculator.calculateExpectedSpending(
  ///   daysElapsed: 10,
  ///   totalDays: 30,
  ///   totalBudget: 1500,
  /// );
  /// // Returns ~650 (43% of budget, vs 33% of time - front-loaded)
  /// ```
  double calculateExpectedSpending(
    int daysElapsed,
    int totalDays,
    double totalBudget, [
    List<HistoricalSpendingPeriod>? historicalData,
  ]) {
    // Guard against invalid inputs
    if (totalDays <= 0) totalDays = 1;
    if (totalBudget <= 0) totalBudget = 0.01;
    if (daysElapsed < 0) daysElapsed = 0;
    if (daysElapsed > totalDays) daysElapsed = totalDays;

    // Normalized time (0 to 1)
    final t = daysElapsed / totalDays;

    // If we have sufficient historical data, blend it with the curve
    if (historicalData != null &&
        historicalData.length >= minHistoricalPeriods) {
      return _adaptiveLearningCurve(t, totalBudget, historicalData);
    }

    // Otherwise use front-loaded curve as default
    return _frontLoadedCurve(t, totalBudget);
  }

  /// Front-loaded spending curve
  ///
  /// Expects more spending early in the period (payday effect).
  ///
  /// **Formula:** `a*t - (a-1)*t²`
  /// where `a` is the front-load factor (default 1.3)
  ///
  /// This creates a curve where spending is faster early on and
  /// tapers toward the end of the period.
  ///
  /// **Example at 50% through period:**
  /// - Linear: 50% of budget
  /// - Front-loaded (1.3): 56.25% of budget
  double _frontLoadedCurve(double t, double totalBudget) {
    const a = defaultFrontLoadFactor;
    // Formula: a*t - (a-1)*t²
    final spendingRatio = a * t - (a - 1) * math.pow(t, 2);
    return totalBudget * math.min(spendingRatio, 1.0); // Cap at 100%
  }

  /// Adaptive learning curve based on historical spending patterns
  ///
  /// **Strategy:**
  /// - 70% weight to historical patterns (learned behavior)
  /// - 30% weight to front-loaded curve (baseline expectation)
  ///
  /// This prevents over-reliance on past data while still learning
  /// from the user's actual spending habits.
  ///
  /// **Parameters:**
  /// - `t`: Normalized time (0 to 1)
  /// - `totalBudget`: Total budget amount
  /// - `historicalData`: List of past spending periods with checkpoints
  double _adaptiveLearningCurve(
    double t,
    double totalBudget,
    List<HistoricalSpendingPeriod> historicalData,
  ) {
    // Calculate average historical spending pattern at this point in time
    final historicalAverage = _getHistoricalAverageAtTime(t, historicalData);

    // Blend historical pattern (70%) with front-loaded curve (30%)
    final frontLoaded = _frontLoadedCurve(t, totalBudget);
    final historical = totalBudget * historicalAverage;

    const blendWeight = 0.7; // 70% historical, 30% front-loaded
    return blendWeight * historical + (1 - blendWeight) * frontLoaded;
  }

  /// Get average spending percentage from historical data at time t
  ///
  /// Uses weighted average where more recent periods are weighted higher.
  /// Weight formula: 0.8^(periods_ago)
  ///
  /// **Example:**
  /// - Most recent period: weight = 1.0
  /// - 1 period ago: weight = 0.8
  /// - 2 periods ago: weight = 0.64
  double _getHistoricalAverageAtTime(
    double t,
    List<HistoricalSpendingPeriod> historicalData,
  ) {
    // Find the closest data points around time t and interpolate
    final relevant = historicalData
        .map((period) => _interpolateSpendingAtTime(t, period))
        .where((val) => val != null)
        .cast<double>()
        .toList();

    if (relevant.isEmpty) return t; // Fallback to linear

    // Return weighted average (more recent periods weighted higher)
    final weights = List.generate(
      relevant.length,
      (i) => math.pow(0.8, relevant.length - 1 - i).toDouble(),
    );
    final weightSum = weights.reduce((a, b) => a + b);

    double weightedSum = 0;
    for (int i = 0; i < relevant.length; i++) {
      weightedSum += relevant[i] * weights[i];
    }

    return weightedSum / weightSum;
  }

  /// Interpolate spending from a historical period at time t
  ///
  /// Finds the surrounding checkpoints and interpolates between them.
  ///
  /// **Returns:** Spending ratio (0 to 1) or null if no valid data
  double? _interpolateSpendingAtTime(
    double t,
    HistoricalSpendingPeriod period,
  ) {
    if (period.checkpoints.isEmpty) return null;

    final totalDays = period.totalDays;
    final totalBudget = period.totalBudget;
    final targetDay = t * totalDays;

    // Find surrounding checkpoints
    SpendingCheckpoint? before;
    SpendingCheckpoint? after;

    for (var cp in period.checkpoints) {
      if (cp.day <= targetDay) before = cp;
      if (cp.day >= targetDay && after == null) after = cp;
    }

    // Interpolate between checkpoints
    if (before != null && after != null && before.day != after.day) {
      final ratio = (targetDay - before.day) / (after.day - before.day);
      final interpolatedSpent = before.spent + ratio * (after.spent - before.spent);
      return interpolatedSpent / totalBudget;
    } else if (before != null) {
      return before.spent / totalBudget;
    } else if (after != null) {
      return after.spent / totalBudget;
    }

    return null;
  }

  /// Calculate Budget At Risk (BAR) score with status
  ///
  /// **Parameters:**
  /// - `actualSpent`: Amount actually spent so far
  /// - `expectedSpent`: Amount expected to have spent by now
  ///
  /// **Returns:** [BARResult] with score, status, and message
  ///
  /// **Status Thresholds:**
  /// - `under` (< 0.85): Well under budget
  /// - `good` (0.85-0.95): Slightly under budget
  /// - `onTrack` (0.95-1.05): Right on track
  /// - `warning` (1.05-1.15): Slightly over budget
  /// - `over` (> 1.15): Significantly over budget
  BARResult calculateBAR(double actualSpent, double expectedSpent) {
    // Guard against division by zero
    if (expectedSpent <= 0) expectedSpent = 0.01;

    final bar = actualSpent / expectedSpent;

    final BARStatus status;
    final String message;

    if (bar < 0.85) {
      status = BARStatus.under;
      message = 'Well under budget! 🎉';
    } else if (bar < 0.95) {
      status = BARStatus.good;
      message = 'Slightly under budget ✓';
    } else if (bar <= 1.05) {
      status = BARStatus.onTrack;
      message = 'Right on track ✓';
    } else if (bar <= 1.15) {
      status = BARStatus.warning;
      message = 'Slightly over budget ⚠️';
    } else {
      status = BARStatus.over;
      message = 'Significantly over budget! 🚨';
    }

    return BARResult(
      bar: bar,
      status: status,
      message: message,
    );
  }

  /// Full calculation with all guards and adaptive learning
  ///
  /// **Parameters:**
  /// - `daysElapsed`: Days since budget started
  /// - `totalDays`: Total days in budget period
  /// - `actualSpent`: Amount actually spent
  /// - `totalBudget`: Total budget amount
  /// - `historicalData`: Optional historical spending patterns
  ///
  /// **Returns:** [BARCalculation] with complete metrics
  ///
  /// **Example:**
  /// ```dart
  /// final result = calculator.calculate(
  ///   daysElapsed: 15,
  ///   totalDays: 30,
  ///   actualSpent: 800,
  ///   totalBudget: 1500,
  /// );
  /// print('BAR: ${result.bar.toStringAsFixed(2)}');
  /// print('Expected: \$${result.expectedSpent.toStringAsFixed(2)}');
  /// print('Status: ${result.message}');
  /// ```
  BARCalculation calculate({
    required int daysElapsed,
    required int totalDays,
    required double actualSpent,
    required double totalBudget,
    List<HistoricalSpendingPeriod>? historicalData,
  }) {
    final expectedSpent = calculateExpectedSpending(
      daysElapsed,
      totalDays,
      totalBudget,
      historicalData,
    );

    final result = calculateBAR(actualSpent, expectedSpent);

    return BARCalculation(
      bar: result.bar,
      status: result.status,
      message: result.message,
      expectedSpent: expectedSpent,
      actualSpent: actualSpent,
      remaining: math.max(0, totalBudget - actualSpent),
      daysRemaining: math.max(0, totalDays - daysElapsed),
    );
  }
}

/// BAR status categories
enum BARStatus {
  /// Well under budget (< 0.85)
  under,

  /// Slightly under budget (0.85-0.95)
  good,

  /// Right on track (0.95-1.05)
  onTrack,

  /// Slightly over budget (1.05-1.15)
  warning,

  /// Significantly over budget (> 1.15)
  over,
}

/// Result of BAR calculation
class BARResult {
  /// BAR value (actualSpent / expectedSpent)
  final double bar;

  /// Status category
  final BARStatus status;

  /// Human-readable message
  final String message;

  const BARResult({
    required this.bar,
    required this.status,
    required this.message,
  });
}

/// Complete BAR calculation with all metrics
class BARCalculation extends BARResult {
  /// Expected spending by now (based on curve)
  final double expectedSpent;

  /// Actual amount spent
  final double actualSpent;

  /// Remaining budget
  final double remaining;

  /// Days remaining in period
  final int daysRemaining;

  const BARCalculation({
    required super.bar,
    required super.status,
    required super.message,
    required this.expectedSpent,
    required this.actualSpent,
    required this.remaining,
    required this.daysRemaining,
  });
}

/// Historical spending period data for adaptive learning
///
/// **Example:**
/// ```dart
/// final period = HistoricalSpendingPeriod(
///   totalDays: 30,
///   totalBudget: 1500,
///   checkpoints: [
///     SpendingCheckpoint(day: 10, spent: 700),
///     SpendingCheckpoint(day: 20, spent: 1100),
///     SpendingCheckpoint(day: 30, spent: 1450),
///   ],
/// );
/// ```
class HistoricalSpendingPeriod {
  /// Total days in this historical period
  final int totalDays;

  /// Total budget for this period
  final double totalBudget;

  /// List of spending checkpoints throughout the period
  final List<SpendingCheckpoint> checkpoints;

  const HistoricalSpendingPeriod({
    required this.totalDays,
    required this.totalBudget,
    required this.checkpoints,
  });
}

/// A single point-in-time spending checkpoint
///
/// Records how much was spent at a specific day in the period.
class SpendingCheckpoint {
  /// Day number in the period (1-based)
  final int day;

  /// Amount spent by this day
  final double spent;

  const SpendingCheckpoint({
    required this.day,
    required this.spent,
  });
}
