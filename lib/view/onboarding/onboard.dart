// lib/view/onboarding/onboard.dart
// MyRheumLog Onboarding Flow (Flutter 3.x + GetX + GetStorage)
// -----------------------------------------------------------
// This file contains a complete, modular onboarding flow with:
// - GetX Controllers, Bindings, and Routes
// - Offline persistence via GetStorage (offline-first)
// - Premium, accessible UI with subtle animations
// - 3-step onboarding: Diagnosis -> Medications -> Notifications
//
// Integration notes:
// - Register OnboardingRoutes.getPages in your GetMaterialApp routes.
// - Start with route Routes.onboarding.
// - Ensure OnboardingBinding is attached to the onboarding route.
// - Hero(tag: 'app_logo') is used to match the Splashscreen logo if needed.

// ignore_for_file: unused_local_variable, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myrheumlogapp/view/homepage/home.dart';

/// Centralized strings for easy i18n later.
class AppStrings {
  static const appName = 'MyRheumLog';

  // Generic
  static const next = 'Next';
  static const back = 'Back';
  static const skip = 'Skip';
  static const finish = 'Finish';
  static const notNow = 'Not now';
  static const enable = 'Enable';
  static const enabled = 'Enabled';
  static const continueToHome = 'Continue to Home';

  // Onboarding general
  static const onboardingTitle = 'Welcome';
  static const onboardingSubtitle = 'Let’s get you set up';
  static const step1Title = 'Quick Profile Setup';
  static const step1Subtitle = 'What is your diagnosis?';
  static const step2Title = 'Current Medications';
  static const step2Subtitle =
      'Add what you take regularly—this helps tracking and reminders.';
  static const step3Title = 'Notifications';
  static const step3Subtitle =
      'Stay on top of your health with timely reminders.';

  // Step 1
  static const selectDiagnosis = 'Select your condition';
  static const diagnosisRequired = 'Please select a diagnosis to continue.';

  // Step 2
  static const noMeds = 'No medications added yet.';
  static const addMedication = '+ Add Medication';
  static const helperCardMsg =
      'Add what you take regularly—this helps tracking and reminders.';
  static const prednisolone = 'Prednisolone';
  static const prednisoloneToggle = 'Taking Prednisolone';
  static const predDoseMgLabel = 'Prednisolone dose (mg)';
  static const invalidDose = 'Enter a valid dose between 1–60 mg.';
  static const painRelief = 'Pain relief';
  static const paracetamol = 'Paracetamol';
  static const ibuprofen = 'Ibuprofen';

  // Bottom Sheet
  static const addMedTitle = 'Add Medication';
  static const quickSelect = 'Quick-select';
  static const dmards = 'DMARDs';
  static const biologics = 'Biologics';
  static const configure = 'Configure';
  static const frequency = 'Frequency';
  static const doseMg = 'Dose (mg, optional)';
  static const dayOfWeek = 'Day of week';
  static const timeOfDay = 'Time';
  static const save = 'Save';
  static const remove = 'Remove';
  static const cancel = 'Cancel';
  static const alreadyAddedTapToRemove =
      'Already added — tap again to remove or use Remove icon.';
  static const examples =
      'Defaults reflect common NICE 2024 UK regimens. Adjust as needed.';

  // Step 3
  static const notifBenefitsTitle = 'Why enable notifications?';
  static const notifBenefit1 = 'Medication reminders';
  static const notifBenefit2 = 'Appointment reminders';
  static const notifBenefit3 = 'Symptom check-ins';
  static const enableNotifications = 'Enable Notifications';
  static const notificationsEnabled = 'Notifications enabled!';
  static const goHome = 'Go to Home';

  // Accessibility / semantics
  static const selected = 'Selected';
}

// Simple routes registry for integration.
class Routes {
  static const onboarding = '/onboarding';
  static const home = '/home';
}

/// Themed color seed for ColorScheme.
const _seedColor = Color(0xFF1F7A8C);

