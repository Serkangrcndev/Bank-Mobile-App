import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../transfers/transfer_screen.dart';
import '../cards/card_details_screen.dart';
import '../dashboard/spending_insights_screen.dart';
import '../lending/lending_dashboard_screen.dart';
import '../support/support_screen.dart';
import '../limits/limits_screen.dart';
import '../locator/locator_screen.dart';
import '../kyc/kyc_verification_screen.dart';
import '../insurance/insurance_screen.dart';
import '../exchange/exchange_screen.dart';
import '../loans/loan_application_screen.dart';
import '../../core/localization/language_manager.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> with TickerProviderStateMixin {
  // ── States ────────────────────────────────────────────────────────────────
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String _query = '';
  
  // Simulated Transactions Database
  List<_SearchTxData> get _allTransactions => [
    _SearchTxData(
      name: 'Starbucks Reserve',
      date: LanguageManager.translate('Today, 08:42 AM', 'Bugün, 08:42'),
      account: LanguageManager.translate('Checking ...4921', 'Vadesiz ...4921'),
      amount: '- \$14.50',
      icon: Icons.coffee_rounded,
    ),
    _SearchTxData(
      name: 'Apple Store',
      date: LanguageManager.translate('Today, 2:45 PM', 'Bugün, 14:45'),
      account: LanguageManager.translate('Credit ...8821', 'Kredi Kartı ...8821'),
      amount: '- \$999.00',
      icon: Icons.storefront_rounded,
    ),
    _SearchTxData(
      name: 'Starbucks Corp',
      date: LanguageManager.translate('Oct 12, 2023', '12 Eki 2023'),
      account: LanguageManager.translate('Card Reload', 'Karta Yükleme'),
      amount: '- \$50.00',
      icon: Icons.coffee_outlined,
    ),
    _SearchTxData(
      name: 'Starbucks Store #4092',
      date: LanguageManager.translate('Sep 28, 2023', '28 Eyl 2023'),
      account: LanguageManager.translate('Credit ...8821', 'Kredi Kartı ...8821'),
      amount: '- \$8.25',
      icon: Icons.coffee_rounded,
    ),
    _SearchTxData(
      name: LanguageManager.translate('Salary Deposit', 'Maaş Ödemesi'),
      date: LanguageManager.translate('Yesterday', 'Dün'),
      account: LanguageManager.translate('Checking ...4920', 'Vadesiz ...4920'),
      amount: '+ \$4,250.00',
      icon: Icons.south_west_rounded,
      isCredit: true,
    ),
    _SearchTxData(
      name: 'Starbucks',
      date: LanguageManager.translate('Oct 12, 2023', '12 Eki 2023'),
      account: LanguageManager.translate('Debit Card', 'Banka Kartı'),
      amount: '- \$6.50',
      icon: Icons.coffee_rounded,
    ),
    _SearchTxData(
      name: 'Whole Foods Market',
      date: LanguageManager.translate('Oct 10, 2023', '10 Eki 2023'),
      account: LanguageManager.translate('Checking ...4921', 'Vadesiz ...4921'),
      amount: '- \$124.30',
      icon: Icons.shopping_basket_rounded,
    ),
  ];

  // Staggered animations for results
  late final AnimationController _listEntranceCtrl;
  late final List<Animation<double>> _listFadeAnims;
  static const int _maxVisibleItems = 6;

  @override
  void initState() {
    super.initState();
    _searchCtrl.text = widget.initialQuery;
    _query = widget.initialQuery;

    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text;
      });
      // Restart entrance animation when query changes
      _listEntranceCtrl.reset();
      _listEntranceCtrl.forward();
    });

    _listEntranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _listFadeAnims = List.generate(_maxVisibleItems, (i) {
      final start = i * 0.08;
      final end = (start + 0.30).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _listEntranceCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _listEntranceCtrl.forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _listEntranceCtrl.dispose();
    super.dispose();
  }

  // ── Voice Search Simulation ────────────────────────────────────────────────
  void _startVoiceSearch() {
    HapticFeedback.mediumImpact();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return _VoiceSearchDialog(
          onFinish: (result) {
            Navigator.pop(context); // Close voice dialog
            _simulateTypingText(result);
          },
        );
      },
    );
  }

  void _simulateTypingText(String targetText) async {
    _searchCtrl.clear();
    _searchFocus.requestFocus();

    // Type letter by letter
    for (int i = 1; i <= targetText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      _searchCtrl.text = targetText.substring(0, i);
      HapticFeedback.lightImpact();
    }
  }

  // ── Helper Navigation ──────────────────────────────────────────────────────
  void _navigateToTransfer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const TransferScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToCardDetails() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const CardDetailsScreen(
          cardType: 'Debit',
          last4: '4092',
          balance: '\$45,200.50',
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter transactions based on query
    final filteredTx = _allTransactions.where((tx) {
      return tx.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Header
            _buildSearchHeader(),

            // ── Main Content Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Suggested Actions (Always visible)
                    _buildSuggestedActions(),
                    const SizedBox(height: 32),

                    // 2. Conditionally build Results or Recent Searches
                    if (_query.isEmpty) ...[
                      _buildRecentSearches(),
                    ] else ...[
                      _buildSearchResults(filteredTx),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Header ──────────────────────────────────────────────────────────
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Focus(
              child: Builder(
                builder: (context) {
                  final isFocused = Focus.of(context).hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0C0C),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isFocused ? const Color(0xFFCCFF00) : const Color(0xFF333333),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: isFocused ? const Color(0xFFCCFF00) : AppColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _searchFocus,
                            autofocus: true,
                            cursorColor: const Color(0xFFCCFF00),
                            style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontSize: 16),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: LanguageManager.translate('Search transactions, contacts, actions...', 'İşlemleri, kişileri, eylemleri arayın...'),
                              hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                            ),
                          ),
                        ),
                        if (_query.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _searchCtrl.clear();
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.mic_none_rounded, color: Colors.white),
            onPressed: _startVoiceSearch,
          ),
        ],
      ),
    );
  }

  // ── Suggested Actions ──────────────────────────────────────────────────────
  Widget _buildSuggestedActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            LanguageManager.translate('SUGGESTED ACTIONS', 'ÖNERİLEN EYLEMLER'),
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionChip(
              icon: Icons.send_rounded,
              label: LanguageManager.translate('Pay a Bill', 'Fatura Öde'),
              onTap: _navigateToTransfer,
            ),
            _buildActionChip(
              icon: Icons.swap_horiz_rounded,
              label: LanguageManager.translate('Transfer Funds', 'Para Transferi'),
              onTap: _navigateToTransfer,
            ),
            _buildActionChip(
              icon: Icons.credit_card_rounded,
              label: LanguageManager.translate('Lock Card', 'Kartı Kilitle'),
              onTap: _navigateToCardDetails,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryFixed, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMd(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Recent Searches (Shown when query is empty) ────────────────────────────
  Widget _buildRecentSearches() {
    final recentSearches = ['Whole Foods', 'Netflix', 'Uber', 'Apple Store'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            LanguageManager.translate('RECENT SEARCHES', 'SON ARAMALAR'),
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentSearches.length,
          itemBuilder: (context, index) {
            final search = recentSearches[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              leading: const Icon(Icons.history_rounded, color: AppColors.secondary, size: 20),
              title: Text(
                search,
                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.secondary, size: 18),
              onTap: () {
                HapticFeedback.selectionClick();
                _searchCtrl.text = search;
              },
            );
          },
        ),
      ],
    );
  }

  // ── Search Results Layout ──────────────────────────────────────────────────
  Widget _buildSearchResults(List<_SearchTxData> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Grid setup: Left column: Transactions, Right column: Contacts & Features
        // Inside SingleChildScrollView, we can layout stacked or row-based.
        // We do a mobile-first column stack.
        
        // Category 1: Transactions
        _buildStaggeredResult(0, _buildTransactionsResultSection(transactions)),
        const SizedBox(height: 32),

        // Category 2: Contacts
        _buildStaggeredResult(1, _buildContactsResultSection()),
        const SizedBox(height: 32),

        // Category 3: Features
        _buildStaggeredResult(2, _buildFeaturesResultSection()),
      ],
    );
  }

  Widget _buildStaggeredResult(int index, Widget child) {
    if (index >= _listFadeAnims.length) return child;
    return FadeTransition(
      opacity: _listFadeAnims[index],
      child: child,
    );
  }

  // ── Results Sections ───────────────────────────────────────────────────────
  Widget _buildTransactionsResultSection(List<_SearchTxData> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LanguageManager.translate('TRANSACTIONS', 'İŞLEMLER'),
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              LanguageManager.translate('See All (${list.length})', 'Tümünü Gör (${list.length})'),
              style: AppTextStyles.labelSm(color: AppColors.primaryFixed).copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFF1A1A1A)),
        if (list.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              LanguageManager.translate('No transactions matching "$_query"', '"$_query" ile eşleşen işlem bulunamadı'),
              style: AppTextStyles.bodyMd(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final tx = list[i];
              return _SearchTxTile(tx: tx);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildContactsResultSection() {
    final matchesContact = _query.toLowerCase().contains('marcus') ||
        _query.toLowerCase().contains('elena') ||
        _query.toLowerCase().contains('sarah') ||
        _query.toLowerCase().contains('david');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LanguageManager.translate('CONTACTS', 'KİŞİLER'),
          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFF1A1A1A)),
        const SizedBox(height: 8),
        if (!matchesContact) ...[
          // Empty State
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.person_search_rounded,
                  color: AppColors.secondary,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  LanguageManager.translate('No contacts matching "$_query"', '"$_query" ile eşleşen kişi bulunamadı'),
                  style: AppTextStyles.labelSm(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ] else ...[
          // Mock Matching Contact
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0C0C0C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF333333)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryFixed,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'M',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _query.substring(0, 1).toUpperCase() + _query.substring(1),
                        style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        LanguageManager.translate('Elite Account Verified', 'Elite Hesap Doğrulandı'),
                        style: AppTextStyles.labelSm(color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.primaryFixed),
                  onPressed: _navigateToTransfer,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturesResultSection() {
    final queryLower = _query.toLowerCase();
    final showInsights = queryLower.contains('coffee') ||
        queryLower.contains('starbucks') ||
        queryLower.contains('spend') ||
        queryLower.contains('insight');
        
    final showLending = queryLower.contains('loan') ||
        queryLower.contains('lend') ||
        queryLower.contains('credit') ||
        queryLower.contains('mortgage');

    final showSupport = queryLower.contains('support') ||
        queryLower.contains('help') ||
        queryLower.contains('faq') ||
        queryLower.contains('chat') ||
        queryLower.contains('desk') ||
        queryLower.contains('ticket');

    final showLimits = queryLower.contains('limit') ||
        queryLower.contains('usage') ||
        queryLower.contains('threshold') ||
        queryLower.contains('spend') ||
        queryLower.contains('power') ||
        queryLower.contains('monthly') ||
        queryLower.contains('daily');

    final showLocator = queryLower.contains('atm') ||
        queryLower.contains('branch') ||
        queryLower.contains('locator') ||
        queryLower.contains('map') ||
        queryLower.contains('address') ||
        queryLower.contains('location') ||
        queryLower.contains('bank') ||
        queryLower.contains('near');

    final showKyc = queryLower.contains('kyc') ||
        queryLower.contains('identity') ||
        queryLower.contains('verify') ||
        queryLower.contains('verification') ||
        queryLower.contains('passport') ||
        queryLower.contains('document') ||
        queryLower.contains('biometric') ||
        queryLower.contains('id');

    final showInsurance = queryLower.contains('insurance') ||
        queryLower.contains('policy') ||
        queryLower.contains('premium') ||
        queryLower.contains('coverage') ||
        queryLower.contains('health') ||
        queryLower.contains('life') ||
        queryLower.contains('home insurance') ||
        queryLower.contains('travel') ||
        queryLower.contains('protect');

    final showExchange = queryLower.contains('exchange') ||
        queryLower.contains('currency') ||
        queryLower.contains('convert') ||
        queryLower.contains('forex') ||
        queryLower.contains('rate') ||
        queryLower.contains('btc') ||
        queryLower.contains('bitcoin') ||
        queryLower.contains('crypto') ||
        queryLower.contains('market') ||
        queryLower.contains('usd') ||
        queryLower.contains('eur');

    final showLoan = queryLower.contains('loan') ||
        queryLower.contains('credit') ||
        queryLower.contains('mortgage') ||
        queryLower.contains('auto loan') ||
        queryLower.contains('borrow') ||
        queryLower.contains('application') ||
        queryLower.contains('apr') ||
        queryLower.contains('installment');

    if (!showInsights && !showLending && !showSupport && !showLimits && !showLocator && !showKyc && !showInsurance && !showExchange && !showLoan) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          LanguageManager.translate('FEATURES', 'ÖZELLİKLER'),
          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)).copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Divider(color: Color(0xFF1A1A1A)),
        const SizedBox(height: 8),
        if (showInsights) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Spending Insights', 'Harcama Analizleri'),
            subtitle: LanguageManager.translate('Analyze coffee expenses', 'Kahve masraflarını analiz et'),
            icon: Icons.insights_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SpendingInsightsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showLending || showSupport || showLimits) const SizedBox(height: 12),
        ],
        if (showLending) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Lending Dashboard', 'Borçlanma Paneli'),
            subtitle: LanguageManager.translate('Manage loans and facilities', 'Kredileri ve imkanları yönet'),
            icon: Icons.real_estate_agent_outlined,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LendingDashboardScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showSupport || showLimits) const SizedBox(height: 12),
        ],
        if (showSupport) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Lumina Support Desk', 'Lumina Destek Merkezi'),
            subtitle: LanguageManager.translate('Search FAQ & chat with support team', 'SSS ara ve destek ekibiyle sohbet et'),
            icon: Icons.support_agent_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SupportScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showLimits) const SizedBox(height: 12),
        ],
        if (showLimits) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Limits & Usage', 'Limitler ve Kullanım'),
            subtitle: LanguageManager.translate('Monitor your spending power & thresholds', 'Harcama gücünü ve eşikleri takip et'),
            icon: Icons.tune_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LimitsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showLocator) const SizedBox(height: 12),
        ],
        if (showLocator) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('ATM & Branch Locator', 'ATM ve Şube Bulucu'),
            subtitle: LanguageManager.translate('Find nearest ATMs and premium branches on map', 'Haritada en yakın ATM ve seçkin şubeleri bul'),
            icon: Icons.map_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LocatorScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showKyc) const SizedBox(height: 12),
        ],
        if (showKyc) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Identity Verification', 'Kimlik Doğrulama'),
            subtitle: LanguageManager.translate('KYC — Unlock premium trading features', 'KYC — Seçkin işlem özelliklerini aç'),
            icon: Icons.verified_user_outlined,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const KycVerificationScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showInsurance) const SizedBox(height: 12),
        ],
        if (showInsurance) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Insurance Portfolio', 'Sigorta Portföyü'),
            subtitle: LanguageManager.translate('Manage policies, coverage, and premium payments', 'Poliçeleri, kapsamı ve prim ödemelerini yönet'),
            icon: Icons.health_and_safety_outlined,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const InsuranceScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showExchange) const SizedBox(height: 12),
        ],
        if (showExchange) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Exchange & Rates', 'Döviz ve Kurlar'),
            subtitle: LanguageManager.translate('Convert currencies and view live market rates', 'Para birimlerini dönüştür ve canlı piyasa kurlarını gör'),
            icon: Icons.currency_exchange_rounded,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const ExchangeScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          if (showLoan) const SizedBox(height: 12),
        ],
        if (showLoan) ...[
          _buildFeatureCard(
            title: LanguageManager.translate('Loan Application', 'Kredi Başvurusu'),
            subtitle: LanguageManager.translate('Apply for personal, mortgage, or auto loans', 'Bireysel, konut veya taşıt kredisine başvur'),
            icon: Icons.account_balance_outlined,
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const LoanApplicationScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF333333)),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: AppColors.primaryFixed,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.secondary, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Search Transaction Tile Widget ───────────────────────────────────────────
class _SearchTxTile extends StatefulWidget {
  const _SearchTxTile({required this.tx});
  final _SearchTxData tx;

