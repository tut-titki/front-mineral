import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/backend_refresh_view.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mineral/core/api/api_client.dart';
import 'package:mineral/core/api/api_services.dart';
import 'package:mineral/core/services/photo_picker_service.dart';

import 'package:mineral/features/orders/data/recommendations_api.dart';
import 'package:mineral/features/orders/data/references_api.dart';
import 'package:mineral/features/orders/data/uploads_api.dart';
import 'package:mineral/features/orders/data/work_orders_api.dart';
import 'package:mineral/features/orders/models/work_order_api_models.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import '../widgets/voice_description_button.dart';

import 'package:mineral/l10n/ui_localization.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/shared/widgets/ui.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key, required this.api, this.photoPicker});

  final ApiServices api;
  final PhotoPickerService? photoPicker;

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final formKey = GlobalKey<FormState>();

  final descriptionController = TextEditingController();
  final descriptionFocus = FocusNode();

  final commentController = TextEditingController();

  late final PhotoPickerService photoPicker;

  // MARK: References

  List<AreaReference> areas = [];
  List<EquipmentReference> equipment = [];
  List<ExecutorReference> executors = [];
  List<NormativeReference> normatives = [];
  List<FaultCodeReference> faultCodes = [];
  List<BrigadeReference> brigades = [];
  bool assignBrigade = false;
  int? brigadeId;

  int? areaId;
  int? equipmentId;
  int? executorId;
  int? normativeId;
  int? faultCodeId;

  // MARK: Order

  WorkOrderType type = WorkOrderType.emergency;

  WorkOrderPriority priority = WorkOrderPriority.emergency;

  bool useNormative = true;

  DateTime deadline = DateTime.now().add(const Duration(hours: 2));

  // MARK: Photos

  final List<OrderPhoto> photos = [];

  bool pickingPhotos = true;

  // MARK: Loading

  bool loadingReferences = true;
  bool loadingEquipment = false;
  bool loadingNormatives = false;
  bool loadingRecommendations = false;
  bool creating = false;
  bool voiceBusy = false;

  // MARK: Recommendations

  List<RecommendedExecutor> recommendedExecutors = [];

  WorkRecommendation? workRecommendation;

  String? pageError;

  @override
  void initState() {
    super.initState();

    photoPicker = widget.photoPicker ?? PhotoPickerService.instance;

    restorePhotos();
    loadInitialData();
  }

  @override
  void dispose() {
    descriptionFocus.dispose();
    descriptionController.dispose();
    commentController.dispose();

    super.dispose();
  }

  // MARK: Initial data

  Future<void> refreshReferences() async {
    if (creating || voiceBusy || loadingEquipment || loadingNormatives) return;
    final selectedArea = areaId;
    final selectedEquipment = equipmentId;
    try {
      final refs = widget.api.references;
      final results = await Future.wait<Object>([
        refs.getAreas(refresh: true),
        refs.getExecutors(),
        refs.getFaultCodes(refresh: true),
        refs.getBrigades(refresh: true),
        refs.getEquipment(areaId: selectedArea, refresh: true),
        refs.getNormatives(equipmentId: selectedEquipment, refresh: true),
      ]);
      if (!mounted ||
          areaId != selectedArea ||
          equipmentId != selectedEquipment) {
        return;
      }
      setState(() {
        areas = results[0] as List<AreaReference>;
        executors = results[1] as List<ExecutorReference>;
        faultCodes = results[2] as List<FaultCodeReference>;
        brigades = results[3] as List<BrigadeReference>;
        equipment = results[4] as List<EquipmentReference>;
        normatives = results[5] as List<NormativeReference>;
        if (!areas.any((item) => item.id == areaId)) {
          areaId = null;
          equipment = [];
        }
        if (!equipment.any((item) => item.id == equipmentId)) {
          equipmentId = null;
          normatives = [];
        }
        if (!normatives.any((item) => item.id == normativeId)) {
          normativeId = null;
        }
        if (!executors.any((item) => item.id == executorId)) executorId = null;
        if (!brigades.any((item) => item.id == brigadeId)) brigadeId = null;
        if (!faultCodes.any((item) => item.id == faultCodeId)) {
          faultCodeId = null;
        }
      });
    } catch (error) {
      if (mounted) showMessage(context, backendError(context, error));
    }
  }

  Future<void> loadInitialData() async {
    setState(() {
      loadingReferences = true;
      pageError = null;
    });

    try {
      final results = await Future.wait([
        widget.api.references.getAreas(),
        widget.api.references.getExecutors(),
        widget.api.references.getFaultCodes(),
        widget.api.references.getBrigades(),
      ]);

      if (!mounted) return;

      areas = results[0] as List<AreaReference>;

      executors = results[1] as List<ExecutorReference>;

      faultCodes = results[2] as List<FaultCodeReference>;
      brigades = results[3] as List<BrigadeReference>;

      if (areas.isNotEmpty) {
        areaId = areas.first.id;
      }

      setState(() {
        loadingReferences = false;
      });

      if (areaId != null) {
        await loadEquipment(areaId!);
      }
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        loadingReferences = false;
        pageError = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        loadingReferences = false;
        pageError = backendError(context, error);
      });
    }
  }

  // MARK: Area / equipment

  Future<void> changeArea(int newAreaId, {int? selectedEquipmentId}) async {
    setState(() {
      areaId = newAreaId;

      equipmentId = null;
      executorId = null;
      normativeId = null;
      faultCodeId = null;

      equipment = [];
      normatives = [];

      recommendedExecutors = [];
      workRecommendation = null;
    });

    await loadEquipment(newAreaId, selectedEquipmentId: selectedEquipmentId);
  }

  Future<void> loadEquipment(
    int selectedAreaId, {
    int? selectedEquipmentId,
  }) async {
    setState(() {
      loadingEquipment = true;
    });

    try {
      final result = await widget.api.references.getEquipment(
        areaId: selectedAreaId,
      );

      if (!mounted || areaId != selectedAreaId) {
        return;
      }

      setState(() {
        equipment = result;

        equipmentId = result.any((item) => item.id == selectedEquipmentId)
            ? selectedEquipmentId
            : (result.isEmpty ? null : result.first.id);

        loadingEquipment = false;
      });

      if (equipmentId != null) {
        await changeEquipment(equipmentId!, force: true);
      }
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        loadingEquipment = false;
      });

      showMessage(context, error.message);
    } catch (error) {
      if (!mounted || areaId != selectedAreaId) return;
      setState(() {
        loadingEquipment = false;
        pageError = backendError(context, error);
      });
    }
  }

  Future<void> changeEquipment(int newEquipmentId, {bool force = false}) async {
    if (!force && equipmentId == newEquipmentId) {
      return;
    }

    setState(() {
      equipmentId = newEquipmentId;

      executorId = null;
      normativeId = null;
      faultCodeId = null;

      normatives = [];
      recommendedExecutors = [];
      workRecommendation = null;

      loadingNormatives = true;
      loadingRecommendations = true;
    });

    try {
      final results = await Future.wait([
        widget.api.references.getNormatives(equipmentId: newEquipmentId),
        widget.api.recommendations.getRecommendedExecutors(
          equipmentId: newEquipmentId,
          description: descriptionController.text,
          faultCodeId: faultCodeId,
        ),
      ]);

      if (!mounted || equipmentId != newEquipmentId) {
        return;
      }

      final loadedNormatives = results[0] as List<NormativeReference>;

      final recommendations = results[1] as List<RecommendedExecutor>;

      setState(() {
        normatives = loadedNormatives;

        recommendedExecutors = recommendations;

        if (loadedNormatives.isNotEmpty) {
          normativeId = loadedNormatives.first.id;
        }

        if (executorId == null) {
          executorId = recommendations
              .where(
                (item) => executors.any(
                  (executor) => executor.id == item.id && executor.isOnShift,
                ),
              )
              .firstOrNull
              ?.id;
        }

        loadingNormatives = false;
        loadingRecommendations = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        loadingNormatives = false;
        loadingRecommendations = false;
      });

      showMessage(context, error.message);
    } catch (error) {
      if (!mounted || equipmentId != newEquipmentId) return;
      setState(() {
        loadingNormatives = false;
        loadingRecommendations = false;
        pageError = backendError(context, error);
      });
    }
  }

  // MARK: AI recommendation

  Future<void> requestWorkRecommendation() async {
    final selectedEquipmentId = equipmentId;

    final description = descriptionController.text.trim();

    if (selectedEquipmentId == null) {
      showMessage(context, 'Сначала выберите оборудование.');
      return;
    }

    if (description.length < 3) {
      showMessage(context, 'Сначала опишите неисправность.');
      return;
    }

    setState(() {
      loadingRecommendations = true;
    });

    try {
      final result = await widget.api.recommendations.getWorkRecommendation(
        description: description,
        equipmentId: selectedEquipmentId,
      );

      if (!mounted || equipmentId != selectedEquipmentId) return;
      setState(() => workRecommendation = result);
      final executorsSuggestion = await widget.api.recommendations
          .getRecommendedExecutors(
            equipmentId: selectedEquipmentId,
            description: description,
            faultCodeId: result.faultCodeId,
          );
      if (!mounted || equipmentId != selectedEquipmentId) return;

      setState(() {
        workRecommendation = result;
        recommendedExecutors = executorsSuggestion;
        loadingRecommendations = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        loadingRecommendations = false;
      });

      showMessage(context, error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        loadingRecommendations = false;
      });
      showMessage(context, backendError(context, error));
    }
  }

  void applyWorkRecommendation() {
    final recommendation = workRecommendation;

    if (recommendation == null) {
      return;
    }

    setState(() {
      final recommendedNormative = recommendation.normativeId;

      if (recommendedNormative != null &&
          normatives.any((item) => item.id == recommendedNormative)) {
        normativeId = recommendedNormative;

        useNormative = true;
      }

      final recommendedFault = recommendation.faultCodeId;

      if (recommendedFault != null &&
          faultCodes.any((item) => item.id == recommendedFault)) {
        faultCodeId = recommendedFault;
      }
    });

    showMessage(context, 'Рекомендация применена.');
  }

  // MARK: Photos

  Future<void> restorePhotos() async {
    try {
      final restored = await photoPicker.takeRecoveredPhotos();

      if (!mounted) return;

      setState(() {
        photos.addAll(restored.take(5 - photos.length));
      });
    } finally {
      if (mounted) {
        setState(() {
          pickingPhotos = false;
        });
      }
    }
  }

  Future<void> addPhotos({required bool camera}) async {
    if (pickingPhotos || photos.length >= 5) {
      return;
    }

    setState(() {
      pickingPhotos = true;
    });

    try {
      final selected = camera
          ? await photoPicker.pickCamera()
          : await photoPicker.pickGallery(5 - photos.length);

      if (!mounted) return;

      setState(() {
        photos.addAll(selected.take(5 - photos.length));
      });
    } on PlatformException catch (error) {
      if (!mounted) return;

      final code = error.code.toLowerCase();

      final denied = code.contains('access') || code.contains('permission');

      showMessage(
        context,
        denied
            ? 'Разрешите доступ к камере или фото в настройках приложения.'
            : 'Не удалось открыть камеру или галерею.',
      );
    } catch (_) {
      if (!mounted) return;

      showMessage(context, 'Не удалось выбрать фотографию.');
    } finally {
      if (mounted) {
        setState(() {
          pickingPhotos = false;
        });
      }
    }
  }

  // MARK: Deadline

  Future<void> selectDeadline() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: deadline,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: uiText(context, 'Срок исполнения'),
      cancelText: uiText(context, 'Отмена'),
      confirmText: uiText(context, 'Выбрать'),
    );

    if (date == null || !mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(deadline),
      helpText: uiText(context, 'Время исполнения'),
      cancelText: uiText(context, 'Отмена'),
      confirmText: uiText(context, 'Выбрать'),
    );

    if (time == null || !mounted) {
      return;
    }

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

  // MARK: Create order

  Future<void> submit() async {
    if (creating || pickingPhotos || loadingReferences || voiceBusy) {
      return;
    }

    if (!formKey.currentState!.validate()) {
      return;
    }

    final selectedAreaId = areaId;
    final selectedEquipmentId = equipmentId;
    final selectedExecutorId = executorId;

    if (selectedAreaId == null) {
      showMessage(context, 'Выберите участок.');
      return;
    }

    if (selectedEquipmentId == null) {
      showMessage(context, 'Выберите оборудование.');
      return;
    }

    if (!assignBrigade && selectedExecutorId == null) {
      showMessage(context, 'Выберите исполнителя.');
      return;
    }

    if (assignBrigade && brigadeId == null) {
      showMessage(
        context,
        backendText(context, 'Выберите бригаду', 'Бригаданы таңдаңыз'),
      );
      return;
    }

    if (useNormative && normativeId == null) {
      showMessage(context, 'Выберите норматив.');
      return;
    }

    if (!useNormative && !deadline.isAfter(DateTime.now())) {
      showMessage(context, 'Выберите срок в будущем.');
      return;
    }

    setState(() {
      creating = true;
    });

    try {
      // Сначала загружаем фотографии.
      //
      // POST /api/uploads не является
      // идемпотентным, поэтому здесь
      // нет автоматического retry.
      final uploadFiles = photos
          .map(
            (photo) =>
                UploadFileInput(bytes: photo.bytes, fileName: photo.name),
          )
          .toList(growable: false);

      final beforePhotoUrls = uploadFiles.isEmpty
          ? <String>[]
          : await widget.api.uploads.uploadPhotoUrls(uploadFiles);
      // Затем создаём сам наряд.
      //
      // POST /api/work-orders также
      // нельзя автоматически повторять.
      await widget.api.workOrders.createWorkOrder(
        CreateWorkOrderInput(
          type: type,
          description: descriptionController.text.trim(),
          areaId: selectedAreaId,
          equipmentId: selectedEquipmentId,
          assigneeId: assignBrigade ? null : selectedExecutorId,
          brigadeId: assignBrigade ? brigadeId : null,
          priority: priority,
          normativeId: useNormative ? normativeId : null,
          deadline: useNormative ? null : deadline.toUtc(),
          comment: commentController.text.trim().isEmpty
              ? null
              : commentController.text.trim(),
          beforePhotoUrls: beforePhotoUrls,
        ),
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on ApiException catch (error) {
      if (!mounted) return;

      showMessage(context, error.message);
    } catch (error) {
      if (!mounted) return;

      showMessage(context, backendError(context, error));
    } finally {
      if (mounted) {
        setState(() {
          creating = false;
        });
      }
    }
  }

  // MARK: Helpers

  ExecutorReference? findExecutor(int id) {
    for (final executor in executors) {
      if (executor.id == id) {
        return executor;
      }
    }

    return null;
  }

  RecommendedExecutor? findRecommendation(int id) {
    for (final executor in recommendedExecutors) {
      if (executor.id == id) {
        return executor;
      }
    }

    return null;
  }

  Color employeeStatusColor(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.available => const Color(0xFF059669),
      EmployeeStatus.busy => const Color(0xFFF59E0B),
      EmployeeStatus.queued => const Color(0xFF2563EB),
      EmployeeStatus.offShift => const Color(0xFF94A3B8),
      EmployeeStatus.unknown => const Color(0xFF94A3B8),
    };
  }

  DropdownMenuItem<int> _brigadeOption(BrigadeReference brigade) {
    final status = brigade.assignmentStatus(executors);
    final label = switch (status) {
      EmployeeStatus.available => uiText(context, 'Свободна'),
      EmployeeStatus.busy || EmployeeStatus.queued => uiText(context, 'Занята'),
      EmployeeStatus.offShift ||
      EmployeeStatus.unknown => uiText(context, status.label),
    };
    return DropdownMenuItem<int>(
      value: brigade.id,
      enabled: status != EmployeeStatus.offShift,
      child: Row(
        children: [
          Icon(Icons.circle, size: 10, color: status.color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  uiText(context, brigade.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: TextStyle(color: status.color, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String employeeStatusLabel(EmployeeStatus status) {
    return switch (status) {
      EmployeeStatus.available => 'Свободен',
      EmployeeStatus.busy => 'В работе',
      EmployeeStatus.queued => 'В очереди',
      EmployeeStatus.offShift => 'Не на смене',
      EmployeeStatus.unknown => 'Неизвестно',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: brand,
          onPrimary: Colors.white,
          secondary: brand,
          onSecondary: Colors.white,
          secondaryContainer: lightBlue,
          onSecondaryContainer: brand,
        ),
        segmentedButtonTheme: SegmentedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? brand : Colors.white,
            ),
            foregroundColor: WidgetStateProperty.resolveWith(
              (states) =>
                  states.contains(WidgetState.selected) ? Colors.white : ink,
            ),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(uiText(context, 'Создание наряда'))),
        bottomNavigationBar: _buildBottomBar(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
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
                  onPressed:
                      creating ||
                          loadingReferences ||
                          pickingPhotos ||
                          voiceBusy
                      ? null
                      : submit,
                  icon: creating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    uiText(context, creating ? 'Создание...' : 'Выдать наряд'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (loadingReferences) {
      return const Center(child: CircularProgressIndicator());
    }

    if (pageError != null) {
      return BackendRefreshView(
        onRefresh: loadInitialData,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 42, color: Colors.red),
              const SizedBox(height: 16),
              Text(pageError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: loadInitialData,
                icon: const Icon(Icons.replay),
                label: Text(uiText(context, 'Повторить')),
              ),
            ],
          ),
        ),
      );
    }

    return BackendRefreshView(
      onRefresh: refreshReferences,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),

                const SizedBox(height: 28),

                _buildDescription(),

                _buildPlace(),

                _buildDeadline(),

                _buildRecommendation(),

                PhotoAttachments(
                  framed: false,
                  title: 'Фото неисправности · до 5',
                  photos: photos,
                  busy: pickingPhotos,
                  onCamera: photoPicker.supportsCamera
                      ? () => addPhotos(camera: true)
                      : null,
                  onGallery: () => addPhotos(camera: false),
                  onRemove: (index) {
                    setState(() {
                      photos.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: lightBlue,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.assignment_outlined, color: brand),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                uiText(context, 'Новый наряд'),
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
                  'Выдача: ${dateLabel(now)} · ${timeLabel(now)}',
                ),
                style: const TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return _OrderFormSection(
      title: 'Описание работ',
      icon: Icons.edit_note_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<WorkOrderType>(
            segments: [
              ButtonSegment(
                value: WorkOrderType.emergency,
                label: Text(uiText(context, 'Аварийный')),
                icon: const Icon(Icons.warning_amber_rounded),
              ),
              ButtonSegment(
                value: WorkOrderType.planned,
                label: Text(uiText(context, 'Плановый')),
                icon: const Icon(Icons.event_available),
              ),
            ],
            selected: {type},
            onSelectionChanged: (value) {
              final selected = value.first;

              setState(() {
                type = selected;

                if (selected == WorkOrderType.emergency) {
                  priority = WorkOrderPriority.emergency;
                } else if (priority == WorkOrderPriority.emergency) {
                  priority = WorkOrderPriority.planned;
                }
              });
              descriptionFocus.requestFocus();
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            key: const ValueKey('order-description'),
            focusNode: descriptionFocus,
            controller: descriptionController,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: uiText(context, 'Проблема и необходимые работы'),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';

              if (text.length < 3) {
                return uiText(context, 'Описание — минимум 3 символа');
              }

              return null;
            },
          ),
          const SizedBox(height: 12),
          VoiceDescriptionButton(
            api: widget.api,
            enabled: !creating,
            onBusyChanged: (busy) => setState(() => voiceBusy = busy),
            onText: (text) {
              descriptionController.text = [
                descriptionController.text.trim(),
                text.trim(),
              ].where((part) => part.isNotEmpty).join(' ');
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: loadingRecommendations
                  ? null
                  : requestWorkRecommendation,
              icon: loadingRecommendations
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(uiText(context, 'Получить AI-рекомендацию')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlace() {
    return _OrderFormSection(
      title: 'Место и исполнитель',
      icon: Icons.location_on_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _selectionCard(
            key: const ValueKey('select-equipment'),
            title: uiText(context, 'Оборудование'),
            placeholder: uiText(context, 'Выберите оборудование'),
            value: equipment
                .where((item) => item.id == equipmentId)
                .firstOrNull,
            label: (item) => uiText(context, item.name),
            details: (item) => [
              areas
                  .where((area) => area.id == item.areaId)
                  .map((area) => uiText(context, area.name))
                  .firstOrNull,
              item.inventoryNumber,
            ].whereType<String>().join(' · '),
            icon: Icons.precision_manufacturing_outlined,
            onTap: creating || loadingEquipment ? null : _selectEquipment,
          ),
          if (loadingEquipment) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(),
          ],

          const SizedBox(height: 16),

          if (loadingRecommendations) const LinearProgressIndicator(),

          if (loadingRecommendations) const SizedBox(height: 16),

          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(uiText(context, 'Исполнитель')),
              ),
              ButtonSegment(
                value: true,
                label: Text(backendText(context, 'Бригада', 'Бригада')),
              ),
            ],
            selected: {assignBrigade},
            onSelectionChanged: creating
                ? null
                : (value) => setState(() => assignBrigade = value.first),
          ),
          const SizedBox(height: 16),
          if (assignBrigade)
            DropdownButtonFormField<int>(
              key: ValueKey('brigade-$brigadeId'),
              initialValue: brigadeId,
              isExpanded: true,
              isDense: false,
              itemHeight: 64,
              decoration: InputDecoration(
                labelText: backendText(context, 'Бригада', 'Бригада'),
              ),
              items: [for (final brigade in brigades) _brigadeOption(brigade)],
              onChanged: creating
                  ? null
                  : (id) => setState(() => brigadeId = id),
              validator: (id) {
                if (id == null) return strings(context).selectBrigade;
                final brigade = brigades
                    .where((item) => item.id == id)
                    .firstOrNull;
                if (brigade == null) return strings(context).selectBrigade;
                if (brigade.assignmentStatus(executors) ==
                    EmployeeStatus.offShift) {
                  return strings(context).brigadeOffShift;
                }
                return null;
              },
            ),
          if (!assignBrigade)
            _selectionCard(
              key: const ValueKey('select-executor'),
              title: uiText(context, 'Исполнитель'),
              placeholder: uiText(context, 'Выберите исполнителя'),
              value: executorId == null ? null : findExecutor(executorId!),
              label: (item) => item.fullName,
              details: (item) => [
                uiText(context, item.statusLabel),
                if (item.currentOrder != null) '№${item.currentOrder!.number}',
                if (item.queue > 0)
                  backendText(
                    context,
                    'В очереди: ${item.queue}',
                    'Кезекте: ${item.queue}',
                  ),
              ].join(' · '),
              icon: Icons.person_outline,
              onTap: creating ? null : _selectExecutor,
            ),
        ],
      ),
    );
  }

  Widget _selectionCard<T extends Object>({
    required Key key,
    required String title,
    required String placeholder,
    required T? value,
    required String Function(T) label,
    required String Function(T) details,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton(
      key: key,
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Row(
        children: [
          Icon(icon, color: brand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: muted)),
                const SizedBox(height: 3),
                Text(
                  value == null ? placeholder : label(value),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (value != null && details(value).isNotEmpty)
                  Text(
                    details(value),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: muted),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.search_rounded, color: brand, size: 20),
        ],
      ),
    );
  }

  Future<T?> _pickOption<T extends Object>({
    required String title,
    required List<T> items,
    required String Function(T) label,
    required String Function(T) details,
    required bool Function(T) enabled,
    required bool Function(T) selected,
    required Widget Function(T) leading,
  }) async {
    String query = '';

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, update) {
            final normalizedQuery = query.trim().toLowerCase();

            final filtered = items.where((item) {
              final haystack = '${label(item)} ${details(item)}'.toLowerCase();

              return haystack.contains(normalizedQuery);
            }).toList();

            final keyboard = MediaQuery.viewInsetsOf(sheetContext).bottom;

            final height = MediaQuery.sizeOf(sheetContext).height - keyboard;

            return Padding(
              padding: EdgeInsets.only(bottom: keyboard),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: height * .7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          autofocus: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search_rounded),
                            hintText: backendText(context, 'Поиск', 'Іздеу'),
                          ),
                          onChanged: (value) {
                            query = value;

                            update(() {});
                          },
                        ),
                      ),

                      const SizedBox(height: 8),

                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                                child: Text(
                                  uiText(
                                    context,
                                    'По вашему запросу ничего не найдено',
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];

                                  return ListTile(
                                    leading: leading(item),
                                    title: Text(label(item)),
                                    subtitle: Text(details(item)),
                                    trailing: selected(item)
                                        ? const Icon(Icons.check, color: brand)
                                        : null,
                                    enabled: enabled(item),
                                    onTap: enabled(item)
                                        ? () {
                                            Navigator.pop(sheetContext, item);
                                          }
                                        : null,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _selectEquipment() async {
    try {
      final items = await widget.api.references.getEquipment();
      if (!mounted) return;
      final selected = await _pickOption<EquipmentReference>(
        title: uiText(context, 'Оборудование'),
        items: items,
        label: (item) => uiText(context, item.name),
        details: (item) => [
          areas
              .where((area) => area.id == item.areaId)
              .map((area) => uiText(context, area.name))
              .firstOrNull,
          item.inventoryNumber,
        ].whereType<String>().join(' · '),
        enabled: (_) => true,
        selected: (item) => item.id == equipmentId,
        leading: (_) => const Icon(Icons.precision_manufacturing_outlined),
      );
      if (!mounted || selected == null || selected.id == equipmentId) return;
      if (selected.areaId == areaId) {
        await changeEquipment(selected.id);
      } else {
        await changeArea(selected.areaId, selectedEquipmentId: selected.id);
      }
    } catch (error) {
      if (mounted) showMessage(context, backendError(context, error));
    }
  }

  Future<void> _selectExecutor() async {
    final recommendedIds = recommendedExecutors.map((item) => item.id).toSet();
    final ordered = [
      ...executors.where((item) => recommendedIds.contains(item.id)),
      ...executors.where((item) => !recommendedIds.contains(item.id)),
    ];
    final selected = await _pickOption<ExecutorReference>(
      title: uiText(context, 'Исполнитель'),
      items: ordered,
      label: (item) => item.fullName,
      details: (item) => [
        if (item.specialty != null) uiText(context, item.specialty!),
        uiText(context, item.statusLabel),
        if (item.currentOrder != null) '№${item.currentOrder!.number}',
        if (item.queue > 0)
          backendText(
            context,
            'В очереди: ${item.queue}',
            'Кезекте: ${item.queue}',
          ),
      ].join(' · '),
      enabled: (item) => item.isOnShift,
      selected: (item) => item.id == executorId,
      leading: (item) => Icon(
        Icons.circle,
        size: 12,
        color: employeeStatusColor(item.employeeStatus),
      ),
    );
    if (mounted && selected != null) setState(() => executorId = selected.id);
  }

  Widget _buildDeadline() {
    return _OrderFormSection(
      title: 'Срок и приоритет',
      icon: Icons.schedule_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<WorkOrderPriority>(
            key: ValueKey('priority-$priority'),
            initialValue: priority,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: uiText(context, 'Приоритет'),
            ),
            items: [
              for (final value in WorkOrderPriority.values)
                DropdownMenuItem(
                  value: value,
                  child: Text(uiText(context, value.label)),
                ),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }

              setState(() {
                priority = value;

                if (value == WorkOrderPriority.emergency) {
                  type = WorkOrderType.emergency;
                }

                if (value == WorkOrderPriority.planned &&
                    type == WorkOrderType.emergency) {
                  type = WorkOrderType.planned;
                }
              });
            },
          ),

          const SizedBox(height: 16),

          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: true,
                label: Text(uiText(context, 'Норматив')),
              ),
              ButtonSegment(
                value: false,
                label: Text(uiText(context, 'Дата и время')),
              ),
            ],
            selected: {useNormative},
            onSelectionChanged: (value) {
              setState(() {
                useNormative = value.first;
              });
            },
          ),

          const SizedBox(height: 16),

          if (useNormative) ...[
            if (loadingNormatives) const LinearProgressIndicator(),

            if (loadingNormatives) const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              key: ValueKey('normative-$equipmentId-$normativeId'),
              initialValue: normativeId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: uiText(context, 'Норматив'),
              ),
              items: [
                for (final normative in normatives)
                  DropdownMenuItem(
                    value: normative.id,
                    child: Text(
                      uiText(
                        context,
                        '${normative.name} · ${normative.hours} ч.',
                      ),
                    ),
                  ),
              ],
              onChanged: loadingNormatives
                  ? null
                  : (value) {
                      setState(() {
                        normativeId = value;
                      });
                    },
              validator: (value) {
                if (!useNormative) {
                  return null;
                }

                return value == null
                    ? uiText(context, 'Выберите норматив')
                    : null;
              },
            ),
          ] else
            OutlinedButton.icon(
              onPressed: selectDeadline,
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(
                uiText(
                  context,
                  '${dateLabel(deadline)} · ${timeLabel(deadline)}',
                ),
              ),
            ),

          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            key: ValueKey('fault-$faultCodeId'),
            initialValue: faultCodeId,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: uiText(context, 'Шифр неисправности (необязательно)'),
            ),
            items: [
              DropdownMenuItem<int>(
                value: null,
                child: Text(uiText(context, 'Не указан')),
              ),
              for (final fault in faultCodes)
                DropdownMenuItem(
                  value: fault.id,
                  child: Text('${fault.code} · ${fault.name}'),
                ),
            ],
            onChanged: (value) {
              setState(() {
                faultCodeId = value;
              });
            },
          ),

          const SizedBox(height: 16),

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
    );
  }

  Widget _buildRecommendation() {
    final recommendation = workRecommendation;

    if (recommendation == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDDD6FE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF7C3AED)),
                SizedBox(width: 10),
                Text(
                  uiText(context, 'AI-рекомендация'),
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ],
            ),

            if (recommendation.explanation != null) ...[
              const SizedBox(height: 12),
              Text(recommendation.explanation!),
            ],

            if (recommendation.estimatedHoursLabel != null) ...[
              const SizedBox(height: 10),
              Text(
                uiText(
                  context,
                  'Оценка времени: ${recommendation.estimatedHoursLabel}',
                ),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: applyWorkRecommendation,
                icon: const Icon(Icons.check),
                label: Text(uiText(context, 'Применить')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - Form section

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
  Widget build(BuildContext context) {
    return Column(
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
}
