// lib/view/onboarding/onboard.dart
// MyRheumLog - Onboarding flow
// Flutter 3.x + GetX + GetStorage (offline-first)
// This file contains: routes, bindings, controller, models, widgets, and pages for the onboarding wizard.
// Each section is commented for clarity.

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

////////////////////////////////////////////////////////////////////////////////
// Strings (simple i18n extension point)
////////////////////////////////////////////////////////////////////////////////
class AppStrings {
  // App
  static const appName = 'MyRheumLog';

  // Routes
  static const onboardingTitle = 'Welcome';
  static const notificationsTitle = 'Notifications';
  static const homeTitle = 'Home';

  // Stepper
  static const step1Title = 'Quick Profile';
  static const step2Title = 'Your Rheumatologist';
  static const step3Title = 'Medications';

  // Common
  static const next = 'Next';
  static const back = 'Back';
  static const skip = 'Skip';
  static const done = 'Done';
  static const continueLabel = 'Continue';
  static const notNow = 'Not now';
  static const enable = 'Enable';
  static const cancel = 'Cancel';
  static const save = 'Save';
  static const add = 'Add';
  static const remove = 'Remove';
  static const search = 'Search';
  static const optional = 'Optional';

  // Step 1 fields
  static const yourName = 'Your name (optional)';
  static const dob = 'Date of birth';
  static const pickDate = 'Pick date';
  static const diagnosis = 'Diagnosis';
  static const diagnosisHint =
      'Choose your diagnosis. You can change this later.';
  static const dobErrorFuture = 'Date of birth cannot be in the future.';
  static const dobRequired = 'Please select your date of birth.';
  static const diagnosisRequired = 'Please select a diagnosis.';

  // Step 2 fields
  static const doctorName = 'Consultant’s name (optional)';
  static const hospitalName = 'Hospital/Clinic name';
  static const clinicHelpline = 'Clinic helpline (optional)';
  static const nextAppointment = 'Next appointment';
  static const nextAppointmentHint = 'Today or future date';
  static const hospitalRequired = 'Hospital/Clinic is required for Next.';
  static const youCanSkip = 'You can skip this step if you prefer.';

  // Step 3 fields
  static const medicationsHeader =
      'Add what you take regularly—this helps tracking and reminders.';
  static const noMeds = 'No medications added yet';
  static const addMedication = '+ Add Medication';
  static const quickSelect = 'Quick select';
  static const dmards = 'DMARDs';
  static const biologics = 'Biologics';
  static const prednisolone = 'Prednisolone';
  static const predDoseMg = 'Dose (mg)';
  static const doseHelper = 'Enter a numeric dose (e.g., 10 mg)';
  static const predDoseInvalid = 'Enter a dose between 0.5 and 100 mg';
  static const painRelief = 'Pain relief';
  static const painReliefOther = 'Other (free text)';
  static const notes = 'Notes';
  static const startDate = 'Start date';
  static const frequency = 'Frequency';
  static const selectFrequency = 'Select frequency';
  static const dayOfWeek = 'Day of week';
  static const timeOfDay = 'Time of day';

  // Notifications screen
  static const notificationsHeader = 'Stay on track';
  static const notificationsBody1 =
      '• Medication reminders\n• Appointment nudges\n• Symptom check-ins';
  static const enableNotifications = 'Enable Notifications';
  static const notNowNotifications = 'Not now';
  static const notificationsEnabled = 'Notifications enabled';
  static const notificationsSaved = 'We’ll remind you when it helps.';

  // Home
  static const homeHello = 'You are all set!';

  // Misc
  static const other = 'Other';
}

////////////////////////////////////////////////////////////////////////////////
// Models
////////////////////////////////////////////////////////////////////////////////