/// Optional theme helpers (use in your GetMaterialApp if desired).
ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: colorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

/// Diagnosis types supported in onboarding.
enum DiagnosisType {
  ra,
  psa,
  as,
  enteropathic,
  reactive,
  uia, // Undifferentiated Inflammatory Arthritis
  other,
}

extension DiagnosisTypeX on DiagnosisType {
  String get label {
    switch (this) {
      case DiagnosisType.ra:
        return 'Rheumatoid Arthritis (RA)';
      case DiagnosisType.psa:
        return 'Psoriatic Arthritis (PsA)';
      case DiagnosisType.as:
        return 'Ankylosing Spondylitis (AS)';
      case DiagnosisType.enteropathic:
        return 'Enteropathic Arthritis';
      case DiagnosisType.reactive:
        return 'Reactive Arthritis';
      case DiagnosisType.uia:
        return 'Undifferentiated Inflammatory Arthritis';
      case DiagnosisType.other:
        return 'Other';
    }
  }

  String get storageKey => toString().split('.').last;

  static DiagnosisType? fromKey(String? key) {
    if (key == null) return null;
    return DiagnosisType.values.firstWhereOrNull((e) => e.storageKey == key);
  }
}

/// Medication entry model with (de)serialization for GetStorage.
class MedicationEntry {
  final String name;
  final String? notes; // For schedule notes like "Weekly Monday 20:00"
  final double? doseMg;
  final String? frequency; // e.g., once daily, twice daily, weekly

  MedicationEntry({
    required this.name,
    this.notes,
    this.doseMg,
    this.frequency,
  });

  MedicationEntry copyWith({
    String? name,
    String? notes,
    double? doseMg,
    String? frequency,
  }) {
    return MedicationEntry(
      name: name ?? this.name,
      notes: notes ?? this.notes,
      doseMg: doseMg ?? this.doseMg,
      frequency: frequency ?? this.frequency,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'notes': notes,
    'doseMg': doseMg,
    'frequency': frequency,
  };

  static MedicationEntry fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      name: json['name'] as String,
      notes: json['notes'] as String?,
      doseMg: json['doseMg'] == null
          ? null
          : (json['doseMg'] as num).toDouble(),
      frequency: json['frequency'] as String?,
    );
  }
}

/// Onboarding controller using GetX and GetStorage.
class OnboardingController extends GetxController {
  // Storage box (initialized in binding).
  final GetStorage box;

  OnboardingController(this.box);

  // Reactive fields
  final Rxn<DiagnosisType> diagnosis = Rxn<DiagnosisType>();
  final RxList<MedicationEntry> medications = <MedicationEntry>[].obs;
  final RxnDouble prednisoloneDoseMg = RxnDouble();
  final RxBool notificationsEnabled = false.obs;

  // Step management
  final RxInt currentStep = 0.obs;
  static const int totalSteps = 3;

  // Keys for persistence
  static const _kDiagnosis = 'diagnosis';
  static const _kMedications = 'medications';
  static const _kPredDose = 'prednisoloneDoseMg';
  static const _kNotifications = 'notificationsEnabled';
  static const _kStep = 'onboardingStep';

  // Derived
  bool get isPrednisoloneOn => (prednisoloneDoseMg.value != null);

  // Frequencies for UI
  final List<String> frequencyOptions = const <String>[
    'Once daily',
    'Twice daily',
    'Three times daily (TDS)',
    'Four times daily (QDS)',
    'Weekly',
    'Fortnightly',
    'Monthly',
    'PRN (as needed)',
  ];

  @override
  void onInit() {
    super.onInit();
    _restore();
    // Persist whenever data changes.
    ever<DiagnosisType?>(diagnosis, (_) => _persistDiagnosis());
    ever<List<MedicationEntry>>(medications, (_) => _persistMedications());
    ever<double?>(prednisoloneDoseMg, (_) => _persistPrednisolone());
    ever<bool>(notificationsEnabled, (_) => _persistNotifications());
    ever<int>(currentStep, (_) => _persistStep());
  }

