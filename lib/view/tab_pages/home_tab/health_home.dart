// File: lib/view/tab_pages/home_tab/health_home.dart
// MyRheumLog - Home Dashboard (Flutter 3.x + GetX)
// This single file contains: Binding, Controller, View, and Widgets.
// You can later split into:
// - home/home_binding.dart
// - home/home_controller.dart
// - home/home_view.dart
// - home/widgets/top_greeting_header.dart
// - home/widgets/quick_actions_grid.dart
// - home/widgets/week_strip_calendar.dart
// - home/widgets/upcoming_summary.dart

// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ===== Theme Tokens =====
class AppTokens {
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF7ED321);
  static const Color warning = Color(0xFFF5A623);
  static const Color alert = Color(0xFFD0021B);
  static const Color bgLight = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF222222);

  static const double radiusL = 20;
  static const double radiusM = 16;

  static const double padH = 16;
  static const double padV = 12;
  static const double cardSpacing = 12;
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animMed = Duration(milliseconds: 260);
  static const Duration stagger = Duration(milliseconds: 50);
}

// ===== Models =====
class WeekDayInfo {
  final DateTime date;
  final bool hasMed;
  final bool hasAppt;
  final bool isToday;

  WeekDayInfo({
    required this.date,
    required this.hasMed,
    required this.hasAppt,
    required this.isToday,
  });
}

// ===== Controller =====
class HomeController extends GetxController {
  // State
  RxString firstName = 'Ola'.obs;
  late DateTime now;

  RxInt dueMedsCount = 2.obs;
  RxInt daysToBloodTest = 3.obs;
  RxDouble adherencePct = 0.72.obs; // 72%

  // Week data
  final Rx<DateTime> weekStart = DateTime.now().startOfWeek().obs;
  final RxList<WeekDayInfo> weekDays = <WeekDayInfo>[].obs;

  // UI anim flags
  final RxBool showHeader = false.obs;
  final RxBool showActions = false.obs;

  // Placeholder route names (wire these in GetMaterialApp routes later if desired)
  static const String routeLogToday = '/log-today';
  static const String routeMedsDue = '/meds-due';
  static const String routeJointPhoto = '/joint-photo';
  static const String routeBloodTest = '/blood-test';

  // Demo data
  final String nextAppointmentText = 'Thu 30 Oct, 10:30 • Royal Rheum Clinic';
  final String nextDoseText = 'Methotrexate 15mg • Fri 31 Oct, 21:00';

  @override
  void onInit() {
    super.onInit();
    now = DateTime.now();
    _buildWeek(weekStart.value);

    // Stagger-in animations on first paint
    Future.delayed(
      const Duration(milliseconds: 60),
      () => showHeader.value = true,
    );
    Future.delayed(
      const Duration(milliseconds: 160),
      () => showActions.value = true,
    );
  }

  void _buildWeek(DateTime start) {
    final today = DateTime.now().dateOnly();
    final List<WeekDayInfo> days = [];
    // Demo markers: meds on Tue(2)/Fri(5), appt on Thu(4) (Mon=1)
    for (int i = 0; i < 7; i++) {
      final date = start.add(Duration(days: i));
      final weekday = date.weekday; // Mon=1..Sun=7
      final hasMed = weekday == DateTime.tuesday || weekday == DateTime.friday;
      final hasAppt = weekday == DateTime.thursday;
      days.add(
        WeekDayInfo(
          date: date,
          hasMed: hasMed,
          hasAppt: hasAppt,
          isToday: date == today,
        ),
      );
    }
    weekDays.assignAll(days);
  }

  void goPrevWeek() {
    final prev = weekStart.value.subtract(const Duration(days: 7));
    weekStart.value = prev;
    _buildWeek(prev);
  }

  void goNextWeek() {
    final next = weekStart.value.add(const Duration(days: 7));
    weekStart.value = next;
    _buildWeek(next);
  }

  // Greeting
  String greeting() {
    final hour = now.hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String longDateString() {
    final d = now;
    return '${_weekdayName(d.weekday)}, ${d.day} ${_monthName(d.month)} ${d.year}';
  }

  // Quick actions taps
  void onTapLogToday() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'DAS Score',
      'Let’s log your symptoms for today.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.to(
      () => _PlaceholderScreen(
        title: 'Log Today (DAS Score)',
        routeName: routeLogToday,
      ),
    );
  }

  void onTapMedsDue() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Medications',
      'You have $dueMedsCount due.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.to(
      () => _PlaceholderScreen(title: 'Meds Due', routeName: routeMedsDue),
    );
  }

  void onTapJointPhoto() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Joint Photo Log',
      'Capture and attach a joint photo.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.to(
      () => _PlaceholderScreen(
        title: 'Joint Photo Log',
        routeName: routeJointPhoto,
      ),
    );
  }

  void onTapBloodTest() {
    HapticFeedback.lightImpact();
    Get.snackbar(
      'Blood Test',
      'Next in ${daysToBloodTest.value} days.',
      snackPosition: SnackPosition.BOTTOM,
    );
    Get.to(
      () => _PlaceholderScreen(title: 'Blood Test', routeName: routeBloodTest),
    );
  }

  // Helpers
  static String _weekdayShort(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String _weekdayName(int weekday) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[(weekday - 1).clamp(0, 6)];
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[(month - 1).clamp(0, 11)];
  }

  String dayLabel(DateTime d) => _weekdayShort(d.weekday);
}

