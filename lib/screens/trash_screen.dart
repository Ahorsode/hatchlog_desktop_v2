import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sync_engine.dart';
import '../services/trash_service.dart';
import '../utils/farm_utils.dart';
import '../utils/settings_profile_contract.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final _service = TrashService();
  String _activeTab = SettingsProfileContract.trashTabs.first.key;
  String _search = '';
  Map<String, List<TrashRecordItem>> _items = const {};
  bool _loading = true;
  String? _error;
  String? _restoringId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final farmId = await FarmUtils.getBoundFarmId() ?? '';
      final items = await _service.loadTrashItems(farmId);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _restore(TrashRecordItem item) async {
    if (!SettingsProfileContract.canRestoreTrashTab(item.tabKey)) return;
    setState(() => _restoringId = item.id);
    try {
      await _service.restoreRecord(tabKey: item.tabKey, recordId: item.id);
      if (mounted) {
        Provider.of<SyncEngine>(context, listen: false).syncNow();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record restored.')),
        );
      }
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _restoringId = null);
    }
  }

  Future<void> _deleteForever(TrashRecordItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete forever?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _restoringId = item.id);
    try {
      await _service.deleteForever(tabKey: item.tabKey, recordId: item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record permanently deleted.')),
        );
      }
      await _load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _restoringId = null);
    }
  }

  List<TrashRecordItem> get _visibleItems {
    final query = _search.trim().toLowerCase();
    final items = _items[_activeTab] ?? const [];
    if (query.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.title.toLowerCase().contains(query) ||
              item.subtitle.toLowerCase().contains(query),
        )
        .toList();
  }

  int _countFor(String key) => (_items[key] ?? const []).length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeTab = SettingsProfileContract.tabByKey(_activeTab)!;
    final visible = _visibleItems;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Recovery Center',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Restore soft-deleted records from your farm cloud data.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search records…',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: SettingsProfileContract.trashTabs.map((tab) {
                      final count = _countFor(tab.key);
                      final selected = tab.key == _activeTab;
                      return FilterChip(
                        label: Text('${tab.label}${count > 0 ? ' ($count)' : ''}'),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeTab = tab.key),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: visible.isEmpty
                        ? Center(
                            child: Text(
                              'No deleted ${activeTab.label.toLowerCase()} found.',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          )
                        : ListView.separated(
                            itemCount: visible.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = visible[index];
                              return ListTile(
                                tileColor: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: cs.outline.withValues(alpha: 0.4)),
                                ),
                                title: Text(
                                  item.title,
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text(item.subtitle),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (activeTab.restoreAllowed)
                                      FilledButton.icon(
                                        onPressed: _restoringId == item.id
                                            ? null
                                            : () => _restore(item),
                                        icon: _restoringId == item.id
                                            ? const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              )
                                            : const Icon(Icons.restore_rounded, size: 16),
                                        label: const Text('Restore'),
                                      ),
                                    if (activeTab.restoreAllowed) const SizedBox(width: 8),
                                    if (activeTab.restoreAllowed)
                                      OutlinedButton(
                                        onPressed: _restoringId == item.id
                                            ? null
                                            : () => _deleteForever(item),
                                        child: const Text('Delete Forever'),
                                      ),
                                    if (!activeTab.restoreAllowed)
                                      const Text(
                                        'Audit only',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
