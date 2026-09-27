import 'dart:math';
import 'package:flutter/material.dart';
import 'tokens.dart';

/// The shared celebration overlay: stars, praise and a confetti shower.
///
/// Fired by [EngineApi.reward] on every success, identically across all games,
/// so the reward-animation preference of young children is met the same way
/// everywhere (report sections 3.2 and 3.4).
class RewardOverlay extends StatefulWidget {
  const RewardOverlay({
    super.key,
    required this.stars,
    required this.message,
    required this.onPlayAgain,
    required this.onHome,
  });

  final int stars;
  final String message;
  final VoidCallback onPlayAgain;
  final VoidCallback onHome;

  @override
  State<RewardOverlay> createState() => _RewardOverlayState();
}

class _RewardOverlayState extends State<RewardOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
        ..forward();
  final _rng = Random();
  late final List<_Confetto> _pieces = List.generate(
    36,
    (_) => _Confetto(
      x: _rng.nextDouble(),
      delay: _rng.nextDouble() * 0.3,
      color: Tokens.confettiColors[_rng.nextInt(Tokens.confettiColors.length)],
      rotation: _rng.nextDouble() * pi * 2,
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModalBarrier(color: Colors.black.withValues(alpha: 0.15)),
        AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(_pieces, _c.value),
          ),
        ),
        Center(
          child: Container(
            margin: const EdgeInsets.all(28),
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎈', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 12),
                Text(widget.message,
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: Tokens.ink)),
                const SizedBox(height: 16),
                Text('⭐' * widget.stars.clamp(1, 5),
                    style: const TextStyle(fontSize: 34)),
                const SizedBox(height: 24),
                _BigButton(
                  label: 'Play again',
                  color: Tokens.green,
                  onTap: widget.onPlayAgain,
                ),
                const SizedBox(height: 14),
                IconButton(
                  iconSize: 40,
                  onPressed: widget.onHome,
                  icon: const Text('🏠', style: TextStyle(fontSize: 34)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton(
      {required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(Tokens.minTapTarget / 2),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.minTapTarget / 2),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
              minHeight: Tokens.minTapTarget, minWidth: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: const Text('Play again',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _Confetto {
  _Confetto(
      {required this.x,
      required this.delay,
      required this.color,
      required this.rotation});
  final double x;
  final double delay;
  final Color color;
  final double rotation;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Confetto> pieces;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay).clamp(0.0, 1.0));
      if (local <= 0) continue;
      final y = local * (size.height + 40) - 20;
      final x = p.x * size.width;
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + local * 6);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-6, -6, 12, 12), const Radius.circular(3)),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.t != t;
}
