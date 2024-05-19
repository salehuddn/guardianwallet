import 'package:local_auth/local_auth.dart';

class BiometricAuth {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    bool isAuthenticated = false;

    if (canCheckBiometrics) {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to access your wallet',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    }

    return isAuthenticated;
  }
}
