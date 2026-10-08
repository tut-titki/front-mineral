# MASTER: backend integration

Current contract audit and remaining gaps: [master_contract_audit.md](master_contract_audit.md).

## Dependencies

`MainApp` keeps the existing `AuthSession` and synchronizes its token with
`ApiServices`. `MasterShell(api: api)` passes that service to Dashboard, Orders,
Team, AI, Reports and Notifications. Creation and detail routes use the same API.
No master screen receives `DemoStore` or the legacy `WorkOrder`.

`DemoStore`, legacy widgets and report snapshots remain for executor/demo code
and its tests. They are not used by the master routes.

`ApiServices` owns one `ApiClient`. Work orders, references, recommendations,
uploads, analytics, assistant, notifications and reports reuse it. Uploads send
their multipart request through that client's HTTP connection. Export requests
return bytes without JSON/UTF-8 decoding.

## Behavior

- Dashboard loads dashboard metrics, attention orders, executors, forecast and
  anomalies independently. A failed section displays an error and retry, without
  synthetic numbers. Sections have manual refresh.
- Orders preserve search, filters and kanban. Lists fetch all pages, using the
  documented limit/offset parameters. Detail routes take the backend order ID.
- Team loads executors and brigades, supports search and availability filtering,
  and opens a real brigade roster. Availability and assigned-order counts come
  from the existing `ExecutorReference` model.
- AI shows overdue/review orders and anomalies. Chat validates 2–1000 characters,
  disables duplicate sends, retains text on failure, and reloads history after
  successful sends.
- Notifications keep string types, including unfamiliar and dynamic overdue
  types. Reading invokes PATCH, then reloads the list. Clicking an associated
  notification opens its order even if marking it read fails.
- Reports request shift, ratings, brigade ratings, materials and downtime.
  PDF/XLSX exports use the authenticated client and the platform save dialog.
  Order detail also opens `/api/reports/work-order/:id`.
- Actions keep existing backend status guards. Mutation responses are followed
  by a full GET. Creating an order or returning from detail refreshes master data.
- Signed photo URLs keep their query string and receive no Authorization header.
  HTTP 401 schedules a full order GET to obtain new URLs. A URL is refreshed once
  automatically to prevent loops; manual refresh remains available. Uploads are
  never retried automatically.

## Realtime

`MasterRealtimeService` owns one Socket.IO connection with websocket transport
and `auth: {token: bearerToken}`. Token changes dispose the previous connection;
force-new connections avoid reusing cached authentication. Logout disposes the
authenticated connection. Both `work-order:changed` and `notification:new`
invalidate REST data. Every connect, including reconnect, invalidates REST data
because the server does not replay missed events. REST and manual refresh work
independently of socket connectivity. Screen subscriptions are cancelled on
dispose, and overlapping loads ignore superseded responses.

Dependencies: [socket_io_client](https://pub.dev/packages/socket_io_client),
[file_saver 0.4.0](https://pub.dev/packages/file_saver/versions/0.4.0).
The latter is compatible with this project's Dart 3.11 SDK.

## Contract boundaries

The current supplied contract documents report schemas and shared filters:
period, from/to, areaId, equipmentId, executorId and brigadeId. The report views
and exports send the same filters; ratings use server-provided scores,
components and explanations. Dynamic nested responses are rendered through
JSON documents. See the current audit for missing optional views and features.

## Validation

Initial migration validation: `flutter analyze` reported no issues; all 75 tests passed.
`dart format` was applied to the changed files and `git diff --check` passes.
`flutter build web --no-pub` cannot run because this existing project has no web
platform configuration. No platforms were generated as part of this migration.
HTTP fixtures are confined to tests. Tests cover status guards, full GET after
closing, pagination, API errors/retry, chat sending, unknown notification types,
signed-photo refresh, binary exports, multipart uploads without retry, mobile
navigation, brigade rosters, report periods, photo attachment limits and ru/kk
localization at mobile/desktop widths.

The initial analyzer had 54 issues, including broken shell constructors,
undefined master screens, legacy test constructors, nullability warnings and
deprecated Radio properties. The migration addresses those integration issues;
authentication and executor behavior are covered by the existing suite.

## Files created during this migration

- `lib/core/api/backend_document.dart`
- `lib/core/services/master_realtime_service.dart`
- `lib/features/analytics/data/analytics_api.dart`
- `lib/features/assistant/data/assistant_api.dart`
- `lib/features/assistant/screens/ai_screen.dart`
- `lib/features/notifications/data/notifications_api.dart`
- `lib/features/notifications/screens/notifications_screen.dart`
- `lib/features/orders/screens/orders_screen.dart` (existing backend list moved
  out of the incorrectly named dashboard file)
- `lib/features/reports/data/reports_api.dart`
- `lib/features/team/screens/team_screen.dart`
- `lib/l10n/backend_ui_labels.dart`
- `lib/shared/widgets/backend_section.dart`
- `test/helpers/backend_api_fixture.dart`
- `test/master_backend_test.dart`
- `docs/master_backend.md`

## Existing files updated during this migration

- `lib/app/app.dart`
- `lib/core/api/api_client.dart`
- `lib/core/api/api_services.dart`
- `lib/features/master/screens/dashboard_screen.dart`
- `lib/features/master/screens/master_shell.dart`
- `lib/features/orders/data/references_api.dart` (existing lint fixes)
- `lib/features/orders/data/uploads_api.dart`
- `lib/features/orders/data/work_orders_api.dart`
- `lib/features/orders/screens/order_detail_screen.dart`
- `lib/features/orders/screens/order_screens.dart`
- `lib/features/reports/screens/reports_screen.dart`
- `lib/l10n/ui_localization.dart`
- `pubspec.yaml`, `pubspec.lock`
- `test/brigades_and_order_edit_test.dart`
- `test/master_localization_test.dart`
- `test/order_filters_test.dart`
- `test/photo_attachments_test.dart`
- `test/reports_period_test.dart`

Some API and order-detail files were already untracked when this task started.
They are listed as existing files here because the migration extends that work.
The pre-existing change to `auth_session.dart` was left intact.
