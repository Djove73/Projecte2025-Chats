import 'package:flutter/material.dart';

class InterestsFormView extends StatefulWidget {
  final void Function(List<String> selected) onContinue;
  const InterestsFormView({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<InterestsFormView> createState() => _InterestsFormViewState();
}

class _InterestsFormViewState extends State<InterestsFormView> {
  final List<String> categories = [
    'Tecnología',
    'Deportes',
    'Finanzas',
    'IA',
    'Actualidad',
    'Ciencia',
    'Viajes',
    'Salud',
    'Entretenimiento',
  ];
  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF232946),
        elevation: 0.5,
        title: const Text('¿Qué te gustaría ver?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecciona tus intereses para personalizar la app:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: categories.map((cat) {
                final isSelected = selected.contains(cat);
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        selected.add(cat);
                      } else {
                        selected.remove(cat);
                      }
                    });
                  },
                  selectedColor: Colors.blue,
                  backgroundColor: const Color(0xFF232946),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selected.isNotEmpty
                    ? () => widget.onContinue(selected.toList())
                    : null,
                child: const Text('Continuar', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 