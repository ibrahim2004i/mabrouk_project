import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mabrouk_app/core/localization/app_strings.dart';
import 'package:get/get.dart';
import 'package:mabrouk_app/core/theme/app_theme.dart';
import 'package:mabrouk_app/features/admin/data/admin_repository.dart';

import 'package:mabrouk_app/features/admin/presentation/admin_complaints_provider.dart';

class AdminComplaintsScreen extends ConsumerWidget {
  const AdminComplaintsScreen({super.key});

  Future<void> _resolveComplaint(BuildContext context, WidgetRef ref, int id) async {
    final notesController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.solveComplaint.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.enterResolutionNotes.tr),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(border: const OutlineInputBorder(), hintText: AppStrings.resolutionHint.tr),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.cancel.tr)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), 
            child: Text(AppStrings.solveComplaint.tr, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(adminComplaintsProvider.notifier).resolve(id, notesController.text);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.complaintMarkedResolved.tr), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppStrings.error.tr}: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const maroon = AppTheme.primaryMaroon;
    final complaintsAsync = ref.watch(adminComplaintsProvider);

    return complaintsAsync.when(
      data: (complaints) {
        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.grey, size: 60),
                const SizedBox(height: 15),
                Text(AppStrings.noComplaintsWorkWell.tr, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(adminComplaintsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final c = complaints[index];
              final status = c['status'] ?? 'pending';
              final isResolved = status == 'resolved';
              final date = DateFormat('yyyy/MM/dd HH:mm').format(DateTime.parse(c['created_at']));

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: AppTheme.get3DShadows(),
                  border: Border.all(color: isResolved ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isResolved ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isResolved ? AppStrings.resolved.tr : AppStrings.pendingReview.tr, 
                            style: TextStyle(
                              color: isResolved ? Colors.green : Colors.red, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 12
                            ),
                          ),
                          Text(date, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c['subject'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(c['description'], style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                          const Divider(height: 24),
                          
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('${AppStrings.complainant.tr}: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(c['complainant_phone'], style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text('${AppStrings.providerInvolved.tr}: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(c['provider_name'], style: const TextStyle(fontSize: 11, color: maroon)),
                              Text(' (${c['provider_phone']})', style: const TextStyle(fontSize: 11)),
                            ],
                          ),

                          if (c['admin_notes'] != null && c['admin_notes'].toString().isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${AppStrings.adminNotes.tr}:', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  Text(c['admin_notes'], style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (!isResolved)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        child: ElevatedButton.icon(
                          onPressed: () => _resolveComplaint(context, ref, c['id']),
                          icon: const Icon(Icons.check, size: 18, color: Colors.white),
                          label: Text(AppStrings.markAsResolved.tr, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: maroon)),
      error: (err, stack) => Center(child: Text('${AppStrings.error.tr}: $err')),
    );
  }
}
