import 'package:flutter/material.dart';
import '../../../models/feeding/feeding_enum.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/feeding_validators.dart';
import 'package:provider/provider.dart';
import 'package:navajeev_m/providers/feeding/feeding_provider.dart';
import 'package:navajeev_m/models/feeding/feeding_model.dart';

class LogFeedingScreen extends StatefulWidget {
  const LogFeedingScreen({super.key});

  @override
  State<LogFeedingScreen> createState() => _LogFeedingScreenState();
}

class _LogFeedingScreenState extends State<LogFeedingScreen> {
  final _formKey = GlobalKey<FormState>();

  FeedingType _selectedType = FeedingType.breast;
  BottleType? _selectedBottleType;
  BreastSide? _selectedBreastSide;

  final _quantityController = TextEditingController();
  final _durationController = TextEditingController();
  final _foodNameController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _durationController.dispose();
    _foodNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Log Feeding",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(),
                      const SizedBox(height: 24),
                      _buildDynamicFields(),
                      const SizedBox(height: 24),
                      _buildNotesField(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("Save Feeding"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: FeedingType.values.map((type) {
        final isSelected = _selectedType == type;
        final activeColor = _getTypeColor(type);

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
            child: Column(
              children: [
                Icon(
                  _getIcon(type),
                  size: 28,
                  color: isSelected ? activeColor : Colors.grey,
                ),
                const SizedBox(height: 6),
                Text(
                  _getLabel(type),
                  style: TextStyle(
                    fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? activeColor : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 3,
                  width: isSelected ? 40 : 0,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getTypeColor(FeedingType type) {
    switch (type) {
      case FeedingType.breast:
        return AppColors.weight;
      case FeedingType.bottle:
        return AppColors.feed;
      case FeedingType.solid:
        return AppColors.mood;
    }
  }

  IconData _getIcon(FeedingType type) {
    switch (type) {
      case FeedingType.breast:
        return Icons.pregnant_woman;
      case FeedingType.bottle:
        return Icons.local_drink;
      case FeedingType.solid:
        return Icons.restaurant;
    }
  }

  String _getLabel(FeedingType type) {
    switch (type) {
      case FeedingType.breast:
        return "Breast";
      case FeedingType.bottle:
        return "Bottle";
      case FeedingType.solid:
        return "Solid";
    }
  }

  Widget _buildDynamicFields() {
    switch (_selectedType) {
      case FeedingType.breast:
        return Column(
          children: [
            _buildBreastSideSelector(),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "Duration (minutes)"),
              validator: (value) =>
                  FeedingValidators.validateDuration(
                      value, _selectedType),
            ),
          ],
        );

      case FeedingType.bottle:
        return Column(
          children: [
            DropdownButtonFormField<BottleType>(
              value: _selectedBottleType,
              decoration:
              const InputDecoration(labelText: "Bottle Type"),
              items: BottleType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(
                    type == BottleType.formula
                        ? "Formula"
                        : "Expressed Milk",
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBottleType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "Quantity (ml)"),
              validator: (value) =>
                  FeedingValidators.validateQuantity(
                      value, _selectedType),
            ),
          ],
        );

      case FeedingType.solid:
        return Column(
          children: [
            TextFormField(
              controller: _foodNameController,
              decoration:
              const InputDecoration(labelText: "Food Name"),
              validator: (value) =>
                  FeedingValidators.validateFoodName(
                      value, _selectedType),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "Quantity"),
              validator: (value) =>
                  FeedingValidators.validateQuantity(
                      value, _selectedType),
            ),
          ],
        );
    }
  }

  Widget _buildBreastSideSelector() {
    return DropdownButtonFormField<BreastSide>(
      value: _selectedBreastSide,
      decoration: const InputDecoration(
        labelText: "Breast Side",
      ),
      items: BreastSide.values.map((side) {
        return DropdownMenuItem(
          value: side,
          child: Text(
            side == BreastSide.left
                ? "Left"
                : side == BreastSide.right
                ? "Right"
                : "Both",
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBreastSide = value;
        });
      },
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      maxLines: 3,
      decoration:
      const InputDecoration(labelText: "Notes (optional)"),
    );
  }

  void _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final breastError =
    FeedingValidators.validateBreastSide(
        _selectedBreastSide, _selectedType);

    if (breastError != null) {
      _showError(breastError);
      return;
    }

    final bottleError =
    FeedingValidators.validateBottleType(
        _selectedBottleType, _selectedType);

    if (bottleError != null) {
      _showError(bottleError);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final provider =
      context.read<FeedingProvider>();

      final feeding = Feeding(
        id: '',
        type: _selectedType,
        bottleType: _selectedType == FeedingType.bottle
            ? _selectedBottleType
            : null,
        breastSide: _selectedType == FeedingType.breast
            ? _selectedBreastSide
            : null,
        quantity: _selectedType != FeedingType.breast
            ? double.tryParse(_quantityController.text)
            : null,
        duration: _selectedType == FeedingType.breast
            ? int.tryParse(_durationController.text)
            : null,
        foodName: _selectedType == FeedingType.solid
            ? _foodNameController.text.trim()
            : null,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        timestamp: DateTime.now(),
      );

      await provider.addFeeding(feeding);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError("Failed to save feeding");
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}