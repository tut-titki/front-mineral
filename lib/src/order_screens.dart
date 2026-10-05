import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/ui_localization.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'demo_store.dart';
import 'ui.dart';
import 'photo_attachments.dart';
import 'photo_picker_service.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, required this.store, this.photoPicker});

  final DemoStore store;
  final PhotoPickerService? photoPicker;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final commentController = TextEditingController();
  final normHoursController = TextEditingController(text: '2');
  Timer? clockTimer;

  String area = DemoStore.areas.keys.first;
  late String equipment = DemoStore.areas[area]!.first;
  int? employeeId;
  String? brigade;
  bool assignBrigade = false;
  bool useNorm = true;
  bool equipmentStopped = false;
  String? faultCode;
  String priority = 'Обычный';
  bool planned = false;
  final List<OrderPhoto> photos = [];
  bool pickingPhotos = true;
  late final photoPicker = widget.photoPicker ?? PhotoPickerService.instance;
  DateTime deadline = DateTime.now().add(Duration(hours: 2));

  @override
  void initState() {
    super.initState();
    restorePhotos();
    widget.store.addListener(refresh);
    clockTimer = Timer.periodic(Duration(seconds: 1), (_) => refresh());
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  Future<void> restorePhotos() async {
    try {
      final restored = await photoPicker.takeRecoveredPhotos();
      if (!mounted) return;
      setState(() => photos.addAll(restored.take(5)));
    } finally {
      if (mounted) setState(() => pickingPhotos = false);
    }
  }

  Future<void> addPhotos({required bool camera}) async {
    if (pickingPhotos || photos.length >= 5) return;
    setState(() => pickingPhotos = true);
    try {
      final selected = camera
          ? await photoPicker.pickCamera()
          : await photoPicker.pickGallery(5 - photos.length);
      if (!mounted) return;
      setState(() => photos.addAll(selected.take(5 - photos.length)));
    } on PlatformException catch (error) {
      if (!mounted) return;
      final denied =
          error.code.toLowerCase().contains('access') ||
          error.code.toLowerCase().contains('permission');
      showMessage(
        context,
        denied
            ? 'Разрешите доступ к камере или фото в настройках приложения.'
            : 'Не удалось открыть камеру или галерею. Попробуйте ещё раз.',
      );
    } on Exception {
      if (mounted) {
        showMessage(
          context,
          'Не удалось загрузить фото. Выберите другой снимок.',
        );
      }
    } finally {
      if (mounted) setState(() => pickingPhotos = false);
    }
  }

  @override
  void dispose() {
    clockTimer?.cancel();
    widget.store.removeListener(refresh);
    normHoursController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    commentController.dispose();
    super.dispose();
  }

  Future<void> selectDeadline() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(Duration(days: 365)),
      helpText: uiText(context, 'Срок исполнения'),
      cancelText: uiText(context, 'Отмена'),
      confirmText: uiText(context, 'Выбрать'),
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(deadline),
      helpText: uiText(context, 'Время исполнения'),
      cancelText: uiText(context, 'Отмена'),
      confirmText: uiText(context, 'Выбрать'),
    );

    if (time == null || !mounted) return;

    setState(() {
      deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void submit() {
    if (pickingPhotos) return;
    if (!formKey.currentState!.validate()) return;

    if (!useNorm && !deadline.isAfter(widget.store.now)) {
      showMessage(context, uiText(context, 'Выберите срок в будущем.'));
      return;
    }

    final description = descriptionController.text.trim();
    try {
      widget.store.issueOrder(
        title: titleController.text.trim().isEmpty
            ? description.split('\n').first
            : titleController.text.trim(),
        description: descriptionController.text.trim(),
        area: area,
        equipment: equipment,
        employeeId: assignBrigade ? null : employeeId,
        brigade: assignBrigade ? brigade : null,
        priority: priority,
        deadline: deadline,
        normHours: useNorm
            ? double.parse(normHoursController.text.replaceAll(',', '.'))
            : null,
        planned: planned,
        comment: commentController.text.trim(),
        photos: photos,
        faultCode: faultCode ?? '',
        equipmentStopped: equipmentStopped,
      );
    } on ArgumentError catch (error) {
      showMessage(context, error.message.toString());
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(uiText(context, 'Создание наряда'))),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: pickingPhotos ? null : submit,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(uiText(context, 'Выдать наряд')),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 800),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: brand,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              uiText(
                                context,
                                'Наряд №${widget.store.nextNumber}',
                              ),
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              uiText(
                                context,
                                'Выдача: ${dateLabel(widget.store.now)} · ${timeLabel(widget.store.now)}',
                              ),
                              style: const TextStyle(
                                color: muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _OrderFormSection(
                    title: 'Описание работ',
                    icon: Icons.edit_note_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text(uiText(context, 'Внеплановый')),
                              icon: Icon(Icons.build_outlined),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text(uiText(context, 'Плановый')),
                              icon: Icon(Icons.event_available),
                            ),
                          ],
                          selected: {planned},
                          onSelectionChanged: (value) {
                            setState(() {
                              planned = value.first;
                              if (planned) priority = 'Плановый';
                              if (!planned && priority == 'Плановый') {
                                priority = 'Обычный';
                              }
                            });
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: titleController,
                          decoration: InputDecoration(
                            labelText: uiText(
                              context,
                              'Название работы (необязательно)',
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: InputDecoration(
                            labelText: uiText(
                              context,
                              'Проблема и необходимые работы',
                            ),
                            suffixIcon: IconButton(
                              tooltip: uiText(context, 'Голосовой ввод'),
                              onPressed: () {
                                showMessage(
                                  context,
                                  'Голосовой ввод подключим позже.',
                                );
                              },
                              icon: Icon(Icons.mic_none),
                            ),
                          ),
                          validator: (value) {
                            return value == null || value.trim().isEmpty
                                ? uiText(context, 'Опишите проблему')
                                : null;
                          },
                        ),
                      ],
                    ),
                  ),
                  _OrderFormSection(
                    title: 'Место и исполнитель',
                    icon: Icons.location_on_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: area,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: uiText(context, 'Участок'),
                          ),
                          items: [
                            for (final name in DemoStore.areas.keys)
                              DropdownMenuItem(
                                value: name,
                                child: Text(uiText(context, name)),
                              ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              area = value;
                              equipment = DemoStore.areas[value]!.first;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          key: ValueKey(area),
                          initialValue: equipment,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: uiText(context, 'Оборудование'),
                          ),
                          items: [
                            for (final name in DemoStore.areas[area]!)
                              DropdownMenuItem(
                                value: name,
                                child: Text(uiText(context, name)),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => equipment = value);
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text(uiText(context, 'Исполнитель')),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text(uiText(context, 'Бригада')),
                            ),
                          ],
                          selected: {assignBrigade},
                          onSelectionChanged: (value) =>
                              setState(() => assignBrigade = value.first),
                        ),
                        SizedBox(height: 16),
                        if (!assignBrigade)
                          DropdownButtonFormField<int>(
                            initialValue: employeeId,
                            isExpanded: true,
                            itemHeight: 84,
                            selectedItemBuilder: (context) => [
                              for (final employee in widget.store.employees)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: widget.store.employeeColor(
                                        employee,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        employee.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                            decoration: InputDecoration(
                              labelText: uiText(context, 'Исполнитель'),
                            ),
                            items: [
                              for (final employee in widget.store.employees)
                                DropdownMenuItem(
                                  value: employee.id,
                                  enabled: employee.onShift,
                                  child: EmployeeChoice(
                                    employee: employee,
                                    store: widget.store,
                                  ),
                                ),
                            ],
                            onChanged: (value) {
                              setState(() => employeeId = value);
                            },
                            validator: (value) {
                              return value == null
                                  ? uiText(context, 'Выберите исполнителя')
                                  : null;
                            },
                          ),
                        if (assignBrigade)
                          DropdownButtonFormField<String>(
                            initialValue: brigade,
                            isExpanded: true,
                            itemHeight: 80,
                            selectedItemBuilder: (context) => [
                              for (final name in widget.store.brigades)
                                Text(uiText(context, name)),
                            ],
                            decoration: InputDecoration(
                              labelText: uiText(context, 'Бригада'),
                            ),
                            items: [
                              for (final name in widget.store.brigades)
                                DropdownMenuItem(
                                  value: name,
                                  enabled: widget.store
                                      .brigadeMembers(name)
                                      .any((e) => e.onShift),
                                  child: BrigadeChoice(
                                    brigade: name,
                                    store: widget.store,
                                  ),
                                ),
                            ],
                            onChanged: (value) =>
                                setState(() => brigade = value),
                            validator: (value) => value == null
                                ? uiText(context, 'Выберите бригаду')
                                : null,
                          ),
                        if (!assignBrigade && employeeId != null) ...[
                          SizedBox(height: 10),
                          StatusTag(
                            widget.store.employeeStatus(
                              widget.store.employee(employeeId!),
                            ),
                            color: widget.store.employeeColor(
                              widget.store.employee(employeeId!),
                            ),
                          ),
                        ],
                        if (assignBrigade && brigade != null) ...[
                          SizedBox(height: 10),
                          BrigadeChoice(brigade: brigade!, store: widget.store),
                        ],
                      ],
                    ),
                  ),
                  _OrderFormSection(
                    title: 'Срок и приоритет',
                    icon: Icons.schedule_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownButtonFormField<String>(
                          key: ValueKey('priority-$priority'),
                          initialValue: priority,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: uiText(context, 'Приоритет'),
                          ),
                          items: [
                            for (final value in [
                              'Аварийный',
                              'Высокий',
                              'Обычный',
                              'Плановый',
                            ])
                              DropdownMenuItem(
                                value: value,
                                child: Text(
                                  uiText(
                                    context,
                                    DemoStore.priorityLabels[value]!,
                                  ),
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                priority = value;
                                if (value == 'Аварийный') planned = false;
                                if (value == 'Плановый') planned = true;
                              });
                            }
                          },
                        ),
                        SizedBox(height: 16),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: true,
                              label: Text(uiText(context, 'Норматив, ч')),
                            ),
                            ButtonSegment(
                              value: false,
                              label: Text(uiText(context, 'Дата и время')),
                            ),
                          ],
                          selected: {useNorm},
                          onSelectionChanged: (value) =>
                              setState(() => useNorm = value.first),
                        ),
                        SizedBox(height: 16),
                        if (useNorm)
                          TextFormField(
                            controller: normHoursController,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              labelText: uiText(context, 'Норматив в часах'),
                            ),
                            validator: (value) {
                              final hours = double.tryParse(
                                (value ?? '').replaceAll(',', '.'),
                              );
                              return hours == null ||
                                      !hours.isFinite ||
                                      hours < 1 / 60 ||
                                      hours > 8760
                                  ? uiText(
                                      context,
                                      'Укажите от 1 минуты до 8760 часов',
                                    )
                                  : null;
                            },
                          ),
                        if (!useNorm)
                          OutlinedButton.icon(
                            onPressed: selectDeadline,
                            icon: Icon(Icons.calendar_month_outlined),
                            label: Text(
                              uiText(
                                context,
                                '${dateLabel(deadline)} · ${timeLabel(deadline)}',
                              ),
                            ),
                          ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: faultCode,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: uiText(
                              context,
                              'Шифр неисправности (необязательно)',
                            ),
                          ),
                          items: [
                            DropdownMenuItem<String>(
                              value: null,
                              child: Text(uiText(context, 'Не указан')),
                            ),
                            for (final code in DemoStore.faultCodes)
                              DropdownMenuItem(
                                value: code,
                                child: Text(uiText(context, code)),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => faultCode = value),
                        ),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            uiText(context, 'Оборудование в простое'),
                          ),
                          value: equipmentStopped,
                          onChanged: (value) =>
                              setState(() => equipmentStopped = value),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: commentController,
                          minLines: 2,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: uiText(context, 'Комментарий'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PhotoAttachments(
                    framed: false,
                    title: 'Фото неисправности · до 5',
                    photos: photos,
                    busy: pickingPhotos,
                    onCamera: photoPicker.supportsCamera
                        ? () => addPhotos(camera: true)
                        : null,
                    onGallery: () => addPhotos(camera: false),
                    onRemove: (index) => setState(() => photos.removeAt(index)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderFormSection extends StatelessWidget {
  const _OrderFormSection({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Icon(icon, size: 21, color: brand),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              uiText(context, title),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      child,
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 26),
        child: Divider(height: 1, color: border),
      ),
    ],
  );
}

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({
    super.key,
    required this.store,
    required this.order,
  });

  final DemoStore store;
  final WorkOrder order;

  Future<String?> requestReason(BuildContext context, String title) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(uiText(context, title)),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: uiText(context, 'Причина'),
              ),
              validator: (value) {
                return value == null || value.trim().isEmpty
                    ? uiText(context, 'Укажите причину')
                    : null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(uiText(context, 'Назад')),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: Text(uiText(context, 'Подтвердить')),
            ),
          ],
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<void> reassign(BuildContext context) async {
    final selectedId = await showDialog<Object>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(uiText(context, 'Исполнитель или бригада')),
          children: [
            for (final employee in store.employees)
              SimpleDialogOption(
                onPressed: !employee.onShift
                    ? null
                    : () => Navigator.pop(dialogContext, employee.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: EmployeeChoice(employee: employee, store: store),
                ),
              ),
            Divider(),
            for (final brigade in store.brigades)
              SimpleDialogOption(
                onPressed: store.brigadeMembers(brigade).any((e) => e.onShift)
                    ? () => Navigator.pop(dialogContext, brigade)
                    : null,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: BrigadeChoice(brigade: brigade, store: store),
                ),
              ),
          ],
        );
      },
    );

    if (selectedId is int) store.reassign(order, selectedId);
    if (selectedId is String) store.reassignBrigade(order, selectedId);
  }

  Future<void> changePriority(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(uiText(context, 'Приоритет наряда')),
          children: [
            for (final priority in [
              'Аварийный',
              'Высокий',
              'Обычный',
              'Плановый',
            ])
              SimpleDialogOption(
                onPressed: () => Navigator.pop(dialogContext, priority),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    uiText(context, DemoStore.priorityLabels[priority]!),
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (selected != null) store.changePriority(order, selected);
  }

  Future<void> changeScore(BuildContext context) async {
    final selected = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(uiText(context, 'Оценка мастера')),
          children: [
            for (var score = 1; score <= 5; score++)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(dialogContext, score.toDouble());
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(uiText(context, '$score из 5')),
                ),
              ),
          ],
        );
      },
    );

    if (selected != null) store.setMasterScore(order, selected);
  }

  Widget information(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            uiText(context, label),
            style: TextStyle(color: muted, fontSize: 12),
          ),
          SizedBox(height: 5),
          Text(
            uiText(context, value),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ink,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  bool get finished =>
      [OrderStatus.closed, OrderStatus.cancelled].contains(order.status);

  Future<void> editOrder(BuildContext context) async {
    if (finished) return;
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings(sheetContext).editOrder,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            for (final item in [
              (
                'assignee',
                Icons.person_add_alt,
                uiText(sheetContext, 'Переназначить'),
              ),
              (
                'priority',
                Icons.flag_outlined,
                uiText(sheetContext, 'Изменить приоритет'),
              ),
              (
                'deadline',
                Icons.schedule_outlined,
                strings(sheetContext).changeDeadline,
              ),
              (
                'cancel',
                Icons.cancel_outlined,
                uiText(sheetContext, 'Отменить наряд'),
              ),
            ])
              ListTile(
                leading: Icon(
                  item.$2,
                  color: item.$1 == 'cancel' ? Colors.red : brand,
                ),
                title: Text(
                  item.$3,
                  style: TextStyle(
                    color: item.$1 == 'cancel' ? Colors.red : ink,
                  ),
                ),
                onTap: () => Navigator.pop(sheetContext, item.$1),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted || finished) return;
    switch (action) {
      case 'assignee':
        await reassign(context);
      case 'priority':
        await changePriority(context);
      case 'deadline':
        await changeDeadline(context);
      case 'cancel':
        final reason = await requestReason(context, 'Отмена наряда');
        if (reason != null && context.mounted) {
          store.changeStatus(order, OrderStatus.cancelled, reason: reason);
        }
    }
  }

  Future<void> changeDeadline(BuildContext context) async {
    final now = store.now;
    final lastDate = now.add(const Duration(days: 365));
    final initial =
        order.deadline.isBefore(now) || order.deadline.isAfter(lastDate)
        ? now
        : order.deadline;
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: lastDate,
      helpText: strings(context).changeDeadline,
    );
    if (date == null || !context.mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(order.deadline),
      helpText: uiText(context, 'Время исполнения'),
    );
    if (time == null || !context.mounted) return;
    try {
      store.changeDeadline(
        order,
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    } on ArgumentError {
      showMessage(context, 'Выберите срок в будущем.');
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(uiText(context, 'Наряд №${order.number}')),
        actions: [
          if (!finished)
            IconButton(
              tooltip: strings(context).editOrder,
              onPressed: () => editOrder(context),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  order.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${order.equipment} · ${order.area}',
                  style: const TextStyle(color: muted, height: 1.5),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    StatusTag(order.status.label, color: order.status.color),
                    StatusTag(
                      order.priority,
                      color: order.emergency ? Colors.red : brand,
                    ),
                    if (order.overdue)
                      StatusTag('Просрочен', color: Colors.red),
                  ],
                ),
                const SizedBox(height: 26),
                _OrderFormSection(
                  title: 'Информация о наряде',
                  icon: Icons.assignment_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      information(context, 'Описание', order.description),
                      information(
                        context,
                        'Тип работ',
                        order.planned ? 'Плановый' : 'Внеплановый',
                      ),
                      information(
                        context,
                        order.brigade == null ? 'Исполнитель' : 'Бригада',
                        store.assignmentLabel(order),
                      ),
                      information(
                        context,
                        'Дата выдачи',
                        '${dateLabel(order.createdAt)} · ${timeLabel(order.createdAt)}',
                      ),
                      information(
                        context,
                        'Срок исполнения',
                        '${dateLabel(order.deadline)} · ${timeLabel(order.deadline)}',
                      ),
                      if (order.normHours != null)
                        information(
                          context,
                          'Норматив',
                          '${order.normHours} ч',
                        ),
                      if (order.faultCode.isNotEmpty)
                        information(
                          context,
                          'Шифр неисправности',
                          order.faultCode,
                        ),
                      information(context, 'Мастер', DemoStore.masterName),
                      if (order.comment.isNotEmpty)
                        information(context, 'Комментарий', order.comment),
                      information(
                        context,
                        'Простой оборудования',
                        order.equipmentStopped
                            ? 'Оборудование остановлено'
                            : 'Нет активного простоя',
                      ),
                    ],
                  ),
                ),
                AdaptiveGrid(
                  minWidth: 300,
                  children: [
                    PhotoAttachments(
                      title: 'До выполнения',
                      photos: order.beforeImages,
                      framed: false,
                    ),
                    PhotoAttachments(
                      title: 'После выполнения',
                      photos: order.afterImages,
                      framed: false,
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 26),
                  child: Divider(height: 1, color: border),
                ),
                if (order.completedWork.isNotEmpty) ...[
                  _OrderFormSection(
                    title: 'Отчёт исполнителя',
                    icon: Icons.task_alt_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        information(
                          context,
                          'Выполненные работы',
                          order.completedWork,
                        ),
                        information(
                          context,
                          'Шифр неисправности',
                          order.faultCode.isEmpty
                              ? 'Не указан'
                              : order.faultCode,
                        ),
                        information(
                          context,
                          'Материалы',
                          order.materials.isEmpty
                              ? 'Не указаны'
                              : order.materials,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    uiText(context, 'Вердикт ИИ: ${order.aiVerdict}'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: brand,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    uiText(
                      context,
                      '${order.aiExplanation}\n'
                      'Оценка ИИ: ${order.aiScore.toStringAsFixed(1)} / 5.\n'
                      'Итоговая оценка: ${order.finalScore.toStringAsFixed(1)} / 5.\n'
                      'Окончательное решение принимает мастер.',
                    ),
                    style: const TextStyle(color: muted, height: 1.6),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => changeScore(context),
                      icon: const Icon(Icons.star_outline),
                      label: Text(uiText(context, 'Изменить оценку')),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
                if (order.status == OrderStatus.review) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => store.changeStatus(
                          order,
                          OrderStatus.closed,
                          reason: 'Работы приняты мастером',
                        ),
                        icon: const Icon(Icons.task_alt),
                        label: Text(uiText(context, 'Принять и закрыть')),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final reason = await requestReason(
                            context,
                            'Вернуть на доработку',
                          );
                          if (reason != null && context.mounted) {
                            store.changeStatus(
                              order,
                              OrderStatus.rework,
                              reason: reason,
                            );
                          }
                        },
                        icon: const Icon(Icons.undo),
                        label: Text(uiText(context, 'На доработку')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                ],
                _OrderFormSection(
                  title: 'История действий',
                  icon: Icons.history_rounded,
                  child: Column(
                    children: [
                      for (final event in order.history.reversed)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: brand,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      eventText(context, event),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${eventAuthor(context, event)} · ${dateLabel(event.time)} ${timeLabel(event.time)}',
                                      style: const TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    ),
  );
}
