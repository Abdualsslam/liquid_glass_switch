import 'package:flutter/material.dart';
import 'package:liquid_glass_switch/liquid_glass_switch.dart';

void main() {
  runApp(const LiquidGlassSwitchExampleApp());
}

class LiquidGlassSwitchExampleApp extends StatelessWidget {
  const LiquidGlassSwitchExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const _DemoPage(),
    );
  }
}

class _DemoPage extends StatefulWidget {
  const _DemoPage();

  @override
  State<_DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<_DemoPage> {
  bool _isSleep = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/image.png', fit: BoxFit.cover),
          Center(
            child: LiquidGlassSwitch(
              value: _isSleep,
              onChanged: (value) {
                setState(() {
                  _isSleep = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
