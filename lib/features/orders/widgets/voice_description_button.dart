import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:record/record.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_services.dart';
import '../../../shared/widgets/backend_section.dart';
import '../../../shared/widgets/ui.dart';

Uint8List voiceWav(Uint8List pcm) {
  final result = Uint8List(44 + pcm.length);
  final header = ByteData.sublistView(result);
  void text(int offset, String value) =>
      result.setRange(offset, offset + value.length, value.codeUnits);
  text(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  text(8, 'WAVE');
  text(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, 1, Endian.little);
  header.setUint32(24, 16000, Endian.little);
  header.setUint32(28, 32000, Endian.little);
  header.setUint16(32, 2, Endian.little);
  header.setUint16(34, 16, Endian.little);
  text(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  result.setRange(44, result.length, pcm);
  return result;
}

Future<String> transcribeVoice(ApiServices api, Uint8List audio) async {
  if (audio.length > 25 * 1024 * 1024) {
    throw const ApiException(
      statusCode: 413,
      message: 'Аудио должно быть не больше 25 МБ',
    );
  }
  final request =
      http.MultipartRequest(
          'POST',
          Uri.parse('${api.baseUrl}/api/ai/transcribe'),
        )
        ..files.add(
          http.MultipartFile.fromBytes(
            'audio',
            audio,
            filename: 'description.wav',
            contentType: MediaType('audio', 'wav'),
          ),
        );
  final response = await api.client.sendMultipart(request);
  final text = (response.data as Map)['text'];
  if (text is! String || text.trim().isEmpty) {
    throw const ApiException(
      statusCode: 422,
      message: 'Речь не распознана. Повторите запись или введите текст.',
    );
  }
  return text;
}

class VoiceDescriptionButton extends StatefulWidget {
  const VoiceDescriptionButton({
    super.key,
    required this.api,
    required this.onText,
    this.enabled = true,
    this.onBusyChanged,
  });
  final ApiServices api;
  final ValueChanged<String> onText;
  final bool enabled;
  final ValueChanged<bool>? onBusyChanged;
  @override
  State<VoiceDescriptionButton> createState() => _VoiceDescriptionButtonState();
}

class _VoiceDescriptionButtonState extends State<VoiceDescriptionButton> {
  AudioRecorder? recorder;
  StreamSubscription<Uint8List>? subscription;
  Timer? timer;
  BytesBuilder audio = BytesBuilder(copy: false);
  bool recording = false, busy = false;
  @override
  void dispose() {
    timer?.cancel();
    subscription?.cancel();
    recorder?.dispose();
    super.dispose();
  }

  Future<void> toggle() async {
    if (busy) return;
    widget.onBusyChanged?.call(true);
    setState(() => busy = true);
    try {
      if (!recording) {
        recorder ??= AudioRecorder();
        if (!await recorder!.hasPermission()) {
          if (mounted) {
            showMessage(
              context,
              backendText(
                context,
                'Разрешите доступ к микрофону или введите текст.',
                'Микрофонға рұқсат беріңіз немесе мәтін енгізіңіз.',
              ),
            );
          }
          return;
        }
        audio = BytesBuilder(copy: false);
        final stream = await recorder!.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: 16000,
            numChannels: 1,
          ),
        );
        if (!mounted) {
          await recorder!.stop();
          return;
        }
        subscription = stream.listen(
          audio.add,
          onError: (Object error) {
            unawaited(cancelRecording(error));
          },
        );
        setState(() => recording = true);
        // Keep the request below the documented 25 MB limit.
        timer = Timer(const Duration(minutes: 5), () => unawaited(toggle()));
      } else {
        timer?.cancel();
        await recorder!.stop();
        await subscription?.cancel();
        subscription = null;
        if (!mounted) return;
        setState(() => recording = false);
        final text = await transcribeVoice(
          widget.api,
          voiceWav(audio.takeBytes()),
        );
        if (mounted) widget.onText(text);
      }
    } catch (error) {
      await recorder?.cancel();
      if (mounted) {
        setState(() => recording = false);
        showMessage(
          context,
          error is ApiException
              ? '${error.message} ${backendText(context, 'Можно повторить запись или ввести текст.', 'Қайта жазуға немесе мәтін енгізуге болады.')}'
              : backendText(
                  context,
                  'Не удалось записать голос. Можно ввести текст.',
                  'Дауыс жазылмады. Мәтін енгізуге болады.',
                ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
        widget.onBusyChanged?.call(recording);
      }
    }
  }

  Future<void> cancelRecording(Object error) async {
    timer?.cancel();
    await recorder?.cancel();
    await subscription?.cancel();
    if (mounted) {
      widget.onBusyChanged?.call(false);
      setState(() {
        recording = false;
        busy = false;
      });
      showMessage(
        context,
        backendText(
          context,
          'Запись прервана. Повторите или введите текст.',
          'Жазу үзілді. Қайталаңыз немесе мәтін енгізіңіз.',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: OutlinedButton.icon(
      onPressed: busy || !widget.enabled ? null : toggle,
      icon: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(recording ? Icons.stop : Icons.mic_none),
      label: Text(
        backendText(
          context,
          busy
              ? 'Обработка голоса…'
              : recording
              ? 'Остановить и распознать'
              : 'Голосовое описание',
          busy
              ? 'Дауыс өңделуде…'
              : recording
              ? 'Тоқтату және тану'
              : 'Дауыспен сипаттау',
        ),
      ),
    ),
  );
}
