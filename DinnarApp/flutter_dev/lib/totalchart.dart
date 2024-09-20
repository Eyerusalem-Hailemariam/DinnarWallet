import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'controller/currency.dart';
import 'package:get/get.dart';
import 'model/currency.dart';
import 'package:get_storage/get_storage.dart';

class Totalchart extends StatefulWidget {
  final List<PieChartSectionData> chartData;
  final double totalAmount;
  final String totalLabel;

  const Totalchart({
    super.key,
    required this.chartData,
    required this.totalAmount,
    required this.totalLabel,
  });

  @override
  State<Totalchart> createState() => _TotalchartState();
}

class _TotalchartState extends State<Totalchart> {
  final CurrencyController currencyController = Get.find<CurrencyController>();
  @override
  void initState() {
    super.initState();

    final storedCurrencyCode = GetStorage().read('selectedCurrency');
    if (storedCurrencyCode != null) {
      currencyController.selectedCurrency.value = Currency.currencies
          .firstWhere((currency) => currency.code == storedCurrencyCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Obx(() {
        final currencySymbol = currencyController.selectedCurrency.value.symbol;

        return Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sections: widget.chartData,
                centerSpaceRadius: 95,
                centerSpaceColor: isDark ? Colors.black : Colors.white,
                sectionsSpace: 2,
                borderData: FlBorderData(show: false),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.totalLabel,
                  style: const TextStyle(
                    fontSize: 17,
                  ),
                ),
                Text(
                  '$currencySymbol${widget.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
