import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  ConsumerState<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  late final List<Map<String, String>> _docs;

  @override
  void initState() {
    super.initState();
    _docs = List.generate(8, (i) => {
      'name': 'Clinical_Report_${i+1}.pdf',
      'size': '${(i+1)*120}KB',
      'type': i % 3 == 0 ? 'Lab Report' : (i % 3 == 1 ? 'Imaging' : 'Physician Notes'),
      'date': '0${8-i}/${10+i}/2024'
    });
  }

  void _uploadDocument() {
    final nameCtrl = TextEditingController();
    String selectedType = 'Physician Notes';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text('Upload Medical Record'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Document Name',
                  hintText: 'e.g. MRI_Brain_Scan',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Record Type'),
                items: ['Lab Report', 'Imaging', 'Physician Notes', 'Other']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() {
                      selectedType = val;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                String filename = nameCtrl.text.trim();
                if (!filename.toLowerCase().endsWith('.pdf')) {
                  filename += '.pdf';
                }
                setState(() {
                  _docs.insert(0, {
                    'name': filename,
                    'size': '180KB',
                    'type': selectedType,
                    'date': DateFormat('MM/dd/yyyy').format(DateTime.now()),
                  });
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Document "$filename" uploaded successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medical Records',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Patient documents and clinical records',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _uploadDocument,
                icon: const Icon(PhosphorIconsRegular.upload, size: 16),
                label: const Text('Upload'),
              ),
            ],
          ).animate().fadeIn(),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _docs.length,
              itemBuilder: (ctx, i) {
                final d = _docs[i];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(PhosphorIconsRegular.filePdf, size: 22, color: AppColors.error),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            d['name']!,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            d['type']!,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            '${d["size"]} · ${d["date"]}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 50 + i * 40)).fadeIn();
              },
            ),
          ),
        ],
      ),
    );
  }
}
