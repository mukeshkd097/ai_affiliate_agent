import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/app_constants.dart';
import '../../services/subscription_service.dart';
import '../../theme/app_theme.dart';

class ProUpgradeScreen extends StatefulWidget {
  const ProUpgradeScreen({super.key});

  @override
  State<ProUpgradeScreen> createState() => _ProUpgradeScreenState();
}

class _ProUpgradeScreenState extends State<ProUpgradeScreen> {
  int _selectedPlan = 1; // 0=monthly, 1=yearly, 2=lifetime
  bool _purchasing = false;

  final _plans = [
    (
      label: 'Monthly',
      price: AppConstants.proMonthlyPriceINR,
      priceUSD: AppConstants.proMonthlyPriceUSD,
      sub: 'Cancel anytime',
      plan: SubscriptionPlan.proMonthly,
    ),
    (
      label: 'Yearly',
      price: AppConstants.proYearlyPriceINR,
      priceUSD: AppConstants.proYearlyPriceUSD,
      sub: 'Save 33% — Best value',
      plan: SubscriptionPlan.proYearly,
    ),
    (
      label: 'Lifetime',
      price: AppConstants.proLifetimePriceINR,
      priceUSD: '\$19.99 once',
      sub: 'Pay once, use forever',
      plan: SubscriptionPlan.proLifetime,
    ),
  ];

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    try {
      final sub = context.read<SubscriptionService>();
      await sub.activatePro(_plans[_selectedPlan].plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Welcome to SnapSort Pro!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C63FF), Color(0xFFFF9F1C)],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 24),
                      Text('💫', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 12),
                      Text(
                        'SnapSort Pro',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Unlimited • Cloud backup • Export',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureList(),
                  const SizedBox(height: 28),
                  const Text(
                    'Choose your plan',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  ..._plans.asMap().entries.map((e) {
                    final idx = e.key;
                    final p = e.value;
                    final isSelected = _selectedPlan == idx;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedPlan = idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary.withOpacity(0.08)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.primary
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(p.label,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight.w700,
                                              fontSize: 16)),
                                      if (idx == 1) ...
                                      [
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accent,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'BEST VALUE',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight:
                                                    FontWeight.w700,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(p.sub,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              children: [
                                Text(p.price,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16)),
                                Text(p.priceUSD,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey)),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppTheme.primary
                                  : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _purchasing ? null : _purchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _purchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Upgrade to Pro',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Restore purchase  •  Privacy Policy  •  Terms',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  final _features = const [
    ('📸', 'Unlimited screenshots', 'No 500-screenshot cap'),
    ('🦖', 'AI-powered auto-sort', '11 smart categories'),
    ('☁️', 'Cloud backup', 'Access from any device'),
    ('📤', 'Export to PDF/ZIP', 'Share or archive anytime'),
    ('🔍', 'Smart search', 'Find any screenshot instantly'),
    ('🔒', 'On-device privacy', 'No cloud upload without consent'),
  ];

  const _FeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features.map((f) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Text(f.$1, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$2,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                    Text(f.$3,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.check_circle,
                  color: AppTheme.success, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}
