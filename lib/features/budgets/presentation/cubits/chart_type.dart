/// Chart type enum for budget details page chart visualization toggle
enum ChartType {
  /// Bar chart view showing allocations vs transactions side-by-side
  bar,

  /// Pie chart view showing allocation distribution
  pie;

  /// Display label for the chart type
  String get label {
    switch (this) {
      case ChartType.bar:
        return 'Bar';
      case ChartType.pie:
        return 'Pie';
    }
  }
}
