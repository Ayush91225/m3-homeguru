import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  List<({String name, String phone})> _contacts = [];
  List<({String name, String phone})> _displayedContacts = [];
  bool _isLoading = false;
  bool _hasPermission = false;
  bool _isLoadingMore = false;
  final int _pageSize = 20;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.contacts.status;
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _loadContacts();
    }
  }

  Future<void> _requestPermission() async {
    setState(() => _isLoading = true);
    final status = await Permission.contacts.request();
    
    if (status.isGranted) {
      setState(() => _hasPermission = true);
      await _loadContacts();
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable contacts permission in settings'),
            action: SnackBarAction(label: 'Settings', onPressed: openAppSettings),
          ),
        );
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      
      final contactsList = <({String name, String phone})>[];
      
      for (final contact in contacts) {
        if (contact.phones.isNotEmpty) {
          final name = contact.displayName;
          final phone = contact.phones.first.number;
          if (name.isNotEmpty && phone.isNotEmpty) {
            contactsList.add((name: name, phone: phone));
          }
        }
      }
      
      setState(() {
        _contacts = contactsList;
        _currentPage = 0;
        _displayedContacts = _contacts.take(_pageSize).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load contacts: $e')),
        );
      }
    }
  }

  void _loadMoreContacts() {
    if (_isLoadingMore || _displayedContacts.length >= _contacts.length) return;
    
    _isLoadingMore = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentPage++;
          final start = _currentPage * _pageSize;
          final end = (start + _pageSize).clamp(0, _contacts.length);
          _displayedContacts.addAll(_contacts.sublist(start, end));
          _isLoadingMore = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (!_hasPermission) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.contacts_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'Access your contacts',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Allow access to invite friends from your contacts',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isLoading ? null : _requestPermission,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.contacts_rounded),
                label: Text(_isLoading ? 'Requesting...' : 'Allow Access'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contacts.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.people_outline_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
                const SizedBox(height: 16),
                Text(
                  'No contacts found',
                  style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          if (i == _displayedContacts.length) {
            if (_displayedContacts.length < _contacts.length) {
              _loadMoreContacts();
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          
          final contact = _displayedContacts[i];
          return _ContactTile(
            name: contact.name,
            phone: contact.phone,
          );
        },
        childCount: _displayedContacts.length + (_displayedContacts.length < _contacts.length ? 1 : 0),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final String name;
  final String phone;

  const _ContactTile({
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.primaryContainer,
            child: Text(
              name[0],
              style: tt.labelLarge?.copyWith(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  phone,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: () => _showInviteSheet(context, name, phone),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
}

void _showInviteSheet(BuildContext context, String name, String phone) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  const referralCode = 'HOMEGURU123';
  const referralLink = 'https://app.homeguruworld.com/refer/$referralCode';
  final message = 'Hey! Join HomeGuru using my referral code: $referralCode\n$referralLink';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Invite $name',
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 24),
            ),
            title: Text('WhatsApp', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Send invite via WhatsApp', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            onTap: () async {
              Navigator.pop(context);
              final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
              final whatsappUrl = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
              
              if (await canLaunchUrl(whatsappUrl)) {
                await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WhatsApp is not installed')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sms_rounded, color: cs.onPrimaryContainer, size: 24),
            ),
            title: Text('SMS', style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            subtitle: Text('Send invite via text message', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            onTap: () async {
              Navigator.pop(context);
              final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
              final smsUrl = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
              
              if (await canLaunchUrl(smsUrl)) {
                await launchUrl(smsUrl);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cannot open SMS app')),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}