  // RESTORE STATE FROM STORAGE
  void _restore() {
    // Diagnosis
    final diagKey = box.read<String?>(_kDiagnosis);
    diagnosis.value = DiagnosisTypeX.fromKey(diagKey);

    // Medications
    final medsRaw = box.read<List<dynamic>>(_kMedications) ?? [];
    final meds = medsRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(MedicationEntry.fromJson)
        .toList();
    medications.assignAll(meds);

    // Prednisolone dose
    final pred = box.read<dynamic>(_kPredDose);
    if (pred is num) {
      prednisoloneDoseMg.value = pred.toDouble();
    } else {
      prednisoloneDoseMg.value = null;
    }

    // Notifications
    notificationsEnabled.value = box.read<bool>(_kNotifications) ?? false;

    // Step
    final step = box.read<int>(_kStep) ?? 0;
    currentStep.value = step.clamp(0, totalSteps - 1);
  }

  // PERSIST HELPERS
  Future<void> _persistDiagnosis() async {
    await box.write(_kDiagnosis, diagnosis.value?.storageKey);
  }

  Future<void> _persistMedications() async {
    await box.write(_kMedications, medications.map((e) => e.toJson()).toList());
  }

  Future<void> _persistPrednisolone() async {
    final val = prednisoloneDoseMg.value;
    if (val == null) {
      await box.remove(_kPredDose);
    } else {
      await box.write(_kPredDose, val);
    }
  }

  Future<void> _persistNotifications() async {
    await box.write(_kNotifications, notificationsEnabled.value);
  }

  Future<void> _persistStep() async {
    await box.write(_kStep, currentStep.value);
  }

  // STEP NAVIGATION
  bool get canGoBack => currentStep.value > 0;
  bool get isLastStep => currentStep.value == totalSteps - 1;

  bool get canGoNext {
    if (currentStep.value == 0) {
      return diagnosis.value != null;
    }
    // Step 2 has no required fields
    // Step 3 can always finish
    return true;
  }

  void nextStep() {
    if (!canGoNext) return;
    if (!isLastStep) {
      currentStep.value++;
    }
  }

  void backStep() {
    if (!canGoBack) return;
    currentStep.value--;
  }

  // DIAGNOSIS
  void setDiagnosis(DiagnosisType d) {
    diagnosis.value = d;
  }

  // MEDICATIONS
  bool hasMedication(String name) => medications.any((m) => m.name == name);

  void addOrUpdateMedication(MedicationEntry entry) {
    final idx = medications.indexWhere((m) => m.name == entry.name);
    if (idx >= 0) {
      medications[idx] = entry;
      medications.refresh();
    } else {
      medications.add(entry);
    }
  }

  void removeMedicationByName(String name) {
    medications.removeWhere((m) => m.name == name);
  }

  // Prednisolone toggle
  void setPrednisoloneOn(bool on) {
    if (!on) prednisoloneDoseMg.value = null;
    if (on && prednisoloneDoseMg.value == null) {
      prednisoloneDoseMg.value = 5; // sensible default
    }
  }

  void setPrednisoloneDose(double? mg) {
    prednisoloneDoseMg.value = mg;
  }
}

/// Binding initializes GetStorage and provides the controller.
class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.putAsync<OnboardingController>(() async {
      // Dedicated box for onboarding.
      await GetStorage.init('onboarding');
      final box = GetStorage('onboarding');
      return OnboardingController(box);
    });
  }
}

/// Route configuration helper (optional).
class OnboardingRoutes {
  static List<GetPage> getPages() => [
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingShell(),
      binding: OnboardingBinding(),
      transition: Transition.cupertinoDialog,
      transitionDuration: const Duration(milliseconds: 220),
    ),
    GetPage(
      name: Routes.home,
      page: () => const OnboardingCompletePlaceholder(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 240),
    ),
  ];
}

