import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/report_provider.dart';

class VisualTrendCard extends StatelessWidget {
  final ReportProvider prov;
  final NumberFormat currency;

  const VisualTrendCard({super.key, required this.prov, required this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // UBAH KE WARNA CERAH
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tren Pemasukan vs Pengeluaran",
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF0F172A), // Warna teks gelap agar kontras
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.bar_chart, color: Color(0xFF64748B), size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Perbandingan performa mingguan",
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // GRAFIK SYNCFUSION TEMA CERAH
          SizedBox(
            height: 220,
            child: SfCartesianChart(
              margin: EdgeInsets.zero,
              plotAreaBorderWidth: 0,
              // Tambahkan Tooltip profesional
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: false,
                format: 'point.y',
                textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
              ),
              primaryXAxis: CategoryAxis(
                labelStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 1, color: Color(0xFFE2E8F0)),
              ),
              primaryYAxis: NumericAxis(
                isVisible: false, // Tetap sembunyikan angka Y agar bersih
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Color(0xFFF1F5F9),
                  dashArray: <double>[5, 5],
                ),
              ),
              legend: Legend(
                isVisible: true,
                position: LegendPosition.top,
                alignment: ChartAlignment.center,
                textStyle: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF1E293B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
                iconHeight: 10,
                iconWidth: 10,
              ),
              series: <CartesianSeries<WeeklyChartData, String>>[
                // Batang Pemasukan (Hijau Teal Modern)
                ColumnSeries<WeeklyChartData, String>(
                  name: 'Pemasukan',
                  dataSource: prov.weeklyChartData,
                  xValueMapper: (WeeklyChartData data, _) => data.weekLabel,
                  yValueMapper: (WeeklyChartData data, _) => data.income,
                  color: const Color.fromARGB(255, 98, 103, 173),
                  width: 0.6,
                  spacing: 0.2,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  animationDuration: 1500,
                ),
                // Batang Pengeluaran (Rose Red Modern)
                ColumnSeries<WeeklyChartData, String>(
                  name: 'Pengeluaran',
                  dataSource: prov.weeklyChartData,
                  xValueMapper: (WeeklyChartData data, _) => data.weekLabel,
                  yValueMapper: (WeeklyChartData data, _) => data.expense,
                  color: const Color(0xFFF43F5E),
                  width: 0.6,
                  spacing: 0.2,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  animationDuration: 1500,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}