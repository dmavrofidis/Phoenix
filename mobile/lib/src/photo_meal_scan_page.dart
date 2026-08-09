import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'state/fitness_store.dart';

class PhotoMealScanPage extends StatefulWidget {
  const PhotoMealScanPage({super.key, required this.store});
  final FitnessStore store;

  @override
  State<PhotoMealScanPage> createState() => _PhotoMealScanPageState();
}

class _PhotoMealScanPageState extends State<PhotoMealScanPage> {
  final _picker = ImagePicker();
  Uint8List? _image;
  _MealVisual _meal = _MealVisual.bowl;
  double _portion = 1;
  bool _saving = false;

  _Estimate get _estimate => _meal.estimate(_portion);

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      imageQuality: 82,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() => _image = bytes);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final estimate = _estimate;
      final decoded = _image == null ? null : img.decodeImage(_image!);
      final resized = decoded == null
          ? _image
          : img.encodeJpg(
              decoded.width > 720
                  ? img.copyResize(decoded, width: 720)
                  : decoded,
              quality: 72,
            );
      await widget.store.addMeal(
        name: '${_meal.label} (photo estimate)',
        calories: estimate.calories,
        proteinGrams: estimate.protein,
        carbohydrateGrams: estimate.carbs,
        fatGrams: estimate.fat,
        fiberGrams: estimate.fiber,
        photoEncodedBytes: resized == null ? '' : base64Encode(resized),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PHOTO MEAL SCAN')),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Take a photo, choose the closest meal type and confirm the portion. Phoenix calculates a transparent local estimate — it does not claim to identify food automatically.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 4 / 3,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: _image == null
                ? const Center(
                    child: Icon(Icons.photo_camera_outlined, size: 54),
                  )
                : Image.memory(_image!, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('CAMERA'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('GALLERY'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Text(
          'WHAT IS ON THE PLATE?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final meal in _MealVisual.values)
              ChoiceChip(
                label: Text(meal.label.toUpperCase()),
                selected: _meal == meal,
                onSelected: (_) => setState(() => _meal = meal),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'PORTION: ${_portion.toStringAsFixed(1)}×',
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        Slider(
          value: _portion,
          min: .5,
          max: 2,
          divisions: 6,
          label: '${_portion.toStringAsFixed(1)}×',
          onChanged: (value) => setState(() => _portion = value),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _metric('${_estimate.calories}', 'kcal'),
                _metric('${_estimate.protein.toStringAsFixed(0)}g', 'protein'),
                _metric('${_estimate.carbs.toStringAsFixed(0)}g', 'carbs'),
                _metric('${_estimate.fat.toStringAsFixed(0)}g', 'fat'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Estimate only: recipes, oil, sauces and portion size can change the actual nutrition. Adjust with the normal meal editor if you know the label or recipe.',
          style: TextStyle(color: Colors.white60),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _image == null || _saving ? null : _save,
          icon: const Icon(Icons.add_task),
          label: Text(_saving ? 'SAVING…' : 'LOG PHOTO ESTIMATE'),
        ),
      ],
    ),
  );

  Widget _metric(String value, String label) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      Text(label, style: const TextStyle(color: Colors.white60)),
    ],
  );
}

enum _MealVisual {
  bowl('Protein bowl', 620, 42, 65, 20, 10),
  rice('Rice & protein', 680, 48, 82, 16, 7),
  sandwich('Sandwich / wrap', 520, 30, 52, 23, 5),
  pasta('Pasta meal', 740, 30, 102, 22, 7),
  salad('Big salad', 420, 26, 30, 24, 11),
  snack('Snack / dessert', 360, 10, 45, 16, 3);

  const _MealVisual(
    this.label,
    this.kcal,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
  );
  final String label;
  final int kcal;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
  _Estimate estimate(double portion) => _Estimate(
    (kcal * portion).round(),
    protein * portion,
    carbs * portion,
    fat * portion,
    fiber * portion,
  );
}

class _Estimate {
  const _Estimate(
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
  );
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;
}