/// Onboarding shell with stepper, animated body, and navigation.
class OnboardingShell extends GetView<OnboardingController> {
  const OnboardingShell({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: CircleAvatar(
                backgroundColor: cs.primary,
                radius: 18,
                child: const Icon(Icons.favorite, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(AppStrings.appName),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              _AnimatedStepper(
                current: controller.currentStep.value,
                total: OnboardingController.totalSteps,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _buildStep(controller.currentStep.value),
                ),
              ),
              const SizedBox(height: 8),
              _BottomNavBar(
                onBack: controller.canGoBack ? controller.backStep : null,
                onNext: controller.canGoNext
                    ? () {
                        if (controller.isLastStep) {
                          // Finish -> go Home
                          Get.offAll(() => HomePage());
                        } else {
                          controller.nextStep();
                        }
                      }
                    : null,
                onSkip: () {
                  if (controller.currentStep.value == 1) {
                    controller.nextStep();
                  } else if (controller.currentStep.value == 2) {
                    Get.offAllNamed(Routes.home);
                  }
                },
                isLast: controller.isLastStep,
                canBack: controller.canGoBack,
                canNext: controller.canGoNext,
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return const _StepDiagnosis();
      case 1:
        return const _StepMedications();
      case 2:
        return const _StepNotifications();
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Top animated stepper/progress indicator.
class _AnimatedStepper extends StatelessWidget {
  final int current;
  final int total;
  const _AnimatedStepper({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 8,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final segmentW = w / total;
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: (current + 1) * segmentW,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(8),
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

/// Bottom navigation area with Back / Skip / Next buttons.
class _BottomNavBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final bool isLast;
  final bool canBack;
  final bool canNext;

  const _BottomNavBar({
    required this.onBack,
    required this.onNext,
    required this.onSkip,
    required this.isLast,
    required this.canBack,
    required this.canNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canBack ? onBack : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.surfaceContainerHighest,
                foregroundColor: cs.onSurfaceVariant,
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(AppStrings.back),
            ),
          ),
          const SizedBox(width: 12),
          if (!isLast)
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(AppStrings.skip),
              ),
            ),
          if (!isLast) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: canNext ? onNext : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(44, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(isLast ? AppStrings.finish : AppStrings.next),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------
// STEP 1: DIAGNOSIS SELECTION
// -----------------------------
class _StepDiagnosis extends GetView<OnboardingController> {
  const _StepDiagnosis();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headline = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.step1Title, style: headline),
          const SizedBox(height: 4),
          Text(
            AppStrings.step1Subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final selected = controller.diagnosis.value;
              final items = DiagnosisType.values;
              return GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final d = items[i];
                  final isSelected = selected == d;
                  return _DiagnosisTile(
                    type: d,
                    selected: isSelected,
                    onTap: () => controller.setDiagnosis(d),
                    color: _diagnosisColor(cs, d),
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (controller.diagnosis.value != null) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 18, color: cs.error),
                  const SizedBox(width: 6),
                  Text(
                    AppStrings.diagnosisRequired,
                    style: TextStyle(color: cs.error),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _diagnosisColor(ColorScheme cs, DiagnosisType d) {
    switch (d) {
      case DiagnosisType.ra:
        return cs.primaryContainer;
      case DiagnosisType.psa:
        return cs.tertiaryContainer;
      case DiagnosisType.as:
        return cs.secondaryContainer;
      case DiagnosisType.enteropathic:
        return cs.surfaceContainerHighest;
      case DiagnosisType.reactive:
        return cs.primary.withOpacity(0.15);
      case DiagnosisType.uia:
        return cs.tertiary.withOpacity(0.15);
      case DiagnosisType.other:
        return cs.secondary.withOpacity(0.15);
    }
  }
}

class _DiagnosisTile extends StatefulWidget {
  final DiagnosisType type;
  final VoidCallback onTap;
  final bool selected;
  final Color color;
  const _DiagnosisTile({
    required this.type,
    required this.onTap,
    required this.selected,
    required this.color,
  });

  @override
  State<_DiagnosisTile> createState() => _DiagnosisTileState();
}

class _DiagnosisTileState extends State<_DiagnosisTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.06,
    );
    _scale = Tween<double>(
      begin: 1,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onBg =
        ThemeData.estimateBrightnessForColor(widget.color) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Semantics(
      button: true,
      selected: widget.selected,
      label:
          '${widget.type.label}${widget.selected ? ', ${AppStrings.selected}' : ''}',
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapCancel: () => _pressCtrl.reverse(),
        onTapUp: (_) => _pressCtrl.reverse(),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: widget.selected ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                if (widget.selected)
                  BoxShadow(
                    color: cs.primary.withOpacity(0.15),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
              ],
              border: Border.all(
                color: widget.selected ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: ScaleTransition(
              scale: _scale,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.type.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: onBg,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------
// STEP 2: MEDICATIONS
// -----------------------------
class _StepMedications extends GetView<OnboardingController> {
  const _StepMedications();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headline = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);

    return Scaffold(
      key: const ValueKey('step2'),
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddMedicationSheet(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addMedication),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.step2Title, style: headline),
            const SizedBox(height: 4),
            _HelperCard(text: AppStrings.helperCardMsg),
            const SizedBox(height: 12),
            _PrednisoloneSection(),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                final meds = controller.medications.toList(growable: false);
                if (meds.isEmpty) {
                  return _EmptyMedsPlaceholder();
                }
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: meds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final m = meds[i];
                    return _MedicationTile(
                      entry: m,
                      onRemove: () => controller.removeMedicationByName(m.name),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 8),
            _PainReliefQuickAdd(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _openAddMedicationSheet(BuildContext context) {
    Get.bottomSheet(
      isScrollControlled: true,
      _AddMedicationSheet(),
      enterBottomSheetDuration: const Duration(milliseconds: 220),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }
}

class _HelperCard extends StatelessWidget {
  final String text;
  const _HelperCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1.5,
      color: cs.primaryContainer.withOpacity(0.35),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMedsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Opacity(
        opacity: 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_liquid, size: 64, color: cs.outline),
            const SizedBox(height: 12),
            Text(
              AppStrings.noMeds,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  final MedicationEntry entry;
  final VoidCallback onRemove;
  const _MedicationTile({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.primary.withOpacity(0.15),
          child: Icon(Icons.medication, color: cs.primary),
        ),
        title: Text(
          entry.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (entry.frequency != null) entry.frequency!,
            if (entry.doseMg != null) '${entry.doseMg!.toStringAsFixed(0)} mg',
            if (entry.notes != null) entry.notes!,
          ].join(' • '),
        ),
        trailing: IconButton(
          tooltip: AppStrings.remove,
          icon: Icon(Icons.close, color: cs.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class _PrednisoloneSection extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Obx(() {
      final on = controller.isPrednisoloneOn;
      final dose = controller.prednisoloneDoseMg.value;
      final controllerText = TextEditingController(
        text: dose?.toStringAsFixed((dose % 1 == 0 ? 0 : 1)) ?? '',
      );
      return Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: on,
                onChanged: controller.setPrednisoloneOn,
                title: const Text(AppStrings.prednisoloneToggle),
                secondary: Icon(Icons.local_pharmacy, color: cs.primary),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: on
                    ? Column(
                        key: const ValueKey('pred_on'),
                        children: [
                          const SizedBox(height: 8),
                          TextField(
                            key: const ValueKey('pred_input'),
                            controller: controllerText,
                            keyboardType: const TextInputType.numberWithOptions(
                              signed: false,
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: AppStrings.predDoseMgLabel,
                              hintText: 'e.g., 5',
                            ),
                            onChanged: (val) {
                              final parsed = double.tryParse(val);
                              controller.setPrednisoloneDose(parsed);
                            },
                          ),
                          const SizedBox(height: 6),
                          Builder(
                            builder: (context) {
                              final valid =
                                  dose != null && dose >= 1 && dose <= 60;
                              if (valid) {
                                return const SizedBox.shrink();
                              }
                              return Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 18,
                                    color: cs.error,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.invalidDose,
                                    style: TextStyle(color: cs.error),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                        ],
                      )
                    : const SizedBox(height: 0),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _PainReliefQuickAdd extends GetView<OnboardingController> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.painRelief,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _ToggleChip(
              label: AppStrings.paracetamol,
              selected: controller.hasMedication(AppStrings.paracetamol),
              onTap: () {
                final name = AppStrings.paracetamol;
                if (controller.hasMedication(name)) {
                  controller.removeMedicationByName(name);
                } else {
                  controller.addOrUpdateMedication(
                    MedicationEntry(
                      name: name,
                      frequency: 'PRN (as needed)',
                      notes: 'Max 1g up to 4x/day as advised',
                    ),
                  );
                }
              },
            ),
            _ToggleChip(
              label: AppStrings.ibuprofen,
              selected: controller.hasMedication(AppStrings.ibuprofen),
              onTap: () {
                final name = AppStrings.ibuprofen;
                if (controller.hasMedication(name)) {
                  controller.removeMedicationByName(name);
                } else {
                  controller.addOrUpdateMedication(
                    MedicationEntry(
                      name: name,
                      frequency: 'PRN (as needed)',
                      notes: 'Take with food; as advised',
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ToggleChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<_ToggleChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ToggleChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctrl.forward(from: 0.95);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: ChoiceChip(
        label: Text(widget.label),
        selected: widget.selected,
        onSelected: (_) => widget.onTap(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        labelStyle: TextStyle(
          color: widget.selected ? cs.onPrimary : cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
        selectedColor: cs.primary,
        backgroundColor: cs.surfaceVariant,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Bottom Sheet for adding medications (chips + expandable sections).
class _AddMedicationSheet extends StatefulWidget {
  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final TextEditingController _search = TextEditingController();
  String _query = '';

  // Quick chips
  final List<String> quick = const [
    'Methotrexate',
    'Sulfasalazine',
    'Hydroxychloroquine',
  ];

  // DMARDs and Biologics
  final List<String> dmards = const [
    'Methotrexate',
    'Sulfasalazine',
    'Hydroxychloroquine',
    'Leflunomide',
    'Azathioprine',
    'Ciclosporin',
    'Mycophenolate',
  ];

  final List<String> biologics = const [
    'Adalimumab',
    'Etanercept',
    'Infliximab',
    'Tocilizumab',
    'Abatacept',
    'Certolizumab',
    'Golimumab',
    'Sarilumab',
    'Ustekinumab',
    'Secukinumab',
    'Ixekizumab',
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() {
        _query = _search.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final cs = Theme.of(context).colorScheme;

    final filteredQuick = quick
        .where((e) => e.toLowerCase().contains(_query))
        .toList();
    final filteredDmards = dmards
        .where((e) => e.toLowerCase().contains(_query))
        .toList();
    final filteredBiologics = biologics
        .where((e) => e.toLowerCase().contains(_query))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scroll) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            controller: scroll,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.addMedTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.examples,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.outline),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      hintText: 'Search medications',
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (filteredQuick.isNotEmpty) ...[
                    Text(
                      AppStrings.quickSelect,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredQuick
                          .map(
                            (m) => _SheetChip(
                              label: m,
                              selected: controller.hasMedication(m),
                              onTap: () => _onMedicationChipTap(context, m),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ExpansionTile(
                    initiallyExpanded: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      AppStrings.dmards,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredDmards
                            .map(
                              (m) => _SheetChip(
                                label: m,
                                selected: controller.hasMedication(m),
                                onTap: () => _onMedicationChipTap(context, m),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: Text(
                      AppStrings.biologics,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    children: [
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredBiologics
                            .map(
                              (m) => _SheetChip(
                                label: m,
                                selected: controller.hasMedication(m),
                                onTap: () => _onMedicationChipTap(context, m),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(AppStrings.cancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onMedicationChipTap(BuildContext context, String name) async {
    final controller = Get.find<OnboardingController>();
    // Toggle off if exists, otherwise configure.
    if (controller.hasMedication(name)) {
      controller.removeMedicationByName(name);
      return;
    }
    // Open config bottom sheet for details.
    final configured = await Get.bottomSheet<MedicationEntry>(
      _MedicationConfigSheet(medName: name),
      isScrollControlled: true,
      enterBottomSheetDuration: const Duration(milliseconds: 200),
      exitBottomSheetDuration: const Duration(milliseconds: 200),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
    if (configured != null) {
      controller.addOrUpdateMedication(configured);
    }
  }
}

class _SheetChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SheetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_SheetChip> createState() => _SheetChipState();
}

class _SheetChipState extends State<_SheetChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(covariant _SheetChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ctrl.forward(from: 0.95);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ScaleTransition(
      scale: _scale,
      child: FilterChip(
        label: Text(widget.label),
        selected: widget.selected,
        onSelected: (_) => widget.onTap(),
        selectedColor: cs.primaryContainer,
        showCheckmark: true,
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// Bottom sheet to configure a medication entry after selecting it.
class _MedicationConfigSheet extends StatefulWidget {
  final String medName;
  const _MedicationConfigSheet({required this.medName});

  @override
  State<_MedicationConfigSheet> createState() => _MedicationConfigSheetState();
}

class _MedicationConfigSheetState extends State<_MedicationConfigSheet> {
  final _doseCtrl = TextEditingController();
  String _frequency = 'Once daily';
  DayOfWeek _dayOfWeek = DayOfWeek.monday;
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    // Defaults (inspired by common NICE 2024 regimens; user can edit)
    final defaults = _MedDefaults.forName(widget.medName);
    _frequency = defaults.frequency;
    if (defaults.defaultDoseMg != null) {
      _doseCtrl.text = defaults.defaultDoseMg!.toStringAsFixed(
        defaults.defaultDoseMg! % 1 == 0 ? 0 : 1,
      );
    }
    if (defaults.frequency.toLowerCase() == 'weekly') {
      _time = const TimeOfDay(hour: 20, minute: 0);
    }
  }

  @override
  void dispose() {
    _doseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isWeekly = _frequency.toLowerCase() == 'weekly';
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.45,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scroll) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SingleChildScrollView(
            controller: scroll,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.medication, color: cs.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${AppStrings.configure}: ${widget.medName}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _doseCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: AppStrings.doseMg,
                      hintText: 'e.g., 15',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    items: _frequencyOptions
                        .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => _frequency = val);
                    },
                    decoration: const InputDecoration(
                      labelText: AppStrings.frequency,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AnimatedOpacity(
                    opacity: isWeekly ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: !isWeekly,
                      child: Column(
                        children: [
                          DropdownButtonFormField<DayOfWeek>(
                            value: _dayOfWeek,
                            items: DayOfWeek.values
                                .map(
                                  (d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d.label),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => _dayOfWeek = val);
                            },
                            decoration: const InputDecoration(
                              labelText: AppStrings.dayOfWeek,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _TimePickerField(
                            label: AppStrings.timeOfDay,
                            time: _time,
                            onPick: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime:
                                    _time ??
                                    const TimeOfDay(hour: 20, minute: 0),
                              );
                              if (picked != null) {
                                setState(() => _time = picked);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          child: const Text(AppStrings.cancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final dose = double.tryParse(_doseCtrl.text);
                            final notes = isWeekly
                                ? 'Weekly on ${_dayOfWeek.label}'
                                      '${_time != null ? ' at ${_time!.format(context)}' : ''}'
                                : null;
                            final entry = MedicationEntry(
                              name: widget.medName,
                              doseMg: dose,
                              frequency: _frequency,
                              notes: notes,
                            );
                            Get.back(result: entry);
                          },
                          child: const Text(AppStrings.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<String> get _frequencyOptions => const [
    'Once daily',
    'Twice daily',
    'Three times daily (TDS)',
    'Four times daily (QDS)',
    'Weekly',
    'Fortnightly',
    'Monthly',
    'PRN (as needed)',
  ];
}

/// Simple common defaults for certain medications.
class _MedDefaults {
  final String name;
  final String frequency;
  final double? defaultDoseMg;

  _MedDefaults(this.name, this.frequency, this.defaultDoseMg);

  static _MedDefaults forName(String name) {
    switch (name) {
      case 'Methotrexate':
        return _MedDefaults(name, 'Weekly', 15);
      case 'Sulfasalazine':
        return _MedDefaults(name, 'Twice daily', 500);
      case 'Hydroxychloroquine':
        return _MedDefaults(name, 'Once daily', 200);
      case 'Leflunomide':
        return _MedDefaults(name, 'Once daily', 10);
      case 'Azathioprine':
        return _MedDefaults(name, 'Once daily', 50);
      case 'Ciclosporin':
        return _MedDefaults(name, 'Twice daily', 100);
      case 'Mycophenolate':
        return _MedDefaults(name, 'Twice daily', 500);
      case 'Adalimumab':
        return _MedDefaults(name, 'Fortnightly', null);
      case 'Etanercept':
        return _MedDefaults(name, 'Weekly', null);
      case 'Infliximab':
        return _MedDefaults(name, 'Monthly', null);
      case 'Tocilizumab':
        return _MedDefaults(name, 'Monthly', null);
      case 'Abatacept':
        return _MedDefaults(name, 'Monthly', null);
      case 'Certolizumab':
        return _MedDefaults(name, 'Fortnightly', null);
      case 'Golimumab':
        return _MedDefaults(name, 'Monthly', null);
      case 'Sarilumab':
        return _MedDefaults(name, 'Fortnightly', null);
      case 'Ustekinumab':
        return _MedDefaults(name, 'Monthly', null);
      case 'Secukinumab':
        return _MedDefaults(name, 'Monthly', null);
      case 'Ixekizumab':
        return _MedDefaults(name, 'Monthly', null);
      default:
        return _MedDefaults(name, 'Once daily', null);
    }
  }
}

/// Simple time picker display field.
class _TimePickerField extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onPick;
  const _TimePickerField({
    required this.label,
    required this.time,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              time != null ? time!.format(context) : '--:--',
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

extension DayOfWeekX on DayOfWeek {
  String get label {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }
}

// -----------------------------
// STEP 3: NOTIFICATIONS (mock)
// -----------------------------
class _StepNotifications extends GetView<OnboardingController> {
  const _StepNotifications();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final headline = Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600);
    return Padding(
      key: const ValueKey('step3'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.step3Title, style: headline),
          const SizedBox(height: 4),
          Text(AppStrings.step3Subtitle),
          const SizedBox(height: 16),
          _BenefitCard(icon: Icons.alarm, text: AppStrings.notifBenefit1),
          const SizedBox(height: 8),
          _BenefitCard(icon: Icons.event, text: AppStrings.notifBenefit2),
          const SizedBox(height: 8),
          _BenefitCard(
            icon: Icons.favorite_outline,
            text: AppStrings.notifBenefit3,
          ),
          const Spacer(),
          Center(
            child: Obx(() {
              final enabled = controller.notificationsEnabled.value;
              return Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: enabled
                        ? Row(
                            key: const ValueKey('enabled_badge'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundColor: cs.primary,
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppStrings.notificationsEnabled,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      controller.notificationsEnabled.value = true;
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: Text(
                      enabled
                          ? AppStrings.enabled
                          : AppStrings.enableNotifications,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.offAllNamed(Routes.home),
                    child: const Text(AppStrings.notNow),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BenefitCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primary.withOpacity(0.15),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------
// Placeholder Home route
// -----------------------------
class OnboardingCompletePlaceholder extends StatelessWidget {
  const OnboardingCompletePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, size: 64, color: cs.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Onboarding complete!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can now start using MyRheumLog.',
                    textAlign: TextAlign.center,
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
