import 'package:flutter/material.dart';

class ParabolaAnimationScreen extends StatefulWidget {
  const ParabolaAnimationScreen({super.key});

  @override
  _ParabolaAnimationScreenState createState() => _ParabolaAnimationScreenState();
}

class _ParabolaAnimationScreenState extends State<ParabolaAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double a = 1.0;
  double b = 0.0;
  double c = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(_controller)
      ..addListener(() {
        setState(() {
          a = _animation.value;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parabola Animation"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: ParabolaPainter(a, b, c),
                  );
                },
              ),
            ),
          ),
          _buildSlider("b", -100.0, 100.0, (value) => setState(() => b = value)),
          _buildSlider("c", -100.0, 100.0, (value) => setState(() => c = value)),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Slider(
            value: label == "b" ? b : c,
            min: min,
            max: max,
            onChanged: onChanged,
            divisions: 200,
            label: (label == "b" ? b : c).toStringAsFixed(2),
          ),
        ],
      ),
    );
  }
}

class ParabolaPainter extends CustomPainter {
  final double a, b, c;

  ParabolaPainter(this.a, this.b, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();

    for (double x = -size.width / 2; x <= size.width / 2; x += 0.1) {
      double y = a * x * x / 100 + b * x + c;
      if (x == -size.width / 2) {
        path.moveTo(size.width / 2 + x, size.height / 2 - y);
      } else {
        path.lineTo(size.width / 2 + x, size.height / 2 - y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
