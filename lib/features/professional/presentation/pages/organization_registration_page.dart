import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/widgets/auth_form_widgets.dart';
import '../../domain/entities/organization_registration.dart';
import '../../domain/entities/verification_status.dart';
import '../providers/professional_providers.dart';
import '../widgets/applicant_documents_panel.dart';
import '../widgets/verification_widgets.dart';

/// Route arguments for [OrganizationRegistrationPage].
typedef OrganizationRouteArgs = ({OrganizationKind kind, OrganizationRegistration? existing});

/// Register a new institution/partner, or view / edit / resubmit an existing one.
class OrganizationRegistrationPage extends ConsumerStatefulWidget {
  const OrganizationRegistrationPage({super.key, required this.kind, this.existing});

  final OrganizationKind kind;
  final OrganizationRegistration? existing;

  @override
  ConsumerState<OrganizationRegistrationPage> createState() => _OrganizationRegistrationPageState();
}

class _OrganizationRegistrationPageState extends ConsumerState<OrganizationRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  late OrganizationRegistration? _saved = widget.existing;
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _license = TextEditingController(text: widget.existing?.licenseNumber);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _email = TextEditingController(text: widget.existing?.email);
  late String? _type = widget.existing?.type;
  bool _saving = false;
  String? _error;

  OrganizationKind get _kind => widget.kind;

  @override
  void dispose() {
    for (final c in [_name, _license, _address, _phone, _email]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final result = await ref
        .read(professionalRepositoryProvider)
        .submitOrganization(
          OrganizationRegistration(
            id: _saved?.id,
            kind: _kind,
            name: _name.text,
            type: _type!,
            licenseNumber: _license.text,
            address: _address.text,
            phone: _phone.text.replaceAll(RegExp(r'[\s-]'), ''),
            email: _email.text,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    result.when(
      success: (saved) {
        final isNew = _saved == null;
        setState(() => _saved = saved);
        ref.invalidate(myOrganizationsProvider(_kind));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNew
                  ? 'Pendaftaran terkirim. Unggah dokumen perizinan agar bisa diverifikasi.'
                  : 'Data ${_kind.label.toLowerCase()} diperbarui.',
            ),
          ),
        );
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final saved = _saved;
    final repository = ref.watch(professionalRepositoryProvider);
    final isInstitution = _kind == OrganizationKind.institution;

    return Scaffold(
      appBar: AppBar(title: Text(saved == null ? 'Daftarkan ${_kind.label}' : saved.name)),
      body: SingleChildScrollView(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (saved != null) ...[
              VerificationStatusCard(status: saved.status, note: saved.reviewNote),
              const SizedBox(height: AppSpacing.md),
            ],
            SectionCard(
              title: 'Data ${_kind.label.toLowerCase()}',
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [LengthLimitingTextInputFormatter(160)],
                      validator: (v) => Validators.requiredText(v, field: 'Nama'),
                      decoration: authInputDecoration(
                        label: isInstitution ? 'Nama instansi *' : 'Nama usaha *',
                        icon: isInstitution ? Icons.local_hospital_outlined : Icons.storefront,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _type,
                      isExpanded: true,
                      items: [
                        for (final entry in _kind.types.entries)
                          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                      ],
                      onChanged: (value) => setState(() => _type = value),
                      validator: (v) =>
                          v == null ? 'Pilih jenis ${_kind.label.toLowerCase()}' : null,
                      decoration: authInputDecoration(
                        label: isInstitution ? 'Jenis instansi *' : 'Kategori usaha *',
                        icon: Icons.category_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _license,
                      keyboardType: isInstitution ? TextInputType.text : TextInputType.number,
                      inputFormatters: isInstitution
                          ? [LengthLimitingTextInputFormatter(64)]
                          : [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                      validator: isInstitution
                          ? (v) =>
                                Validators.registrationNumber(v, field: 'Nomor izin', maxLength: 64)
                          : Validators.nib,
                      decoration: authInputDecoration(
                        label: '${_kind.licenseLabel} *',
                        icon: Icons.verified_user_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _address,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => _kind.requiresAddress
                          ? Validators.requiredText(v, field: 'Alamat')
                          : null,
                      decoration: authInputDecoration(
                        label: _kind.requiresAddress ? 'Alamat *' : 'Alamat',
                        icon: Icons.place_outlined,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      validator: Validators.optionalPhone,
                      decoration: authInputDecoration(label: 'Telepon', icon: Icons.phone_outlined),
                    ),
                    if (isInstitution) ...[
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.optionalEmail,
                        decoration: authInputDecoration(
                          label: 'Email instansi',
                          icon: Icons.mail_outline,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    if (saved?.status == VerificationStatus.approved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Text(
                          'Mengubah nama, jenis, atau ${_kind.licenseLabel} akan memicu verifikasi ulang.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (_error != null) ...[
                      AuthErrorBanner(message: _error!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    AuthSubmitButton(
                      label: switch (saved?.status) {
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
            if (saved?.id != null) ...[
              const SizedBox(height: AppSpacing.md),
              ApplicantDocumentsPanel(
                scope: repository.documentScope(kind: _kind.name, subjectId: saved!.id),
                hint: isInstitution
                    ? 'Unggah izin operasional dan dokumen penanggung jawab.'
                    : 'Unggah NIB (OSS) dan izin usaha terkait (mis. izin apotek).',
                canDelete: saved.status != VerificationStatus.approved,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
