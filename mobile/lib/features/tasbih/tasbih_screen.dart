import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/database/app_database.dart';

class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> with SingleTickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  String _currentDhikr = 'سبحان الله';
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _incrementCount() {
    HapticFeedback.lightImpact();
    _animController.forward().then((_) => _animController.reverse());

    setState(() {
      _count++;
      if (_count == _target) {
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _resetCount() {
    setState(() {
      _count = 0;
    });
  }

  Future<void> _saveRecord() async {
    if (_count == 0) return;

    final db = ref.read(databaseProvider);
    await db.saveTasbihRecord(
      TasbihRecordsCompanion(
        dhikrText: drift.Value(_currentDhikr),
        count: drift.Value(_count),
        target: drift.Value(_target),
        createdAt: drift.Value(DateTime.now()),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ عدد التسبيح في السجل')),
      );
    }
  }

  void _showDhikrPicker() {
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<TasbihPreset>>(
          future: db.getTasbihPresets(),
          builder: (context, snapshot) {
            final presets = snapshot.data ?? [];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'اختر الذكر',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: presets.length,
                        itemBuilder: (context, index) {
                          final p = presets[index];
                          final isSelected = p.dhikrText == _currentDhikr;

                          return ListTile(
                            title: Text(
                              p.dhikrText,
                              style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primary : null,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check_circle, color: AppColors.primary)
                                : null,
                            onTap: () {
                              setState(() {
                                _currentDhikr = p.dhikrText;
                                _target = p.target;
                                _count = 0;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
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

  void _showHistorySheet() {
    final db = ref.read(databaseProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<TasbihRecord>>(
          future: db.getTasbihHistory(),
          builder: (context, snapshot) {
            final records = snapshot.data ?? [];

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سجل التسبيح',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      const Expanded(
                        child: Center(child: Text('لا توجد سجلات تسبيح سابقة')),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final r = records[index];
                            return ListTile(
                              title: Text(r.dhikrText, style: const TextStyle(fontFamily: 'Amiri', fontSize: 17)),
                              subtitle: Text(
                                '${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year} - ${r.createdAt.hour}:${r.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${r.count} / ${r.target}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                              ),
                            );
                          },
                        ),
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
    final progress = _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المسبحة الإلكترونية'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'السجل',
            onPressed: _showHistorySheet,
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dhikr selector pill
              InkWell(
                onTap: _showDhikrPicker,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: AppColors.primary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currentDhikr,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Large Circular Counter Tap Target
              GestureDetector(
                onTap: _incrementCount,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 240,
                        height: 240,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          backgroundColor: AppColors.dividerLight.withAlpha(80),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      Container(
                        width: 210,
                        height: 210,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withAlpha(30),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$_count',
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              'اضغط للتسبيح',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Target count controller
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('الهدف: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  DropdownButton<int>(
                    value: _target,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 33, child: Text('33')),
                      DropdownMenuItem(value: 34, child: Text('34')),
                      DropdownMenuItem(value: 100, child: Text('100')),
                      DropdownMenuItem(value: 500, child: Text('500')),
                      DropdownMenuItem(value: 1000, child: Text('1000')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _target = val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons: Reset & Save
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _resetCount,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _saveRecord,
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ السجل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