  @override
  State<_SearchTxTile> createState() => _SearchTxTileState();
}

class _SearchTxTileState extends State<_SearchTxTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) {
        setState(() => _hovered = false);
        HapticFeedback.selectionClick();
      },
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF0C0C0C) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: const Border(
            bottom: BorderSide(color: Color(0xFF111111)),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: _hovered ? const Color(0xFFCCFF00) : const Color(0xFF333333),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                widget.tx.icon,
                color: _hovered ? const Color(0xFFCCFF00) : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tx.name,
                    style: AppTextStyles.bodyMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${widget.tx.date} • ${widget.tx.account}',
                    style: AppTextStyles.labelSm(color: AppColors.secondary),
                  ),
                ],
              ),
            ),
            Text(
              widget.tx.amount,
              style: AppTextStyles.labelMd(
                color: widget.tx.isCredit ? AppColors.primaryFixed : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Voice Search Dialog Widget ───────────────────────────────────────────────
class _VoiceSearchDialog extends StatefulWidget {
  const _VoiceSearchDialog({required this.onFinish});
  final ValueChanged<String> onFinish;

  @override
  State<_VoiceSearchDialog> createState() => _VoiceSearchDialogState();
}

class _VoiceSearchDialogState extends State<_VoiceSearchDialog> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Simulate speech detection
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        widget.onFinish('Starbucks');
      }
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: const Color(0xFF0C0C0C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF333333)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing rings
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 80 * _pulseAnim.value,
                      height: 80 * _pulseAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFCCFF00).withValues(alpha: 0.15 * (2.0 - _pulseAnim.value)),
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFCCFF00),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              LanguageManager.translate('Listening...', 'Dinleniyor...'),
              style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              LanguageManager.translate('Try saying "Starbucks" or "Whole Foods"', 'Şunu söylemeyi deneyin: "Starbucks" veya "Whole Foods"'),
              style: AppTextStyles.bodyMd(color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchTxData {
  const _SearchTxData({
    required this.name,
    required this.date,
    required this.account,
    required this.amount,
    required this.icon,
    this.isCredit = false,
  });

  final String name;
  final String date;
  final String account;
  final String amount;
  final IconData icon;
  final bool isCredit;
}
