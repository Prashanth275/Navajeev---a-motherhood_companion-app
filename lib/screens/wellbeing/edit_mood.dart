import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:navajeev_m/providers/wellbeing/wellbeing_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/mood_config.dart';

class AddEditWellbeingScreen extends StatefulWidget {
  const AddEditWellbeingScreen({super.key});

  @override
  State<AddEditWellbeingScreen> createState() =>
      _AddEditWellbeingScreenState();
}

class _AddEditWellbeingScreenState
    extends State<AddEditWellbeingScreen> {

  DateTime selectedDate = DateTime.now();

  int mood = 3;
  int energy = 3;
  int stress = 3;
  int sleepQuality = 3;

  final TextEditingController notesController =
  TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEntryForDate(selectedDate);
  }

  Future<void> _loadEntryForDate(DateTime date) async {
    setState(() => isLoading = true);

    final provider =
    context.read<WellbeingProvider>();

    final id =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final entry =
    await provider.repo.getEntry(provider.auth.currentUser!.id, id);

    if (entry != null) {
      mood = entry.mood;
      energy = entry.energy;
      stress = entry.stress;
      sleepQuality = entry.sleepQuality;
      notesController.text = entry.notes;
    } else {
      mood = 3;
      energy = 3;
      stress = 3;
      sleepQuality = 3;
      notesController.clear();
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.read<WellbeingProvider>();

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log mood"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // DATE PICKER
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM d, yyyy')
                      .format(selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon:
                  const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked =
                    await showDatePicker(
                      context: context,
                      initialDate:
                      selectedDate,
                      firstDate:
                      DateTime(2020),
                      lastDate:
                      DateTime.now(),
                    );

                    if (picked != null) {
                      setState(() {
                        selectedDate =
                            picked;
                      });
                      await _loadEntryForDate(
                          picked);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // MOOD SELECTOR
            const Text(
              "How are you feeling?",
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _MoodSelector(
              selected: mood,
              onChanged: (value) {
                setState(() {
                  mood = value;
                });
              },
            ),

            const SizedBox(height: 30),

            _buildSlider(
              label: "Energy",
              value: energy,
              icon: Icons.bolt,
              color: Colors.amber,
              onChanged: (v) => setState(() => energy = v),
            ),

            _buildSlider(
              label: "Stress",
              value: stress,
              icon: Icons.psychology,
              color: Colors.red[400]!,
              onChanged: (v) => setState(() => stress = v),
            ),

            _buildSlider(
              label: "Sleep Quality",
              value: sleepQuality,
              icon: Icons.bedtime,
              color: Colors.indigo[300]!,
              onChanged: (v) => setState(() => sleepQuality = v),
            ),

            const SizedBox(height: 32),
            const Text(
              "Add a note (optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What was on your mind?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
            const SizedBox(height: 40),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await provider.saveEntry(
                    date: selectedDate,
                    mood: mood,
                    energy: energy,
                    stress: stress,
                    sleepQuality:
                    sleepQuality,
                    notes: notesController.text
                        .trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text("Save entry"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              "$value/5",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: color,
          inactiveColor: color.withOpacity(0.15),
          onChanged: (v) => onChanged(v.round()),
        ),
      ],
    );
  }
}

class _MoodSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _MoodSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (index) {
        final value = index + 1;
        final isSelected = selected == value;
        final color = MoodConfig.getIconColor(value);

        return Column(
          children: [
            GestureDetector(
              onTap: () => onChanged(value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.transparent,
                  border: isSelected
                      ? Border.all(
                    color: color, width: 2
                  )
                      : Border.all(color: Colors.transparent, width: 2),
                ),
                child: Icon(
                  MoodConfig.getIcon(value),
                  size: 32,
                  color: isSelected ? color : Colors.grey[400],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              MoodConfig.getLabel(value),
              style: TextStyle(fontSize: 11,
                color: isSelected ? color : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,),
            ),
          ],
        );
      }),
    );
  }
}