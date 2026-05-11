import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../widgets/shared/search/search_card.dart';
import '../../../widgets/shared/search/tutor_card.dart';
import '../../../widgets/shared/search/shimmer_card.dart';
import '../../../widgets/shared/search/filter_bar.dart';
import '../../../services/learner_data_model.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  String? _selectedCategory;
  String? _selectedBoard;
  String? _selectedGrade;
  String? _selectedSubject;
  String? _selectedBudget;

  List<Map<String, dynamic>> _allTutors = [];
  List<Map<String, dynamic>> _displayedTutors = [];
  List<Map<String, dynamic>> _filteredTutors = [];
  bool _isLoading = false;
  int _currentPage = 0;
  static const int _itemsPerPage = 15;
  bool _scrollPending = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTutors();
  }

  Future<void> _loadTutors() async {
    final apiTutors = await LearnerDataModel.fetchTutors(limit: 100);
    if (!mounted) return;
    setState(() {
      _allTutors = apiTutors.map((t) => LearnerDataModel.mapTutorForWidget(t)).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allTutors;
    if (_selectedSubject != null && _selectedSubject != 'Others') {
      filtered = filtered.where((t) {
        return (t['subjects'] as List<dynamic>).any((s) => s['name'] == _selectedSubject);
      }).toList();
    }
    if (_selectedBudget != null && _selectedBudget != 'Others') {
      filtered = filtered.where((t) {
        final rates = (t['subjects'] as List<dynamic>).map((s) => s['hourlyRate'] as int);
        final min = rates.reduce((a, b) => a < b ? a : b);
        return switch (_selectedBudget) {
          'Under ₹300/hr'  => min < 300,
          '₹300-500/hr'    => min >= 300 && min <= 500,
          '₹500-800/hr'    => min >= 500 && min <= 800,
          'Above ₹800/hr'  => min > 800,
          _               => true,
        };
      }).toList();
    }
    if (!mounted) return;
    setState(() {
      _filteredTutors = filtered;
      _displayedTutors = filtered.take(_itemsPerPage).toList();
      _currentPage = 1;
      _isLoading = false;
    });
  }

  void _loadMoreTutors() {
    if (_isLoading || !mounted) return;
    final start = _currentPage * _itemsPerPage;
    if (start >= _filteredTutors.length) return;
    setState(() {
      _isLoading = true;
      _displayedTutors.addAll(_filteredTutors.sublist(start, (start + _itemsPerPage).clamp(0, _filteredTutors.length)));
      _currentPage++;
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollPending) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 400) {
      _scrollPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollPending = false;
        _loadMoreTutors();
      });
    }
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) return;
    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: _searchController.text.trim(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: SearchCard(
              controller: _searchController,
              onSearch: _performSearch,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: FilterBar(
            selectedCategory: _selectedCategory,
            selectedBoard: _selectedBoard,
            selectedGrade: _selectedGrade,
            selectedSubject: _selectedSubject,
            selectedBudget: _selectedBudget,
            onCategoryChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _selectedBoard = null;
                _selectedGrade = null;
                _selectedSubject = null;
              });
              _applyFilters();
            },
            onBoardChanged: (value) {
              setState(() {
                _selectedBoard = value;
                _selectedGrade = null;
                _selectedSubject = null;
              });
            },
            onGradeChanged: (value) {
              setState(() {
                _selectedGrade = value;
                _selectedSubject = null;
              });
            },
            onSubjectChanged: (value) {
              setState(() {
                _selectedSubject = value;
              });
              _applyFilters();
            },
            onBudgetChanged: (value) {
              setState(() {
                _selectedBudget = value;
              });
              _applyFilters();
            },
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        _displayedTutors.isEmpty && !_isLoading
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: cs.primary.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        _filteredTutors.isEmpty && _allTutors.isNotEmpty
                            ? 'No tutors found'
                            : 'Loading tutors...',
                        style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            : _displayedTutors.isEmpty && _isLoading
            ? SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => ShimmerCard(
                      isLeft: index.isEven,
                      isTop: index < 2,
                    ),
                    childCount: 6,
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _displayedTutors.length) {
                        return ShimmerCard(
                          isLeft: index.isEven,
                          isTop: index < 2,
                        );
                      }
                      
                      final tutor = _displayedTutors[index];
                      final isLeft = index.isEven;
                      final isTop = index < 2;
                      final totalItems = _displayedTutors.length;
                      final isBottom = index >= totalItems - 2;
                      
                      return RepaintBoundary(
                        child: TutorCard(
                          tutor: tutor,
                          isTopLeft: isTop && isLeft,
                          isTopRight: isTop && !isLeft,
                          isBottomLeft: isBottom && isLeft,
                          isBottomRight: isBottom && !isLeft,
                        ),
                      );
                    },
                    childCount: _displayedTutors.length + (_isLoading ? 1 : 0),
                  ),
                ),
              ),
      ],
    );
  }
}