// ===== Binding =====

// ===== View =====
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? theme.colorScheme.surface : AppTokens.bgLight;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTokens.padH,
                      vertical: AppTokens.padV,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TopGreetingHeader(),
                        const SizedBox(height: 16),
                        QuickActionsGrid(),
                        const SizedBox(height: 8),
                        // WeekStripCalendar(),
                        const SizedBox(height: 8),
                        UpcomingSummary(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ===== Widgets =====

// Top Greeting Header
class TopGreetingHeader extends GetView<HomeController> {
  const TopGreetingHeader({super.key});

  final Duration _anim = AppTokens.animMed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Obx(
      () => AnimatedOpacity(
        duration: _anim,
        opacity: controller.showHeader.value ? 1 : 0,
        curve: Curves.easeOut,
        child: AnimatedSlide(
          duration: _anim,
          curve: Curves.easeOut,
          offset: controller.showHeader.value
              ? Offset.zero
              : const Offset(0, 0.05),
          child: Semantics(
            header: true,
            child: Container(
              padding: const EdgeInsets.all(AppTokens.padH),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppTokens.radiusL),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'user_avatar_hero',
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTokens.primary.withOpacity(0.12),
                      child: Icon(
                        CupertinoIcons.person_fill,
                        color: AppTokens.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _GreetingText(onSurface: onSurface)),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'edit',
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Get.snackbar(
                        'Settings',
                        'Coming soon',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: Icon(
                      Icons.edit_rounded,
                      color: onSurface.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GreetingText extends GetView<HomeController> {
  final Color onSurface;
  const _GreetingText({required this.onSurface});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: onSurface,
    );
    final subtitleStyle = theme.textTheme.bodyMedium?.copyWith(
      color: onSurface.withOpacity(0.7),
    );

    return Obx(() {
      final greet = controller.greeting();
      final name = controller.firstName.value;
      final dateStr = controller.longDateString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greet, $name 👋',
            style: titleStyle?.copyWith(fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(dateStr, style: subtitleStyle),
        ],
      );
    });
  }
}

// Quick Actions Grid
class QuickActionsGrid extends StatefulWidget {
  const QuickActionsGrid({super.key});

  @override
  State<QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends State<QuickActionsGrid> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    // Stagger grid appearance
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 700 ? 4 : 2;

    List<Widget> items = [
      _buildItem(
        index: 0,
        icon: CupertinoIcons.pencil,
        title: 'Log Today',
        caption: 'DAS Score',
        gradient: _primaryGradient(),
        onTap: ctrl.onTapLogToday,
        heroTag: 'logTodayHero',
      ),
      _buildItem(
        index: 1,
        icon: CupertinoIcons.capsule_fill,
        title: 'Meds Due',
        captionBuilder: (context) => Obx(() {
          final due = ctrl.dueMedsCount.value;
          return Text(
            '$due remaining',
            style: _captionStyle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        trailing: _SmallProgressRing(value: 0.3), // decorative micro-indicator
        gradient: _secondaryGradient(),
        onTap: ctrl.onTapMedsDue,
      ),
      _buildItem(
        index: 2,
        icon: CupertinoIcons.camera_fill,
        title: 'Joint Photo Log',
        caption: 'Capture update',
        gradient: _mixedGradient(),
        onTap: ctrl.onTapJointPhoto,
      ),
      _buildItem(
        index: 3,
        icon: CupertinoIcons.drop_fill,
        title: 'Blood Test',
        captionBuilder: (context) => Obx(() {
          return Text(
            'in ${ctrl.daysToBloodTest.value} days',
            style: _captionStyle(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
        gradient: _warningGradient(),
        onTap: ctrl.onTapBloodTest,
      ),
    ];

    return Obx(() {
      // Fade the whole grid after controller flag becomes true
      final gridVisible = Get.find<HomeController>().showActions.value && _show;
      return AnimatedOpacity(
        duration: AppTokens.animMed,
        opacity: gridVisible ? 1 : 0,
        child: GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: columns,
          crossAxisSpacing: AppTokens.cardSpacing,
          mainAxisSpacing: AppTokens.cardSpacing,
          childAspectRatio: 1.2,
          children: items,
        ),
      );
    });
  }

  Widget _buildItem({
    required int index,
    required IconData icon,
    required String title,
    String? caption,
    Widget Function(BuildContext context)? captionBuilder,
    required Gradient gradient,
    Widget? trailing,
    required VoidCallback onTap,
    String? heroTag,
  }) {
    final delay = AppTokens.stagger * index;

    return _Stagger(
      delay: delay,
      child: PressableCard(
        onTap: onTap,
        gradient: gradient,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: heroTag != null
                    ? Hero(
                        tag: heroTag,
                        child: Icon(icon, color: Colors.white),
                      )
                    : Icon(icon, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionTitleCaption(
                title: title,
                caption: caption,
                captionBuilder: captionBuilder,
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  TextStyle _captionStyle(BuildContext context) {
    final theme = Theme.of(context);
    return theme.textTheme.bodySmall!.copyWith(
      color: Colors.white.withOpacity(0.9),
    );
  }

  LinearGradient _primaryGradient() => LinearGradient(
    colors: [AppTokens.primary, AppTokens.primary.withOpacity(0.75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient _secondaryGradient() => LinearGradient(
    colors: [AppTokens.secondary, AppTokens.secondary.withOpacity(0.7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient _mixedGradient() => LinearGradient(
    colors: [
      AppTokens.primary.withOpacity(0.85),
      AppTokens.secondary.withOpacity(0.85),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  LinearGradient _warningGradient() => LinearGradient(
    colors: [AppTokens.warning, AppTokens.warning.withOpacity(0.75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class _SmallProgressRing extends StatelessWidget {
  final double value;
  const _SmallProgressRing({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: (value).clamp(0.0, 1.0),
            strokeWidth: 3,
            backgroundColor: Colors.white.withOpacity(0.25),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ActionTitleCaption extends StatelessWidget {
  final String title;
  final String? caption;
  final Widget Function(BuildContext context)? captionBuilder;

  const _ActionTitleCaption({
    required this.title,
    this.caption,
    this.captionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final captionStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white.withOpacity(0.95),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        if (captionBuilder != null)
          captionBuilder!(context)
        else if (caption != null)
          Text(
            caption!,
            style: captionStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

/*
// Week Strip Calendar
class WeekStripCalendar extends StatefulWidget {
  const WeekStripCalendar({super.key});

  @override
  State<WeekStripCalendar> createState() => _WeekStripCalendarState();
}

class _WeekStripCalendarState extends State<WeekStripCalendar> {
  // For AnimatedSwitcher transitions
  Key _listKeyFor(DateTime start) =>
      ValueKey('week_${start.toIso8601String()}');

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(AppTokens.padH),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row with arrows
          Row(
            children: [
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ctrl.goPrevWeek();
                },
                tooltip: 'Previous week',
                icon: Icon(Icons.chevron_left_rounded, color: onSurface),
              ),
              Expanded(
                child: Obx(() {
                  final start = ctrl.weekStart.value;
                  final end = start.add(const Duration(days: 6));
                  final title =
                      '${HomeController._weekdayName(start.weekday)} ${start.day} ${HomeController._monthName(start.month)}'
                      ' - '
                      '${HomeController._weekdayName(end.weekday)} ${end.day} ${HomeController._monthName(end.month)}';
                  return Center(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
              ),
              IconButton(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ctrl.goNextWeek();
                },
                tooltip: 'Next week',
                icon: Icon(Icons.chevron_right_rounded, color: onSurface),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Days row
          Obx(() {
            final start = ctrl.weekStart.value;
            final key = _listKeyFor(start);
            final days = ctrl.weekDays;

            return AnimatedSwitcher(
              duration: AppTokens.animMed,
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(anim);
                return FadeTransition(
                  opacity: anim,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: Row(
                key: key,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(days.length, (i) {
                  final d = days[i];
                  return _DayPill(info: d);
                }),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final WeekDayInfo info;
  const _DayPill({required this.info});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final theme = Theme.of(context);
    final isToday = info.isToday;

    final baseColor = isToday
        ? AppTokens.primary
        : theme.colorScheme.surfaceVariant;
    final textColor = isToday ? Colors.white : theme.colorScheme.onSurface;

    return Column(
      children: [
        Text(
          ctrl.dayLabel(info.date),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          selected: isToday,
          label:
              '${ctrl.dayLabel(info.date)} ${info.date.day}. ${isToday ? 'Today.' : ''} ${info.hasMed ? 'Medication due.' : ''} ${info.hasAppt ? 'Appointment.' : ''}',
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isToday ? baseColor : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isToday ? baseColor : theme.colorScheme.outlineVariant,
              ),
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: AppTokens.primary.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Text(
                  '${info.date.day}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (info.hasMed)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          CupertinoIcons.capsule_fill,
                          size: 14,
                          color: isToday ? Colors.white : AppTokens.secondary,
                        ),
                      ),
                    if (info.hasAppt)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          CupertinoIcons.person_2_fill,
                          size: 14,
                          color: isToday ? Colors.white : AppTokens.primary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/
// Upcoming Summary
class UpcomingSummary extends StatelessWidget {
  const UpcomingSummary({super.key});

  final Duration _anim = AppTokens.animFast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ctrl = Get.find<HomeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming & Summary',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        // Next Appointment
        AnimatedContainer(
          duration: _anim,
          curve: Curves.easeOut,
          child: PressableCard(
            onTap: () {
              HapticFeedback.selectionClick();
              Get.snackbar(
                'Appointment',
                'Details opened',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            background: theme.colorScheme.surface,
            gradient: LinearGradient(
              colors: [
                AppTokens.primary.withOpacity(0.08),
                AppTokens.primary.withOpacity(0.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              children: [
                _IconBadge(
                  color: AppTokens.primary,
                  icon: CupertinoIcons.calendar,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ctrl.nextAppointmentText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Next Dose
        AnimatedContainer(
          duration: _anim,
          curve: Curves.easeOut,
          child: PressableCard(
            onTap: ctrl.onTapMedsDue,
            background: theme.colorScheme.surface,
            gradient: LinearGradient(
              colors: [
                AppTokens.secondary.withOpacity(0.10),
                AppTokens.secondary.withOpacity(0.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Row(
              children: [
                _IconBadge(
                  color: AppTokens.secondary,
                  icon: CupertinoIcons.capsule,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ctrl.nextDoseText,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Adherence
        AnimatedContainer(
          duration: _anim,
          curve: Curves.easeOut,
          child: Obx(() {
            final pct = ctrl.adherencePct.value.clamp(0.0, 1.0);
            final percentText = '${(pct * 100).round()}%';
            return PressableCard(
              onTap: () {},
              background: theme.colorScheme.surface,
              gradient: LinearGradient(
                colors: [
                  AppTokens.primary.withOpacity(0.06),
                  AppTokens.secondary.withOpacity(0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconBadge(
                        color: AppTokens.primary,
                        icon: CupertinoIcons.chart_bar_alt_fill,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Adherence This Week',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        percentText,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 12,
                      child: Stack(
                        children: [
                          Container(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.6,
                            ),
                          ),
                          AnimatedContainer(
                            duration: AppTokens.animMed,
                            curve: Curves.easeOutCubic,
                            width: MediaQuery.sizeOf(context).width * pct,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTokens.primary,
                                  AppTokens.secondary,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        _HintRow(),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _IconBadge({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _HintRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 16,
          color: isDark ? Colors.white70 : AppTokens.textDark.withOpacity(0.6),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Tip: This screen works offline. Data will sync when online.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? Colors.white70
                  : AppTokens.textDark.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}

// ===== Reusable Pressable Card =====
class PressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? background;

  const PressableCard({
    super.key,
    required this.child,
    required this.onTap,
    this.gradient,
    this.background,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = widget.background ?? theme.colorScheme.surface;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: AppTokens.animFast,
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(AppTokens.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radiusL),
            onTap: widget.onTap,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.padH),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 72, minWidth: 48),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ===== Placeholder Screen for Routes =====
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String routeName;
  const _PlaceholderScreen({required this.title, required this.routeName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'This is a placeholder for "$routeName".\nWire your screen here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Utilities & Extensions =====
class _Stagger extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _Stagger({required this.child, this.delay = Duration.zero});

  @override
  State<_Stagger> createState() => _StaggerState();
}

class _StaggerState extends State<_Stagger> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _show ? 1 : 0,
      duration: AppTokens.animMed,
      curve: Curves.easeOut,
      child: AnimatedSlide(
        duration: AppTokens.animMed,
        curve: Curves.easeOut,
        offset: _show ? Offset.zero : const Offset(0, 0.07),
        child: widget.child,
      ),
    );
  }
}

extension _DateHelpers on DateTime {
  DateTime startOfWeek() {
    // Monday as start of week
    final d = dateOnly();
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  DateTime dateOnly() => DateTime(year, month, day);
}

// ===== To use this screen =====
// 1) Ensure GetMaterialApp is set in main.dart.
// 2) Bind: GetPage(name: '/home', page: () => const HomeView(), binding: HomeBinding())
// 3) Navigate: Get.toNamed('/home')
// 4) Replace placeholder navigation with your routes later.
// 5) Where to plug offline DB: HomeController._buildWeek and state fields (e.g., next appointment, doses).
