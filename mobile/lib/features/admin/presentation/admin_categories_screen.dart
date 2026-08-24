import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class AdminCategoriesScreen extends ConsumerStatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  ConsumerState<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends ConsumerState<AdminCategoriesScreen> {
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    final apiClient = ref.read(apiClientProvider);

    try {
      final url = _selectedType == 'all'
          ? '/categories/admin/all'
          : '/categories/admin/all?type=$_selectedType';
      final res = await apiClient.dio.get(url);

      if (mounted) {
        setState(() {
          _categories = res.data['data'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل التصنيفات')),
        );
      }
    }
  }

  Future<void> _deleteCategory(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا التصنيف؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final apiClient = ref.read(apiClientProvider);
      try {
        await apiClient.dio.delete('/categories/admin/$id');
        _fetchCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف التصنيف بنجاح')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف التصنيف')),
          );
        }
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? item]) {
    final isEditing = item != null;
    final nameArController = TextEditingController(text: item?['name_ar'] ?? '');
    final nameEnController = TextEditingController(text: item?['name'] ?? '');
    String type = item?['type'] ?? 'dua';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isEditing ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameArController,
                    decoration: const InputDecoration(labelText: 'اسم التصنيف بالعربية'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameEnController,
                    decoration: const InputDecoration(labelText: 'اسم التصنيف بالإنجليزية (Name)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(labelText: 'نوع المحتوى'),
                    items: const [
                      DropdownMenuItem(value: 'dua', child: Text('الأدعية والأذكار')),
                      DropdownMenuItem(value: 'podcast', child: Text('البودكاست')),
                      DropdownMenuItem(value: 'video', child: Text('الفيديوهات')),
                      DropdownMenuItem(value: 'pdf', child: Text('الكتب (PDF)')),
                    ],
                    onChanged: (val) => setModalState(() => type = val ?? 'dua'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (nameArController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى كتابة اسم التصنيف')),
                        );
                        return;
                      }

                      final payload = {
                        'name_ar': nameArController.text.trim(),
                        'name': nameEnController.text.trim().isEmpty
                            ? nameArController.text.trim()
                            : nameEnController.text.trim(),
                        'type': type,
                      };

                      final apiClient = ref.read(apiClientProvider);
                      try {
                        if (isEditing) {
                          await apiClient.dio.put('/categories/admin/${item['id']}', data: payload);
                        } else {
                          await apiClient.dio.post('/categories/admin', data: payload);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          _fetchCategories();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isEditing ? 'تم تعديل التصنيف بنجاح' : 'تمت إضافة التصنيف بنجاح')),
                          );
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('حدث خطأ أثناء حفظ التصنيف')),
                          );
                        }
                      }
                    },
                    child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة التصنيف'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة التصنيفات'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'إضافة تصنيف جديد',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: _selectedType == 'all',
                    onSelected: (selected) {
                      setState(() => _selectedType = 'all');
                      _fetchCategories();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('الأدعية'),
                    selected: _selectedType == 'dua',
                    onSelected: (selected) {
                      setState(() => _selectedType = 'dua');
                      _fetchCategories();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('البودكاست'),
                    selected: _selectedType == 'podcast',
                    onSelected: (selected) {
                      setState(() => _selectedType = 'podcast');
                      _fetchCategories();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('الفيديوهات'),
                    selected: _selectedType == 'video',
                    onSelected: (selected) {
                      setState(() => _selectedType = 'video');
                      _fetchCategories();
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('الكتب'),
                    selected: _selectedType == 'pdf',
                    onSelected: (selected) {
                      setState(() => _selectedType = 'pdf');
                      _fetchCategories();
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? const Center(child: Text('لا توجد تصنيفات'))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _categories.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          return ListTile(
                            title: Text(cat['name_ar'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('النوع: ${cat['type']} • الاسم: ${cat['name']}', style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => _showAddEditDialog(cat),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                  onPressed: () => _deleteCategory(cat['id']),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
