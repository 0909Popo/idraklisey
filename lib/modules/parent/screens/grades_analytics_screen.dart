import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/grade_model.dart';

class GradesAnalyticsScreen extends StatefulWidget {
  const GradesAnalyticsScreen({super.key});

  @override
  State<GradesAnalyticsScreen> createState() => _GradesAnalyticsScreenState();
}

class _GradesAnalyticsScreenState extends State<GradesAnalyticsScreen> {
  AssessmentType? _selectedFilter;
  int _selectedChartType = 0; // 0: Line Chart, 1: Bar Chart

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStudent = appState.student;

    final studentGrades = (appState.currentRole == UserRole.student || appState.currentRole == UserRole.parent)
        ? appState.grades.where((g) => g.studentId == null || g.studentId == currentStudent.id).toList()
        : appState.grades;

    final filteredGrades = _selectedFilter == null
        ? studentGrades
        : studentGrades.where((g) => g.type == _selectedFilter).toList();

    double avgScore = 0;
    if (studentGrades.isNotEmpty) {
      final pcts = studentGrades.map((g) => g.percentage).toList();
      avgScore = (pcts.reduce((a, b) => a + b) / pcts.length).clamp(0.0, 100.0);
    }

    final calculatedGpa = ((avgScore / 100.0) * 5.0).clamp(0.0, 5.0);
    final gpaDisplay = currentStudent.gpa > 0 && currentStudent.gpa <= 5.0
        ? '${currentStudent.gpa.toStringAsFixed(2)} / 5.0'
        : (avgScore > 0 ? '${calculatedGpa.toStringAsFixed(2)} / 5.0' : '0.00 / 5.0');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(appState.currentRole == UserRole.admin
            ? 'Ümumi Məktəb Qiymətləri'
            : '${currentStudent.fullName} • Qiymətlər & GPA'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ümumi Tərəqqi İndeksi',
                            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                avgScore > 0 ? avgScore.toStringAsFixed(1) : '0.0',
                                style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900),
                              ),
                              const Text(
                                ' / 100 Bal',
                                style: TextStyle(color: AppColors.primaryAccent, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryAccent.withAlpha(80), width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'GPA (Ortalama)',
                              style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              gpaDisplay,
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (studentGrades.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(Icons.insights_outlined, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Hələlik heç bir qiymət daxil edilməyib.',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Müəllim tərəfindən KSQ, BSQ daxil edildikdə burada tərəqqi qrafikləri əks olunacaq.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

            if (studentGrades.isNotEmpty) ...[
              // Dynamic Chart Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tədris Dinamikası',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              _buildToggleBtn(0, Icons.show_chart_rounded, 'Line'),
                              _buildToggleBtn(1, Icons.bar_chart_rounded, 'Bar'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      height: 190,
                      child: _selectedChartType == 0
                          ? _buildLineChart(studentGrades)
                          : _buildBarChart(studentGrades),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildFilterChip('Bütün Qiymətlər', null),
                    _buildFilterChip('KSQ', AssessmentType.ksq),
                    _buildFilterChip('BSQ', AssessmentType.bsq),
                    _buildFilterChip('Diaqnostik', AssessmentType.diagnostic),
                    _buildFilterChip('Monitorinq', AssessmentType.monitoring),
                    _buildFilterChip('Beynəlxalq', AssessmentType.international),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const SectionHeader(
                title: 'Rəsmi Qiymətləndirmə Jurnalı',
                subtitle: 'Müəllim şərhləri və rəsmi protokollar',
              ),

              // Grades Records List
              ...filteredGrades.map((grade) => _buildGradeCard(context, appState, grade, currentStudent.id)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildToggleBtn(int index, IconData icon, String label) {
    final isSelected = _selectedChartType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedChartType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AssessmentType? type) {
    final isSelected = _selectedFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = type),
        selectedColor: AppColors.primaryAccent,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 11.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.surface,
        side: BorderSide(color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildLineChart(List<GradeRecord> grades) {
    final chronological = grades.reversed.toList();
    final spots = chronological.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.percentage);
    }).toList();

    return LineChart(
      LineChartData(
        clipData: const FlClipData.all(),
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (val, meta) {
                return Text(
                  '${val.toInt()}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9.5),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primaryAccent,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 3.5,
                  color: AppColors.primaryAccent,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primaryAccent.withAlpha(25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<GradeRecord> grades) {
    final chronological = grades.reversed.toList().take(8).toList();
    final barGroups = chronological.asMap().entries.map((e) {
      final isHigh = e.value.percentage >= 80;
      final isMid = e.value.percentage >= 60;
      final barColor = isHigh ? AppColors.success : (isMid ? AppColors.primaryAccent : AppColors.warning);

      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.percentage,
            color: barColor,
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 25,
              getTitlesWidget: (val, meta) {
                return Text(
                  '${val.toInt()}',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9.5),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, AppState appState, GradeRecord grade, String currentStudentId) {
    final isHigh = grade.percentage >= 80;
    final isMid = grade.percentage >= 60;
    final badgeColor = isHigh ? AppColors.success : (isMid ? AppColors.primaryAccent : AppColors.warning);
    final displayScoreStr = grade.score == grade.score.toInt() ? '${grade.score.toInt()}' : '${grade.score}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  StatusBadge(
                    label: grade.type.displayName,
                    color: AppColors.primaryAccent,
                    fontSize: 9.5,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd.MM.yyyy').format(grade.date),
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
              if (appState.currentRole == UserRole.admin || appState.currentRole == UserRole.teacher)
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  onSelected: (val) {
                    if (val == 'delete') {
                      _showDeleteGradeDialog(context, appState, grade, currentStudentId);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 15),
                          SizedBox(width: 8),
                          Text('Qiyməti Sil', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.subject,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                    Text(
                      grade.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    Text(
                      displayScoreStr,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      grade.gradeLetter,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (grade.teacherFeedback.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Müəllim Rəyi: "${grade.teacherFeedback}"',
                style: TextStyle(
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteGradeDialog(BuildContext context, AppState appState, GradeRecord grade, String currentStudentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Qiymət Qeydini Sil'),
        content: Text('"${grade.title}" (${grade.score} bal) qeydini silmək və GPA-nı yenidən hesablamaq istəyirsiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              appState.deleteGrade(grade.id, currentStudentId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Qiymət silindi və GPA yeniləndi!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
