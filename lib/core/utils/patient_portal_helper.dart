import '../../models/models.dart';

class PatientPortalExplanation {
  final String title;
  final String description;
  final List<MapEntry<String, String>> glossary;
  final List<String> nextSteps;

  const PatientPortalExplanation({
    required this.title,
    required this.description,
    required this.glossary,
    required this.nextSteps,
  });

  static PatientPortalExplanation generate(
      AuthorizationRequest request, AiDecision? decision) {
    // 1. Identify simplified names for procedures, diagnoses, drugs
    final procName = _simplifyProcedure(request.procedureCode, request.procedureDescription);
    final diagName = _simplifyDiagnosis(request.diagnosisCode, request.diagnosisDescription);
    final treatment = request.drugName ?? procName;

    // 2. Build Status Title and Description
    String title = '';
    String description = '';
    final List<String> nextSteps = [];
    final List<MapEntry<String, String>> glossary = [];

    switch (request.status) {
      case AuthorizationStatus.approved:
        title = 'Approved!';
        description =
            'Great news! Your insurance company has approved the request for **$treatment** to treat your **$diagName**. '
            'We reviewed the medical records submitted by your doctor and confirmed this is the right, standard care for your condition.';
        nextSteps.addAll([
          'Call your doctor\'s office to schedule your treatment or appointment.',
          'Ask your doctor if you need to do any preparation (such as fasting or stopping specific medicines) beforehand.',
        ]);
        break;

      case AuthorizationStatus.rejected:
        title = 'Needs More Information (Not Approved Yet)';
        
        // Check if step therapy or conservative treatment is mentioned
        final isStepTherapy = (request.rejectionReason ?? '').toLowerCase().contains('step') ||
            (request.rejectionReason ?? '').toLowerCase().contains('conservative') ||
            (decision?.finalJustification ?? '').toLowerCase().contains('step') ||
            (decision?.finalJustification ?? '').toLowerCase().contains('conservative');

        if (isStepTherapy) {
          description =
              'Your request for **$treatment** is currently not approved because your plan requires trying simpler treatments first. '
              'For a **$diagName**, standard guidelines state you must first complete a trial of safer or less invasive treatments (like physical therapy or standard medicines) for a few weeks. '
              'We haven\'t received records showing that you\'ve tried these yet.';
        } else {
          description =
              'Your request for **$treatment** is currently not approved because the insurance plan needs more details. '
              'The records submitted by your doctor didn\'t contain enough details to show why this specific treatment is medically necessary right now.';
        }
        nextSteps.addAll([
          'Contact your doctor\'s office and ask if there are alternative treatments or standard medicines you should try first.',
          'If you have already tried other treatments or physical therapy, ask your doctor to send those records to the insurance plan so they can review your request again.',
          'Talk with your doctor about whether they should file an appeal (a request to reconsider the decision).',
        ]);
        break;

      case AuthorizationStatus.pending:
      case AuthorizationStatus.underReview:
        title = 'Still Being Reviewed';
        description =
            'Your doctor\'s request for **$treatment** has been received and is currently being checked by our medical review team. '
            'We are making sure this is covered under your insurance plan and is the safest treatment for your **$diagName**. This check usually takes a few days.';
        nextSteps.addAll([
          'You do not need to take any action right now.',
          'We will notify both you and your doctor as soon as a final decision is made.',
        ]);
        break;

      case AuthorizationStatus.escalated:
        title = 'Under Review by a Medical Specialist';
        description =
            'Your request for **$treatment** has been passed to a senior doctor who specializes in **$diagName**. '
            'Because this is a major treatment or surgery, we want to make sure it is the safest and most effective option for you. '
            'Our specialist is carefully reading your doctor\'s notes to make a decision.';
        nextSteps.addAll([
          'No immediate action is needed from you.',
          'We are working on this review quickly and will contact your doctor directly if we need any more medical records.',
        ]);
        break;

      case AuthorizationStatus.draft:
        title = 'Being Prepared by Your Doctor';
        description =
            'This request is in draft status. Your doctor\'s office is still writing the request and gathering your records, and has not submitted it to the insurance plan yet.';
        nextSteps.addAll([
          'Check with your doctor\'s office if you have questions about when they will submit this request.',
        ]);
        break;

      case AuthorizationStatus.withdrawn:
        title = 'Canceled';
        description =
            'This request for **$treatment** was canceled by your doctor\'s office. No review will be performed.';
        nextSteps.addAll([
          'Call your doctor\'s office if you believe this was canceled by mistake.',
        ]);
        break;
    }

    // 3. Build Glossary (layperson terms)
    // Add procedure code explanation
    glossary.add(MapEntry(
      '${request.procedureCode}: ${request.procedureDescription}',
      _getProcedureExplanation(request.procedureCode),
    ));

    // Add diagnosis code explanation
    glossary.add(MapEntry(
      'ICD-10 ${request.diagnosisCode}: ${request.diagnosisDescription}',
      _getDiagnosisExplanation(request.diagnosisCode),
    ));

    // Add drug explanation if applicable
    if (request.drugName != null) {
      glossary.add(MapEntry(
        request.drugName!,
        _getDrugExplanation(request.drugName!),
      ));
    }

    // Add general terms based on status or reasons
    glossary.add(const MapEntry(
      'Prior Authorization',
      'A safety check where insurance companies review certain medicines or procedures before you get them, ensuring they are safe, effective, and covered.',
    ));

    if (request.status == AuthorizationStatus.rejected) {
      glossary.add(const MapEntry(
        'Medical Necessity',
        'A rule saying a treatment must be appropriate and really needed to treat your health condition, rather than just being a matter of convenience.',
      ));
      glossary.add(const MapEntry(
        'Step Therapy / Conservative Treatment',
        'A policy requiring you to try safer, simpler, or less expensive treatments first (like physical therapy or standard pills) before you can get approved for more complex or expensive ones.',
      ));
    }

    return PatientPortalExplanation(
      title: title,
      description: description,
      glossary: glossary,
      nextSteps: nextSteps,
    );
  }

