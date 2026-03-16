import 'dart:math';

class CalculatorLogic {
  String _expression = '';
  String _display = '0';
  String _result = '';
  bool _justEvaluated = false;

  String get display => _display;
  String get expression => _expression;
  String get result => _result;

  void input(String value) {
    if (_justEvaluated) {
      if ('0123456789.'.contains(value)) {
        _expression = '';
        _display = '';
      } else {
        _expression = _result;
        _display = _result;
      }
      _justEvaluated = false;
    }

    if (value == 'C') {
      _expression = '';
      _display = '0';
      _result = '';
      return;
    }

    if (value == '⌫') {
      if (_display.isNotEmpty && _display != '0') {
        _display = _display.length == 1 ? '0' : _display.substring(0, _display.length - 1);
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      }
      return;
    }

    if (value == '=') {
      _evaluate();
      return;
    }

    if (['sin', 'cos', 'tan', 'log', 'ln', '√', 'x²', 'π', 'e'].contains(value)) {
      _applyScientific(value);
      return;
    }

    if (value == '%') {
      _applyPercent();
      return;
    }

    if (value == '+/-') {
      _toggleSign();
      return;
    }

    if (value == '.') {
      final parts = _display.split(RegExp(r'[\+\-\×\÷]'));
      if (parts.last.contains('.')) return;
    }

    _display += value;
    _expression += value;
  }

  void _applyScientific(String func) {
    double? current = double.tryParse(_display.replaceAll(',', ''));
    if (current == null) return;

    double res;
    String label;
    switch (func) {
      case 'sin': res = sin(current * pi / 180); label = 'sin($current)'; break;
      case 'cos': res = cos(current * pi / 180); label = 'cos($current)'; break;
      case 'tan': res = tan(current * pi / 180); label = 'tan($current)'; break;
      case 'log': if (current <= 0) return; res = log(current) / ln10; label = 'log($current)'; break;
      case 'ln': if (current <= 0) return; res = log(current); label = 'ln($current)'; break;
      case '√': if (current < 0) return; res = sqrt(current); label = '√($current)'; break;
      case 'x²': res = current * current; label = '($current)²'; break;
      case 'π': res = pi; label = 'π'; break;
      case 'e': res = e; label = 'e'; break;
      default: return;
    }

    _result = _formatResult(res);
    _expression = '$label = $_result';
    _display = _result;
    _justEvaluated = true;
  }

  void _applyPercent() {
    double? current = double.tryParse(_display.replaceAll(',', ''));
    if (current == null) return;
    double res = current / 100;
    _result = _formatResult(res);
    _expression = '$current% = $_result';
    _display = _result;
    _justEvaluated = true;
  }

  void _toggleSign() {
    double? current = double.tryParse(_display.replaceAll(',', ''));
    if (current == null) return;
    _display = _formatResult(current * -1);
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      String expr = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      double res = _evalSimple(expr);
      _result = _formatResult(res);
      _expression = '$_expression = $_result';
      _display = _result;
      _justEvaluated = true;
    } catch (_) {
      _display = 'Error';
    }
  }

  double _evalSimple(String expr) {
    expr = expr.trim();
    List<String> tokens = [];
    String current = '';

    for (int i = 0; i < expr.length; i++) {
      String ch = expr[i];
      if ('+-*/'.contains(ch) && current.isNotEmpty) {
        tokens.add(current);
        tokens.add(ch);
        current = '';
      } else {
        current += ch;
      }
    }
    if (current.isNotEmpty) tokens.add(current);
    if (tokens.isEmpty) throw Exception('Empty');

    List<dynamic> processed = tokens.map((t) => double.tryParse(t) ?? t).toList();

    for (int i = 1; i < processed.length - 1; i++) {
      if (processed[i] == '*' || processed[i] == '/') {
        double a = processed[i - 1] as double;
        double b = processed[i + 1] as double;
        processed[i - 1] = processed[i] == '*' ? a * b : a / b;
        processed.removeAt(i);
        processed.removeAt(i);
        i--;
      }
    }

    double result = processed[0] as double;
    for (int i = 1; i < processed.length - 1; i += 2) {
      double b = processed[i + 1] as double;
      if (processed[i] == '+') result += b;
      if (processed[i] == '-') result -= b;
    }
    return result;
  }

  String _formatResult(double value) {
    if (value == value.roundToDouble()) return value.toInt().toString();
    String str = value.toStringAsFixed(10);
    str = str.replaceAll(RegExp(r'0+$'), '');
    str = str.replaceAll(RegExp(r'\.$'), '');
    return str;
  }

  String getHistoryEntry() => _expression;
}
