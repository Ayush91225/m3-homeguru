import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneSheet extends StatefulWidget {
  final String currentTimezone;
  final Function(String) onTimezoneChanged;

  const TimezoneSheet({
    super.key,
    required this.currentTimezone,
    required this.onTimezoneChanged,
  });

  @override
  State<TimezoneSheet> createState() => _TimezoneSheetState();
}

class _TimezoneSheetState extends State<TimezoneSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _allLocations = [];
  
  // Extended city/region aliases using timezone package's built-in data
  // This searches through all 600+ IANA timezone locations
  final Map<String, List<String>> _locationKeywords = {};

  @override
  void initState() {
    super.initState();
    _allLocations = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _buildLocationKeywords();
  }

  void _buildLocationKeywords() {
    // Build keywords from timezone database itself
    for (final location in _allLocations) {
      final parts = location.split('/');
      final keywords = <String>[];
      
      // Add each part as keyword
      for (final part in parts) {
        keywords.add(part.toLowerCase());
        keywords.add(part.replaceAll('_', ' ').toLowerCase());
      }
      
      _locationKeywords[location] = keywords;
    }
    
    // Add common aliases for major cities
    _locationKeywords['Asia/Kolkata']?.addAll(['india', 'mumbai', 'delhi', 'bangalore', 'chennai', 'hyderabad', 'pune', 'jodhpur', 'jaipur', 'rajasthan', 'maharashtra']);
    _locationKeywords['America/New_York']?.addAll(['nyc', 'usa', 'eastern']);
    _locationKeywords['America/Los_Angeles']?.addAll(['la', 'california', 'pacific']);
    _locationKeywords['Europe/London']?.addAll(['uk', 'britain', 'england']);
  }

  List<String> get _filteredLocations {
    if (_searchQuery.isEmpty) {
      return _allLocations.take(50).toList();
    }
    
    final query = _searchQuery.toLowerCase().trim();
    final results = <String>{};
    
    // Search in location keywords/aliases
    _locationKeywords.forEach((location, keywords) {
      for (final keyword in keywords) {
        if (keyword.contains(query) || query.contains(keyword)) {
          results.add(location);
          break;
        }
      }
    });
    
    // Search in timezone location paths (continent/region/city)
    for (final location in _allLocations) {
      final locationLower = location.toLowerCase();
      final parts = location.split('/');
      
      // Check full path
      if (locationLower.contains(query)) {
        results.add(location);
        continue;
      }
      
      // Check each part (continent, region, city)
      for (final part in parts) {
        final partClean = part.replaceAll('_', ' ').toLowerCase();
        if (partClean.contains(query) || query.contains(partClean)) {
          results.add(location);
          break;
        }
      }
    }
    
    return results.take(50).toList();
  }

  String _formatLocation(String location) {
    final parts = location.split('/');
    if (parts.length > 1) {
      return parts.last.replaceAll('_', ' ');
    }
    return location;
  }

  String _getRegion(String location) {
    final parts = location.split('/');
    if (parts.length > 1) {
      return parts[0];
    }
    return '';
  }

  String _getOffset(String location) {
    try {
      final tz.Location loc = tz.getLocation(location);
      final now = tz.TZDateTime.now(loc);
      final offset = now.timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60).abs();
      final sign = hours >= 0 ? '+' : '';
      if (minutes == 0) {
        return 'UTC$sign$hours';
      }
      return 'UTC$sign$hours:${minutes.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select Timezone',
                    style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search city, state, or country',
                        hintStyle: TextStyle(fontSize: 14, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, size: 18, color: cs.onSurfaceVariant),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filteredLocations.length,
                itemBuilder: (context, index) {
                  final location = _filteredLocations[index];
                  final isSelected = location == widget.currentTimezone;
                  final offset = _getOffset(location);
                  final region = _getRegion(location);

                  return ListTile(
                    onTap: () {
                      widget.onTimezoneChanged(location);
                      Navigator.pop(context);
                    },
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Icon(
                      Icons.location_city_rounded,
                      size: 18,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(
                      _formatLocation(location),
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${region.isNotEmpty ? '$region • ' : ''}$offset',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded, size: 20, color: cs.primary)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: isSelected ? cs.primaryContainer.withValues(alpha: 0.3) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
