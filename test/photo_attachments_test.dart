import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mineral/shared/data/demo_store.dart';
import 'package:mineral/shared/models/models.dart';
import 'package:mineral/features/orders/screens/order_screens.dart';
import 'package:mineral/features/orders/widgets/photo_attachments.dart';
import 'package:mineral/core/services/photo_picker_service.dart';
import 'package:mineral/core/theme/app_theme.dart';

class FakePhotoPicker extends PhotoPickerService {
  FakePhotoPicker(this.photo);
  final OrderPhoto photo;
  bool cancel = false;
  bool deny = false;
  int? galleryLimit;

  @override
  bool get supportsCamera => true;

  @override
  Future<List<OrderPhoto>> takeRecoveredPhotos() async => [];

  @override
  Future<List<OrderPhoto>> pickCamera() async {
    if (deny) throw PlatformException(code: 'camera_access_denied');
    return cancel ? [] : [photo];
  }

  @override
  Future<List<OrderPhoto>> pickGallery(int remaining) async {
    galleryLimit = remaining;
    return cancel ? [] : List.filled(6, photo);
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> choosePhotoSource(WidgetTester tester, String source) async {
  expect(find.text('Камера'), findsNothing);
  expect(find.text('Галерея'), findsNothing);
  await tapVisible(tester, find.text('Прикрепить фото'));
  expect(find.text('Выберите источник фото'), findsOneWidget);
  await tapVisible(tester, find.text(source));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<FakePhotoPicker> picker() async {
    final image = await rootBundle.load('assets/logo_blue.png');
    return FakePhotoPicker(
      OrderPhoto(name: 'test.png', bytes: image.buffer.asUint8List()),
    );
  }

  testWidgets('camera, gallery limit, preview, removal and order attachment', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final fake = await picker();
    final store = DemoStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        key: const ValueKey('create'),
        theme: buildAppTheme(),
        home: const Scaffold(body: Text('Главная')),
        initialRoute: '/create',
        routes: {
          '/create': (_) => CreateOrderScreen(store: store, photoPicker: fake),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Ремонт насоса');
    await tester.enterText(find.byType(TextFormField).at(1), 'Устранить течь');
    await tapVisible(tester, find.byType(DropdownButtonFormField<int>));
    await tester.tap(find.textContaining('Данияр Садыков').last);
    await tester.pumpAndSettle();
    await choosePhotoSource(tester, 'Камера');
    expect(find.text('1/5'), findsOneWidget);
    await choosePhotoSource(tester, 'Галерея');
    expect(fake.galleryLimit, 4);
    expect(find.text('5/5'), findsOneWidget);
    final attachButton = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Прикрепить фото'),
    );
    expect(attachButton.onPressed, isNull);
    await tapVisible(tester, find.byTooltip('Удалить фото 1'));
    expect(find.text('4/5'), findsOneWidget);
    await tapVisible(tester, find.byType(Image).first);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Выдать наряд'));
    expect(store.orders.first.title, 'Ремонт насоса');
    expect(store.orders.first.beforeImages, hasLength(4));
    expect(store.orders.first.beforePhotos, 4);
    expect(store.orders.first.beforeImages.first.bytes, fake.photo.bytes);
    await tester.pumpWidget(
      MaterialApp(
        key: const ValueKey('detail'),
        theme: buildAppTheme(),
        home: OrderDetailScreen(store: store, order: store.orders.first),
      ),
    );
    await tester.pumpAndSettle();
    final attachments = tester
        .widgetList<PhotoAttachments>(find.byType(PhotoAttachments))
        .toList();
    expect(attachments.first.photos, hasLength(4));
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancel and denied permission leave photo list unchanged', (
    tester,
  ) async {
    addTearDown(() async => tester.pumpWidget(const SizedBox.shrink()));
    final fake = await picker();
    fake.cancel = true;
    final store = DemoStore();
    addTearDown(store.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: CreateOrderScreen(store: store, photoPicker: fake),
      ),
    );
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Прикрепить фото'));
    await tapVisible(tester, find.text('Отмена'));
    expect(find.text('0/5'), findsOneWidget);
    await choosePhotoSource(tester, 'Камера');
    expect(find.text('0/5'), findsOneWidget);
    fake.cancel = false;
    fake.deny = true;
    await choosePhotoSource(tester, 'Камера');
    expect(find.text('0/5'), findsOneWidget);
    expect(find.textContaining('Разрешите доступ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
