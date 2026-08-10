import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';

// Purpose: Demonstrate both Ephemeral State and App State with counters
// Responsibilities: Show two counters - one local (ephemeral) and one app-wide
// Why this class exists: To visually compare ephemeral vs app state behavior

class DualCounterScreen extends StatefulWidget {
  const DualCounterScreen({super.key});

  @override
  State<DualCounterScreen> createState() => _DualCounterScreenState();
}

class _DualCounterScreenState extends State<DualCounterScreen> {
  // Ephemeral state - local counter managed with setState()
  int _ephemeralCounter = 0;

  void _incrementEphemeral() {
    setState(() {
      _ephemeralCounter++;
    });
  }

  void _decrementEphemeral() {
    if (_ephemeralCounter > 0) {
      setState(() {
        _ephemeralCounter--;
      });
    }
  }

  void _resetEphemeral() {
    setState(() {
      _ephemeralCounter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral vs App State'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'State Comparison',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Compare ephemeral (local) vs app-wide state.\n'
                    'Ephemeral resets on screen rebuild.\n'
                    'App state persists across navigation.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ephemeral State Counter
            _buildCounterCard(
              theme: theme,
              title: 'EPHEMERAL STATE',
              subtitle: 'Local setState() - Resets on rebuild',
              icon: Icons.phone_android,
              counterValue: _ephemeralCounter,
              onIncrement: _incrementEphemeral,
              onDecrement: _decrementEphemeral,
              onReset: _resetEphemeral,
              color: theme.colorScheme.tertiary,
            ),
            const SizedBox(height: 16),

            // App State Counter
            Consumer<CounterProvider>(
              builder: (context, counterProvider, child) {
                return _buildCounterCard(
                  theme: theme,
                  title: 'APP STATE',
                  subtitle: 'Provider - Persists across screens',
                  icon: Icons.cloud,
                  counterValue: counterProvider.counter,
                  onIncrement: counterProvider.increment,
                  onDecrement: counterProvider.decrement,
                  onReset: counterProvider.reset,
                  color: theme.colorScheme.primary,
                );
              },
            ),
            const SizedBox(height: 24),

            // Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Key Differences',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildDifferenceItem(
                      theme,
                      'Ephemeral State',
                      'Managed locally with setState()',
                      'Lost when widget is disposed/rebuilt',
                      Icons.phone_android,
                    ),
                    const SizedBox(height: 8),
                    _buildDifferenceItem(
                      theme,
                      'App State',
                      'Managed with Provider pattern',
                      'Persists across entire app lifecycle',
                      Icons.cloud,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required int counterValue,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required VoidCallback onReset,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '$counterValue',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filled(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                  style: IconButton.styleFrom(
                    backgroundColor: color.withValues(alpha: 0.2),
                    foregroundColor: color,
                  ),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.outlined(
                  onPressed: onReset,
                  icon: const Icon(Icons.refresh),
                  style: IconButton.styleFrom(
                    side: BorderSide(color: color.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifferenceItem(
    ThemeData theme,
    String title,
    String description1,
    String description2,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              Text(
                description2,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
