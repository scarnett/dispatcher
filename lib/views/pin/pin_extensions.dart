import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/date_utils.dart';

extension UserPINExtension on UserPIN {
  /// Checks to see if a pin verification code is expired
  bool isExpired() {
    if ((this != null) && (this.verificationExpireDate != null)) {
      final DateTime now = getNow();
      if (now.isAfter(this.verificationExpireDate)) {
        return true;
      }
    }

    return false;
  }
}
