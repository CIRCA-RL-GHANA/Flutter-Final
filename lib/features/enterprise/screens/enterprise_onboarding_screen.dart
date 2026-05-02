/// Enterprise › Onboarding Screen
/// Allows an account owner to register their business on the Genie Enterprise
/// platform (pathways 1–5), upload KYB documents, and view profile status.

import 'package:flutter/material.dart';
import '../../../../core/services/enterprise_service.dart';

const _kGold = Color(0xFFD4A017);
const _kCyan = Color(0xFF00BCD4);

final _enterpriseTypes = [
  'corporation',
  'streaming_platform',
  'record_label',
  'delivery_network',
  'food_aggregator',
  'marketplace',
  'qsr_chain',
  'financial_institution',
  'other',
];

final _pathwayLabels = {
  1: 'Payment Gateway',
  2: 'Full Commerce API',
  3: 'Genie Storefront',
  4: 'Agentic AI Concierge',
  5: 'Facilitator-Grade Direct',
};

class EnterpriseOnboardingScreen extends StatefulWidget {
  const EnterpriseOnboardingScreen({super.key});
  @override
  State<EnterpriseOnboardingScreen> createState() =>
      _EnterpriseOnboardingScreenState();
}

class _EnterpriseOnboardingScreenState
    extends State<EnterpriseOnboardingScreen> {
  final _svc = EnterpriseService();
  final _formKey = GlobalKey<FormState>();

  final _legalNameCtrl = TextEditingController();
  final _taxIdCtrl = TextEditingController();
  final _webhookCtrl = TextEditingController();
  String _selectedType = 'corporation';
  final Set<int> _selectedPathways = {};
  bool _loading = false;
  String? _resultMessage;

  @override
  void dispose() {
    _legalNameCtrl.dispose();
    _taxIdCtrl.dispose();
    _webhookCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    final res = await _svc.registerEnterprise(
      legalName: _legalNameCtrl.text.trim(),
      enterpriseType: _selectedType,
      taxId: _taxIdCtrl.text.trim().isEmpty ? null : _taxIdCtrl.text.trim(),
      webhookUrl:
          _webhookCtrl.text.trim().isEmpty ? null : _webhookCtrl.text.trim(),
      enabledPathways: _selectedPathways.toList(),
    );

    if (mounted) {
      setState(() {
        _loading = false;
        _resultMessage = res.success
            ? 'Enterprise registered successfully! Awaiting KYB review.'
            : res.message ?? 'Registration failed.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        foregroundColor: Colors.white,
        title: const Text('Enterprise Onboarding',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Business Details'),
              const SizedBox(height: 12),
              _field(
                controller: _legalNameCtrl,
                label: 'Legal Company Name',
                hint: 'Acme Corporation Ltd.',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              _field(
                controller: _taxIdCtrl,
                label: 'Tax / VAT ID (optional)',
                hint: 'GB123456789',
              ),
              const SizedBox(height: 16),
              _sectionLabel('Business Type'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                dropdownColor: const Color(0xFF1A1A2E),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Enterprise Type'),
                items: _enterpriseTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 16),
              _sectionLabel('Access Pathways'),
              const SizedBox(height: 8),
              ..._pathwayLabels.entries.map((e) => CheckboxListTile(
                    activeColor: _kGold,
                    checkColor: Colors.black,
                    title: Text(
                      '${e.key}. ${e.value}',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    value: _selectedPathways.contains(e.key),
                    onChanged: (v) => setState(() {
                      if (v == true) {
                        _selectedPathways.add(e.key);
                      } else {
                        _selectedPathways.remove(e.key);
                      }
                    }),
                    contentPadding: EdgeInsets.zero,
                  )),
              const SizedBox(height: 16),
              _sectionLabel('Webhook URL (optional)'),
              const SizedBox(height: 8),
              _field(
                controller: _webhookCtrl,
                label: 'Webhook URL',
                hint: 'https://yourapp.com/webhooks/genie',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),
              if (_resultMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _resultMessage!.contains('success')
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _resultMessage!.contains('success')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Text(
                    _resultMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kGold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.black),
                        )
                      : const Text('Submit for KYB Review',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            color: _kCyan, fontWeight: FontWeight.bold, fontSize: 14),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        keyboardType: keyboardType,
        validator: validator,
        decoration: _inputDecoration(label).copyWith(hintText: hint),
      );

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D2D44)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2D2D44)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _kGold),
        ),
      );
}
