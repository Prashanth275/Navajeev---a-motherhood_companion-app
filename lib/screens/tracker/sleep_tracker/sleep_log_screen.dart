import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import 'package:navajeev_m/providers/Sleep/sleep_providers.dart';

class SleepLogScreen extends StatefulWidget {
  const SleepLogScreen({super.key});

  @override
  State<SleepLogScreen> createState() => _SleepLogScreenState();
}

class _SleepLogScreenState extends State<SleepLogScreen> {
  bool _isNight = true;

  DateTime? _startTime;
  DateTime? _endTime;

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              _buildTimePicker(
                label: "Start Time",
                value: _startTime,
                onTap: () => _pickDateTime(isStart: true),
              ),
              const SizedBox(height: 16),
              _buildTimePicker(
                label: "End Time",
                value: _endTime,
                onTap: () => _pickDateTime(isStart: false),
              ),
              const SizedBox(height: 16),
              _buildQuickButtons(),
              const Spacer(),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 8),
        Text(
          "Log Sleep",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ],
    );
  }
  Widget _buildTypeSelector() {
    return Row(
      children: [
        _buildTypeButton("Night", true),
        const SizedBox(width: 12),
        _buildTypeButton("Nap", false),
      ],
    );
  }

  Widget _buildTypeButton(String title, bool value) {
    final selected = _isNight == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isNight = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppColors.sleep : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildTimePicker({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              value == null
                  ? "Select date & time"
                  : value.toString(),
            ),
          ),
        ),
      ],
    );
  }
  Future<void> _pickDateTime({required bool isStart}) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
    });
  }
  Widget _buildQuickButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _startTime = DateTime.now();
              });
            },
            child: const Text("Start Now"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _endTime = DateTime.now();
              });
            },
            child: const Text("End Now"),
          ),
        ),
      ],
    );
  }
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sleep,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Save"),
      ),
    );
  }
  Future<void> _save() async {
    if (_startTime == null || _endTime == null) {
      _showError("Please select start and end time");
      return;
    }

    if (_endTime!.isBefore(_startTime!)) {
      _showError("End time must be after start time");
      return;
    }
    if (_isNight) {
      final hour = _startTime!.hour;

      if (hour >= 6 && hour < 18) {
        final confirm = await _showNightWarningDialog();
        if (!confirm) return;
      }

    }


    setState(() => _isSaving = true);

    await context.read<SleepProvider>().addSession(
      start: _startTime!,
      end: _endTime!,
      isNight: _isNight,
    );

    if (!mounted) return;

    Navigator.pop(context);
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  Future<bool> _showNightWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Night Sleep"),
        content: const Text(
          "This time looks like daytime. Are you sure this is Night sleep?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}