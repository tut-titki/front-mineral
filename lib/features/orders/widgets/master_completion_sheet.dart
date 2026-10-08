import 'package:flutter/material.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_services.dart';
import '../../../core/services/photo_picker_service.dart';
import '../../../l10n/ui_localization.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/backend_section.dart';
import '../data/references_api.dart';
import '../data/work_orders_api.dart';
import '../models/work_order_api_models.dart';
import 'photo_attachments.dart';

/// Completing a card requires its execution report, even when initiated by drag.
class MasterCompletionSheet extends StatefulWidget {
  const MasterCompletionSheet({
    super.key,
    required this.api,
    required this.order,
    required this.clientActionId,
  });

  final ApiServices api;
  final WorkOrderApiModel order;
  final String clientActionId;

  @override
  State<MasterCompletionSheet> createState() => _MasterCompletionSheetState();
}

class _MasterCompletionSheetState extends State<MasterCompletionSheet> {
  final _form = GlobalKey<FormState>();
  final _work = TextEditingController();
  final _photos = <OrderPhoto>[];
  final _uploaded = <OrderPhoto, String>{};
  final _materials = <_MaterialInput>[];
  List<FaultCodeReference> _faultCodes = [];
  List<MaterialReference> _catalog = [];
  int? _faultCodeId;
  bool _loading = true;
  bool _busy = false;
  bool _picking = false;
  bool _referenceError = false;
  String? _error;
  String? _photoError;

