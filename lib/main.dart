import 'package:flutter/material.dart';
import 'package:hidden_calculator/constants/app_theme.dart';
import 'package:hidden_calculator/screens/auth_screen.dart';
import 'package:hidden_calculator/screens/vault_screen.dart';
import 'package:hidden_calculator/services/auth_service.dart';
import 'package:hidden_calculator/services/vault_service.dart';
import 'package:hidden_calculator/widgets/calculator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  final vaultService = VaultService();
  
  await vaultService.initialize();
  
  runApp(MyApp(
    authService: authService,
    vaultService: vaultService,
  ));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final VaultService vaultService;
  
  const MyApp({
    Key? key,
    required this.authService,
    required this.vaultService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final AuthService _authService = AuthService();
  bool _showVault = false;
  bool _needsSetup = false;
  
  @override
  void initState() {
    super.initState();
    _checkSetup();
  }
  
  Future<void> _checkSetup() async {
    final isPasscodeSet = await _authService.isPasscodeSet();
    if (!isPasscodeSet) {
      setState(() {
        _needsSetup = true;
      });
    }
  }
  
  void _onSetupComplete() {
    setState(() {
      _needsSetup = false;
    });
  }
  
  void _onUnlockVault() {
    setState(() {
      _showVault = true;
    });
  }
  
  void _onSpecialCodeEntered(String code) async {
    final isValid = await _authService.verifySpecialPasscode(code);
    if (isValid) {
      setState(() {
        _showVault = true;
      });
    }
  }
  
  void _onVaultExit() {
    setState(() {
      _showVault = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_needsSetup) {
      return AuthScreen(
        isSetup: true,
        onAuthSuccess: _onSetupComplete,
      );
    }
    
    if (_showVault) {
      return WillPopScope(
        onWillPop: () async {
          _onVaultExit();
          return false;
        },
        child: Scaffold(
          body: const VaultScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: _onVaultExit,
            heroTag: 'exitVault',
            backgroundColor: Colors.red,
            child: const Icon(Icons.exit_to_app),
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Calculator(
            onSpecialCodeEntered: _onSpecialCodeEntered,
          ),
        ),
      ),
    );
  }
}
