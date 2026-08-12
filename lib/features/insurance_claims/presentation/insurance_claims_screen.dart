import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/authorizations_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../models/models.dart';

// ─── Active Insurance Model & Provider ───────────────────────────────────────
class ActiveInsurance {
  final String policyNumber;
  final String memberId;
  final String policyHolder;
  final String validity;
  final String coverage;
  final String insurer;

  const ActiveInsurance({
    required this.policyNumber,
    required this.memberId,
    required this.policyHolder,
    required this.validity,
    required this.coverage,
    required this.insurer,
  });

  ActiveInsurance copyWith({
    String? policyNumber,
    String? memberId,
    String? policyHolder,
    String? validity,
    String? coverage,
    String? insurer,
  }) {
    return ActiveInsurance(
      policyNumber: policyNumber ?? this.policyNumber,
      memberId: memberId ?? this.memberId,
      policyHolder: policyHolder ?? this.policyHolder,
      validity: validity ?? this.validity,
      coverage: coverage ?? this.coverage,
      insurer: insurer ?? this.insurer,
    );
  }
}

// Global provider to store and update active insurance details
final activeInsuranceProvider = StateProvider<ActiveInsurance>((ref) {
  return const ActiveInsurance(
    policyNumber: "POL-73625142",
    memberId: "BCBS-890123",
    policyHolder: "Emily Thompson",
    validity: "2027-12-31",
    coverage: "BlueCross HMO Select - 90% In-Network Coverage",
    insurer: "Blue Cross Blue Shield",
  );
});

// ─── Insurance OCR State & Provider ──────────────────────────────────────────
class InsuranceOcrState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? extractedFields;
  final String? detectedInsurer;
  final double? confidenceScore;
  final double? processingTimeMs;
  final bool isOfflineFallback;

  const InsuranceOcrState({
    this.isLoading = false,
    this.error,
    this.extractedFields,
    this.detectedInsurer,
    this.confidenceScore,
    this.processingTimeMs,
    this.isOfflineFallback = false,
  });

  InsuranceOcrState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? extractedFields,
    String? detectedInsurer,
    double? confidenceScore,
    double? processingTimeMs,
    bool? isOfflineFallback,
  }) {
    return InsuranceOcrState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      extractedFields: extractedFields ?? this.extractedFields,
      detectedInsurer: detectedInsurer ?? this.detectedInsurer,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      processingTimeMs: processingTimeMs ?? this.processingTimeMs,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
    );
  }
}

