import 'package:mineral/l10n/ui_localization.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/executor_material_tile.dart';
import 'package:mineral/core/services/photo_picker_service.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import 'package:mineral/features/executor/data/executor_repository.dart';
import 'package:mineral/shared/models/models.dart';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({
    super.key,
    required this.store,
    required this.order,
    required this.employeeId,
  });
  final ExecutorRepository store;
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
  List<String> get _catalog => widget.store.executorMaterials;
  String? _fault;
  String? _material;
  String? _photoError;
  bool _busy = false;
  bool _sending = false;
  bool _submitted = false;
  String _previousMaterials = '';
  @override
  void initState() {
    super.initState();
    _work.text = widget.order.completedWork;
    _fault = widget.store.executorFaultCodes.contains(widget.order.faultCode)
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
    final draft = widget.store.executionDraft(
      widget.employeeId,
      widget.order.number,
    );
    if (draft != null) {
      _work.text = draft.work;
      _comment.text = draft.comment;
      _fault = widget.store.executorFaultCodes.contains(draft.faultCode)
          ? draft.faultCode
          : null;
      _materials
        ..clear()
        ..addAll(draft.materials);
      _photos
        ..clear()
        ..addAll(draft.photos);
      _previousMaterials = draft.legacyMaterials;
    }
    _work.addListener(_scheduleSave);
    _comment.addListener(_scheduleSave);
    _lifecycle = AppLifecycleListener(
      onInactive: () => unawaited(_persist()),
      onPause: () => unawaited(_persist()),
    );
    unawaited(_restore());
  }

  Timer? _saveTimer;
  AppLifecycleListener? _lifecycle;
  bool _restoring = true;
  bool _draftLoadError = false;
  bool _draftSaveError = false;
  bool _allowPop = false;
  bool _saved = false;
  bool _leaving = false;
  int _revision = 0;

  Future<void> _restore() async {
    setState(() {
      _restoring = true;
      _draftLoadError = false;
    });
    try {
      final draft = await widget.store.restoreExecutionDraft(
        widget.employeeId,
        widget.order.number,
      );
      if (!mounted) return;
      if (draft != null) {
        _work.text = draft.work;
        _comment.text = draft.comment;
        _fault = widget.store.executorFaultCodes.contains(draft.faultCode)
            ? draft.faultCode
            : null;
        _materials
          ..clear()
          ..addAll(draft.materials);
        _photos
          ..clear()
          ..addAll(draft.photos);
        _previousMaterials = draft.legacyMaterials;
      }
      setState(() {
        _restoring = false;
        _saved = draft != null;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _restoring = false;
          _draftLoadError = true;
        });
      }
    }
  }

  void _edit(VoidCallback change) {
    setState(change);
    _scheduleSave();
  }

  void _scheduleSave() {
    if (_submitted || _restoring || _draftLoadError || _sending) return;
    _revision++;
    _saveTimer?.cancel();
    if (_saved && mounted) setState(() => _saved = false);
    _saveTimer = Timer(
      const Duration(milliseconds: 400),
      () => unawaited(_persist()),
    );
  }

  Future<bool> _persist({bool force = false}) async {
    if (_submitted || _restoring || _draftLoadError || (_sending && !force)) {
      return !_draftLoadError;
    }
    _saveTimer?.cancel();
    final revision = _revision;
    try {
      await widget.store.saveExecutionDraft(
        widget.employeeId,
        widget.order.number,
        _report(),
      );
      if (mounted) {
        setState(() {
          _saved = revision == _revision;
          _draftSaveError = false;
        });
      }
      return true;
    } catch (_) {
      if (mounted) setState(() => _draftSaveError = true);
      return false;
    }
  }

  Future<void> _leave() async {
    if (_sending || _restoring || _leaving) return;
    _leaving = true;
    if (!_draftLoadError && !await _persist()) {
      _leaving = false;
      return;
    }
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _lifecycle?.dispose();
    if (!_submitted && !_restoring && !_draftLoadError) {
      unawaited(
        widget.store
            .saveExecutionDraft(
              widget.employeeId,
              widget.order.number,
              _report(),
            )
            .catchError((Object _) {}),
      );
    }
    _work.dispose();
    _comment.dispose();
    _quantity.dispose();
    super.dispose();
  }

  Future<void> _pick(bool camera) async {
    if (_busy || _photos.length >= 5) return;
    setState(() => _busy = true);
    try {
      if (!await _persist() || !mounted) return;
      final picker = PhotoPickerService.instance;
      final photos = camera
          ? await picker.pickCamera()
          : await picker.pickGallery(5 - _photos.length);
      if (!mounted) return;
      _edit(() {
        _photos.addAll(photos.take(5 - _photos.length));
        if (_photos.isNotEmpty) _photoError = null;
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              uiText(
                context,
                'Не удалось добавить фото. Проверьте разрешения.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  ExecutionDraft _report() => ExecutionDraft(
    work: _work.text,
    faultCode: _fault ?? '',
    comment: _comment.text,
    legacyMaterials: _previousMaterials,
    materials: _materials,
    photos: _photos,
  );

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    setState(
      () => _photoError = !widget.order.planned && _photos.isEmpty
          ? 'Для внепланового наряда нужно фото после'
          : null,
    );
    if (!valid || _photoError != null || _busy) return;
    if (_material != null || _quantity.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            uiText(context, 'Добавьте выбранный материал в список'),
          ),
        ),
      );
      return;
    }
    if (_sending || _restoring || _draftLoadError) return;
    setState(() => _sending = true);
    try {
      if (!await _persist(force: true) || !mounted) return;
      _saveTimer?.cancel();
      await widget.store.submitExecution(
        widget.employeeId,
        widget.order,
        _report(),
      );
      _submitted = true;
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings(context).submitReportFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
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
                  decoration: InputDecoration(
                    labelText: uiText(context, 'Материал'),
                  ),
                  items: _catalog
                      .map(
                        (m) => DropdownMenuItem(
                          value: m,
                          child: Text(uiText(context, m)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _material = v),
                  validator: (v) =>
                      v == null ? uiText(context, 'Выберите материал') : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _quantity,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: uiText(context, 'Количество'),
                  ),
                  validator: (v) {
                    final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                    return n == null || !n.isFinite || n <= 0
                        ? uiText(context, 'Введите количество больше нуля')
                        : _material?.endsWith('шт') == true &&
                              n != n.roundToDouble()
                        ? strings(context).wholePieceQuantity
                        : null;
                  },
                ),
                OutlinedButton(
                  onPressed: () {
                    if (!_materialForm.currentState!.validate()) return;
                    _edit(() {
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
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(60),
                  ),
                  child: Text(uiText(context, 'Добавить материал')),
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
  Widget build(BuildContext context) => PopScope(
    canPop: _submitted || _allowPop,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) unawaited(_leave());
    },
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          strings(context).closeOrderNumber('${widget.order.number}'),
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
            onPressed: _busy || _sending || _restoring || _draftLoadError
                ? null
                : _submit,
            icon: const Icon(Icons.send_outlined),
            label: Text(
              _sending
                  ? uiText(context, 'Отправка…')
                  : uiText(context, 'Отправить на проверку'),
            ),
          ),
        ),
      ),
      body: _draftLoadError
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      strings(context).draftLoadFailed,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _restore,
                      child: Text(strings(context).retry),
                    ),
                  ],
                ),
              ),
            )
          : Theme(
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
              child: AbsorbPointer(
                absorbing: _sending || _restoring || _draftLoadError,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Stack(
                          children: [
                            const Positioned(
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _SectionLabel(
                                    number: '1',
                                    label: uiText(
                                      context,
                                      'Выполненные работы',
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: _SectionLabel(
                                    number: '2',
                                    label: uiText(context, 'Материалы и код'),
                                  ),
                                ),
                                Expanded(
                                  child: _SectionLabel(
                                    number: '3',
                                    label: uiText(
                                      context,
                                      'Фото и комментарий',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_restoring)
                          const LinearProgressIndicator()
                        else if (_draftSaveError)
                          TextButton.icon(
                            onPressed: () => unawaited(_persist()),
                            icon: const Icon(Icons.error_outline),
                            label: Text(strings(context).draftSaveFailed),
                          )
                        else if (_saved)
                          Text(
                            strings(context).draftSaved,
                            style: const TextStyle(
                              color: Color(0xFF687385),
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(height: 16),
                        _label(
                          Icons.assignment_outlined,
                          uiText(context, 'Что было сделано?'),
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          style: const TextStyle(fontSize: 14),
                          controller: _work,
                          minLines: 2,
                          maxLines: 4,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: uiText(
                              context,
                              'Опишите выполненные работы',
                            ),
                          ),
                          validator: (v) => (v ?? '').trim().isEmpty
                              ? uiText(context, 'Опишите выполненные работы')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _label(
                          Icons.build_outlined,
                          uiText(context, 'Код неисправности'),
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF182230),
                          ),
                          initialValue: _fault,
                          isExpanded: true,
                          decoration: InputDecoration(
                            hintText: uiText(context, 'Выберите код'),
                          ),
                          items: widget.store.executorFaultCodes
                              .map(
                                (code) => DropdownMenuItem(
                                  value: code,
                                  child: Text(uiText(context, code)),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => _edit(() => _fault = v),
                          validator: (v) => v == null
                              ? uiText(context, 'Выберите шифр')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        if (_previousMaterials.isNotEmpty)
                          Text(
                            strings(
                              context,
                            ).previousMaterialsValue(_previousMaterials),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: _label(
                                Icons.inventory_2_outlined,
                                uiText(context, 'Использованные материалы'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_materials.isEmpty)
                          Text(uiText(context, 'Материалы не использовались')),
                        for (final entry in _materials.entries.toList())
                          ExecutorMaterialTile(
                            name: entry.key,
                            quantity: entry.value,
                            onChanged: (value) =>
                                _edit(() => _materials[entry.key] = value),
                            onRemove: () =>
                                _edit(() => _materials.remove(entry.key)),
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
                            textStyle: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 26),
                          label: Text(uiText(context, 'Добавить материал')),
                        ),
                        const SizedBox(height: 16),
                        _label(
                          Icons.camera_alt_outlined,
                          uiText(context, 'Фото после выполнения работ'),
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
                                        tooltip: uiText(
                                          context,
                                          'Удалить фото',
                                        ),
                                        onPressed: _busy
                                            ? null
                                            : () => _edit(
                                                () => _photos.removeAt(i),
                                              ),
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
                              style: _photoButtonStyle(
                                context,
                                highlighted: true,
                              ),
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 26,
                              ),
                              label: Text(
                                uiText(context, 'Сделать фото после'),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          OutlinedButton.icon(
                            onPressed: _busy ? null : () => _pick(false),
                            style: _photoButtonStyle(context),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 24,
                            ),
                            label: Text(uiText(context, 'Выбрать из галереи')),
                          ),
                        ] else
                          Text(
                            uiText(
                              context,
                              'Добавлено 5 из 5 фото. Удалите фото, чтобы добавить новое.',
                            ),
                          ),
                        if (_busy)
                          const Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: LinearProgressIndicator(),
                          ),
                        if (_photoError != null)
                          Text(
                            uiText(context, _photoError!),
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        const SizedBox(height: 16),
                        _label(
                          Icons.chat_bubble_outline,
                          uiText(context, 'Комментарий (необязательно)'),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          style: const TextStyle(fontSize: 14),
                          controller: _comment,
                          minLines: 2,
                          maxLines: 3,
                          maxLength: 500,
                          decoration: InputDecoration(
                            hintText: uiText(
                              context,
                              'Дополнительная информация',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
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