// Diagnosis options (extendable)
enum DiagnosisType {
  ra, // Rheumatoid Arthritis (RA)
  psa, // Psoriatic Arthritis (PsA)
  as, // Ankylosing Spondylitis (AS)
  enteropathic, // Enteropathic arthritis
  jia, // Juvenile Idiopathic Arthritis
  reactive, // Reactive arthritis
  sle, // Systemic Lupus Erythematosus (if relevant)
  other, // Other
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
        return 'Enteropathic arthritis';
      case DiagnosisType.jia:
        return 'Juvenile Idiopathic Arthritis';
      case DiagnosisType.reactive:
        return 'Reactive arthritis';
      case DiagnosisType.sle:
        return 'Systemic Lupus Erythematosus';
      case DiagnosisType.other:
        return 'Other';
    }
  }

  Color get colorHint {
    switch (this) {
      case DiagnosisType.ra:
        return const Color(0xFF4CB9AB);
      case DiagnosisType.psa:
        return const Color(0xFF7CA8F2);
      case DiagnosisType.as:
        return const Color(0xFFF2A97C);
      case DiagnosisType.enteropathic:
        return const Color(0xFF9AD0C2);
      case DiagnosisType.jia:
        return const Color(0xFFD0A3FF);
      case DiagnosisType.reactive:
        return const Color(0xFFFFC75F);
      case DiagnosisType.sle:
        return const Color(0xFF6EC1E4);
      case DiagnosisType.other:
        return const Color(0xFFB0BEC5);
    }
  }
}

// Medication entry data class
class MedicationEntry {
  final String name;
  final double? doseMg; // optional numeric dose (if applicable)
  final String? notes; // frequency/schedule or free notes

  MedicationEntry({required this.name, this.doseMg, this.notes});

  MedicationEntry copyWith({String? name, double? doseMg, String? notes}) {
    return MedicationEntry(
      name: name ?? this.name,
      doseMg: doseMg ?? this.doseMg,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'doseMg': doseMg,
    'notes': notes,
  };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) =>
      MedicationEntry(
        name: json['name'] as String,
        doseMg: (json['doseMg'] as num?)?.toDouble(),
        notes: json['notes'] as String?,
      );
}

////////////////////////////////////////////////////////////////////////////////
// Controller (GetX) + Persistence
////////////////////////////////////////////////////////////////////////////////

class OnboardingController extends GetxController {
  // Storage
  static const _boxName = 'myrheumlog';
  static const _kData = 'onboarding_data';
  static const _kStep = 'onboarding_step';
  final GetStorage storage = GetStorage(_boxName);

  // Reactive fields
  final RxnString name = RxnString();
  final Rxn<DateTime> dateOfBirth = Rxn<DateTime>();
  final Rx<DiagnosisType?> diagnosis = Rx<DiagnosisType?>(null);

  final RxnString doctorName = RxnString();
  final RxnString hospitalName = RxnString();
  final RxnString clinicHelpline = RxnString();
  final Rxn<DateTime> nextAppointment = Rxn<DateTime>();

  final RxList<MedicationEntry> medications = <MedicationEntry>[].obs;
  final RxBool prednisoloneOn = false.obs;
  final RxnDouble prednisoloneDoseMg = RxnDouble();
  final RxList<String> painRelief = <String>[].obs;

  final RxBool notificationsEnabled = false.obs;

  // Step control
  final RxInt currentStep = 0.obs; // 0..2

  // Pain relief suggestions
  final List<String> _painReliefOptions = const [
    'Paracetamol',
    'Ibuprofen',
    'Naproxen',
    'Codeine',
  ];
  List<String> get painReliefOptions => _painReliefOptions;

