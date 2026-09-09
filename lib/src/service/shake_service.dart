import 'sensor_service.dart';

class ShakeService {
  final PhoneShakeCallback onPhoneShake;

  ShakeService({required this.onPhoneShake});

  ShakeDetector? shakeDetector;

  void start() {
    shakeDetector = ShakeDetector.autoStart(onPhoneShake: onPhoneShake);
  }

  void stop() {
    shakeDetector?.stopListening();
  }
}
