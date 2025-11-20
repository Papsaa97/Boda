// lib/features/activity/presentation/screens/activity_add_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';


import '../controllers/activity_controller.dart';

class ActivityAddScreen extends ConsumerStatefulWidget {
  const ActivityAddScreen({super.key});

  @override
  ConsumerState<ActivityAddScreen> createState() => _ActivityAddScreenState();
}

class _ActivityAddScreenState extends ConsumerState<ActivityAddScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  DateTime _date = DateTime.now();
  String _zoneId = 'Z1';
  String? _notes;
  String? _imagePath;

  late final TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _updateDateText();
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  void _updateDateText() {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');
    _dateController.text = formatter.format(_date);
  }

  Future<void> _pickDateTime() async {
    // Zavřeme klávesnici
    FocusScope.of(context).requestFocus(FocusNode());

    final datePicked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (datePicked == null) {
      return;
    }

    final timePicked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );

    if (timePicked == null) {
      return;
    }

    setState(() {
      _date = DateTime(
        datePicked.year,
        datePicked.month,
        datePicked.day,
        timePicked.hour,
        timePicked.minute,
      );
      _updateDateText();
    });
  }

  Future<void> _submitForm() async {
    final formState = _formKey.currentState;
    if (formState == null) return;

    if (!formState.validate()) {
      // Formulář není validní → neukládat.
      return;
    }

    formState.save();

    final controller = ref.read(activityControllerProvider.notifier);

    await controller.addActivity(
      title: _title,
      date: _date,
      zoneId: _zoneId,
      notes: _notes,
      imagePath: _imagePath,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // Seznam zón – zatím natvrdo dle blueprintu (později může být provider). :contentReference[oaicite:1]{index=1}
    final zoneOptions = <String, String>{
      'Z1': 'Z1 - Zeleninová',
      'Z2': 'Z2 - Okrasná',
      'Z3': 'Z3 - Ovocný sad',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nová aktivita'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Název
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Název aktivity',
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Zadej název aktivity';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!.trim();
                  },
                ),
                const SizedBox(height: 16),

                // Datum a čas
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Datum a čas',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _pickDateTime,
                ),
                const SizedBox(height: 16),

                // Zóna (dropdown)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Zóna',
                  ),
                  value: _zoneId,
                  items: zoneOptions.entries
                      .map(
                        (entry) => DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _zoneId = value ?? 'Z1';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Poznámka
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Poznámka (volitelné)',
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    final trimmed = value?.trim();
                    _notes = (trimmed == null || trimmed.isEmpty) ? null : trimmed;
                  },
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                    );

                    if (result != null && result.files.isNotEmpty) {
                      final file = result.files.single;

                      // Na mobilech / desktopech má path smysl. Na webu bývá null – to je ok,
                      // tam stejně fotky zatím cíleně neřešíme.
                    if (file.path != null) {
                      setState(() {
                        _imagePath = file.path;
                      });
                    } else {
                      // fallback – žádná path (typicky web), jen info
                      if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Soubor byl vybrán, ale nemá lokální cestu (typicky Web).'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.photo),
                    label: Text(_imagePath == null ? 'Přidat fotku' : 'Změnit fotku'),
                    ),

                    if (_imagePath != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(_imagePath!),
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Uložit
                    ElevatedButton(
                  onPressed: _submitForm,
                child: const Text('Uložit aktivitu'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
