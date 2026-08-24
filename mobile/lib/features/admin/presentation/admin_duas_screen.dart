import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class AdminDuasScreen extends ConsumerStatefulWidget {
  const AdminDuasScreen({super.key});

  @override
  ConsumerState<AdminDuasScreen> createState() => _AdminDuasScreenState();
}

class _AdminDuasScreenState extends ConsumerState<AdminDuasScreen> {
  List<dynamic> _duas = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final apiClient = ref.read(apiClientProvider);

    try {
      final resDuas = await apiClient.dio.get('/duas/admin/all');
      final resCats = await apiClient.dio.get('/categories/admin/all?type=dua');

      if (mounted) {
        setState(() {
          _duas = resDuas.data['data'] as List<dynamic>? ?? [];
          _categories = resCats.data['data'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل بيانات الأدعية من الخادم')),
        );
      }
    }
  }

  Future<void> _togglePublish(String id) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.dio.patch('/duas/admin/$id/publish');
      _fetchData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تغيير حالة النشر')),
        );
      }
    }
  }

  Future<void> _deleteDua(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الدعاء نهائياً؟'),
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
        await apiClient.dio.delete('/duas/admin/$id');
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الدعاء بنجاح')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف الدعاء')),
          );
        }
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? item]) {
    final isEditing = item != null;
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final arabicController = TextEditingController(text: item?['arabic_text'] ?? '');
    final translationController = TextEditingController(text: item?['translation'] ?? '');
    final sourceController = TextEditingController(text: item?['source'] ?? '');
    String? selectedCatId = item?['category_id'];
    bool isPublished = item?['is_published'] ?? true;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isEditing ? 'تعديل الدعاء' : 'إضافة دعاء جديد',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان الدعاء'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: arabicController,
                      maxLines: 4,
                      decoration: const InputDecoration(labelText: 'النص العربي للدعاء'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: translationController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'الترجمة / الشرح (اختياري)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sourceController,
                      decoration: const InputDecoration(labelText: 'المصدر (مثل: صحيح البخاري / القرآن الكريم)'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCatId,
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                      items: _categories.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['id'] as String,
                          child: Text(c['name_ar'] as String),
                        );
                      }).toList(),
                      onChanged: (val) => setModalState(() => selectedCatId = val),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('نشر فوري في التطبيق'),
                      value: isPublished,
                      onChanged: (val) => setModalState(() => isPublished = val),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty || arabicController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى ملء العنوان والنص العربي')),
                          );
                          return;
                        }

                        final payload = {
                          'title': titleController.text.trim(),
                          'arabic_text': arabicController.text.trim(),
                          'translation': translationController.text.trim().isEmpty ? null : translationController.text.trim(),
                          'source': sourceController.text.trim().isEmpty ? null : sourceController.text.trim(),
                          'category_id': selectedCatId,
                          'is_published': isPublished,
                        };

                        final apiClient = ref.read(apiClientProvider);
                        try {
                          if (isEditing) {
                            await apiClient.dio.put('/duas/admin/${item['id']}', data: payload);
                          } else {
                            await apiClient.dio.post('/duas/admin', data: payload);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            _fetchData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? 'تم تعديل الدعاء بنجاح' : 'تمت إضافة الدعاء بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('حدث خطأ أثناء حفظ الدعاء')),
                            );
                          }
                        }
                      },
                      child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الدعاء'),
                    ),
                  ],
                ),
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
        title: const Text('إدارة الأدعية'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'إضافة دعاء جديد',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _duas.isEmpty
              ? const Center(child: Text('لا توجد أدعية مضافة بعد'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _duas.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final dua = _duas[index];
                    final isPublished = dua['is_published'] == true;

                    return ListTile(
                      title: Text(dua['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        dua['arabic_text'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Amiri', fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPublished ? Icons.visibility : Icons.visibility_off,
                              color: isPublished ? AppColors.success : Colors.grey,
                            ),
                            tooltip: isPublished ? 'منشور (اضغط لإلغاء النشر)' : 'مسودة (اضغط للنشر)',
                            onPressed: () => _togglePublish(dua['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showAddEditDialog(dua),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deleteDua(dua['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
