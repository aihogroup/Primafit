import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/widgets/auth_form_widgets.dart';
import '../../domain/entities/doctor_registration.dart';
import '../../domain/entities/verification_status.dart';
import '../providers/professional_providers.dart';
import '../widgets/applicant_documents_panel.dart';
import '../widgets/verification_widgets.dart';

/// Apply (or resubmit) as a doctor. Approval by a superadmin grants the
/// `doctor` role; until then the registration is private to the applicant.
class DoctorRegistrationPage extends ConsumerWidget {
  const DoctorRegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(myDoctorRegistrationProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran Dokter')),
      body: AsyncValueView(
        value: registration,
        onRetry: () => ref.invalidate(myDoctorRegistrationProvider),
        data: (existing) => _DoctorForm(existing: existing),
      ),
    );
  }
}

class _DoctorForm extends ConsumerStatefulWidget {
  const _DoctorForm({required this.existing});

  final DoctorRegistration? existing;

  @override
  ConsumerState<_DoctorForm> createState() => _DoctorFormState();
}

class _DoctorFormState extends ConsumerState<_DoctorForm> {
  static const _specializations = [
    'Dokter Umum',
    'Penyakit Dalam',
    'Anak',
    'Kandungan & Kebidanan',
    'Jantung & Pembuluh Darah',
    'Kulit & Kelamin',
    'Saraf',
    'Kesehatan Jiwa',
    'Gizi Klinik',
    'Paru',
    'Mata',
    'THT',
    'Gigi',
  ];

  final _formKey = GlobalKey<FormState>();
  late final _str = TextEditingController(text: widget.existing?.strNumber);
  late final _sip = TextEditingController(text: widget.existing?.sipNumber);
  late final _specialization = TextEditingController(text: widget.existing?.specialization);
  late final _fee = TextEditingController(
    text: widget.existing == null ? '' : widget.existing!.consultationFee.toStringAsFixed(0),
  );
  late final _bio = TextEditingController(text: widget.existing?.bio);
  final _specializationFocus = FocusNode();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_str, _sip, _specialization, _fee, _bio]) {
      c.dispose();
    }
    _specializationFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final result = await ref
        .read(professionalRepositoryProvider)
        .submitDoctor(
          DoctorRegistration(
            strNumber: _str.text,
            sipNumber: _sip.text,
            specialization: _specialization.text,
            consultationFee: int.tryParse(_fee.text.replaceAll('.', '')) ?? 0,
            bio: _bio.text,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (saved) {
        ref.invalidate(myDoctorRegistrationProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved.status == VerificationStatus.pending
                  ? 'Pendaftaran terkirim. Unggah dokumen STR/SIP untuk mempercepat verifikasi.'
                  : 'Data dokter diperbarui.',
            ),
          ),
        );
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final repository = ref.watch(professionalRepositoryProvider);

    return SingleChildScrollView(
      padding: AppSpacing.page,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (existing != null) ...[
            VerificationStatusCard(status: existing.status, note: existing.reviewNote),
            const SizedBox(height: AppSpacing.md),
          ] else ...[
            Text(
              'Daftarkan diri Anda sebagai dokter untuk membuka layanan konsultasi online. '
              'Tim Primafit akan memverifikasi STR dan SIP Anda.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          SectionCard(
            title: 'Data praktik',
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _str,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => Validators.registrationNumber(v, field: 'Nomor STR'),
                    decoration: authInputDecoration(
                      label: 'Nomor STR *',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _sip,
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) => Validators.registrationNumber(
                      v,
                      field: 'Nomor SIP',
                      required: false,
                      maxLength: 64,
                    ),
                    decoration: authInputDecoration(
                      label: 'Nomor SIP',
                      icon: Icons.assignment_ind_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Autocomplete<String>(
                    textEditingController: _specialization,
                    focusNode: _specializationFocus,
                    optionsBuilder: (value) => _specializations.where(
                      (s) => s.toLowerCase().contains(value.text.toLowerCase()),
                    ),
                    fieldViewBuilder: (context, controller, focusNode, _) => TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [LengthLimitingTextInputFormatter(80)],
                      validator: (v) => Validators.requiredText(v, field: 'Spesialisasi'),
                      decoration: authInputDecoration(
                        label: 'Spesialisasi *',
                        icon: Icons.medical_services_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _fee,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.rupiah,
                    decoration: authInputDecoration(
                      label: 'Tarif konsultasi (Rp)',
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _bio,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: authInputDecoration(
                      label: 'Profil singkat',
                      icon: Icons.notes_outlined,
                    ),
                  ),
                  if (existing?.status == VerificationStatus.approved)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Text(
                        'Mengubah STR, SIP, atau spesialisasi akan menonaktifkan peran dokter '
                        'sampai diverifikasi ulang.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  if (_error != null) ...[
                    AuthErrorBanner(message: _error!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AuthSubmitButton(
                    label: switch (existing?.status) {
                      null => 'Kirim pendaftaran',
                      VerificationStatus.rejected => 'Kirim ulang',
                      _ => 'Simpan perubahan',
                    },
                    isLoading: _saving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
          if (existing != null) ...[
            const SizedBox(height: AppSpacing.md),
            ApplicantDocumentsPanel(
              scope: repository.documentScope(kind: 'doctor'),
              hint: 'Unggah scan STR, SIP, dan KTP.',
              canDelete: existing.status != VerificationStatus.approved,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
