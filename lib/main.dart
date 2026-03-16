import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calculator_logic.dart';
import 'history_screen.dart';

void main() {
  runApp(const KalkulatorApp());
}

class KalkulatorApp extends StatelessWidget {
  const KalkulatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorLogic _logic = CalculatorLogic();
  bool _showScientific = false;

  static const Color _accent = Color(0xFFFF6B35);
  static const Color _btnDark = Color(0xFF222222);
  static const Color _btnGray = Color(0xFF2E2E2E);
  static const Color _btnLight = Color(0xFF3A3A3A);

  void _press(String val) async {
    final prevExpr = _logic.expression;
    setState(() => _logic.input(val));

    if (val == '=' && _logic.expression.isNotEmpty && _logic.expression != prevExpr) {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList('calc_history') ?? [];
      history.add(_logic.expression);
      if (history.length > 50) history.removeAt(0);
      await prefs.setStringList('calc_history', history);
    }
  }

  Widget _buildDisplay() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white54, size: 26),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
              ),
              IconButton(
                icon: Icon(
                  _showScientific ? Icons.keyboard_arrow_up : Icons.science_outlined,
                  color: _showScientific ? _accent : Colors.white54,
                  size: 26,
                ),
                onPressed: () => setState(() => _showScientific = !_showScientific),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _logic.expression.isEmpty ? '' : _logic.expression.replaceAll('= ', '\n= '),
            style: GoogleFonts.spaceMono(color: Colors.white38, fontSize: 14),
            textAlign: TextAlign.right,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _logic.display,
              style: GoogleFonts.spaceMono(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w700,
                letterSpacing: -2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, {Color? bg, Color? fg, bool isZero = false}) {
    return Expanded(
      flex: isZero ? 2 : 1,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _press(label);
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          height: 70,
          decoration: BoxDecoration(
            color: bg ?? _btnDark,
            borderRadius: BorderRadius.circular(35),
            border: bg == null ? Border.all(color: Colors.white10, width: 0.5) : null,
            boxShadow: bg == _accent
                ? [BoxShadow(color: _accent.withOpacity(0.35), blurRadius: 16, spreadRadius: 1)]
                : null,
          ),
          alignment: isZero ? Alignment.centerLeft : Alignment.center,
          padding: isZero ? const EdgeInsets.only(left: 28) : EdgeInsets.zero,
          child: Text(
            label,
            style: GoogleFonts.spaceMono(
              color: fg ?? Colors.white,
              fontSize: label.length > 2 ? 15 : 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScientificRow(List<String> keys) {
    return Row(
      children: keys.map((k) => _btn(k, bg: _btnGray, fg: Colors.white70)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _buildDisplay(),
            Container(height: 1, color: Colors.white10, margin: const EdgeInsets.symmetric(horizontal: 16)),
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _showScientific
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          _buildScientificRow(['sin', 'cos', 'tan', 'π']),
                          _buildScientificRow(['log', 'ln', '√', 'e']),
                          _buildScientificRow(['x²', '(', ')', '+/-']),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(children: [
                      _btn('C', bg: _btnLight, fg: Colors.white),
                      _btn('+/-', bg: _btnLight, fg: Colors.white),
                      _btn('%', bg: _btnLight, fg: Colors.white),
                      _btn('÷', bg: _accent, fg: Colors.white),
                    ]),
                    Row(children: [
                      _btn('7'), _btn('8'), _btn('9'),
                      _btn('×', bg: _accent, fg: Colors.white),
                    ]),
                    Row(children: [
                      _btn('4'), _btn('5'), _btn('6'),
                      _btn('-', bg: _accent, fg: Colors.white),
                    ]),
                    Row(children: [
                      _btn('1'), _btn('2'), _btn('3'),
                      _btn('+', bg: _accent, fg: Colors.white),
                    ]),
                    Row(children: [
                      _btn('0', isZero: true),
                      _btn('.'),
                      _btn('⌫'),
                      _btn('=', bg: _accent, fg: Colors.white),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