  // DMARD & Biologics (extendable)
  final List<String> quickMeds = const [
    'Methotrexate',
    'Sulfasalazine',
    'Hydroxychloroquine',
  ];
  final List<String> dmardsList = const [
    'Methotrexate',
    'Sulfasalazine',
    'Hydroxychloroquine',
    'Leflunomide',
    'Azathioprine',
    'Ciclosporin',
    'Mycophenolate',
  ];
  final List<String> biologicsList = const [
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

  // Init: load persisted state and determine step
  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  // Validation
  bool get isDobValid =>
      dateOfBirth.value != null && !dateOfBirth.value!.isAfter(DateTime.now());
  bool get isDiagnosisValid => diagnosis.value != null;

  bool get step1Valid => isDobValid && isDiagnosisValid;

  bool get step2CanNext => (hospitalName.value?.trim().isNotEmpty ?? false);
  bool get step2CanSkip => true;

  bool get predDoseValid {
    if (!prednisoloneOn.value) return true;
    final d = prednisoloneDoseMg.value;
    if (d == null) return false;
    return d >= 0.5 && d <= 100;
  }

  bool get step3Valid => predDoseValid;

  // Add/remove medications; avoid duplicates by name (case-insensitive)
  void addOrUpdateMedication(MedicationEntry entry) {
    final idx = medications.indexWhere(
      (e) => e.name.toLowerCase().trim() == entry.name.toLowerCase().trim(),
    );
    if (idx >= 0) {
      medications[idx] = entry;
    } else {
      medications.add(entry);
    }
  }

  void removeMedicationByName(String name) {
    medications.removeWhere(
      (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
    );
  }

  bool hasMedication(String name) {
    return medications.indexWhere(
          (e) => e.name.toLowerCase().trim() == name.toLowerCase().trim(),
        ) >=
        0;
  }

  // Pain relief toggle
  void togglePainRelief(String item) {
    if (painRelief.contains(item)) {
      painRelief.remove(item);
    } else {
      painRelief.add(item);
    }
  }

  // Step navigation with persistence
  Future<void> goNext() async {
    if (currentStep.value < 2) {
      await persist();
      currentStep.value += 1;
      await storage.write(_kStep, currentStep.value);
    } else {
      // From Step 3 → Notifications page
      await persist();
      Get.toNamed(OnboardingRoutes.notifications);
    }
  }

  Future<void> goBack() async {
    if (currentStep.value > 0) {
      currentStep.value -= 1;
      await storage.write(_kStep, currentStep.value);
    }
  }

  Future<void> skipStep() async {
    // Persist what we have and move forward
    await persist();
    await goNext();
  }

  // Persist entire state
  Future<void> persist() async {
    await storage.write(_kData, toJson());
    await storage.write(_kStep, currentStep.value);
  }

  // Load state
  void _loadFromStorage() {
    try {
      final json = storage.read<Map>(_kData);
      if (json != null) {
        name.value = json['name'] as String?;
        final dobStr = json['dateOfBirth'] as String?;
        dateOfBirth.value = dobStr != null ? DateTime.tryParse(dobStr) : null;

        final diagStr = json['diagnosis'] as String?;
        diagnosis.value = diagStr != null
            ? DiagnosisType.values.firstWhereOrNull((d) => d.name == diagStr)
            : null;

        doctorName.value = json['doctorName'] as String?;
        hospitalName.value = json['hospitalName'] as String?;
        clinicHelpline.value = json['clinicHelpline'] as String?;
        final apptStr = json['nextAppointment'] as String?;
        nextAppointment.value = apptStr != null
            ? DateTime.tryParse(apptStr)
            : null;

        final medsList =
            (json['medications'] as List?)
                ?.cast<Map>()
                .map((m) => MedicationEntry.fromJson(m.cast<String, dynamic>()))
                .toList() ??
            [];
        medications.assignAll(medsList);

        prednisoloneOn.value = (json['predOn'] as bool?) ?? false;
        prednisoloneDoseMg.value = (json['predDoseMg'] as num?)?.toDouble();

        final pains = (json['painRelief'] as List?)?.cast<String>() ?? [];
        painRelief.assignAll(pains);

        notificationsEnabled.value =
            (json['notificationsEnabled'] as bool?) ?? false;
      }
      final step = storage.read<int>(_kStep);
      if (step != null) {
        currentStep.value = step.clamp(0, 2);
      } else {
        // Compute step if not present
        currentStep.value = _computeResumeStep();
      }
    } catch (_) {
      // Ignore malformed storage; start fresh
      currentStep.value = 0;
    }
  }

  int _computeResumeStep() {
    if (!step1Valid) return 0;
    if (!step2CanNext) return 1;
    return 2;
  }

  // Serialize state
  Map<String, dynamic> toJson() => {
    'name': name.value,
    'dateOfBirth': dateOfBirth.value?.toIso8601String(),
    'diagnosis': diagnosis.value?.name,
    'doctorName': doctorName.value,
    'hospitalName': hospitalName.value,
    'clinicHelpline': clinicHelpline.value,
    'nextAppointment': nextAppointment.value?.toIso8601String(),
    'medications': medications.map((m) => m.toJson()).toList(),
    'predOn': prednisoloneOn.value,
    'predDoseMg': prednisoloneDoseMg.value,
    'painRelief': painRelief.toList(),
    'notificationsEnabled': notificationsEnabled.value,
  };
}

////////////////////////////////////////////////////////////////////////////////
// Bindings
////////////////////////////////////////////////////////////////////////////////

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(),
      fenix: true,
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Routes with custom transitions
////////////////////////////////////////////////////////////////////////////////

class SlideFadeTransition extends CustomTransition {
  final Duration duration;
  SlideFadeTransition({this.duration = const Duration(milliseconds: 220)});
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetTween = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));
    final fadeTween = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.easeOut));
    return FadeTransition(
      opacity: animation.drive(fadeTween),
      child: SlideTransition(
        position: animation.drive(offsetTween),
        child: child,
      ),
    );
  }
}