class InsuranceOcrNotifier extends StateNotifier<InsuranceOcrState> {
  InsuranceOcrNotifier() : super(const InsuranceOcrState());

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 5),
  ));

  Future<void> verifyCard(String cardName, List<int> bytes) async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Prepare Multipart file upload
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: cardName),
      });

      // Call the Flask Python Microservice
      final response = await _dio.post(
        'http://127.0.0.1:8000/verify',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer dev-key-12345',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        state = InsuranceOcrState(
          isLoading: false,
          extractedFields: data['extracted_fields'] as Map<String, dynamic>,
          detectedInsurer: data['detected_insurer'] as String?,
          confidenceScore: (data['confidence_score'] as num?)?.toDouble(),
          processingTimeMs: (data['processing_time_ms'] as num?)?.toDouble(),
          isOfflineFallback: false,
        );
      } else {
        throw Exception("Server returned status: ${response.statusCode}");
      }
    } catch (e) {
      // Flask is offline or failed. Trigger local client-side OCR mock fallback gracefully.
      debugPrint("Flask service connection failed: $e. Falling back to client-side mock verification.");
      
      // Simulate network & OCR parsing latency
      await Future.delayed(const Duration(milliseconds: 1200));

      final fnLower = cardName.toLowerCase();
      Map<String, dynamic> mockFields;
      String mockInsurer;

      if (fnLower.contains('blue') || fnLower.contains('bcbs')) {
        mockInsurer = "Blue Cross Blue Shield";
        mockFields = {
          "policy_number": "POL-99182736",
          "member_id": "BCBS-789012",
          "policy_holder": "Emily Thompson",
          "validity": "2027-12-31",
          "coverage": "BlueCross PPO Premium - 90% In-Network, \$500 Deductible"
        };
      } else if (fnLower.contains('aetna')) {
        mockInsurer = "Aetna";
        mockFields = {
          "policy_number": "AET-44388271",
          "member_id": "AETNA-456789",
          "policy_holder": "Emily Thompson",
          "validity": "2026-06-30",
          "coverage": "Aetna Choice POS II - 80% In-Network, \$1000 Deductible"
        };
      } else if (fnLower.contains('uhc') || fnLower.contains('united')) {
        mockInsurer = "UnitedHealthcare";
        mockFields = {
          "policy_number": "UHC-88992211",
          "member_id": "UHC-123456",
          "policy_holder": "Emily Thompson",
          "validity": "2027-01-01",
          "coverage": "UnitedHealthcare Choice Plus - 100% Preventive, \$250 Deductible"
        };
      } else {
        mockInsurer = "Cigna Health Care";
        mockFields = {
          "policy_number": "CIG-99882200",
          "member_id": "CIG-234567",
          "policy_holder": "Emily Thompson",
          "validity": "2027-06-30",
          "coverage": "Cigna OAP - 90% In-Network, \$750 Deductible"
        };
      }

      state = InsuranceOcrState(
        isLoading: false,
        extractedFields: mockFields,
        detectedInsurer: mockInsurer,
        confidenceScore: 0.95,
        processingTimeMs: 142.0,
        isOfflineFallback: true,
      );
    }
  }

  void clear() {
    state = const InsuranceOcrState();
  }
}

final insuranceOcrProvider = StateNotifierProvider<InsuranceOcrNotifier, InsuranceOcrState>((ref) {
  return InsuranceOcrNotifier();
});

// ─── Screen Layout ───────────────────────────────────────────────────────────
class InsuranceClaimsScreen extends ConsumerStatefulWidget {
  const InsuranceClaimsScreen({super.key});

  @override
  ConsumerState<InsuranceClaimsScreen> createState() => _InsuranceClaimsScreenState();
}

class _InsuranceClaimsScreenState extends ConsumerState<InsuranceClaimsScreen> {
  final List<Map<String, dynamic>> _demoCards = [
    {
      "name": "BlueCross_PPO_Card.jpg",
      "insurer": "Blue Cross Blue Shield",
      "bytes": [1, 2, 3, 4], // synthetic file bytes
      "color": const Color(0xFF1E3A8A),
    },
    {
      "name": "Aetna_POS_Card.jpg",
      "insurer": "Aetna Health Care",
      "bytes": [5, 6, 7, 8],
      "color": const Color(0xFF7C2D12),
    },
    {
      "name": "UHC_ChoicePlus_Card.jpg",
      "insurer": "UnitedHealthcare",
      "bytes": [9, 10, 11, 12],
      "color": const Color(0xFF0F766E),
    },
  ];

  Map<String, dynamic>? _selectedDemoCard;

  Future<void> _pickAndVerifyCard() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final name = file.name;
        
        List<int> bytes;
        if (kIsWeb) {
          if (file.bytes != null) {
            bytes = file.bytes!;
          } else {
            throw Exception("Could not read file bytes on web.");
          }
        } else {
          if (file.path != null) {
            final ioFile = io.File(file.path!);
            bytes = await ioFile.readAsBytes();
          } else if (file.bytes != null) {
            bytes = file.bytes!;
          } else {
            throw Exception("Could not read file path or bytes.");
          }
        }

        await ref.read(insuranceOcrProvider.notifier).verifyCard(name, bytes);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error picking file: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeInsurance = ref.watch(activeInsuranceProvider);
    final ocrState = ref.watch(insuranceOcrProvider);
    final auths = ref.watch(authorizationsProvider);
    
