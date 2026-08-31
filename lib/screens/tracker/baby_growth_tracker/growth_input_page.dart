import 'package:flutter/material.dart';
import 'package:navajeev_m/models/user_model.dart';
import 'package:navajeev_m/services/growth/growth_service.dart';
import 'package:navajeev_m/services/auth_service.dart';
import 'package:provider/provider.dart';

class AddGrowthPage extends StatefulWidget {
  const AddGrowthPage({super.key});

  @override
  State<AddGrowthPage> createState() => _AddGrowthPageState();
}

class _AddGrowthPageState extends State<AddGrowthPage> {
  final _formKey = GlobalKey<FormState>();

  DateTime _date = DateTime.now();

  final _weightCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  final _headCtrl = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _lengthCtrl.dispose();
    _headCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final baby = user?.babyDetails;
    final babyId = user?.activeBabyId;

    if (baby == null || babyId == null) {
      return const Scaffold(
        body: Center(child: Text('Baby profile not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Growth Entry'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _datePicker(baby),
                const SizedBox(height: 16),
                _numberField(
                  controller: _weightCtrl,
                  label: 'Weight (kg)',
                  hint: 'Eg: 7.8',
                  required: true,
                ),
                const SizedBox(height: 12),
                _numberField(
                  controller: _lengthCtrl,
                  label: 'Length (cm)',
                  hint: 'Eg: 68',
                  required: true,
                ),
                const SizedBox(height: 12),
                _numberField(
                  controller: _headCtrl,
                  label: 'Head circumference (cm)',
                  hint: 'Optional',
                ),
                const SizedBox(height: 24),
                _saveButton(babyId, baby),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _datePicker(BabyDetails baby) {
    return ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Colors.black12),
      ),
      title: const Text('Date'),
      subtitle: Text(
        '${_date.day}/${_date.month}/${_date.year}',
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () async {
        final firstDate = baby.dateOfBirth;
        final lastDate = DateTime.now();
        var initialDate = _date;

        if (initialDate.isBefore(firstDate)) {
          initialDate = firstDate;
        } else if (initialDate.isAfter(lastDate)) {
          initialDate = lastDate;
        }

        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
        );

        if (picked != null) {
          setState(() {
            _date = picked;
          });
        }
      },
    );
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType:
      const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (v) {
        if (required && (v == null || v.trim().isEmpty)) {
          return 'Required';
        }
        if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _saveButton(String babyId, BabyDetails baby) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: _saving
            ? null
            : () async {
          if (!_formKey.currentState!.validate()) return;

          setState(() => _saving = true);

          try {
            await GrowthService().addGrowthRecord(
              babyId: babyId,
              baby: baby,
              checkInDate: _date,
              weightKg: double.parse(_weightCtrl.text),
              lengthCm: double.parse(_lengthCtrl.text),
              headCircumferenceCm: _headCtrl.text.isNotEmpty
                  ? double.parse(_headCtrl.text)
                  : null,
            );

            if (mounted) Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          } finally {
            if (mounted) setState(() => _saving = false);
          }
        },
        child: _saving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Save Growth'),
      ),
    );
  }
}
