import 'package:flutter/material.dart';
import 'package:hidden_calculator/constants/app_constants.dart';
import 'package:hidden_calculator/services/auth_service.dart';
import 'package:lottie/lottie.dart';
import 'package:local_auth/local_auth.dart';

class AuthScreen extends StatefulWidget {
  final bool isSetup;
  final VoidCallback onAuthSuccess;
  
  const AuthScreen({
    Key? key,
    this.isSetup = false,
    required this.onAuthSuccess,
  }) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _passcodeController = TextEditingController();
  final _confirmPasscodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _useBiometrics = false;
  bool _showConfirmPasscode = false;
  String _errorMessage = '';
  
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _checkBiometrics();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _passcodeController.dispose();
    _confirmPasscodeController.dispose();
    super.dispose();
  }
  
  Future<void> _checkBiometrics() async {
    if (!widget.isSetup) {
      final canUseBiometrics = await _authService.canUseBiometrics();
      final biometricsEnabled = await _authService.isBiometricEnabled();
      
      if (canUseBiometrics && biometricsEnabled) {
        setState(() {
          _useBiometrics = true;
        });
        
        // Auto-trigger biometric auth
        _authenticateWithBiometrics();
      }
    }
  }
  
  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    final success = await _authService.authenticateWithBiometrics();
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      widget.onAuthSuccess();
    } else {
      setState(() {
        _errorMessage = 'Biometric authentication failed';
      });
    }
  }
  
  Future<void> _verifyPasscode() async {
    if (_passcodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a passcode';
      });
      return;
    }
    
    if (widget.isSetup) {
      if (_showConfirmPasscode) {
        if (_passcodeController.text != _confirmPasscodeController.text) {
          setState(() {
            _errorMessage = 'Passcodes do not match';
          });
          return;
        }
        
        setState(() {
          _isLoading = true;
          _errorMessage = '';
        });
        
        final success = await _authService.setPasscode(_passcodeController.text);
        
        setState(() {
          _isLoading = false;
        });
        
        if (success) {
          // Set the same passcode as special passcode for now
          await _authService.setSpecialPasscode(_passcodeController.text);
          widget.onAuthSuccess();
        } else {
          setState(() {
            _errorMessage = 'Failed to set passcode';
          });
        }
      } else {
        setState(() {
          _showConfirmPasscode = true;
          _errorMessage = '';
        });
      }
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final success = await _authService.verifyPasscode(_passcodeController.text);
      
      setState(() {
        _isLoading = false;
      });
      
      if (success) {
        widget.onAuthSuccess();
      } else {
        setState(() {
          _errorMessage = 'Invalid passcode';
          _passcodeController.clear();
        });
      }
    }
  }
  
  Future<void> _toggleBiometrics() async {
    final canUseBiometrics = await _authService.canUseBiometrics();
    
    if (canUseBiometrics) {
      final biometricsEnabled = await _authService.isBiometricEnabled();
      await _authService.setBiometricEnabled(!biometricsEnabled);
      
      setState(() {
        _useBiometrics = !biometricsEnabled;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication is not available on this device')),
      );
    }
  }
  
  Widget _buildPasscodeInput() {
    return Column(
      children: [
        TextField(
          controller: _passcodeController,
          decoration: InputDecoration(
            labelText: 'Enter Passcode',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
        ),
        if (_showConfirmPasscode) ...[
          const SizedBox(height: AppDimensions.paddingLarge),
          TextField(
            controller: _confirmPasscodeController,
            decoration: InputDecoration(
              labelText: 'Confirm Passcode',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              prefixIcon: const Icon(Icons.lock_outline),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyPasscode(),
          ),
        ],
      ],
    );
  }
  
  Widget _buildButton(String text, VoidCallback onPressed) {
    return AnimatedBuilder(
      animation: _buttonScaleAnimation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            _animationController.forward().then((_) {
              _animationController.reverse();
            });
            onPressed();
          },
          child: Transform.scale(
            scale: _buttonScaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingMedium,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                AppAnimations.lockAnimation,
                width: 200,
                height: 200,
              ),
              const SizedBox(height: AppDimensions.paddingLarge),
              Text(
                widget.isSetup ? 'Set Up Vault Passcode' : 'Enter Vault Passcode',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingMedium),
              Text(
                widget.isSetup
                    ? 'Create a passcode to access your hidden vault\nYou will enter this on the calculator to unlock the vault'
                    : 'Enter your passcode to access the vault',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.paddingLarge * 2),
              _buildPasscodeInput(),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.paddingMedium),
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const SizedBox(height: AppDimensions.paddingLarge),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _buildButton(
                      widget.isSetup
                          ? _showConfirmPasscode
                              ? 'Set Passcode'
                              : 'Continue'
                          : 'Unlock',
                      _verifyPasscode,
                    ),
              if (!widget.isSetup) ...[
                const SizedBox(height: AppDimensions.paddingLarge),
                FutureBuilder<bool>(
                  future: _authService.canUseBiometrics(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Use Biometrics'),
                              const SizedBox(width: AppDimensions.paddingMedium),
                              Switch(
                                value: _useBiometrics,
                                onChanged: (_) => _toggleBiometrics(),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                          if (_useBiometrics) ...[
                            const SizedBox(height: AppDimensions.paddingMedium),
                            IconButton(
                              icon: const Icon(Icons.fingerprint),
                              onPressed: _authenticateWithBiometrics,
                              iconSize: 40,
                              color: AppColors.primary,
                            ),
                          ],
                        ],
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 