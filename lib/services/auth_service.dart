import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  static const String _passcodeKey = 'calculator_passcode';
  static const String _useBiometricsKey = 'use_biometrics';
  static const String _specialPasscodeKey = 'special_passcode';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  Future<bool> isPasscodeSet() async {
    final storedPasscode = await _secureStorage.read(key: _passcodeKey);
    return storedPasscode != null;
  }
  
  Future<bool> setPasscode(String passcode) async {
    try {
      // Hash the passcode before storing it
      final hashedPasscode = _hashPasscode(passcode);
      await _secureStorage.write(key: _passcodeKey, value: hashedPasscode);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> verifyPasscode(String passcode) async {
    try {
      final storedPasscode = await _secureStorage.read(key: _passcodeKey);
      if (storedPasscode == null) return false;
      
      final hashedInput = _hashPasscode(passcode);
      return hashedInput == storedPasscode;
    } catch (e) {
      return false;
    }
  }
  
  String _hashPasscode(String passcode) {
    final bytes = utf8.encode(passcode); 
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  Future<bool> setSpecialPasscode(String passcode) async {
    try {
      // Hash the special passcode before storing it
      final hashedPasscode = _hashPasscode(passcode);
      await _secureStorage.write(key: _specialPasscodeKey, value: hashedPasscode);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isSpecialPasscodeSet() async {
    final storedPasscode = await _secureStorage.read(key: _specialPasscodeKey);
    return storedPasscode != null;
  }
  
  Future<bool> verifySpecialPasscode(String passcode) async {
    try {
      final storedPasscode = await _secureStorage.read(key: _specialPasscodeKey);
      if (storedPasscode == null) return false;
      
      final hashedInput = _hashPasscode(passcode);
      return hashedInput == storedPasscode;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _useBiometricsKey, value: enabled.toString());
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _useBiometricsKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics && 
             await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the hidden vault',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable || 
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // Handle specific biometric errors
        return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> deleteAllData() async {
    await _secureStorage.deleteAll();
  }
} 