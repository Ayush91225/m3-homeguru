import 'package:flutter/material.dart';
import '../../../data/filter_data.dart';
import 'filter_chip.dart' as custom;
import 'filter_dropdown.dart';

class FilterBar extends StatelessWidget {
  final String? selectedCategory;
  final String? selectedBoard;
  final String? selectedGrade;
  final String? selectedSubject;
  final String? selectedBudget;
  final Function(String?) onCategoryChanged;
  final Function(String?) onBoardChanged;
  final Function(String?) onGradeChanged;
  final Function(String?) onSubjectChanged;
  final Function(String?) onBudgetChanged;

  const FilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedBoard,
    required this.selectedGrade,
    required this.selectedSubject,
    required this.selectedBudget,
    required this.onCategoryChanged,
    required this.onBoardChanged,
    required this.onGradeChanged,
    required this.onSubjectChanged,
    required this.onBudgetChanged,
  });

  List<String>? _getAvailableSubjects() {
    if (selectedCategory == 'School Education' && selectedBoard != null && selectedGrade != null) {
      return FilterData.subjectOptions['$selectedBoard-$selectedGrade'];
    } else if (selectedCategory == 'Language Learning' && selectedBoard != null) {
      return FilterData.subjectOptions['Language Learning-$selectedBoard'];
    } else if (selectedCategory != null && selectedCategory != 'School Education' && selectedCategory != 'Language Learning') {
      return FilterData.subjectOptions[selectedCategory];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final availableSubjects = _getAvailableSubjects();
    
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          custom.FilterChip(
            label: selectedCategory ?? 'Category',
            isSelected: selectedCategory != null,
            onTap: () => FilterDropdown.show(
              context,
              title: 'Select Category',
              options: FilterData.categoryOptions,
              selected: selectedCategory,
              onSelect: onCategoryChanged,
            ),
          ),
          
          if (selectedCategory == 'School Education') ...[ 
            const SizedBox(width: 8),
            custom.FilterChip(
              label: selectedBoard ?? 'Board',
              isSelected: selectedBoard != null,
              onTap: () => FilterDropdown.show(
                context,
                title: 'Select Board',
                options: FilterData.boardOptions['School Education']!,
                selected: selectedBoard,
                onSelect: onBoardChanged,
              ),
            ),
          ],

          if (selectedCategory == 'Language Learning') ...[
            const SizedBox(width: 8),
            custom.FilterChip(
              label: selectedBoard ?? 'Type',
              isSelected: selectedBoard != null,
              onTap: () => FilterDropdown.show(
                context,
                title: 'Select Type',
                options: const ['Foreign', 'Regional', 'Others'],
                selected: selectedBoard,
                onSelect: onBoardChanged,
              ),
            ),
          ],
          
          if (selectedBoard != null && FilterData.gradeOptions.containsKey(selectedBoard)) ...[
            const SizedBox(width: 8),
            custom.FilterChip(
              label: selectedGrade ?? 'Grade',
              isSelected: selectedGrade != null,
              onTap: () => FilterDropdown.show(
                context,
                title: 'Select Grade',
                options: FilterData.gradeOptions[selectedBoard]!,
                selected: selectedGrade,
                onSelect: onGradeChanged,
              ),
            ),
          ],
          
          if (availableSubjects != null) ...[
            const SizedBox(width: 8),
            custom.FilterChip(
              label: selectedSubject ?? (selectedCategory == 'Language Learning' ? 'Language' : 'Subject'),
              isSelected: selectedSubject != null,
              onTap: () => FilterDropdown.show(
                context,
                title: selectedCategory == 'Language Learning' ? 'Select Language' : 'Select Subject',
                options: availableSubjects,
                selected: selectedSubject,
                onSelect: onSubjectChanged,
              ),
            ),
          ],
          
          const SizedBox(width: 8),
          custom.FilterChip(
            label: selectedBudget ?? 'Budget',
            isSelected: selectedBudget != null,
            onTap: () => FilterDropdown.show(
              context,
              title: 'Select Budget',
              options: FilterData.budgetOptions,
              selected: selectedBudget,
              onSelect: onBudgetChanged,
            ),
          ),
        ],
      ),
    );
  }
}
