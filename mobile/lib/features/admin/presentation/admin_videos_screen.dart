import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/app_providers.dart';

class AdminVideosScreen extends ConsumerStatefulWidget {
  const AdminVideosScreen({super.key});

  @override
  ConsumerState<AdminVideosScreen> createState() => _AdminVideosScreenState();
}

class _AdminVideosScreenState extends ConsumerState<AdminVideosScreen> {
  List<dynamic> _videos = [];
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
      final resVideos = await apiClient.dio.get('/videos/admin/all');
      final resCats = await apiClient.dio.get('/categories/admin/all?type=video');

      if (mounted) {
        setState(() {
          _videos = resVideos.data['data'] as List<dynamic>? ?? [];
          _categories = resCats.data['data'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحميل بيانات الفيديوهات من الخادم')),
        );
      }
    }
  }

  Future<void> _togglePublish(String id) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      await apiClient.dio.patch('/videos/admin/$id/publish');
      _fetchData();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تغيير حالة النشر')),
        );
      }
    }
  }

  Future<void> _deleteVideo(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الفيديو نهائياً؟'),
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
        await apiClient.dio.delete('/videos/admin/$id');
        _fetchData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف الفيديو بنجاح')),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل حذف الفيديو')),
          );
        }
      }
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? item]) {
    final isEditing = item != null;
    final titleController = TextEditingController(text: item?['title'] ?? '');
    final descController = TextEditingController(text: item?['description'] ?? '');
    final urlController = TextEditingController(text: item?['video_url'] ?? '');
    final thumbController = TextEditingController(text: item?['thumbnail_url'] ?? '');
    final publisherController = TextEditingController(text: item?['publisher'] ?? '');
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
                      isEditing ? 'تعديل بيانات الفيديو' : 'إضافة فيديو إسلامي جديد',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'عنوان الفيديو / الدرس'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'رابط الفيديو (URL)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: thumbController,
                      decoration: const InputDecoration(labelText: 'رابط الصورة المصغرة (اختياري)'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: publisherController,
                      decoration: const InputDecoration(labelText: 'الناشر / القناة / الشيخ'),
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
                        if (titleController.text.trim().isEmpty || urlController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى ملء العنوان ورابط الفيديو')),
                          );
                          return;
                        }

                        final payload = {
                          'title': titleController.text.trim(),
                          'video_url': urlController.text.trim(),
                          'description': descController.text.trim().isEmpty ? null : descController.text.trim(),
                          'thumbnail_url': thumbController.text.trim().isEmpty ? null : thumbController.text.trim(),
                          'publisher': publisherController.text.trim().isEmpty ? null : publisherController.text.trim(),
                          'category_id': selectedCatId,
                          'is_published': isPublished,
                        };

                        final apiClient = ref.read(apiClientProvider);
                        try {
                          if (isEditing) {
                            await apiClient.dio.put('/videos/admin/${item['id']}', data: payload);
                          } else {
                            await apiClient.dio.post('/videos/admin', data: payload);
                          }
                          if (context.mounted) {
                            Navigator.pop(context);
                            _fetchData();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(isEditing ? 'تم تعديل الفيديو بنجاح' : 'تمت إضافة الفيديو بنجاح')),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('حدث خطأ أثناء حفظ الفيديو')),
                            );
                          }
                        }
                      },
                      child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الفيديو'),
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
        title: const Text('إدارة الفيديوهات'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        tooltip: 'إضافة فيديو جديد',
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _videos.isEmpty
              ? const Center(child: Text('لا توجد فيديوهات مضافة بعد'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _videos.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final video = _videos[index];
                    final isPublished = video['is_published'] == true;

                    return ListTile(
                      title: Text(video['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(video['publisher'] ?? video['video_url'] ?? '', style: const TextStyle(fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPublished ? Icons.visibility : Icons.visibility_off,
                              color: isPublished ? AppColors.success : Colors.grey,
                            ),
                            onPressed: () => _togglePublish(video['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => _showAddEditDialog(video),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deleteVideo(video['id']),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
