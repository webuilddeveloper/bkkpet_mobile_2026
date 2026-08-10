import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 64,
    this.label,
  });

  final double size;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Lottie.asset(
          'assets/lotties/loading.json',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(
            label!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}

class AppRefreshIndicator extends StatefulWidget {
  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  final Widget child;
  final Future<void> Function() onRefresh;

  @override
  State<AppRefreshIndicator> createState() => _AppRefreshIndicatorState();
}

class _AppRefreshIndicatorState extends State<AppRefreshIndicator> {
  bool _refreshing = false;

  Future<void> _handleRefresh() async {
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.noSpinner(
      onRefresh: _handleRefresh,
      child: Stack(
        children: [
          widget.child,
          if (_refreshing)
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(child: AppLoadingIndicator(size: 42)),
            ),
        ],
      ),
    );
  }
}