  // Helper maps for layperson terminology
  static String _simplifyProcedure(String code, String desc) {
    switch (code) {
      case '93015':
        return 'Heart Stress Test';
      case '70553':
        return 'Brain MRI Scan';
      case '96413':
        return 'Chemotherapy Infusion';
      case '22612':
        return 'Lower Back Surgery';
      case '99214':
        return 'Routine Doctor Visit';
      case 'J0202':
        return 'Tysabri Injection';
      default:
        if (desc.toLowerCase().contains('mri')) return 'MRI Scan';
        if (desc.toLowerCase().contains('stress test')) return 'Heart Stress Test';
        if (desc.toLowerCase().contains('fusion') || desc.toLowerCase().contains('surgery')) return 'Back Surgery';
        if (desc.toLowerCase().contains('visit')) return 'Doctor Visit';
        return desc;
    }
  }

  static String _simplifyDiagnosis(String code, String desc) {
    switch (code) {
      case 'I25.10':
        return 'blocked heart arteries';
      case 'C50.912':
        return 'breast cancer';
      case 'G44.209':
      case 'G43.909':
        return 'chronic migraine headaches';
      case 'M54.5':
        return 'severe lower back pain';
      case 'G35':
        return 'Multiple Sclerosis (MS)';
      default:
        if (desc.toLowerCase().contains('headache') || desc.toLowerCase().contains('migraine')) return 'severe headaches';
        if (desc.toLowerCase().contains('heart')) return 'heart condition';
        if (desc.toLowerCase().contains('back')) return 'back pain';
        if (desc.toLowerCase().contains('cancer') || desc.toLowerCase().contains('neoplasm')) return 'cancer';
        return desc.toLowerCase();
    }
  }

  static String _getProcedureExplanation(String code) {
    switch (code) {
      case '93015':
        return 'A check where you walk on a treadmill while hooked up to monitors to see how well your heart handles exercise.';
      case '70553':
        return 'A safe scan that uses magnets to take highly detailed 3D pictures of inside your brain (without using harmful radiation).';
      case '96413':
        return 'An IV drip that delivers powerful medicine directly into your bloodstream to help fight cancer cells.';
      case '22612':
        return 'A surgery that joins two or more bones in your lower back together to stop painful movement.';
      case '99214':
        return 'A standard 15-to-30 minute appointment with your doctor to check on an ongoing condition or adjust your medicine.';
      case 'J0202':
        return 'A prescription medicine given by IV drip once every 4 weeks to help prevent Multiple Sclerosis flare-ups.';
      default:
        return 'A clinical code used by doctor offices to identify the specific medical service or test requested.';
    }
  }

  static String _getDiagnosisExplanation(String code) {
    switch (code) {
      case 'I25.10':
        return 'A condition where the main blood vessels that supply your heart become hardened or narrowed by cholesterol buildup.';
      case 'C50.912':
        return 'A medical condition where cells in the breast tissue multiply out of control, forming a tumor.';
      case 'G44.209':
        return 'A common headache that feels like a tight band wrapped around your head, often triggered by stress or muscle tension.';
      case 'G43.909':
        return 'A severe, throbbing headache condition that can also cause nausea, vomiting, and extreme sensitivity to light or sound.';
      case 'M54.5':
        return 'Pain or discomfort located in the bottom section of your back, which can be caused by muscle strain, discs, or joints.';
      case 'G35':
        return 'A long-term condition where your body\'s immune system accidentally attacks the protective covering of your nerves, making it hard for your brain to send signals to the rest of your body.';
      default:
        return 'A clinical code used internationally to precisely define a disease, injury, or health symptom.';
    }
  }

  static String _getDrugExplanation(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('aimovig') || lower.contains('erenumab')) {
      return 'A preventative injection taken once a month to block the signals in your body that trigger migraine headaches.';
    }
    if (lower.contains('tysabri') || lower.contains('natalizumab')) {
      return 'A strong preventative medicine given by IV drip in a clinic to treat flare-ups of Multiple Sclerosis.';
    }
    return 'A prescription medication recommended by your doctor for your specific treatment plan.';
  }
}
