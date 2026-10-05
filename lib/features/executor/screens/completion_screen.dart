import 'package:flutter/material.dart';
import 'package:mineral/core/services/photo_picker_service.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final DemoStore store;
  final WorkOrder order;
  final int employeeId;

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> {
  final _form = GlobalKey<FormState>();
  final _work = TextEditingController();
  final _comment = TextEditingController();
  final _quantity = TextEditingController();
  final _materialForm = GlobalKey<FormState>();
  final _photos = <OrderPhoto>[];
  final _materials = <String, double>{};
  static const _catalog = [
    'Подшипник · шт',
    'Уплотнение · шт',
    'Кабель · м',
    'Масло · л',
    'Смазка · кг',
  ];
  String? _fault;
  String? _material;
  String? _photoError;
  bool _busy = false;
  String _previousMaterials = '';
  @override
  void initState() {
    super.initState();
    _work.text = widget.order.completedWork;
    _fault = DemoStore.faultCodes.contains(widget.order.faultCode)
        ? widget.order.faultCode
        : null;
    _photos.addAll(widget.order.afterImages);
    final unparsed = <String>[];
    for (final line in widget.order.materials.split('\n')) {
      final i = line.lastIndexOf(':');
      final name = i < 0 ? '' : line.substring(0, i);
      final quantity = i < 0
          ? null
          : double.tryParse(line.substring(i + 1).trim());
      if (_catalog.contains(name) &&
          quantity != null &&
          quantity.isFinite &&
          quantity > 0) {
        _materials[name] = quantity;
      } else if (line.isNotEmpty && line != 'Материалы не использовались') {
        unparsed.add(line);
      }
    }
    _previousMaterials = unparsed.join('\n');
  }

  @override
  void dispose() {
    _work.dispose();
    _comment.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _pick(bool camera) async {
    if (_busy || _photos.length >= 5) return;
    setState(() => _busy = true);
    try {
      final picker = PhotoPickerService.instance;
      final photos = camera
          ? await picker.pickCamera()
          : await picker.pickGallery(5 - _photos.length);
      if (!mounted) return;
      setState(() {
        _photos.addAll(photos.take(5 - _photos.length));
        if (_photos.isNotEmpty) _photoError = null;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось добавить фото. Проверьте разрешения.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    final valid = _form.currentState!.validate();
    setState(
      () => _photoError = !widget.order.planned && _photos.isEmpty
          ? 'Для внепланового наряда нужно фото после'
          : null,
    );
    if (!valid || _photoError != null || _busy) return;
    if (_material != null || _quantity.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте выбранный материал в список')),
      );
      return;
    }
    final order = widget.order;
    if (order.status != OrderStatus.working ||
        !widget.store.assignedTo(widget.employeeId).contains(order)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Статус или исполнитель наряда изменился'),
        ),
      );
      return;
    }
    order.completedWork = _work.text.trim();
    order.faultCode = _fault!;
    order.materials = _materials.isEmpty && _previousMaterials.isEmpty
        ? 'Материалы не использовались'
        : _materials.entries.map((e) => '${e.key}: ${e.value}').join('\n');
    if (_previousMaterials.isNotEmpty) {
      order.materials = '$_previousMaterials\n${order.materials}'.trim();
    }
    order.comment = _comment.text.trim().isEmpty
        ? order.comment
        : '${order.comment}\n${_comment.text.trim()}'.trim();
    order.afterImages
      ..clear()
      ..addAll(_photos);
    order.afterPhotos = _photos.length;
    order.aiVerdict = 'Ожидает проверки';
    order.aiExplanation = 'Отчёт отправлен. Проверка ИИ ещё не выполнена.';
    widget.store.changeStatus(
      order,
      OrderStatus.review,
      author: widget.store.employee(widget.employeeId).name,
    );
    Navigator.pop(context);
  }

  Widget _label(IconData icon, String text, {bool required = false}) => Row(
    children: [
      Icon(icon, size: 18, color: const Color(0xFF65748B)),
      const SizedBox(width: 8),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      if (required) const Text(' *', style: TextStyle(color: Colors.red)),
    ],
  );

  ButtonStyle _photoButtonStyle(
    BuildContext context, {
    bool highlighted = false,
  }) => OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(60),
    backgroundColor: highlighted ? const Color(0xFFEDF4FC) : Colors.white,
    foregroundColor: const Color(0xFF01408B),
    side: const BorderSide(color: Color(0xFFCDDEF3)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
  );

  Future<void> _addMaterial() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _materialForm,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey(_material),
                  initialValue: _material,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Материал'),
                  items: _catalog
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _material = v),
                  validator: (v) => v == null ? 'Выберите материал' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Количество'),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return n == null || !n.isFinite || n <= 0
                        ? 'Введите количество больше нуля'
                        : null;
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    if (!_materialForm.currentState!.validate()) return;
                    setState(() {
                      _materials.update(
                        _material!,
                        (n) =>
                            n +
                            double.parse(_quantity.text.replaceAll(',', '.')),
                        ifAbsent: () =>
                            double.parse(_quantity.text.replaceAll(',', '.')),
                      );
                      _material = null;
                      _quantity.clear();
                      _materialForm.currentState!.reset();
                      Navigator.pop(context);
                    });
                  },
                  child: const Text('Добавить материал'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted) return;
    setState(() {
      _material = null;
      _quantity.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: Text(
        'Закрытие наряда №${widget.order.number}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF01408B),
            minimumSize: const Size.fromHeight(54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _busy ? null : _submit,
          icon: const Icon(Icons.send_outlined),
          label: const Text('Отправить на проверку'),
        ),
      ),
    ),
    body: Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF7F9FC),
          contentPadding: const EdgeInsets.all(12),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE5EAF2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF01408B)),
          ),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Stack(
                children: [
                  Positioned(
                    top: 13,
                    left: 45,
                    right: 45,
                    child: Divider(
                      height: 1,
                      thickness: 2,
                      color: Color(0xFFBDCBE0),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _SectionLabel(
                          number: '1',
                          label: 'Выполненные работы',
                        ),
                      ),
                      Expanded(
                        child: _SectionLabel(
                          number: '2',
                          label: 'Материалы и код',
                        ),
                      ),
                      Expanded(
                        child: _SectionLabel(
                          number: '3',
                          label: 'Фото и комментарий',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _label(
                Icons.assignment_outlined,
                'Что было сделано?',
                required: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(fontSize: 14),
                controller: _work,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Опишите выполненные работы',
                ),
                validator: (v) => (v ?? '').trim().isEmpty
                    ? 'Опишите выполненные работы'
                    : null,
              ),
              const SizedBox(height: 16),
              _label(Icons.build_outlined, 'Код неисправности', required: true),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                style: const TextStyle(fontSize: 14, color: Color(0xFF182230)),
                initialValue: _fault,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Выберите код'),
                items: DemoStore.faultCodes
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: (v) => _fault = v,
                validator: (v) => v == null ? 'Выберите шифр' : null,
              ),
              const SizedBox(height: 16),
              if (_previousMaterials.isNotEmpty)
                Text('Ранее указанные материалы:\n$_previousMaterials'),
              Row(
                children: [
                  Expanded(
                    child: _label(
                      Icons.inventory_2_outlined,
                      'Использованные материалы',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_materials.isEmpty) const Text('Материалы не использовались'),
              for (final entry in _materials.entries.toList())
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE6EAF2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Уменьшить',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          if (entry.value <= 1) {
                            _materials.remove(entry.key);
                          } else {
                            _materials[entry.key] = entry.value - 1;
                          }
                        }),
                        icon: const Icon(Icons.remove, size: 16),
                      ),
                      Text(
                        entry.value == entry.value.roundToDouble()
                            ? '${entry.value.toInt()}'
                            : '${entry.value}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      IconButton(
                        tooltip: 'Увеличить',
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(
                          () => _materials[entry.key] = entry.value + 1,
                        ),
                        icon: const Icon(
                          Icons.add,
                          size: 16,
                          color: Color(0xFF01408B),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _addMaterial,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(60),
                  backgroundColor: const Color(0xFFEDF4FC),
                  foregroundColor: const Color(0xFF01408B),
                  side: const BorderSide(color: Color(0xFFCDDEF3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 26),
                label: const Text('Добавить материал'),
              ),
              const SizedBox(height: 16),
              _label(
                Icons.camera_alt_outlined,
                'Фото после выполнения работ',
                required: !widget.order.planned,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (var i = 0; i < _photos.length; i++)
                    SizedBox(
                      width: 128,
                      height: 100,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: GestureDetector(
                                onTap: () => PhotoAttachments(
                                  title: '',
                                  photos: _photos,
                                ).preview(context, _photos[i]),
                                child: Image.memory(
                                  _photos[i].bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              tooltip: 'Удалить фото',
                              onPressed: _busy
                                  ? null
                                  : () => setState(() => _photos.removeAt(i)),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              icon: const Icon(Icons.close, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_photos.length < 5) ...[
                if (PhotoPickerService.instance.supportsCamera) ...[
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _pick(true),
                    style: _photoButtonStyle(context, highlighted: true),
                    icon: const Icon(Icons.camera_alt_rounded, size: 26),
                    label: const Text('Сделать фото после'),
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pick(false),
                  style: _photoButtonStyle(context),
                  icon: const Icon(Icons.photo_library_outlined, size: 24),
                  label: const Text('Выбрать из галереи'),
                ),
              ] else
                const Text(
                  'Добавлено 5 из 5 фото. Удалите фото, чтобы добавить новое.',
                ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
              if (_photoError != null)
                Text(
                  _photoError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              const SizedBox(height: 16),
              _label(Icons.chat_bubble_outline, 'Комментарий (необязательно)'),
              const SizedBox(height: 8),
              TextFormField(
                style: const TextStyle(fontSize: 14),
                controller: _comment,
                minLines: 2,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Дополнительная информация',
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.number, required this.label});
  final String number;
  final String label;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      CircleAvatar(
        radius: 14,
        backgroundColor: number == '1'
            ? const Color(0xFF01408B)
            : const Color(0xFFDFEBFA),
        child: Text(
          number,
          style: TextStyle(
            color: number == '1' ? Colors.white : const Color(0xFF65748B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF65748B),
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
