// File: lib/track/ui_tokens.dart
// ignore_for_file: deprecated_member_use

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UITokens {
  // Brand colors
  static const Color primary = Color(0xFF4A90E2);
  static const Color secondary = Color(0xFF7ED321);
  static const Color warning = Color(0xFFF5A623);
  static const Color alert = Color(0xFFD0021B);
  static const Color bg = Color(0xFFF8F9FA);
  static const Color text = Color(0xFF222222);

  // Surfaces (light/dark aware)
  static Color surface(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color onSurface(BuildContext c) => Theme.of(c).colorScheme.onSurface;

  static const double radius = 20;
  static const Duration anim200 = Duration(milliseconds: 200);
  static const Duration anim240 = Duration(milliseconds: 240);
  static const Curve curve = Curves.easeOutCubic;

  static List<List<Color>> cardGradients(Brightness b) => [
    [
      primary.withOpacity(b == Brightness.dark ? 0.24 : 0.18),
      primary.withOpacity(b == Brightness.dark ? 0.36 : 0.28),
    ],
    [
      secondary.withOpacity(b == Brightness.dark ? 0.24 : 0.18),
      secondary.withOpacity(b == Brightness.dark ? 0.36 : 0.28),
    ],
    [
      warning.withOpacity(b == Brightness.dark ? 0.24 : 0.18),
      warning.withOpacity(b == Brightness.dark ? 0.36 : 0.28),
    ],
    [
      alert.withOpacity(b == Brightness.dark ? 0.22 : 0.16),
      alert.withOpacity(b == Brightness.dark ? 0.32 : 0.24),
    ],
  ];

  static ButtonStyle primaryButton(BuildContext c) => ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(56),
    backgroundColor: primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    elevation: 2,
  );

  static ButtonStyle secondaryButton(BuildContext c) =>
      OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: primary,
        side: BorderSide(color: primary.withOpacity(0.8), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      );

  static TextStyle labelLg(BuildContext c) =>
      Theme.of(c).textTheme.titleMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onSurface(c),
      ) ??
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface(c));

  static TextStyle bodyLg(BuildContext c) =>
      Theme.of(
        c,
      ).textTheme.bodyLarge?.copyWith(fontSize: 16, color: onSurface(c)) ??
      TextStyle(fontSize: 16, color: onSurface(c));

  static BoxDecoration cardDecoration(
    BuildContext c, {
    List<Color>? gradient,
    Color? color,
  }) {
    final radiusVal = BorderRadius.circular(radius);
    return BoxDecoration(
      color: color,
      gradient: gradient != null
          ? LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : null,
      borderRadius: radiusVal,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static EdgeInsets pagePadding(BuildContext c) =>
      const EdgeInsets.fromLTRB(16, 12, 16, 24);
}

// File: lib/track/quick_log_controller.dart

class DailyLog {
  final double vas;
  final Set<String> tags;
  final DateTime time;
  final String note;

  DailyLog({
    required this.vas,
    required this.tags,
    required this.time,
    required this.note,
  });
}

class QuickLogController extends GetxController {
  final RxDouble vas = 5.0.obs;
  final RxSet<String> tags = <String>{'stiffness', 'fatigue'}.obs;
  final Rx<DateTime> logTime = DateTime.now().obs;
  final RxString note = ''.obs;

  final logs = <DailyLog>[].obs;

  // For slider haptic thresholds
  final _thresholds = {2, 5, 8};
  int _lastTick = -1;

  void onVasChanged(double v) {
    vas.value = v.clamp(0.0, 10.0);
    final tick = vas.value.round();
    if (tick != _lastTick && _thresholds.contains(tick)) {
      HapticFeedback.mediumImpact();
    }
    _lastTick = tick;
  }

  void toggleTag(String key) {
    if (tags.contains(key)) {
      tags.remove(key);
    } else {
      tags.add(key);
    }
    tags.refresh();
    HapticFeedback.selectionClick();
  }

  void setDate(DateTime dt) {
    logTime.value = DateTime(
      dt.year,
      dt.month,
      dt.day,
      logTime.value.hour,
      logTime.value.minute,
    );
  }

  void setTime(TimeOfDay tod) {
    logTime.value = DateTime(
      logTime.value.year,
      logTime.value.month,
      logTime.value.day,
      tod.hour,
      tod.minute,
    );
  }

  Future<void> openDailyLogSheet({bool focusNote = false}) async {
    HapticFeedback.selectionClick();
    await Get.bottomSheet(
      DailyLogSheet(focusNote: focusNote),
      isScrollControlled: true,
      enableDrag: true,
      backgroundColor: Get.theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }

  void saveDailyLog() {
    final entry = DailyLog(
      vas: vas.value,
      tags: Set<String>.from(tags),
      time: logTime.value,
      note: note.value.trim(),
    );
    logs.insert(0, entry);
    HapticFeedback.heavyImpact();
    Get.back();
    Get.rawSnackbar(
      messageText: Text(
        'Daily log saved',
        style: TextStyle(
          color: Get.theme.colorScheme.onInverseSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Colors.green.shade600,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  // Navigation
  void goToDas28() {
    HapticFeedback.selectionClick();
    Get.to(() => const Das28View(), transition: Transition.cupertino);
  }

  void goToBASDAI() {
    HapticFeedback.selectionClick();
    Get.to(() => const BasdaiView(), transition: Transition.cupertino);
  }

  void goToJointMap() {
    HapticFeedback.selectionClick();
    Get.to(() => const JointMapView(), transition: Transition.cupertino);
  }

  void goToPhotos() {
    HapticFeedback.selectionClick();
    Get.to(() => const PhotoDiaryView(), transition: Transition.cupertino);
  }
}

// Forward declarations for navigation (avoid circular imports in controller file)
class Das28PlaceholderView extends StatelessWidget {
  const Das28PlaceholderView({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // replaced by real page in assessments/das28_view.dart
}

class BasdaiViewPage extends StatelessWidget {
  const BasdaiViewPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // replaced by real page
}

class JointMapViewPage extends StatelessWidget {
  const JointMapViewPage({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // replaced by real page
}

class PhotoDiaryView extends StatelessWidget {
  const PhotoDiaryView({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink(); // replaced by real page
}

// File: lib/track/widgets/header_card.dart

class HeaderCard extends StatefulWidget {
  const HeaderCard({super.key});

  @override
  State<HeaderCard> createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Stagger: header shows first
    Future.delayed(const Duration(milliseconds: 60), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  String _emojiFor(double v) {
    if (v <= 2) return '😌';
    if (v <= 4) return '🙂';
    if (v <= 6) return '😐';
    if (v <= 8) return '😣';
    return '😖';
  }

  Color _vasColor(double v) {
    if (v <= 2) return Colors.green.shade500;
    if (v <= 4) return Colors.teal.shade500;
    if (v <= 6) return Colors.amber.shade700;
    if (v <= 8) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuickLogController>();
    final b = Theme.of(context).brightness;
    final g = UITokens.cardGradients(b)[0];

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: UITokens.anim240,
      curve: UITokens.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: UITokens.anim240,
        curve: UITokens.curve,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: UITokens.cardDecoration(context, gradient: g),
          child: Obx(() {
            final v = c.vas.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling today?',
                  style: UITokens.labelLg(context).copyWith(
                    fontSize: 22,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(_emojiFor(v), style: const TextStyle(fontSize: 38)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'VAS ${v.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: UITokens.text,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 14,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 26,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withOpacity(0.35),
                    thumbColor: Colors.white,
                    overlayColor: Colors.white.withOpacity(0.15),
                    valueIndicatorColor: _vasColor(v),
                    showValueIndicator: ShowValueIndicator.always,
                  ),
                  child: Slider(
                    min: 0,
                    max: 10,
                    divisions: 100,
                    label: v.toStringAsFixed(1),
                    value: v,
                    onChanged: (nv) => c.onVasChanged(nv),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

//  lib/track/widgets/quick_tags_card.dart

class QuickTagsCard extends StatefulWidget {
  const QuickTagsCard({super.key});

  @override
  State<QuickTagsCard> createState() => _QuickTagsCardState();
}

class _QuickTagsCardState extends State<QuickTagsCard> {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuickLogController>();
    final b = Theme.of(context).brightness;
    final g = UITokens.cardGradients(b)[1];

    final tags = const [
      ('stiffness', 'Morning stiffness', Icons.wb_twilight),
      ('swollen', 'Swollen joints', Icons.bubble_chart),
      ('tender', 'Tender joints', Icons.touch_app),
      ('fatigue', 'Fatigue', Icons.battery_alert),
      ('good', 'Good day', Icons.tag_faces),
    ];
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: UITokens.anim240,
      curve: UITokens.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: UITokens.anim240,
        curve: UITokens.curve,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: UITokens.cardDecoration(context, gradient: g),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick tags',
                style: UITokens.labelLg(context).copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final spacing = 12.0;
                  final columns = constraints.maxWidth > 520 ? 2 : 2;
                  final chipWidth = (constraints.maxWidth - spacing) / columns;
                  return Obx(() {
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: tags.map((t) {
                        final selected = c.tags.contains(t.$1);
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: chipWidth,
                            maxWidth: chipWidth,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              UITokens.radius,
                            ),
                            onTap: () => c.toggleTag(t.$1),
                            child: AnimatedContainer(
                              duration: UITokens.anim200,
                              curve: UITokens.curve,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(
                                  UITokens.radius,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    selected ? 0 : 0.35,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    t.$3,
                                    color: selected
                                        ? UITokens.primary
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      t.$2,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? UITokens.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  AnimatedOpacity(
                                    opacity: selected ? 1 : 0.0,
                                    duration: UITokens.anim200,
                                    child: const Icon(
                                      Icons.check_circle,
                                      color: UITokens.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// File: lib/track/widgets/action_row.dart

class ActionRow extends StatefulWidget {
  const ActionRow({super.key});

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuickLogController>();

    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: UITokens.anim240,
      curve: UITokens.curve,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.05),
        duration: UITokens.anim240,
        curve: UITokens.curve,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 560;
            final primaryBtn = ElevatedButton.icon(
              style: UITokens.primaryButton(context),
              onPressed: () => c.openDailyLogSheet(),
              icon: const Icon(Icons.save_rounded),
              label: const Text('Save Daily Log', textAlign: TextAlign.center),
            );
            final secondaryBtn = OutlinedButton.icon(
              style: UITokens.secondaryButton(context),
              onPressed: () => c.openDailyLogSheet(focusNote: true),
              icon: const Icon(Icons.note_add_rounded),
              label: const Text('Add Note'),
            );
            if (isWide) {
              return Row(
                children: [
                  Expanded(child: primaryBtn),
                  const SizedBox(width: 12, height: 12),
                  Expanded(child: secondaryBtn),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primaryBtn,
                  const SizedBox(height: 12),
                  secondaryBtn,
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

// File: lib/track/widgets/daily_log_sheet.dart

class DailyLogSheet extends StatefulWidget {
  final bool focusNote;
  const DailyLogSheet({super.key, this.focusNote = false});

  @override
  State<DailyLogSheet> createState() => _DailyLogSheetState();
}

class _DailyLogSheetState extends State<DailyLogSheet> {
  final _noteCtrl = TextEditingController();
  final _noteFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final c = Get.find<QuickLogController>();
    _noteCtrl.text = c.note.value;
    if (widget.focusNote) {
      // Slight delay to ensure sheet is presented before focusing
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _noteFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuickLogController>();
    final mq = MediaQuery.of(context);
    final pad = mq.viewInsets.bottom + 16.0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, pad),
        child: Obx(() {
          final time = c.logTime.value;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text('Daily Log', style: UITokens.labelLg(context)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(
                    avatar: const Text('🎚️'),
                    label: Text('VAS ${c.vas.value.toStringAsFixed(1)}/10'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: c.tags.map((t) {
                        final label = {
                          'stiffness': 'Stiffness',
                          'swollen': 'Swollen',
                          'tender': 'Tender',
                          'fatigue': 'Fatigue',
                          'good': 'Good day',
                        }[t]!;
                        return Chip(
                          avatar: const Text('🏷️'),
                          label: Text(label),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: UITokens.secondaryButton(context),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: time,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) c.setDate(picked);
                      },
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(
                        '${time.year}-${time.month.toString().padLeft(2, '0')}-${time.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: UITokens.secondaryButton(context),
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(time),
                        );
                        if (picked != null) c.setTime(picked);
                      },
                      icon: const Icon(Icons.schedule_rounded),
                      label: Text(TimeOfDay.fromDateTime(time).format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                focusNode: _noteFocus,
                controller: _noteCtrl,
                onChanged: (v) => c.note.value = v,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Optional note (e.g. triggers, activities)',
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(UITokens.radius),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: UITokens.primaryButton(context),
                  onPressed: () => c.saveDailyLog(),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Save Log'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// File: lib/track/quick_log_view.dart

class QuickLogView extends StatefulWidget {
  const QuickLogView({super.key});

  @override
  State<QuickLogView> createState() => _QuickLogViewState();
}

class _QuickLogViewState extends State<QuickLogView> {
  bool _cardsVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) setState(() => _cardsVisible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.find<QuickLogController>();
    final b = Theme.of(context).brightness;
    final gradients = UITokens.cardGradients(b);

    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        padding: UITokens.pagePadding(context),
        child: SingleChildScrollView(
          padding: UITokens.pagePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HeaderCard(),
              const SizedBox(height: 16),
              const QuickTagsCard(),
              const SizedBox(height: 16),
              const ActionRow(),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: _cardsVisible ? 1 : 0,
                duration: UITokens.anim240,
                curve: UITokens.curve,
                child: AnimatedSlide(
                  offset: _cardsVisible ? Offset.zero : const Offset(0, 0.05),
                  duration: UITokens.anim240,
                  curve: UITokens.curve,
                  child: _AssessmentCardsGrid(
                    onA: c.goToDas28,
                    onB: c.goToBASDAI,
                    onC: c.goToJointMap,
                    onD: c.goToPhotos,
                    gradients: gradients,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                final logs = c.logs;
                if (logs.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent logs', style: UITokens.labelLg(context)),
                    const SizedBox(height: 8),
                    ...logs.take(5).map((l) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(UITokens.radius),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: UITokens.primary.withOpacity(0.15),
                            child: Text(
                              l.vas.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            '${l.time.year}-${l.time.month.toString().padLeft(2, '0')}-${l.time.day.toString().padLeft(2, '0')} '
                            '${TimeOfDay.fromDateTime(l.time).format(context)}',
                          ),
                          subtitle: Text(
                            [
                              if (l.tags.isNotEmpty)
                                l.tags
                                    .map(
                                      (t) => {
                                        'stiffness': 'Stiffness',
                                        'swollen': 'Swollen',
                                        'tender': 'Tender',
                                        'fatigue': 'Fatigue',
                                        'good': 'Good day',
                                      }[t]!,
                                    )
                                    .join(', '),
                              if (l.note.isNotEmpty) l.note,
                            ].where((s) => s.isNotEmpty).join(' • '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentCardsGrid extends StatelessWidget {
  final VoidCallback onA, onB, onC, onD;
  final List<List<Color>> gradients;
  const _AssessmentCardsGrid({
    required this.onA,
    required this.onB,
    required this.onC,
    required this.onD,
    required this.gradients,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _CardItem(
        title: 'DAS28 Calculator',
        caption: 'Tender/Swollen + ESR/CRP',
        icon: Icons.calculate_rounded,
        onTap: onA,
        gradient: gradients[0],
      ),
      _CardItem(
        title: 'BASDAI',
        caption: '6-item activity index',
        icon: Icons.tune_rounded,
        onTap: onB,
        gradient: gradients[1],
      ),
      _CardItem(
        title: 'Joint Map',
        caption: 'Mark tender/swollen',
        icon: Icons.grid_on_rounded,
        onTap: onC,
        gradient: gradients[2],
      ),
      _CardItem(
        title: 'Photos',
        caption: 'Track visible changes',
        icon: Icons.photo_library_rounded,
        onTap: onD,
        gradient: gradients[3],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 640;
        final crossAxisCount = isWide ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 120,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, i) => _PressCard(item: items[i]),
        );
      },
    );
  }
}

class _CardItem {
  final String title;
  final String caption;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> gradient;
  _CardItem({
    required this.title,
    required this.caption,
    required this.icon,
    required this.onTap,
    required this.gradient,
  });
}

class _PressCard extends StatefulWidget {
  final _CardItem item;
  const _PressCard({required this.item});

  @override
  State<_PressCard> createState() => _PressCardState();
}

class _PressCardState extends State<_PressCard> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: UITokens.anim200,
      curve: UITokens.curve,
      child: InkWell(
        borderRadius: BorderRadius.circular(UITokens.radius),
        onHighlightChanged: (v) => setState(() => _pressed = v),
        onTap: widget.item.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: UITokens.cardDecoration(
            context,
            gradient: widget.item.gradient,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  widget.item.icon,
                  color: UITokens.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: DefaultTextStyle(
                  style: UITokens.labelLg(
                    context,
                  ).copyWith(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.caption,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.95),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// File: lib/track/assessments/das28_view.dart

class Das28Controller extends GetxController {
  final RxInt tjc = 3.obs;
  final RxInt sjc = 4.obs;
  final RxDouble patientGlobal = 50.0.obs; // 0-100
  final RxBool useCRP = true.obs;
  final RxDouble esr = 20.0.obs; // mm/hr
  final RxDouble crp = 1.5.obs; // mg/dL (example)

  double get das28 {
    final tj = tjc.value.toDouble();
    final sj = sjc.value.toDouble();
    final vas = patientGlobal.value;
    if (useCRP.value) {
      return 0.56 * math.sqrt(tj) +
          0.28 * math.sqrt(sj) +
          0.36 * math.log(crp.value + 1) +
          0.014 * vas +
          0.96;
    } else {
      return 0.56 * math.sqrt(tj) +
          0.28 * math.sqrt(sj) +
          0.70 * math.log(esr.value) +
          0.014 * vas;
    }
  }

  String get category {
    final v = das28;
    if (v < 2.6) return 'Remission';
    if (v < 3.2) return 'Low';
    if (v <= 5.1) return 'Moderate';
    return 'High';
  }

  Color categoryColor(BuildContext context) {
    switch (category) {
      case 'Remission':
        return Colors.green.shade600;
      case 'Low':
        return Colors.teal.shade600;
      case 'Moderate':
        return Colors.amber.shade700;
      case 'High':
      default:
        return Colors.red.shade600;
    }
  }
}

class Das28View extends StatelessWidget {
  const Das28View({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(Das28Controller());
    return Scaffold(
      appBar: AppBar(title: const Text('DAS28 Calculator')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: UITokens.pagePadding(context),
          child: Obx(() {
            final value = c.das28;
            final cat = c.category;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NumberFieldRow(
                  label: 'Tender joints (0–28)',
                  value: c.tjc.value.toString(),
                  onInc: () => c.tjc.value = (c.tjc.value + 1).clamp(0, 28),
                  onDec: () => c.tjc.value = (c.tjc.value - 1).clamp(0, 28),
                ),
                const SizedBox(height: 12),
                _NumberFieldRow(
                  label: 'Swollen joints (0–28)',
                  value: c.sjc.value.toString(),
                  onInc: () => c.sjc.value = (c.sjc.value + 1).clamp(0, 28),
                  onDec: () => c.sjc.value = (c.sjc.value - 1).clamp(0, 28),
                ),
                const SizedBox(height: 16),
                Text(
                  'Patient Global (0–100)',
                  style: UITokens.labelLg(context),
                ),
                Slider(
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: c.patientGlobal.value.round().toString(),
                  value: c.patientGlobal.value,
                  onChanged: (v) => c.patientGlobal.value = v,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [
                    ChoiceChip(
                      selectedColor: UITokens.primary.withOpacity(0.15),
                      label: const Text('Use CRP'),
                      selected: c.useCRP.value,
                      onSelected: (_) => c.useCRP.value = true,
                    ),
                    ChoiceChip(
                      selectedColor: UITokens.primary.withOpacity(0.15),
                      label: const Text('Use ESR'),
                      selected: !c.useCRP.value,
                      onSelected: (_) => c.useCRP.value = false,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (c.useCRP.value)
                  _StepperField(
                    label: 'CRP (mg/L)',
                    value: c.crp.value,
                    onChanged: (v) => c.crp.value = v.clamp(0.0, 200.0),
                  )
                else
                  _StepperField(
                    label: 'ESR (mm/hr)',
                    value: c.esr.value,
                    onChanged: (v) => c.esr.value = v.clamp(1.0, 200.0),
                    min: 1,
                  ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(UITokens.radius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Your DAS28: ${value.toStringAsFixed(2)}',
                          style: UITokens.labelLg(context),
                        ),
                      ),
                      Chip(
                        label: Text(
                          cat,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        backgroundColor: c.categoryColor(context),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _NumberFieldRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onInc;
  final VoidCallback onDec;
  const _NumberFieldRow({
    required this.label,
    required this.value,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: UITokens.bodyLg(context))),
        Row(
          children: [
            _IconBtn(icon: Icons.remove, onTap: onDec),
            SizedBox(
              width: 56,
              child: Center(
                child: Text(value, style: UITokens.labelLg(context)),
              ),
            ),
            _IconBtn(icon: Icons.add, onTap: onInc),
          ],
        ),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _StepperField extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    // ignore: unused_element_parameter
    this.max = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(1)}',
          style: UITokens.bodyLg(context),
        ),
        Slider(
          min: min,
          max: max,
          divisions: (max - min).round(),
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// File: lib/track/assessments/basdai_view.dart

class BasdaiController extends GetxController {
  final RxList<double> q = List<double>.filled(6, 5.0).obs;

  double get score {
    final avg1 = (q[0] + q[1] + q[2] + q[3]) / 4;
    final avg2 = (q[4] + q[5]) / 2;
    return (avg1 + avg2) / 2;
  }
}

class BasdaiView extends StatelessWidget {
  const BasdaiView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(BasdaiController());
    final labels = const [
      'Overall fatigue',
      'Spinal pain',
      'Peripheral joint pain/swelling',
      'Enthesitis (areas of tenderness)',
      'Morning stiffness duration',
      'Morning stiffness severity',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('BASDAI')),
      body: SafeArea(
        child: Obx(() {
          final score = c.score;
          return SingleChildScrollView(
            padding: UITokens.pagePadding(context),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(UITokens.radius),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Score: ${score.toStringAsFixed(2)}',
                          style: UITokens.labelLg(context),
                        ),
                      ),
                      Chip(
                        label: Text(
                          score < 4 ? 'Low' : 'High',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: score < 4
                            ? Colors.teal.shade600
                            : Colors.orange.shade700,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(6, (i) {
                  return _BasdaiSlider(
                    label: labels[i],
                    value: c.q[i],
                    onChanged: (v) {
                      c.q[i] = v;
                      c.q.refresh();
                    },
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BasdaiSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _BasdaiSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UITokens.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: UITokens.bodyLg(context)),
            Slider(
              min: 0,
              max: 10,
              divisions: 100,
              label: value.toStringAsFixed(1),
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

// File: lib/track/assessments/joint_map_view.dart

class JointMapController extends GetxController {
  // Mock markers on a simple grid for front/back
  final RxBool tenderMode = true.obs; // true=tender(blue), false=swollen(red)
  final RxSet<int> tender = <int>{2, 7}.obs;
  final RxSet<int> swollen = <int>{5}.obs;

  void toggle(int id) {
    if (tenderMode.value) {
      if (tender.contains(id)) {
        tender.remove(id);
      } else {
        tender.add(id);
      }
      tender.refresh();
    } else {
      if (swollen.contains(id)) {
        swollen.remove(id);
      } else {
        swollen.add(id);
      }
      swollen.refresh();
    }
  }

  void clearAll() {
    tender.clear();
    swollen.clear();
    tender.refresh();
    swollen.refresh();
  }
}

class JointMapView extends StatelessWidget {
  const JointMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(JointMapController());
    return Scaffold(
      appBar: AppBar(title: const Text('Joint Map')),
      body: SafeArea(
        child: Padding(
          padding: UITokens.pagePadding(context),
          child: Column(
            children: [
              _LegendRow(controller: c),
              const SizedBox(height: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cols = 4;
                    final rows = 6;
                    final total = cols * rows;
                    final size = constraints.biggest;
                    final cellW = size.width / cols;
                    final cellH = size.height / rows;
                    return Obx(() {
                      return Stack(
                        children: [
                          // Front placeholder
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.08,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.accessibility_new,
                                  size: 400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                          // Grid and markers
                          ...List.generate(total, (i) {
                            final col = i % cols;
                            final row = i ~/ cols;
                            final left = col * cellW;
                            final top = row * cellH;
                            final isTender = c.tender.contains(i);
                            final isSwollen = c.swollen.contains(i);
                            Color? color;
                            if (isTender) color = Colors.blueAccent;
                            if (isSwollen) color = Colors.redAccent;
                            return Positioned(
                              left: left,
                              top: top,
                              width: cellW,
                              height: cellH,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () => c.toggle(i),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color:
                                          color?.withOpacity(0.85) ??
                                          Colors.transparent,
                                      border: Border.all(
                                        color:
                                            color ??
                                            Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      );
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: UITokens.secondaryButton(context),
                      onPressed: c.clearAll,
                      icon: const Icon(Icons.clear_all_rounded),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: UITokens.primaryButton(context),
                      onPressed: () {
                        Get.rawSnackbar(
                          message: 'Joint map saved',
                          duration: const Duration(seconds: 2),
                        );
                      },
                      icon: const Icon(Icons.save_alt_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final JointMapController controller;
  const _LegendRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tenderMode = controller.tenderMode.value;
      return Row(
        children: [
          ChoiceChip(
            selected: tenderMode,
            onSelected: (_) => controller.tenderMode.value = true,
            label: const Text('Tender'),
            selectedColor: Colors.blueAccent.withOpacity(0.2),
            avatar: const CircleAvatar(
              radius: 6,
              backgroundColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            selected: !tenderMode,
            onSelected: (_) => controller.tenderMode.value = false,
            label: const Text('Swollen'),
            selectedColor: Colors.redAccent.withOpacity(0.2),
            avatar: const CircleAvatar(
              radius: 6,
              backgroundColor: Colors.redAccent,
            ),
          ),
          const Spacer(),
          Row(
            children: const [
              CircleAvatar(radius: 6, backgroundColor: Colors.blueAccent),
              SizedBox(width: 6),
              Text('Tender'),
              SizedBox(width: 12),
              CircleAvatar(radius: 6, backgroundColor: Colors.redAccent),
              SizedBox(width: 6),
              Text('Swollen'),
            ],
          ),
        ],
      );
    });
  }
}

class PhotoItem {
  final Color color;
  String note;
  PhotoItem({required this.color, this.note = ''});
}

class PhotosController extends GetxController {
  final RxList<PhotoItem> items = <PhotoItem>[].obs;

  void addMockPhoto() {
    final rnd = math.Random();
    final color = HSVColor.fromAHSV(
      1,
      rnd.nextDouble() * 360,
      0.5 + rnd.nextDouble() * 0.5,
      0.7,
    ).toColor();
    items.add(PhotoItem(color: color));
    items.refresh();
  }

  void updateNote(int index, String note) {
    if (index >= 0 && index < items.length) {
      items[index].note = note;
      items.refresh();
    }
  }
}

class PhotosView extends StatelessWidget {
  const PhotosView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PhotosController());
    return Scaffold(
      appBar: AppBar(title: const Text('Photo Diary')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          c.addMockPhoto();
          Get.rawSnackbar(message: 'Mock photo added');
        },
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Add Photo'),
      ),
      body: SafeArea(
        child: Obx(() {
          return GridView.builder(
            padding: UITokens.pagePadding(context),
            itemCount: c.items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (_, i) => _PhotoTile(index: i),
          );
        }),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final int index;
  const _PhotoTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<PhotosController>();
    final item = c.items[index];
    return InkWell(
      onTap: () async {
        final ctrl = TextEditingController(text: item.note);
        await Get.bottomSheet(
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Photo note', style: UITokens.labelLg(context)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Add an optional note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: UITokens.primaryButton(context),
                      onPressed: () {
                        c.updateNote(index, ctrl.text.trim());
                        Get.back();
                      },
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isScrollControlled: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          children: [
            if (item.note.isNotEmpty)
              Positioned(
                left: 6,
                right: 6,
                bottom: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.note,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
