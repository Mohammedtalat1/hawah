import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class AdminPdfsScreen extends ConsumerStatefulWidget {
  const AdminPdfsScreen({super.key});

  @override
  ConsumerState<AdminPdfsScreen> createState() => _AdminPdfsScreenState();
}

class _AdminPdfsScreenState extends ConsumerState<AdminPdfsScreen> {
  List<dynamic> _pdfs = [];
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
      final resPdfs = await apiClient.dio.get('/pdfs/admin/all');
      final resCats = await apiClient.dio.get('/categories/admin/all?type=pdf');

      if (mounted) {
        setState(() {
          _pdfs = resPdfs.data['data'] as List<dynamic>? ?? [];
          _categories = resCats.data['data'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل بيانات الكتب من الخادم')),
        );
      }
    }
  }

  Future<void> _togglePublish(String id) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.dio.patch('/pdfs/admin/$id/publish');
      _fetchData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تغيير حالة النشر')),
        );
      }
    }
  }

  Future<void> _deletePdf(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الكتاب نهائياً؟'),
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
        await apiClient.dio.delete('/pdfs/admin/$id');
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الكتاب بنجاح')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف الكتاب')),
          );
        }
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? item]) {
    final isEditing = item != null;
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final authorController = TextEditingController(text: item?['author'] ?? '');
    final urlController = TextEditingController(text: item?['pdf_url'] ?? '');
    final coverController = TextEditingController(text: item?['cover_url'] ?? '');
    final sizeController = TextEditingController(text: item?['file_size'] ?? '');
    String? selectedCatId = item?['category_id'];
    bool isPublished = item?['is_published'] ?? true;
    bool isDownloadable = item?['is_downloadable'] ?? true;

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
                      isEditing ? 'تعديل بيانات الكتاب' : 'إضافة كتاب PDF جديد',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان الكتاب'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: authorController,
                      decoration: const InputDecoration(labelText: 'اسم المؤلف / المحقق'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'رابط ملف PDF المباشر (URL)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: coverController,
                      decoration: const InputDecoration(labelText: 'رابط صورة الغلاف (اختياري)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: sizeController,
                      decoration: const InputDecoration(labelText: 'حجم الملف (مثال: 5.2 MB)'),
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
                      title: const Text('السماح للمستخدمين بالتحميل'),
                      value: isDownloadable,
                      onChanged: (val) => setModalState(() => isDownloadable = val),
                    ),
                    SwitchListTile(
                      title: const Text('نشر فوري في التطبيق'),
                      value: isPublished,
                      onChanged: (val) => setModalState(() => isPublished = val),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى ملء العنوان ورابط PDF')),
                          );
                          return;
                        }

                        final payload = {
                          'title': titleController.text.trim(),
                          'pdf_url': urlController.text.trim(),
                          'author': authorController.text.trim().isEmpty ? null : authorController.text.trim(),
                          'cover_url': coverController.text.trim().isEmpty ? null : coverController.text.trim(),
                          'file_size': sizeController.text.trim().isEmpty ? null : sizeController.text.trim(),
                          'category_id': selectedCatId,
                          'is_downloadable': isDownloadable,
                          'is_published': isPublished,
                        };

                        final apiClient = ref.read(apiClientProvider);
                        try {
                          if (isEditing) {
                            await apiClient.dio.put('/pdfs/admin/${item['id']}', data: payload);
                          } else {
                            await apiClient.dio.post('/pdfs/admin', data: payload);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            _fetchData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? 'تم تعديل الكتاب بنجاح' : 'تمت إضافة الكتاب بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('حدث خطأ أثناء حفظ الكتاب')),
                            );
                          }
                        }
                      },
                      child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الكتاب'),
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
        title: const Text('إدارة مكتبة الكتب'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'إضافة كتاب جديد',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfs.isEmpty
              ? const Center(child: Text('لا توجد كتب مضافة بعد'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _pdfs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final pdf = _pdfs[index];
                    final isPublished = pdf['is_published'] == true;

                    return ListTile(
                      title: Text(pdf['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(pdf['author'] ?? pdf['file_size'] ?? '', style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPublished ? Icons.visibility : Icons.visibility_off,
                              color: isPublished ? AppColors.success : Colors.grey,
                            ),
                            onPressed: () => _togglePublish(pdf['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showAddEditDialog(pdf),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deletePdf(pdf['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