    // Filter authorizations to only show claims/authorizations belonging to this patient
    final user = ref.watch(currentUserProvider);
    final claims = auths.where((a) => a.patientName.toLowerCase() == user?.name.toLowerCase()).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen intro animation
          Text(
            'Manage and verify your active insurance plans and view related authorization claims.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.1),

          const SizedBox(height: 24),

          LayoutBuilder(builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 900;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildDigitalCardWallet(activeInsurance)),
                  const SizedBox(width: 24),
                  Expanded(flex: 4, child: _buildOcrVerificationModule(ocrState)),
                ],
              );
            }
            return Column(
              children: [
                _buildDigitalCardWallet(activeInsurance),
                const SizedBox(height: 24),
                _buildOcrVerificationModule(ocrState),
              ],
            );
          }),

          const SizedBox(height: 32),

          // ─── Claims / Authorization History Section ────────────────────────
          _buildClaimsHistoryTable(claims),
        ],
      ),
    );
  }

  // ─── Digital Wallet Card Widget ────────────────────────────────────────────
  Widget _buildDigitalCardWallet(ActiveInsurance active) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.wallet, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Active Insurance Card',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Glassmorphic Digital Insurance Card
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: active.insurer.contains("Blue") 
                    ? [const Color(0xFF1E40AF), const Color(0xFF3B82F6)] 
                    : active.insurer.contains("Aetna") 
                        ? [const Color(0xFF9A3412), const Color(0xFFEA580C)]
                        : active.insurer.contains("United")
                            ? [const Color(0xFF0F766E), const Color(0xFF14B8A6)]
                            : [const Color(0xFF4F46E5), const Color(0xFF6366F1)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.shadowBlue,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      active.insurer.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Icon(Icons.contactless_outlined, color: Colors.white, size: 28),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MEMBER ID / POLICY NUMBER',
                      style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      active.memberId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CARD HOLDER',
                          style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          active.policyHolder,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EXPIRES',
                          style: TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          active.validity,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ).animate().scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),

          const SizedBox(height: 20),
          Divider(color: AppColors.border),
          const SizedBox(height: 10),

          // Detail rows
          _buildDetailRow("Policy Number", active.policyNumber),
          _buildDetailRow("Coverage Details", active.coverage),
          _buildDetailRow("Status", "ACTIVE / VERIFIED", isStatus: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary)),
          Flexible(
            child: isStatus 
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value, 
                    style: const TextStyle(color: AppColors.successDark, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                )
              : Text(
                  value, 
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  // ─── OCR Verification Module Widget ────────────────────────────────────────
  Widget _buildOcrVerificationModule(InsuranceOcrState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.shieldCheck, color: AppColors.accent, size: 22),
              const SizedBox(width: 10),
              Text(
                'AI Insurance Verification (Flask OCR)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Upload Card / Simulation select box
          if (state.extractedFields == null && !state.isLoading) ...[
            InkWell(
              onTap: _pickAndVerifyCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.neutral50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(PhosphorIconsRegular.cloudArrowUp, color: AppColors.neutral400, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Upload Insurance Card Photo',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supports PNG, JPG, JPEG or PDF formats',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Select a Demo Card to Simulate Scan:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Demo cards buttons
            Row(
              children: _demoCards.map((card) {
                final isSelected = _selectedDemoCard == card;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => setState(() => _selectedDemoCard = card),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? card['color'].withOpacity(0.12) : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: isSelected ? card['color'] : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(PhosphorIconsRegular.fileImage, color: isSelected ? card['color'] : AppColors.neutral500, size: 24),
                            const SizedBox(height: 6),
                            Text(
                              card['insurer'].toString().split(' ').first,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? card['color'] : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Scan button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _selectedDemoCard == null
                    ? null
                    : () {
                        ref.read(insuranceOcrProvider.notifier).verifyCard(
                              _selectedDemoCard!['name'],
                              _selectedDemoCard!['bytes'],
                            );
                      },
                icon: const Icon(Icons.document_scanner_rounded, color: Colors.white, size: 18),
                label: const Text('Verify Card with OCR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                ),
              ),
            ),
          ] else if (state.isLoading) ...[
            // Verification Loader
            Container(
              height: 300,
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'OCR Parsing Insurance Card...',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 600.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Connecting to Flask Python Backend...',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            )
          ] else if (state.extractedFields != null) ...[
            // Flask Offline Fallback Warning
            if (state.isOfflineFallback)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.warningDark),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Flask Backend Offline",
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningDark, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Running client-side mock verification. Start Python Flask backend by running:\n'cd insurance_service && python main.py'",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.warningDark, height: 1.3, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().shake(duration: 400.ms),

            // Extracted Results Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Insurer Detected',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      state.detectedInsurer ?? "Unknown Insurer",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Confidence Score', style: Theme.of(context).textTheme.labelSmall),
                    Text(
                      '${((state.confidenceScore ?? 0.95) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.success, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border),
            const SizedBox(height: 10),

            // Results details
            _buildResultRow("Policy Holder Name", state.extractedFields!['policy_holder']?.toString() ?? ""),
            _buildResultRow("Member ID / Policy Number", state.extractedFields!['member_id']?.toString() ?? ""),
            _buildResultRow("Policy Group Number", state.extractedFields!['policy_number']?.toString() ?? ""),
            _buildResultRow("Valid Until", state.extractedFields!['validity']?.toString() ?? ""),
            _buildResultRow("Coverage Benefits", state.extractedFields!['coverage']?.toString() ?? ""),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(insuranceOcrProvider.notifier).clear();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: const Text('Scan Another'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply scan to active card
                      final fields = state.extractedFields!;
                      ref.read(activeInsuranceProvider.notifier).state = ActiveInsurance(
                        policyNumber: fields['policy_number']?.toString() ?? "POL-N/A",
                        memberId: fields['member_id']?.toString() ?? "ID-N/A",
                        policyHolder: fields['policy_holder']?.toString() ?? "Emily Thompson",
                        validity: fields['validity']?.toString() ?? "2027-12-31",
                        coverage: fields['coverage']?.toString() ?? "Verified Medical Plan",
                        insurer: state.detectedInsurer ?? "General Insurer",
                      );
                      
                      // Clear OCR verification state
                      ref.read(insuranceOcrProvider.notifier).clear();

                      // Show SnackBar success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 10),
                              Text("Successfully updated active insurance details!"),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                    ),
                    child: const Text('Apply Verified Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Claims / Prior Authorization History Widget ───────────────────────────
  Widget _buildClaimsHistoryTable(List<AuthorizationRequest> list) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.shadowMd,
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.clipboardText, color: AppColors.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                'Claims & Authorization History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(PhosphorIconsRegular.folderSimple, size: 40, color: AppColors.neutral300),
                    const SizedBox(height: 12),
                    Text('No prior authorization claims found.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => Divider(color: AppColors.border, height: 1),
              itemBuilder: (ctx, i) {
                final claim = list[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: claim.status.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          claim.status.icon,
                          color: claim.status.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              claim.procedureDescription.isNotEmpty 
                                  ? claim.procedureDescription 
                                  : (claim.drugName ?? "Medical Procedure"),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${claim.authNumber}  •  CPT/NDC: ${claim.procedureCode.isNotEmpty ? claim.procedureCode : (claim.drugNdc ?? "N/A")}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: claim.status.bgColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              claim.status.label.toUpperCase(),
                              style: TextStyle(
                                color: claim.status.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Requested: ${claim.requestedAt.year}-${claim.requestedAt.month.toString().padLeft(2, '0')}-${claim.requestedAt.day.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
