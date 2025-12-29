import 'package:logger/logger.dart';

/// Remote logging stub - ready for Firebase Crashlytics integration
class RemoteLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    // TODO: Implement remote logging (Firebase Crashlytics)
    // For now, this is a stub that does nothing
    // When ready, uncomment and implement:
    // for (var line in event.lines) {
    //   FirebaseCrashlytics.instance.log(line);
    // }
    // if (event.level == Level.error || event.level == Level.fatal) {
    //   FirebaseCrashlytics.instance.recordError(
    //     event.origin.error,
    //     event.origin.stackTrace,
    //   );
    // }
  }
}
