import 'package:flutter/material.dart';
import 'package:hidden_calculator/constants/app_constants.dart';
import 'package:hidden_calculator/services/auth_service.dart';

class Calculator extends StatefulWidget {
  final Function(String) onSpecialCodeEntered;
  
  const Calculator({
    Key? key,
    required this.onSpecialCodeEntered,
  }) : super(key: key);

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> with SingleTickerProviderStateMixin {
  String _input = '0';
  String _result = '';
  String _operation = '';
  double _firstOperand = 0;
  bool _shouldReplaceInput = false;
  String _secretCode = '';
  
  final AuthService _authService = AuthService();
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
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _checkSecretCode(String digit) {
    _secretCode += digit;
    
    // Keep only the last 6 digits for checking
    if (_secretCode.length > 6) {
      _secretCode = _secretCode.substring(_secretCode.length - 6);
    }
    
    _checkForSpecialPasscode();
  }
  
  Future<void> _checkForSpecialPasscode() async {
    if (_secretCode.length < 4) return;
    
    if (await _authService.verifySpecialPasscode(_secretCode)) {
      widget.onSpecialCodeEntered(_secretCode);
    }
  }
  
  void _appendDigit(String digit) {
    _checkSecretCode(digit);
    
    if (_shouldReplaceInput) {
      setState(() {
        _input = digit;
        _shouldReplaceInput = false;
      });
      return;
    }
    
    setState(() {
      if (_input == '0') {
        _input = digit;
      } else {
        _input += digit;
      }
    });
  }
  
  void _appendDecimal() {
    if (_shouldReplaceInput) {
      setState(() {
        _input = '0.';
        _shouldReplaceInput = false;
      });
      return;
    }
    
    setState(() {
      if (!_input.contains('.')) {
        _input += '.';
      }
    });
  }
  
  void _toggleSign() {
    setState(() {
      if (_input.startsWith('-')) {
        _input = _input.substring(1);
      } else {
        _input = '-$_input';
      }
    });
  }
  
  void _calculatePercentage() {
    setState(() {
      final double value = double.tryParse(_input) ?? 0;
      _input = (value / 100).toString();
      // Remove trailing zeros
      if (_input.contains('.')) {
        _input = _input.replaceAll(RegExp(r'\.0+$'), '');
        _input = _input.replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');
      }
    });
  }
  
  void _clear() {
    setState(() {
      _input = '0';
      _result = '';
      _operation = '';
      _firstOperand = 0;
    });
  }
  
  void _setOperation(String operation) {
    double inputValue = double.tryParse(_input) ?? 0;
    
    if (_operation.isEmpty) {
      // First operation
      _firstOperand = inputValue;
      _result = _input;
    } else {
      // Chain operations
      _performCalculation(inputValue);
      _firstOperand = double.tryParse(_result) ?? 0;
    }
    
    setState(() {
      _operation = operation;
      _shouldReplaceInput = true;
    });
  }
  
  void _performCalculation(double secondOperand) {
    double result = 0;
    
    switch (_operation) {
      case AppStrings.add:
        result = _firstOperand + secondOperand;
        break;
      case AppStrings.subtract:
        result = _firstOperand - secondOperand;
        break;
      case AppStrings.multiply:
        result = _firstOperand * secondOperand;
        break;
      case AppStrings.divide:
        if (secondOperand != 0) {
          result = _firstOperand / secondOperand;
        } else {
          // Handle division by zero
          setState(() {
            _result = 'Error';
            return;
          });
        }
        break;
    }
    
    String resultString = result.toString();
    // Remove trailing zeros
    if (resultString.contains('.')) {
      resultString = resultString.replaceAll(RegExp(r'\.0+$'), '');
      resultString = resultString.replaceAll(RegExp(r'(\.\d*?)0+$'), r'$1');
    }
    
    setState(() {
      _result = resultString;
    });
  }
  
  void _calculateResult() {
    if (_operation.isEmpty) return;
    
    final double secondOperand = double.tryParse(_input) ?? 0;
    _performCalculation(secondOperand);
    
    setState(() {
      _input = _result;
      _operation = '';
      _firstOperand = 0;
      _shouldReplaceInput = true;
    });
    
    // Check if the result is a special code
    _checkSecretCode('=');
  }
  
  Widget _buildButton(
    String text, 
    VoidCallback onPressed, {
    Color backgroundColor = AppColors.numberButton,
    Color textColor = Colors.white,
    bool isWide = false,
  }) {
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
              width: isWide ? AppDimensions.calculatorButtonSize * 2 + AppDimensions.calculatorButtonPadding : AppDimensions.calculatorButtonSize,
              height: AppDimensions.calculatorButtonSize,
              margin: const EdgeInsets.all(AppDimensions.calculatorButtonPadding / 2),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 28,
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
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.calculatorBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingLarge,
              vertical: AppDimensions.paddingMedium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _result,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _input,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                AppStrings.clear,
                _clear,
                backgroundColor: AppColors.functionButton,
              ),
              _buildButton(
                AppStrings.plusMinus,
                _toggleSign,
                backgroundColor: AppColors.functionButton,
              ),
              _buildButton(
                AppStrings.percent,
                _calculatePercentage,
                backgroundColor: AppColors.functionButton,
              ),
              _buildButton(
                AppStrings.divide,
                () => _setOperation(AppStrings.divide),
                backgroundColor: AppColors.operatorButton,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('7', () => _appendDigit('7')),
              _buildButton('8', () => _appendDigit('8')),
              _buildButton('9', () => _appendDigit('9')),
              _buildButton(
                AppStrings.multiply,
                () => _setOperation(AppStrings.multiply),
                backgroundColor: AppColors.operatorButton,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('4', () => _appendDigit('4')),
              _buildButton('5', () => _appendDigit('5')),
              _buildButton('6', () => _appendDigit('6')),
              _buildButton(
                AppStrings.subtract,
                () => _setOperation(AppStrings.subtract),
                backgroundColor: AppColors.operatorButton,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton('1', () => _appendDigit('1')),
              _buildButton('2', () => _appendDigit('2')),
              _buildButton('3', () => _appendDigit('3')),
              _buildButton(
                AppStrings.add,
                () => _setOperation(AppStrings.add),
                backgroundColor: AppColors.operatorButton,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildButton(
                '0',
                () => _appendDigit('0'),
                isWide: true,
              ),
              _buildButton(
                AppStrings.decimal,
                _appendDecimal,
              ),
              _buildButton(
                AppStrings.equals,
                _calculateResult,
                backgroundColor: AppColors.operatorButton,
              ),
            ],
          ),
        ],
      ),
    );
  }
} 