class OnboardingRoutes {
  static const onboarding = '/onboarding';
  static const notifications = '/onboarding/notifications';
  static const home = '/home';

  static List<GetPage> pages = [
    GetPage(
      name: onboarding,
      page: () => const OnboardingShellPage(),
      binding: OnboardingBinding(),
      customTransition: SlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 220),
    ),
    GetPage(
      name: notifications,
      page: () => const NotificationsSetupPage(),
      binding: OnboardingBinding(),
      customTransition: SlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 220),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      customTransition: SlideFadeTransition(),
      transitionDuration: const Duration(milliseconds: 220),
    ),
  ];
}

////////////////////////////////////////////////////////////////////////////////
// Reusable UI Widgets (premium, accessible, animated)
////////////////////////////////////////////////////////////////////////////////

// Section card with rounded corners and soft elevation
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const SectionCard({
    super.key,
    this.title,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      child: Material(
        color: scheme.surface,
        elevation: 2,
        shadowColor: scheme.shadow.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// Stepper header with animated progress and labels
class AppStepper extends StatelessWidget {
  final int current; // 0..2
  const AppStepper({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final labels = [
      AppStrings.step1Title,
      AppStrings.step2Title,
      AppStrings.step3Title,
    ];
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Progress bar
          SizedBox(
            height: 6,
            child: LayoutBuilder(
              builder: (ctx, cns) {
                final width = cns.maxWidth;
                final progress = (current + 1) / 3.0;
                return Stack(
                  children: [
                    Container(
                      width: width,
                      height: 6,
                      decoration: BoxDecoration(
                        color: scheme.surfaceVariant.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: width * progress,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [scheme.primary, scheme.primaryContainer],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              final active = i == current;
              return AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                  color: active ? scheme.primary : scheme.onSurfaceVariant,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(labels[i]),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Quick select Chip with scale+fade animation
class QuickSelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const QuickSelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: selected ? 1.0 : 0.98,
      duration: const Duration(milliseconds: 120),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selected ? scheme.onPrimary : scheme.onSurface,
        ),
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outlineVariant),
        visualDensity: const VisualDensity(vertical: -2, horizontal: -2),
      ),
    );
  }
}

// Medication list tile
class MedicationTile extends StatelessWidget {
  final MedicationEntry med;
  final VoidCallback onRemove;
  const MedicationTile({super.key, required this.med, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.medication, color: scheme.onPrimaryContainer),
        ),
        title: Text(med.name, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(
          [
            if (med.doseMg != null) '${med.doseMg} mg',
            if (med.notes?.isNotEmpty == true) med.notes!,
          ].join(' • '),
        ),
        trailing: IconButton(
          tooltip: AppStrings.remove,
          icon: Icon(Icons.close, color: scheme.error),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Pages
////////////////////////////////////////////////////////////////////////////////

class OnboardingShellPage extends GetView<OnboardingController> {
  const OnboardingShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Row(
          children: [
            Hero(
              tag: 'app_logo',
              child: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.favorite, color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.appName),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              // Stepper
              AppStepper(current: controller.currentStep.value),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _headerFor(controller.currentStep.value),
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              // Animated step content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) {
                    final offsetTween = Tween<Offset>(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).chain(CurveTween(curve: Curves.easeOutCubic));
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: anim.drive(offsetTween),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStep(context, controller.currentStep.value),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Header per step
  String _headerFor(int step) {
    switch (step) {
      case 0:
        return AppStrings.step1Title;
      case 1:
        return AppStrings.step2Title;
      case 2:
        return AppStrings.step3Title;
      default:
        return '';
    }
  }

  // Step pages
  Widget _buildStep(BuildContext context, int step) {
    switch (step) {
      case 0:
        return const _Step1Profile();
      case 1:
        return const _Step2Rheumatologist();
      case 2:
        return const _Step3Medications();
      default:
        return const SizedBox.shrink();
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
// Step 1: Quick Profile Setup
////////////////////////////////////////////////////////////////////////////////

class _Step1Profile extends GetView<OnboardingController> {
  const _Step1Profile();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final focusScope = FocusScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Name
          SectionCard(
            title: 'About you',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppStrings.yourName,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (v) =>
                      controller.name.value = v.trim().isEmpty ? null : v,
                  onSubmitted: (_) => focusScope.nextFocus(),
                ),
                const SizedBox(height: 16),
                // DOB + Diagnosis
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _DateField(
                          label: AppStrings.dob,
                          valueText: controller.dateOfBirth.value != null
                              ? _fmtDate(controller.dateOfBirth.value!)
                              : AppStrings.pickDate,
                          errorText: controller.dateOfBirth.value == null
                              ? null
                              : (controller.isDobValid
                                    ? null
                                    : AppStrings.dobErrorFuture),
                          onTap: () async {
                            final now = DateTime.now();
                            final first = DateTime(now.year - 110, 1, 1);
                            final picked = await showDatePicker(
                              context: context,
                              initialDate:
                                  controller.dateOfBirth.value ??
                                  DateTime(now.year - 40, now.month, now.day),
                              firstDate: first,
                              lastDate: now,
                              helpText: AppStrings.dob,
                            );
                            if (picked != null)
                              controller.dateOfBirth.value = picked;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Tooltip(
                        message: AppStrings.diagnosisHint,
                        child: Obx(
                          () => GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: DiagnosisType.values.map((d) {
                              final isSel = controller.diagnosis.value == d;
                              return InkWell(
                                onTap: () => controller.diagnosis.value = d,
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? d.colorHint.withOpacity(0.4)
                                        : d.colorHint.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel
                                          ? d.colorHint
                                          : Theme.of(
                                              context,
                                            ).colorScheme.outlineVariant,
                                      width: isSel ? 2 : 1,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: d.colorHint.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Center(
                                    child: Text(
                                      d.label,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: isSel
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onPrimary
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        fontWeight: isSel
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(() {
                  if (controller.step1Valid) return const SizedBox.shrink();
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      !controller.isDobValid
                          ? (controller.dateOfBirth.value == null
                                ? AppStrings.dobRequired
                                : AppStrings.dobErrorFuture)
                          : (!controller.isDiagnosisValid
                                ? AppStrings.diagnosisRequired
                                : ''),
                      style: TextStyle(color: scheme.error),
                    ),
                  );
                }),
              ],
            ),
          ),
          // Nav
          _NavBar(
            onBack: null,
            backEnabled: false,
            onNext: controller.step1Valid ? controller.goNext : null,
            nextLabel: AppStrings.next,
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// DOB field (button-like)
class _DateField extends StatelessWidget {
  final String label;
  final String valueText;
  final String? errorText;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.valueText,
    required this.onTap,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.event, color: scheme.primary),
                const SizedBox(width: 8),
                Text(valueText),
              ],
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(errorText!, style: TextStyle(color: scheme.error)),
        ],
      ],
    );
  }
}

// Diagnosis picker with colorful chips/cards
class _DiagnosisPicker extends StatelessWidget {
  final DiagnosisType? selected;
  final ValueChanged<DiagnosisType> onSelect;

  const _DiagnosisPicker({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = DiagnosisType.values;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.diagnosis),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((d) {
            final isSel = selected == d;
            return InkWell(
              onTap: () => onSelect(d),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSel
                      ? d.colorHint.withOpacity(0.4)
                      : d.colorHint.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? d.colorHint : scheme.outlineVariant,
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                            color: d.colorHint.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  d.label,
                  style: TextStyle(
                    color: isSel ? scheme.onPrimary : scheme.onSurfaceVariant,
                    fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Step 2: Your Rheumatologist
////////////////////////////////////////////////////////////////////////////////

class _Step2Rheumatologist extends GetView<OnboardingController> {
  const _Step2Rheumatologist();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final focusScope = FocusScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SectionCard(
            title: 'Care team',
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: AppStrings.doctorName,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (v) =>
                      controller.doctorName.value = v.trim().isEmpty ? null : v,
                  onSubmitted: (_) => focusScope.nextFocus(),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => TextField(
                    decoration: InputDecoration(
                      labelText: AppStrings.hospitalName,
                      border: const OutlineInputBorder(),
                      errorText:
                          controller.step2CanNext ||
                              controller.hospitalName.value == null
                          ? null
                          : AppStrings.hospitalRequired,
                    ),
                    textInputAction: TextInputAction.next,
                    onChanged: (v) => controller.hospitalName.value =
                        v.trim().isEmpty ? null : v,
                    onSubmitted: (_) => focusScope.nextFocus(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: AppStrings.clinicHelpline,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  onChanged: (v) => controller.clinicHelpline.value =
                      v.trim().isEmpty ? null : v,
                  onSubmitted: (_) => focusScope.nextFocus(),
                ),
                const SizedBox(height: 12),
                Obx(
                  () => _DateField(
                    label: AppStrings.nextAppointment,
                    valueText: controller.nextAppointment.value != null
                        ? _fmtDate(controller.nextAppointment.value!)
                        : AppStrings.nextAppointmentHint,
                    onTap: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: controller.nextAppointment.value ?? now,
                        firstDate: DateTime(now.year, now.month, now.day),
                        lastDate: DateTime(now.year + 5),
                        helpText: AppStrings.nextAppointment,
                      );
                      if (picked != null)
                        controller.nextAppointment.value = picked;
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppStrings.youCanSkip,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
          _NavBar(
            onBack: controller.goBack,
            backEnabled: true,
            onNext: controller.step2CanNext ? controller.goNext : null,
            onSkip: controller.step2CanSkip ? controller.skipStep : null,
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

////////////////////////////////////////////////////////////////////////////////
// Step 3: Current Medications
////////////////////////////////////////////////////////////////////////////////

class _Step3Medications extends GetView<OnboardingController> {
  const _Step3Medications();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            children: [
              SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.medicationsHeader,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              // Medications list
              Obx(() {
                final items = controller.medications;
                if (items.isEmpty) {
                  return _EmptyStateCard(
                    icon: Icons.medication_liquid,
                    title: AppStrings.noMeds,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items
                      .map(
                        (m) => AnimatedOpacity(
                          key: ValueKey(m.name),
                          duration: const Duration(milliseconds: 180),
                          opacity: 1.0,
                          child: MedicationTile(
                            med: m,
                            onRemove: () =>
                                controller.removeMedicationByName(m.name),
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
              const SizedBox(height: 8),
              // Prednisolone toggle + dose
              SectionCard(
                title: AppStrings.prednisolone,
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text(AppStrings.prednisolone),
                        value: controller.prednisoloneOn.value,
                        onChanged: (v) {
                          controller.prednisoloneOn.value = v;
                          if (!v) controller.prednisoloneDoseMg.value = null;
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: controller.prednisoloneOn.value
                            ? Column(
                                key: const ValueKey('pred_on'),
                                children: [
                                  TextField(
                                    decoration: InputDecoration(
                                      labelText: AppStrings.predDoseMg,
                                      helperText: AppStrings.doseHelper,
                                      errorText: controller.predDoseValid
                                          ? null
                                          : AppStrings.predDoseInvalid,
                                      border: const OutlineInputBorder(),
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                    onChanged: (v) {
                                      final parsed = double.tryParse(v);
                                      controller.prednisoloneDoseMg.value =
                                          parsed;
                                    },
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              // Pain relief chips
              SectionCard(
                title: AppStrings.painRelief,
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.painReliefOptions.map((o) {
                          final selected = controller.painRelief.contains(o);
                          return QuickSelectChip(
                            label: o,
                            selected: selected,
                            onTap: () => controller.togglePainRelief(o),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      _OtherPainReliefField(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _NavBar(
                onBack: controller.goBack,
                backEnabled: true,
                onNext: controller.step3Valid ? controller.goNext : null,
                onSkip: controller.skipStep,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
        // FAB to add medications
        Positioned(
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
          right: 16,
          child: SizedBox(
            width: 200, // Set a finite width to avoid infinite constraints
            child: FloatingActionButton.extended(
              heroTag: 'add_med',
              onPressed: () => _openAddMedicationSheet(context),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addMedication),
            ),
          ),
        ),
      ],
    );
  }

  void _openAddMedicationSheet(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddMedicationSheet(
        quick: controller.quickMeds,
        dmards: controller.dmardsList,
        biologics: controller.biologicsList,
        onPick: (name) => _openDoseConfigSheet(context, name),
      ),
    );
  }

  void _openDoseConfigSheet(BuildContext context, String medName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MedicationDoseSheet(medName: medName),
    );
  }
}

// Empty state card
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  const _EmptyStateCard({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28.0),
        child: Column(
          children: [
            Icon(icon, size: 48, color: scheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

// Bottom sheet: Add Medication (search + quick chips + lists)
class _AddMedicationSheet extends StatefulWidget {
  final List<String> quick;
  final List<String> dmards;
  final List<String> biologics;
  final ValueChanged<String> onPick;

  const _AddMedicationSheet({
    required this.quick,
    required this.dmards,
    required this.biologics,
    required this.onPick,
  });

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    List<String> filter(List<String> list) {
      if (query.trim().isEmpty) return list;
      final q = query.toLowerCase();
      return list.where((e) => e.toLowerCase().contains(q)).toList();
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: '${AppStrings.search} medications',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.quickSelect,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filter(widget.quick).map((m) {
                  return ActionChip(
                    label: Text(m),
                    onPressed: () => widget.onPick(m),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _MedGroup(
                title: AppStrings.dmards,
                meds: filter(widget.dmards),
                onPick: widget.onPick,
              ),
              const SizedBox(height: 8),
              _MedGroup(
                title: AppStrings.biologics,
                meds: filter(widget.biologics),
                onPick: widget.onPick,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MedGroup extends StatelessWidget {
  final String title;
  final List<String> meds;
  final ValueChanged<String> onPick;
  const _MedGroup({
    required this.title,
    required this.meds,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      initiallyExpanded: true,
      children: meds
          .map((m) => ListTile(title: Text(m), onTap: () => onPick(m)))
          .toList(),
    );
  }
}

// Dose/Frequency configuration sheet (simple, guideline-informed hints)
enum _Frequency { onceDaily, twiceDaily, tds, weekly, fortnightly, monthly }

extension _FrequencyX on _Frequency {
  String get label {
    switch (this) {
      case _Frequency.onceDaily:
        return 'Once daily';
      case _Frequency.twiceDaily:
        return 'Twice daily';
      case _Frequency.tds:
        return 'TDS (three times daily)';
      case _Frequency.weekly:
        return 'Weekly';
      case _Frequency.fortnightly:
        return 'Every 2 weeks';
      case _Frequency.monthly:
        return 'Monthly';
    }
  }
}

class _MedicationDoseSheet extends StatefulWidget {
  final String medName;
  const _MedicationDoseSheet({required this.medName});

  @override
  State<_MedicationDoseSheet> createState() => _MedicationDoseSheetState();
}

class _MedicationDoseSheetState extends State<_MedicationDoseSheet> {
  _Frequency? freq;
  double? doseMg;
  DateTime? startDate;
  final notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Guideline-inspired defaults
    final n = widget.medName.toLowerCase();
    if (n.contains('methotrexate')) {
      freq = _Frequency.weekly;
      notesCtrl.text = 'Default: once weekly (adjust as advised)';
    } else if (n.contains('sulfasalazine')) {
      freq = _Frequency.twiceDaily;
      notesCtrl.text =
          'Guide: titrate over weeks (e.g., 500 mg daily in week 1, then increase) – adjust per clinician advice';
    } else if (n.contains('hydroxychloroquine')) {
      freq = _Frequency.onceDaily;
      notesCtrl.text =
          'Typical: 200–400 mg daily (max per weight) – adjust as advised';
    } else if (n.contains('adalimumab') ||
        n.contains('etanercept') ||
        n.contains('infliximab') ||
        n.contains('biologic')) {
      freq = _Frequency.fortnightly; // common for some biologics
      notesCtrl.text =
          'Typical biologic schedule – adjust per product guidance';
    }
  }

  @override
  void dispose() {
    notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),
          Text(widget.medName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          // Frequency selector
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.frequency,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _Frequency.values.map((f) {
              final selected = freq == f;
              return ChoiceChip(
                label: Text(f.label),
                selected: selected,
                onSelected: (_) => setState(() => freq = f),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Dose (optional)
          TextField(
            decoration: const InputDecoration(
              labelText: 'Dose (mg, optional)',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (v) => setState(() => doseMg = double.tryParse(v)),
          ),
          const SizedBox(height: 12),
          // Start date
          _DateField(
            label: AppStrings.startDate,
            valueText: startDate != null
                ? _fmtDate(startDate!)
                : AppStrings.pickDate,
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: startDate ?? now,
                firstDate: DateTime(now.year - 1),
                lastDate: DateTime(now.year + 3),
                helpText: AppStrings.startDate,
              );
              if (picked != null) setState(() => startDate = picked);
            },
          ),
          const SizedBox(height: 12),
          // Notes
          TextField(
            controller: notesCtrl,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: AppStrings.notes,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // Save
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final freqText = freq?.label;
                    final combinedNotes = [
                      if (freqText != null) freqText,
                      if (startDate != null) 'Start: ${_fmtDate(startDate!)}',
                      if (notesCtrl.text.trim().isNotEmpty)
                        notesCtrl.text.trim(),
                    ].join(' • ');
                    controller.addOrUpdateMedication(
                      MedicationEntry(
                        name: widget.medName,
                        doseMg: doseMg,
                        notes: combinedNotes.isEmpty ? null : combinedNotes,
                      ),
                    );
                    controller.persist();
                    Navigator.of(context).pop(); // close dose sheet
                    Navigator.of(context).pop(); // close add sheet
                  },
                  child: Text(AppStrings.save),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

// Other pain relief entry (free text that adds as chip)
class _OtherPainReliefField extends StatefulWidget {
  @override
  State<_OtherPainReliefField> createState() => _OtherPainReliefFieldState();
}

class _OtherPainReliefFieldState extends State<_OtherPainReliefField> {
  final ctrl = TextEditingController();

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: AppStrings.painReliefOther,
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _add(controller),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _add(controller),
          child: const Text(AppStrings.add),
        ),
      ],
    );
  }

  void _add(OnboardingController c) {
    final text = ctrl.text.trim();
    if (text.isEmpty) return;
    c.togglePainRelief(text); // add or remove
    ctrl.clear();
    c.persist();
  }
}

////////////////////////////////////////////////////////////////////////////////
// Notifications Setup (Final screen)
////////////////////////////////////////////////////////////////////////////////

class NotificationsSetupPage extends GetView<OnboardingController> {
  const NotificationsSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.notificationsTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SectionCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 36,
                      color: scheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.notificationsHeader,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(AppStrings.notificationsBody1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Obx(
                () => AnimatedOpacity(
                  opacity: controller.notificationsEnabled.value ? 1 : 1,
                  duration: const Duration(milliseconds: 180),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle),
                        label: const Text(AppStrings.enableNotifications),
                        onPressed: () async {
                          controller.notificationsEnabled.value = true;
                          await controller.persist();
                          Get.snackbar(
                            AppStrings.notificationsEnabled,
                            AppStrings.notificationsSaved,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          await Future.delayed(
                            const Duration(milliseconds: 120),
                          );
                          Get.offAllNamed(OnboardingRoutes.home);
                        },
                        // Use finite min width and desired height to avoid infinite constraints.
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          controller.notificationsEnabled.value = false;
                          await controller.persist();
                          Get.offAllNamed(OnboardingRoutes.home);
                        },
                        child: const Text(AppStrings.notNowNotifications),
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

////////////////////////////////////////////////////////////////////////////////
// NavBar (Back/Skip/Next)
////////////////////////////////////////////////////////////////////////////////

class _NavBar extends StatelessWidget {
  final VoidCallback? onBack;
  final bool backEnabled;
  final VoidCallback? onNext;
  final VoidCallback? onSkip;
  final String nextLabel;

  const _NavBar({
    required this.onBack,
    required this.backEnabled,
    required this.onNext,
    this.onSkip,
    this.nextLabel = AppStrings.next,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600), // Set a finite width
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              // Back
              Expanded(
                child: OutlinedButton(
                  onPressed: backEnabled ? onBack : null,
                  child: const Text(AppStrings.back),
                ),
              ),
              const SizedBox(width: 8),
              // Skip (if available)
              if (onSkip != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSkip,
                    child: const Text(AppStrings.skip),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              // Next
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  child: Text(nextLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////
// Home (placeholder)
////////////////////////////////////////////////////////////////////////////////

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.homeTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'app_logo',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.favorite, color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(height: 16),
            const Text(AppStrings.homeHello),
            const SizedBox(height: 8),
            Text(
              'This is a placeholder Home screen.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
