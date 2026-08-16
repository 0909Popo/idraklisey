import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/attendance_model.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() => _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  late int _selectedDay;
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = _currentDate.day;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStudent = appState.student;
    final attendanceMap = appState.attendance;

    int presentCount = 0;
    int lateCount = 0;
    int absentCount = 0;

    int totalPeriods = 0;
    int attendedPeriods = 0;

    attendanceMap.forEach((_, att) {
      if (att.status == AttendanceStatus.present) presentCount++;
      if (att.status == AttendanceStatus.late) lateCount++;
      if (att.status == AttendanceStatus.absent) absentCount++;

      for (final p in att.periodDetails) {
        totalPeriods++;
        if (p.status == AttendanceStatus.present || p.status == AttendanceStatus.late) {
          attendedPeriods++;
        }
      }
    });

    final int calculatedRate = totalPeriods > 0
        ? ((attendedPeriods / totalPeriods) * 100).round()
        : (currentStudent.attendanceRate > 0 ? currentStudent.attendanceRate : 100);

    final selectedDayData = attendanceMap[_selectedDay];
    final monthName = DateFormat('MMMM yyyy').format(_currentDate);

    // Number of days in current month
    final int daysInMonth = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
    // Weekday of the first day (Monday=1, Sunday=7)
    final firstDayWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
    final emptyLeadingSlots = firstDayWeekday - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${currentStudent.fullName} • Davamiyyət'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header & Summary Statistics
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, color: AppColors.goldLight, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            monthName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.successLight),
                        ),
                        child: Text(
                          'Davamiyyət: $calculatedRate%',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStatItem('İştirak', '$presentCount Gün', AppColors.success, Icons.check_circle_rounded),
                      _buildSummaryStatItem('Gecikmə', '$lateCount Dəfə', AppColors.warning, Icons.access_time_filled_rounded),
                      _buildSummaryStatItem('Qayıb', '$absentCount Gün', AppColors.danger, Icons.cancel_rounded),
                    ],
                  ),
                ],
              ),
            ),

            // Legend Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem('İştirak', AppColors.success, Icons.check_circle_rounded),
                  _buildLegendItem('Gecikmə', AppColors.warning, Icons.access_time_filled_rounded),
                  _buildLegendItem('Qayıb', AppColors.danger, Icons.cancel_rounded),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Full Month Calendar Matrix Grid
            CustomCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Weekday headers: B.E, Ç.A, Ç., C.A, C., Ş., B.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _CalendarHeaderCell('B.E'),
                      _CalendarHeaderCell('Ç.A'),
                      _CalendarHeaderCell('Ç.'),
                      _CalendarHeaderCell('C.A'),
                      _CalendarHeaderCell('C.'),
                      _CalendarHeaderCell('Ş.', isWeekend: true),
                      _CalendarHeaderCell('B.', isWeekend: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 10),

                  // Calendar Days Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: daysInMonth + emptyLeadingSlots,
                    itemBuilder: (context, index) {
                      final dayNum = index - emptyLeadingSlots + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox();
                      }

                      final attendance = attendanceMap[dayNum];
                      final isSelected = dayNum == _selectedDay;
                      final isToday = dayNum == _currentDate.day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = dayNum;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withAlpha(20)
                                : (isToday ? AppColors.gold.withAlpha(15) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isToday ? AppColors.gold : AppColors.cardBorder),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected || isToday ? FontWeight.w900 : FontWeight.w600,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              _buildStatusIcon(attendance?.status),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Selected Day Header
            SectionHeader(
              title: '$_selectedDay $monthName Təfərrüatları',
              subtitle: 'Həmin günün bütün dərs saatları üzrə davamiyyət qeydləri',
            ),

            // Selected Day Details Card
            if (selectedDayData != null && selectedDayData.periodDetails.isNotEmpty) ...[
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Day Summary Banner
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              _buildStatusIcon(selectedDayData.status, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _getStatusTitle(selectedDayData.status),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: currentStudent.className.isNotEmpty ? '${currentStudent.className} Sinfi' : 'Sinif',
                          color: AppColors.primary,
                        ),
                      ],
                    ),

                    if (selectedDayData.note != null && selectedDayData.note!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(selectedDayData.status),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: _getStatusColor(selectedDayData.status)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                selectedDayData.note!,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(selectedDayData.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 14),

                    // Header for All Periods
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Gün Ərzində Keçilən Dərslər (${selectedDayData.periodDetails.length} Dərs):',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Status',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // List of ALL periods for this day
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedDayData.periodDetails.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final period = selectedDayData.periodDetails[index];
                        final periodColor = _getStatusColor(period.status);

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: periodColor.withAlpha(12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: periodColor.withAlpha(50)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: periodColor.withAlpha(25),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13,
                                          color: periodColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        period.subject,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            period.time != null && period.time!.isNotEmpty ? period.time! : 'Dərs Saatı',
                                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              _buildPeriodStatusBadge(period.status),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else ...[
              CustomCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text(
                        'Bu gün üçün heç bir dərs davamiyyət qeydi yoxdur.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Dərslər başladıqda və müəllim tərəfindən davamiyyət yoxlanıldıqda hər bir saat üzrə status burada canlı görünəcək.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(AttendanceStatus? status, {double size = 16}) {
    switch (status) {
      case AttendanceStatus.present:
        return Icon(Icons.check_circle_rounded, color: AppColors.success, size: size);
      case AttendanceStatus.late:
        return Icon(Icons.access_time_filled_rounded, color: AppColors.warning, size: size);
      case AttendanceStatus.absent:
        return Icon(Icons.cancel_rounded, color: AppColors.danger, size: size);
      case AttendanceStatus.holiday:
        return Icon(Icons.beach_access_rounded, color: AppColors.textMuted, size: size);
      default:
        return Icon(Icons.remove_circle_outline_rounded, color: AppColors.cardBorder, size: size);
    }
  }

  Widget _buildPeriodStatusBadge(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('İştirak Edib', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.late:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('Gecikib', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.absent:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.cancel_rounded, color: Colors.white, size: 14),
              SizedBox(width: 4),
              Text('Qayıb', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.holiday:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.textSecondary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('Tətil', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        );
    }
  }

  String _getStatusTitle(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return 'Dərslərdə Tam İştirak Edib';
      case AttendanceStatus.late:
        return 'Dərsə Gecikmə Qeydə Alınıb';
      case AttendanceStatus.absent:
        return 'Qayıb Qeydə Alınıb';
      case AttendanceStatus.holiday:
        return 'İstirahət / Tətil Günü';
    }
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.absent:
        return AppColors.danger;
      case AttendanceStatus.holiday:
        return AppColors.textSecondary;
    }
  }

  Color _getStatusBgColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return AppColors.successLight;
      case AttendanceStatus.late:
        return AppColors.warningLight;
      case AttendanceStatus.absent:
        return AppColors.dangerLight;
      case AttendanceStatus.holiday:
        return AppColors.background;
    }
  }
}

class _CalendarHeaderCell extends StatelessWidget {
  final String text;
  final bool isWeekend;

  const _CalendarHeaderCell(this.text, {this.isWeekend = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isWeekend ? AppColors.danger : AppColors.textSecondary,
      ),
    );
  }
}
