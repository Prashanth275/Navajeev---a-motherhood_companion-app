import 'package:flutter/material.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/growth/growth_service.dart';



class AddGrowthModal extends StatefulWidget {
  final String babyId;
  final BabyDetails baby;
  const AddGrowthModal({super.key, required this.babyId, required this.baby});

  @override
  State<AddGrowthModal> createState() => _AddGrowthModalState();
}

class _AddGrowthModalState extends State<AddGrowthModal> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _headCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Growth Record", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Date Picker Field
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text("Date: ${_date.day}/${_date.month}/${_date.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: widget.baby.dateOfBirth,
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _field(_weightCtrl, "Weight (kg)", Icons.monitor_weight, isRequired: true)),
                const SizedBox(width: 12),
                Expanded(child: _field(_lengthCtrl, "Height (cm)", Icons.height, isRequired: true)),
              ],
            ),
            const SizedBox(height: 12),
            _field(_headCtrl, "Head Circumference (cm - optional)", Icons.face, isRequired: false),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink[200],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saving ? null : _submit,
                child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text("Save Record", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {bool isRequired = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (isRequired && (v == null || v.trim().isEmpty)) {
          return 'Required';
        }
        if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await GrowthService().addGrowthRecord(
        babyId: widget.babyId,
        baby: widget.baby,
        checkInDate: _date,
        weightKg: double.parse(_weightCtrl.text),
        lengthCm: double.parse(_lengthCtrl.text),
        headCircumferenceCm: _headCtrl.text.isNotEmpty ? double.parse(_headCtrl.text) : null,
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}