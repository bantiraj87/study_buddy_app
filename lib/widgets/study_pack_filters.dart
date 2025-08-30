import 'package:flutter/material.dart';
import '../models/study_pack.dart';

enum SortOption {
  nameAZ('Name A-Z'),
  nameZA('Name Z-A'),
  newest('Newest First'),
  oldest('Oldest First'),
  progress('Progress'),
  cardCount('Card Count');

  const SortOption(this.displayName);
  final String displayName;
}

class StudyPackFilters extends StatelessWidget {
  final String searchQuery;
  final Set<String> selectedSubjects;
  final Set<DifficultyLevel> selectedDifficulties;
  final SortOption selectedSortOption;
  final bool showFavoritesOnly;
  final List<String> availableSubjects;
  
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Set<String>> onSubjectsChanged;
  final ValueChanged<Set<DifficultyLevel>> onDifficultiesChanged;
  final ValueChanged<SortOption> onSortChanged;
  final ValueChanged<bool> onFavoritesToggle;
  final VoidCallback onClearFilters;

  const StudyPackFilters({
    Key? key,
    required this.searchQuery,
    required this.selectedSubjects,
    required this.selectedDifficulties,
    required this.selectedSortOption,
    required this.showFavoritesOnly,
    required this.availableSubjects,
    required this.onSearchChanged,
    required this.onSubjectsChanged,
    required this.onDifficultiesChanged,
    required this.onSortChanged,
    required this.onFavoritesToggle,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search study packs...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Sort button
              PopupMenuButton<SortOption>(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort by',
                onSelected: onSortChanged,
                itemBuilder: (context) => SortOption.values.map((option) {
                  return PopupMenuItem<SortOption>(
                    value: option,
                    child: Row(
                      children: [
                        if (selectedSortOption == option)
                          const Icon(Icons.check, size: 16)
                        else
                          const SizedBox(width: 16),
                        const SizedBox(width: 8),
                        Text(option.displayName),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Favorites filter
              FilterChip(
                label: const Text('Favorites'),
                selected: showFavoritesOnly,
                onSelected: onFavoritesToggle,
                avatar: Icon(
                  showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                ),
              ),
              
              // Subject filters
              ...availableSubjects.map((subject) {
                final isSelected = selectedSubjects.contains(subject);
                return FilterChip(
                  label: Text(subject),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newSubjects = Set<String>.from(selectedSubjects);
                    if (selected) {
                      newSubjects.add(subject);
                    } else {
                      newSubjects.remove(subject);
                    }
                    onSubjectsChanged(newSubjects);
                  },
                );
              }),
              
              // Difficulty filters
              ...DifficultyLevel.values.map((difficulty) {
                final isSelected = selectedDifficulties.contains(difficulty);
                return FilterChip(
                  label: Text(difficulty.displayName),
                  selected: isSelected,
                  selectedColor: difficulty.color.withOpacity(0.2),
                  onSelected: (selected) {
                    final newDifficulties = Set<DifficultyLevel>.from(selectedDifficulties);
                    if (selected) {
                      newDifficulties.add(difficulty);
                    } else {
                      newDifficulties.remove(difficulty);
                    }
                    onDifficultiesChanged(newDifficulties);
                  },
                  avatar: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: difficulty.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              
              // Clear filters button
              if (_hasActiveFilters)
                ActionChip(
                  label: const Text('Clear All'),
                  onPressed: onClearFilters,
                  avatar: const Icon(Icons.clear, size: 16),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters {
    return searchQuery.isNotEmpty ||
           selectedSubjects.isNotEmpty ||
           selectedDifficulties.isNotEmpty ||
           showFavoritesOnly ||
           selectedSortOption != SortOption.nameAZ;
  }
}