  @override
  void initState() {
    super.initState();
    _work.text = widget.order.completionText ?? '';
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait<Object>([
        widget.api.references.getFaultCodes(),
        widget.api.references.getMaterials(),
      ]);
      if (!mounted) return;
      setState(() {
        _faultCodes = results[0] as List<FaultCodeReference>;
        _catalog = results[1] as List<MaterialReference>;
        final initialId = widget.order.faultCode?.id;
        _faultCodeId ??= _faultCodes.any((item) => item.id == initialId)
            ? initialId
            : null;
        _loading = false;
        _referenceError = false;
      });
    } catch (failure) {
      if (mounted) {
        setState(() {
          _loading = false;
          _referenceError = true;
          _error = _message(failure);
        });
      }
    }
  }

  String _message(Object failure) => uiText(
    context,
    failure is ApiException
        ? failure.message
        : 'Не удалось отправить отчёт. Повторите попытку.',
  );

  Future<void> _pickPhotos(bool camera) async {
    setState(() {
      _picking = true;
      _photoError = null;
    });
    try {
      final picker = PhotoPickerService.instance;
      final photos = camera
          ? await picker.pickCamera()
          : await picker.pickGallery(5 - _photos.length);
      if (!mounted) return;
      setState(() => _photos.addAll(photos.take(5 - _photos.length)));
    } catch (_) {
      if (mounted) {
        setState(
          () => _photoError = uiText(
            context,
            'Не удалось добавить фото. Проверьте разрешения.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    final photoMissing = widget.order.isEmergency && _photos.isEmpty;
    setState(
      () => _photoError = photoMissing
          ? backendText(
              context,
              'Для аварийного наряда нужно фото после',
              'Авариялық наряд үшін жұмыстан кейінгі фото қажет',
            )
          : null,
    );
    if (!valid || photoMissing) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      for (final photo in _photos) {
        if (_uploaded.containsKey(photo)) continue;
        final uploaded = await widget.api.uploads.uploadPhoto(
          bytes: photo.bytes,
          fileName: photo.name,
          takenAt: photo.takenAt,
        );
        _uploaded[photo] = uploaded.url;
      }
      await widget.api.workOrders.performAction(
        widget.order.id,
        WorkOrderActionInput(
          action: WorkOrderAction.complete,
          clientActionId: widget.clientActionId,
          completionText: _work.text,
          faultCodeId: _faultCodeId,
          afterPhotoUrls: [for (final photo in _photos) _uploaded[photo]!],
          materialUsages: [
            for (final material in _materials)
              {
                'materialId': material.id,
                'quantity': double.parse(
                  material.quantity.text.replaceAll(',', '.'),
                ),
              },
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (failure) {
      if (mounted) setState(() => _error = _message(failure));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _work.dispose();
    for (final material in _materials) {
      material.quantity.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy && !_picking,
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .8,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Text(
                  uiText(context, 'Отправить на проверку'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : Form(
                        key: _form,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            if (_error != null) ...[
                              Text(
                                _error!,
                                style: const TextStyle(color: Colors.red),
                              ),
                              TextButton(
                                onPressed: _busy
                                    ? null
                                    : (_referenceError
                                          ? _loadReferences
                                          : _submit),
                                child: Text(uiText(context, 'Повторить')),
                              ),
                            ],
                            TextFormField(
                              key: const ValueKey('kanban-completion-work'),
                              controller: _work,
                              enabled: !_busy,
                              minLines: 3,
                              maxLines: 6,
                              decoration: InputDecoration(
                                labelText: uiText(context, 'Что было сделано?'),
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? uiText(
                                      context,
                                      'Опишите выполненные работы',
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<int>(
                              key: const ValueKey('kanban-completion-fault'),
                              initialValue: _faultCodeId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: uiText(context, 'Код неисправности'),
                              ),
                              items: [
                                for (final code in _faultCodes)
                                  DropdownMenuItem(
                                    value: code.id,
                                    child: Text(
                                      uiText(context, code.displayName),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: _busy
                                  ? null
                                  : (value) =>
                                        setState(() => _faultCodeId = value),
                              validator: (value) => value == null
                                  ? uiText(context, 'Выберите шифр')
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            Text(uiText(context, 'Использованные материалы')),
                            for (final material in _materials) ...[
                              const SizedBox(height: 12),
                              Row(
                                key: ObjectKey(material),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<int>(
                                      isExpanded: true,
                                      initialValue: material.id,
                                      items: [
                                        for (final item in _catalog)
                                          DropdownMenuItem(
                                            value: item.id,
                                            child: Text(
                                              uiText(
                                                context,
                                                '${item.name} · ${item.unit}',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                      onChanged: _busy
                                          ? null
                                          : (id) => setState(
                                              () => material.id = id,
                                            ),
                                      validator: (id) => id == null
                                          ? uiText(context, 'Выберите материал')
                                          : null,
                                      decoration: InputDecoration(
                                        labelText: uiText(context, 'Материал'),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: material.quantity,
                                      enabled: !_busy,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: InputDecoration(
                                        labelText: uiText(
                                          context,
                                          'Количество',
                                        ),
                                      ),
                                      validator: (text) {
                                        final value = double.tryParse(
                                          (text ?? '').replaceAll(',', '.'),
                                        );
                                        return value == null ||
                                                !value.isFinite ||
                                                value <= 0
                                            ? uiText(
                                                context,
                                                'Введите количество больше нуля',
                                              )
                                            : null;
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _busy
                                        ? null
                                        : () => setState(() {
                                            _materials.remove(material);
                                            WidgetsBinding.instance
                                                .addPostFrameCallback(
                                                  (_) => material.quantity
                                                      .dispose(),
                                                );
                                          }),
                                    icon: const Icon(Icons.close),
                                    tooltip: uiText(context, 'Удалить'),
                                  ),
                                ],
                              ),
                            ],
                            TextButton.icon(
                              onPressed: _busy || _catalog.isEmpty
                                  ? null
                                  : () => setState(
                                      () => _materials.add(_MaterialInput()),
                                    ),
                              icon: const Icon(Icons.add),
                              label: Text(uiText(context, 'Добавить материал')),
                            ),
                            const SizedBox(height: 16),
                            PhotoAttachments(
                              title: 'Фото после выполнения работ',
                              photos: _photos,
                              busy: _busy || _picking,
                              onCamera:
                                  PhotoPickerService.instance.supportsCamera
                                  ? () => _pickPhotos(true)
                                  : null,
                              onGallery: () => _pickPhotos(false),
                              onRemove: _busy || _picking
                                  ? null
                                  : (index) => setState(() {
                                      _uploaded.remove(_photos.removeAt(index));
                                    }),
                            ),
                            if (_photoError != null)
                              Text(
                                _photoError!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _busy || _picking
                          ? null
                          : () => Navigator.pop(context),
                      child: Text(uiText(context, 'Отмена')),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _loading || _busy || _picking
                            ? null
                            : _submit,
                        child: _busy
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      backendText(
                                        context,
                                        'Проверяем отчёт…',
                                        'Есепті тексеріп жатырмыз…',
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Text(uiText(context, 'Отправить на проверку')),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _MaterialInput {
  int? id;
  final quantity = TextEditingController();
}
