import 'package:flutter/material.dart';
import '../../../core/api/api_services.dart';
import '../../../shared/widgets/backend_section.dart';
import '../data/references_api.dart';
import '../../../l10n/ui_localization.dart';

/// The same reference filters apply to the master's list and reports.
class MasterScopeFilters extends StatelessWidget {
  const MasterScopeFilters({
    super.key,
    required this.api,
    required this.value,
    required this.onChanged,
  });
  final ApiServices api;
  final Map<String, int> value;
  final ValueChanged<Map<String, int>> onChanged;
  Future<List<Object>> _load() async => Future.wait<Object>([
    api.references.getAreas(),
    api.references.getEquipment(),
    api.references.getExecutors(),
    api.references.getBrigades(),
  ]);
  @override
  Widget build(BuildContext context) => BackendSection<List<Object>>(
    load: _load,
    builder: (context, data) {
      final areas = data[0] as List<AreaReference>;
      final equipment = (data[1] as List<EquipmentReference>).where(
        (e) => value['areaId'] == null || e.areaId == value['areaId'],
      );
      final executors = data[2] as List<ExecutorReference>;
      final brigades = data[3] as List<BrigadeReference>;
      Widget field(
        String key,
        String ru,
        String kk,
        Iterable<(int, String)> items,
      ) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<int>(
          key: ValueKey('scope-$key-${value[key]}'),
          initialValue: value[key],
          isExpanded: true,
          decoration: InputDecoration(labelText: backendText(context, ru, kk)),
          items: [
            DropdownMenuItem<int>(
              value: null,
              child: Text(backendText(context, 'Все', 'Барлығы')),
            ),
            for (final item in items)
              DropdownMenuItem(
                value: item.$1,
                child: Text(
                  uiText(context, item.$2),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (id) {
            final next = Map<String, int>.from(value);
            if (id == null) {
              next.remove(key);
            } else {
              next[key] = id;
            }
            if (key == 'areaId') next.remove('equipmentId');
            onChanged(next);
          },
        ),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          field(
            'areaId',
            'Участок',
            'Учаске',
            areas.map((e) => (e.id, e.name)),
          ),
          field(
            'equipmentId',
            'Оборудование',
            'Жабдық',
            equipment.map((e) => (e.id, e.name)),
          ),
          field(
            'executorId',
            'Исполнитель',
            'Орындаушы',
            executors.map((e) => (e.id, e.fullName)),
          ),
          field(
            'brigadeId',
            'Бригада',
            'Бригада',
            brigades.map((e) => (e.id, e.name)),
          ),
        ],
      );
    },
  );
}
