import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/admin/data/admin_repository.dart';

class AdminManageProvidersScreen extends ConsumerStatefulWidget {
  const AdminManageProvidersScreen({super.key});

  @override
  ConsumerState<AdminManageProvidersScreen> createState() => _AdminManageProvidersScreenState();
}

class _AdminManageProvidersScreenState extends ConsumerState<AdminManageProvidersScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _deleteProvider(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.confirmDelete.tr),
        content: Text('${AppStrings.confirmDeleteProvider.tr} "$name" ${AppStrings.irreversibly.tr}? ${AppStrings.deleteProviderWarning.tr}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel.tr)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(AppStrings.deletePermanent.tr, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(adminRepoProvider).deleteProvider(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.providerDeletedSuccess.tr), backgroundColor: Colors.green));
        setState(() {}); // Refresh
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.error.tr}: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    const maroon = AppTheme.primaryMaroon;
    const gold = AppTheme.accentGold;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ref.read(adminRepoProvider).getProviders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: maroon));
        }

        if (snapshot.hasError) {
          return Center(child: Text('${AppStrings.error.tr}: ${snapshot.error}'));
        }

        final providers = snapshot.data ?? [];
        final filteredProviders = providers.where((p) {
          final query = _searchQuery.toLowerCase();
          return (p['brand_name']?.toString().toLowerCase().contains(query) ?? false) ||
                 (p['phone_number']?.toString().contains(query) ?? false);
        }).toList();

        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: AppStrings.searchProviderHint.tr,
                  prefixIcon: const Icon(Icons.search, color: maroon),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
            ),
            
            Expanded(
              child: filteredProviders.isEmpty 
                  ? Center(child: Text(AppStrings.noProvidersAvailable.tr))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredProviders.length,
                      itemBuilder: (context, index) {
                        final p = filteredProviders[index];
                        final brandName = p['brand_name'] ?? AppStrings.unnamed.tr;
                        final phone = p['phone_number'] ?? AppStrings.unknown.tr;
                        final servicesCount = p['total_services'] ?? 0;
                        final date = p['created_at'] != null ? DateFormat('yyyy/MM/dd').format(DateTime.parse(p['created_at'])) : AppStrings.unknown.tr;

                        return InkWell(
                          onTap: () => context.push(
                            '/provider/my-services', 
                            extra: {'id': p['id'], 'name': brandName}
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppTheme.get3DShadows(),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(color: gold.withOpacity(0.1), shape: BoxShape.circle),
                                      child: const Icon(Icons.storefront, color: gold, size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            brandName, 
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: maroon)
                                          ),
                                          Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                          const SizedBox(height: 5),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 4,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.category_outlined, size: 14, color: Colors.grey[400]),
                                                  const SizedBox(width: 4),
                                                  Text('${AppStrings.services.tr}: $servicesCount', style: const TextStyle(fontSize: 11)),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.access_time_outlined, size: 14, color: Colors.grey[400]),
                                                  const SizedBox(width: 4),
                                                  Text('${AppStrings.joinDate.tr}: $date', style: const TextStyle(fontSize: 11)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                                      tooltip: AppStrings.deleteAccount.tr,
                                      onPressed: () => _deleteProvider(p['id'], brandName),
                                    ),
                                  ],
                                ),
                                const Divider(height: 25),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _buildMinimalStat(Icons.pending_actions, '${p['pending_count'] ?? 0}', Colors.orange),
                                      const SizedBox(width: 8),
                                      _buildMinimalStat(Icons.check_circle_outline, '${p['confirmed_count'] ?? 0}', Colors.green),
                                      const SizedBox(width: 8),
                                      _buildMinimalStat(Icons.verified, '${p['completed_count'] ?? 0}', Colors.blue),
                                      const SizedBox(width: 8),
                                      _buildMinimalStat(Icons.cancel_outlined, '${p['cancelled_count'] ?? 0}', Colors.red),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMinimalStat(IconData icon, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            count,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
