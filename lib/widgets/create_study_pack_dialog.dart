import 'package:flutter/material.dart';
import '../models/study_pack.dart';

class CreateStudyPackDialog extends StatefulWidget {
  final StudyPack? studyPackToEdit;
  final List<String> availableSubjects;

  const CreateStudyPackDialog({
    Key? key,
    this.studyPackToEdit,
    required this.availableSubjects,
  }) : super(key: key);

  @override
  State<CreateStudyPackDialog> createState() => _CreateStudyPackDialogState();
}

class _CreateStudyPackDialogState extends State<CreateStudyPackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _subjectController = TextEditingController();
  
  DifficultyLevel _selectedDifficulty = DifficultyLevel.beginner;
  int _cardCount = 10;
  
  bool get _isEditing => widget.studyPackToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final pack = widget.studyPackToEdit!;
      _titleController.text = pack.title;
      _descriptionController.text = pack.description;
      _subjectController.text = pack.subject;
      _selectedDifficulty = pack.difficulty;
      _cardCount = pack.cardCount;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _isEditing ? Icons.edit : Icons.add,
                    size: 28,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isEditing ? 'Edit Study Pack' : 'Create Study Pack',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  hintText: 'Enter study pack title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Subject field with dropdown
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'Enter or select subject',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.arrow_drop_down),
                    tooltip: 'Select from existing subjects',
                    onSelected: (subject) {
                      _subjectController.text = subject;
                    },
                    itemBuilder: (context) => widget.availableSubjects.map((subject) {
                      return PopupMenuItem<String>(
                        value: subject,
                        child: Text(subject),
                      );
                    }).toList(),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe what this study pack covers',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                textInputAction: TextInputAction.newline,
              ),
              
              const SizedBox(height: 16),
              
              // Difficulty selection
              const Text(
                'Difficulty Level *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: DifficultyLevel.values.map((difficulty) {
                  final isSelected = _selectedDifficulty == difficulty;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDifficulty = difficulty;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? difficulty.color.withOpacity(0.1)
                                : Colors.grey[100],
                            border: Border.all(
                              color: isSelected
                                  ? difficulty.color
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: difficulty.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                difficulty.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // Card count slider
              const Text(
                'Initial Card Count',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('5'),
                  Expanded(
                    child: Slider(
                      value: _cardCount.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: _cardCount.toString(),
                      onChanged: (value) {
                        setState(() {
                          _cardCount = value.round();
                        });
                      },
                    ),
                  ),
                  const Text('100'),
                ],
              ),
              Text(
                '$_cardCount cards',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(_isEditing ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final studyPack = StudyPack(
        id: _isEditing ? widget.studyPackToEdit!.id : DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        difficulty: _selectedDifficulty,
        cardCount: _cardCount,
        createdAt: _isEditing ? widget.studyPackToEdit!.createdAt : DateTime.now(),
        lastStudied: _isEditing ? widget.studyPackToEdit!.lastStudied : DateTime.now(),
        progress: _isEditing ? widget.studyPackToEdit!.progress : 0.0,
        isFavorite: _isEditing ? widget.studyPackToEdit!.isFavorite : false,
      );
      
      Navigator.of(context).pop(studyPack);
    }
  }
}
