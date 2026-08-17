import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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

    final int daysInMonth = DateUtils.getDaysInMonth(_currentDate.year, _currentDate.month);
    final firstDayWeekday = DateTime(_currentDate.year, _currentDate.month, 1).weekday;
    final emptyLeadingSlots = firstDayWeekday - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${currentStudent.fullName} • Davamiyyət'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header & Summary Statistics Card
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
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, color: AppColors.primaryAccent, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            monthName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success.withAlpha(60)),
                        ),
                        child: Text(
                          'Davamiyyət: $calculatedRate%',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withAlpha(25), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStatItem('İştirak', '$presentCount Gün', AppColors.success, Icons.check_circle_outline_rounded),
                      _buildSummaryStatItem('Gecikmə', '$lateCount Dəfə', AppColors.warning, Icons.schedule_outlined),
                      _buildSummaryStatItem('Qayıb', '$absentCount Gün', AppColors.danger, Icons.cancel_outlined),
                    ],
                  ),
                ],
              ),
            ),

            // Legend Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem('İştirak', AppColors.success, Icons.check_circle_outline_rounded),
                  _buildLegendItem('Gecikmə', AppColors.warning, Icons.schedule_outlined),
                  _buildLegendItem('Qayıb', AppColors.danger, Icons.cancel_outlined),
                  _buildLegendItem('Tətil', AppColors.textMuted, Icons.beach_access_outlined),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Calendar Grid Card
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
                children: [
                  // Weekday labels
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CalendarHeaderCell('B.e'),
                      _CalendarHeaderCell('Ç.a'),
                      _CalendarHeaderCell('Çər'),
                      _CalendarHeaderCell('C.a'),
                      _CalendarHeaderCell('Cüm'),
                      _CalendarHeaderCell('Şənb', isWeekend: true),
                      _CalendarHeaderCell('Baz', isWeekend: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(color: AppColors.cardBorder, height: 1),
                  const SizedBox(height: 10),

                  // Days Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: emptyLeadingSlots + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < emptyLeadingSlots) {
                        return const SizedBox.shrink();
                      }
                      final dayNum = index - emptyLeadingSlots + 1;
                      final isSelected = dayNum == _selectedDay;
                      final isToday = dayNum == _currentDate.day;
                      final att = attendanceMap[dayNum];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDay = dayNum;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryAccent.withAlpha(25)
                                : (isToday ? AppColors.background : AppColors.surface),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryAccent
                                  : (isToday ? AppColors.primaryAccent.withAlpha(60) : AppColors.cardBorder),
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                                  color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              if (att != null)
                                _buildStatusIcon(att.status, size: 13)
                              else
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted.withAlpha(60),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Daily Details Section
            SectionHeader(
              title: '$_selectedDay $monthName - Günlük Qeydlər',
              subtitle: 'Saatlar üzrə dərs davamiyyəti və qeydlər',
            ),

            if (selectedDayData != null && selectedDayData.periodDetails.isNotEmpty) ...[
              Container(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getStatusTitle(selectedDayData.status),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _getStatusColor(selectedDayData.status),
                          ),
                        ),
                        if (selectedDayData.note != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Qeyd: ${selectedDayData.note}',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: AppColors.cardBorder, height: 1),
                    const SizedBox(height: 6),

                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedDayData.periodDetails.length,
                      separatorBuilder: (_, __) => Divider(color: AppColors.cardBorder, height: 1),
                      itemBuilder: (context, idx) {
                        final period = selectedDayData.periodDetails[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent.withAlpha(15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${idx + 1}-ci Dərs',
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      period.subject,
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_busy_outlined, size: 40, color: AppColors.textMuted),
                      const SizedBox(height: 10),
                      Text(
                        'Bu gün üçün heç bir dərs davamiyyət qeydi yoxdur.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Dərslər başladıqda status burada canlı görünəcək.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 3),
        Text(
          title,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(AttendanceStatus? status, {double size = 16}) {
    switch (status) {
      case AttendanceStatus.present:
        return Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: size);
      case AttendanceStatus.late:
        return Icon(Icons.schedule_outlined, color: AppColors.warning, size: size);
      case AttendanceStatus.absent:
        return Icon(Icons.cancel_outlined, color: AppColors.danger, size: size);
      case AttendanceStatus.holiday:
        return Icon(Icons.beach_access_outlined, color: AppColors.textMuted, size: size);
      default:
        return Icon(Icons.remove_circle_outline_rounded, color: AppColors.cardBorder, size: size);
    }
  }

  Widget _buildPeriodStatusBadge(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.success.withAlpha(60)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_rounded, color: AppColors.success, size: 12),
              SizedBox(width: 3),
              Text('İştirak Edib', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.late:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.warning.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.warning.withAlpha(60)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule_outlined, color: AppColors.warning, size: 12),
              SizedBox(width: 3),
              Text('Gecikib', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.absent:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.danger.withAlpha(20),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.danger.withAlpha(60)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.danger, size: 12),
              SizedBox(width: 3),
              Text('Qayıb', style: TextStyle(color: AppColors.danger, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
        );
      case AttendanceStatus.holiday:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.cardBorder,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('Tətil', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
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
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: isWeekend ? AppColors.danger : AppColors.textSecondary,
      ),
    );
  }
}
