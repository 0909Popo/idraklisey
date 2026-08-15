import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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

    // Filter grades for active student if role is student or parent
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Overview Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
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
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                avgScore > 0 ? avgScore.toStringAsFixed(1) : '0.0',
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
                              ),
                              const Text(
                                ' / 100 Bal',
                                style: TextStyle(color: AppColors.goldLight, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.goldLight, width: 1.2),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'GPA (Ortalama)',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              gpaDisplay,
                              style: const TextStyle(color: AppColors.goldLight, fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (studentGrades.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: const [
                      Icon(Icons.insights_rounded, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 14),
                      Text(
                        'Hələlik heç bir qiymət daxil edilməyib.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Müəllim tərəfindən KSQ, BSQ və ya digər qiymətləndirmə daxil edildikdə burada tərəqqi qrafikləri əks olunacaq.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Dynamic Chart Card with Switcher (Line / Bar)
              CustomCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tədris Dinamikası',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        // Chart Type Toggle
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
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
                    const SizedBox(height: 20),

                    // Chart Display
                    SizedBox(
                      height: 200,
                      child: _selectedChartType == 0
                          ? _buildLineChart(studentGrades)
                          : _buildBarChart(studentGrades),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Bütün Qiymətlər', null),
                      _buildFilterChip('KSQ', AssessmentType.ksq),
                      _buildFilterChip('BSQ', AssessmentType.bsq),
                      _buildFilterChip('Diaqnostik', AssessmentType.diagnostic),
                      _buildFilterChip('Monitorinq', AssessmentType.monitoring),
                      _buildFilterChip('Beynəlxalq (IB/STR)', AssessmentType.international),
                    ],
                  ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedFilter = type),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
      ),
    );
  }

  Widget _buildLineChart(List<GradeRecord> grades) {
    // Chronological order: oldest to newest
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
              reservedSize: 32,
              interval: 20,
              getTitlesWidget: (val, meta) {
                return Text(
                  '${val.toInt()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
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
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: AppColors.primaryAccent,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryAccent.withAlpha(50),
                  AppColors.primaryAccent.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<GradeRecord> grades) {
    final chronological = grades.reversed.toList();
    return BarChart(
      BarChartData(
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
              reservedSize: 32,
              interval: 20,
              getTitlesWidget: (val, meta) {
                return Text(
                  '${val.toInt()}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: chronological.asMap().entries.map((e) {
          final isHigh = e.value.percentage >= 80;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.percentage,
                color: isHigh ? AppColors.success : AppColors.primaryAccent,
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, AppState appState, GradeRecord grade, String currentStudentId) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    Color badgeColor;
    switch (grade.type) {
      case AssessmentType.diagnostic:
        badgeColor = Colors.blue;
        break;
      case AssessmentType.monitoring:
        badgeColor = Colors.orange;
        break;
      case AssessmentType.ksq:
        badgeColor = AppColors.primary;
        break;
      case AssessmentType.bsq:
        badgeColor = Colors.purple;
        break;
      case AssessmentType.international:
        badgeColor = AppColors.goldDark;
        break;
    }

    final isIb = grade.type == AssessmentType.international && grade.maxScore == 7.0;
    final displayScoreStr = isIb
        ? '${grade.displayScore.toInt()} / 7 Band'
        : grade.displayScore.toStringAsFixed(grade.displayScore % 1 == 0 ? 0 : 1);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                label: grade.type.displayName,
                color: badgeColor,
                fontSize: 10,
              ),
              Row(
                children: [
                  Text(
                    dateFormat.format(grade.date),
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
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
                            Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 16),
                            SizedBox(width: 8),
                            Text('Qiyməti Sil', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      grade.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withAlpha(80)),
                ),
                child: Column(
                  children: [
                    Text(
                      displayScoreStr,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      grade.gradeLetter,
                      style: TextStyle(
                        fontSize: 10,
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
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Müəllim Rəyi: "${grade.teacherFeedback}"',
                style: const TextStyle(
                  fontSize: 12,
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
