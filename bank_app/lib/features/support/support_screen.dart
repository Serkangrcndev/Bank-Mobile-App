import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/notifications/app_notification.dart';
import '../../core/localization/language_manager.dart';

/// Support Center Screen
/// Implements "Fintech Elite | Support Center" HTML mockup.
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  // ── Entrance animation ───────────────────────────────────────────────────
  late final AnimationController _entranceCtrl;
  static const int _sectionCount = 5;
  late final List<Animation<double>> _fadeAnims;
  late final List<Animation<Offset>> _slideAnims;

  // ── Toast ────────────────────────────────────────────────────────────────
  bool _toastVisible = false;

  // ── Chat state ───────────────────────────────────────────────────────────
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _chatScroll = ScrollController();
  List<_ChatMsg> get _initialMessages => [
    _ChatMsg(
      text: LanguageManager.translate(
        'Welcome back, Arthur. I see your last trade was processed successfully. How may I assist your portfolio today?',
        'Tekrar hoş geldiniz, Arthur. Son işleminizin başarıyla gerçekleştiğini görüyorum. Bugün portföyünüz konusunda size nasıl yardımcı olabilirim?',
      ),
      isUser: false,
      time: '10:42 AM',
    ),
    _ChatMsg(
      text: LanguageManager.translate(
        'I need to verify my recent wire transfer to the Singapore branch.',
        'Singapur şubesine yaptığım son havale işlemini doğrulamam gerekiyor.',
      ),
      isUser: true,
      time: '10:43 AM',
    ),
    _ChatMsg(
      text: LanguageManager.translate(
        'Tracking transaction ID #FE-9921-SGP. The funds are currently in clearing and expected to settle within 2 hours. Would you like a detailed receipt?',
        '#FE-9921-SGP numaralı işlem takip ediliyor. Fonlar şu anda takasta ve 2 saat içinde yerleşmesi bekleniyor. Detaylı bir makbuz ister misiniz?',
      ),
      isUser: false,
      time: '10:43 AM',
    ),
  ];
  late List<_ChatMsg> _mutableMessages;
  bool _isTyping = false;

  // ── Video call button ────────────────────────────────────────────────────
  bool _isStartingCall = false;

  @override
  void initState() {
    super.initState();
    _mutableMessages = _initialMessages;

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceCtrl,
            curve: Interval(start, end, curve: Curves.easeOut)),
      );
    });
    _slideAnims = List.generate(_sectionCount, (i) {
      final start = i * 0.10;
      final end = (start + 0.45).clamp(0.0, 1.0);
      return Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _entranceCtrl,
              curve: Interval(start, end, curve: Curves.easeOutCubic)));
    });
    _entranceCtrl.forward();

    // Toast notification after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _toastVisible = true);
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) setState(() => _toastVisible = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _msgCtrl.dispose();
    _chatScroll.dispose();
    super.dispose();
  }

  Widget _staggered(int i, Widget child) => FadeTransition(
        opacity: _fadeAnims[i],
        child: SlideTransition(position: _slideAnims[i], child: child),
      );

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();
    _msgCtrl.clear();
    setState(() {
      _mutableMessages.add(_ChatMsg(text: text, isUser: true, time: _nowTime()));
      _isTyping = true;
    });
    _scrollToBottom();

    AppNotification.info(
      context,
      title: LanguageManager.translate('Message Sent', 'Mesaj Gönderildi'),
      message: LanguageManager.translate('End-to-end encrypted via Protocol v2.4', 'Protokol v2.4 ile uçtan uca şifrelendi'),
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isTyping = false;
        _mutableMessages.add(_ChatMsg(
          text: LanguageManager.translate(
            'I\'m processing your request. Our team will have a response shortly. Is there anything else you need assistance with?',
            'Talebinizi işleme alıyorum. Ekibimiz kısa süre içinde yanıt verecektir. Yardımcı olabileceğimiz başka bir konu var mı?',
          ),
          isUser: false,
          time: '',
        ));
      });
      _scrollToBottom();
    }
  }

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour == 0 ? 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    final suffix = now.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $suffix';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScroll.hasClients) {
        _chatScroll.animateTo(
          _chatScroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── AppBar ───────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: AppColors.background.withValues(alpha: 0.85),
                elevation: 0,
                toolbarHeight: 64,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.80),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryFixed, size: 20),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                ),
                title: Text(
                  'Fintech Elite',
                  style: AppTextStyles.headlineMd().copyWith(
                    color: AppColors.primaryFixed,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.onSurfaceVariant),
                    onPressed: () {},
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      // ── Hero ─────────────────────────────────────────
                      _staggered(0, _buildHero()),
                      const SizedBox(height: 28),

                      // ── Video Call + Phone cards ──────────────────────
                      _staggered(1, _buildTopCards()),
                      const SizedBox(height: 16),

                      // ── Chat panel ───────────────────────────────────
                      _staggered(2, _buildChatPanel()),
                      const SizedBox(height: 16),

                      // ── Location + Email side cards ───────────────────
                      _staggered(3, _buildSideCards()),
                      const SizedBox(height: 28),

                      // ── Quick Solutions FAQ ───────────────────────────
                      _staggered(4, _buildQuickSolutions()),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Toast notification ────────────────────────────────────────
          _buildToast(),
        ],
      ),
    );
  }

  // ── Hero ───────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageManager.translate('Premium Support', 'Ayrıcalıklı Destek'),
          style: AppTextStyles.headlineXl().copyWith(letterSpacing: -1.5),
        ),
        const SizedBox(height: 8),
        Text(
          LanguageManager.translate(
            'Connect with our elite concierge team through our high-security communication channels. Priority assistance is active for your account.',
            'Yüksek güvenlikli iletişim kanallarımız aracılığıyla elit destek ekibimizle bağlantı kurun. Hesabınız için öncelikli destek etkindir.',
          ),
          style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  // ── Video Call + Phone row ─────────────────────────────────────────────────
  Widget _buildTopCards() {
    return Column(
      children: [
        // Video call card
        _VideoCallCard(
          isLoading: _isStartingCall,
          onStart: () async {
            HapticFeedback.heavyImpact();
            setState(() => _isStartingCall = true);

            AppNotification.pending(
              context,
              title: LanguageManager.translate('Connecting to Banker', 'Müşteri Temsilcisine Bağlanıyor'),
              message: LanguageManager.translate('Establishing encrypted video link...', 'Şifreli video bağlantısı kuruluyor...'),
              duration: const Duration(seconds: 3),
            );

            await Future.delayed(const Duration(milliseconds: 1600));
            if (mounted) {
              setState(() => _isStartingCall = false);
              AppNotification.success(
                context,
                title: LanguageManager.translate('Session Ready', 'Görüşme Hazır'),
                message: LanguageManager.translate('Your private banker is waiting.', 'Özel bankacınız sizi bekliyor.'),
              );
            }
          },
        ),
        const SizedBox(height: 12),

        // Phone card
        _PhoneCard(),
      ],
    );
  }

  // ── Chat panel ─────────────────────────────────────────────────────────────
  Widget _buildChatPanel() {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Chat header ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
            child: Row(
              children: [
                // Avatar with online dot
                Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHighest,
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvTqBaZ6EDXw3QoQkLbVvTljP-WDoFqKcLbvZqPD3hfY01_DDt2uIuH--pb-teaSKXdwU10LUD6B7xmXPSAw5p9Nygi5rkgwJU8aIFTadX8VqGfHukEhinvrSkqxQoPBFqtvkw3PO1EueaJV8CeYcD8ySjAiJvMEW-pAbdRH7zGYUNrBmuLUwsw-2O4a-GAmbMXdu6jqC_9F29lhugMZjX07Wj5iB13JZkG-BGguZOBREXC3szTwaXNM6OmEfcpL9WxmVUL5ydDNxR',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                            Icons.smart_toy_outlined,
                            color: AppColors.primaryFixed,
                            size: 22),
                      ),
                    ),
                    Positioned(
                      bottom: 1,
                      right: 1,
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.black, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LanguageManager.translate('Elite AI Concierge', 'Elite Yapay Zeka Asistanı'),
                        style: AppTextStyles.labelMd(
                                color: AppColors.primaryFixed)
                            .copyWith(letterSpacing: 0.3),
                      ),
                      Text(
                        LanguageManager.translate('ENCRYPTED PROTOCOL V2.4', 'ŞİFRELİ PROTOKOL V2.4'),
                        style: AppTextStyles.labelSm(
                                color: AppColors.onSurfaceVariant)
                            .copyWith(fontSize: 9, letterSpacing: 1.0),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert_rounded,
                    color: AppColors.onSurfaceVariant, size: 20),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1F1F1F)),

          // ── Messages ───────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _chatScroll,
              padding: const EdgeInsets.all(16),
              itemCount: _mutableMessages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (_isTyping && i == _mutableMessages.length) {
                  return _TypingIndicator();
                }
                return _ChatBubble(msg: _mutableMessages[i]);
              },
            ),
          ),

          // ── Input ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
              border: const Border(top: BorderSide(color: Color(0xFF2A2A2A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgCtrl,
                    style: AppTextStyles.bodyMd(color: AppColors.primary)
                        .copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: LanguageManager.translate('Type a message...', 'Bir mesaj yazın...'),
                      hintStyle: AppTextStyles.bodyMd(
                              color: AppColors.onSurfaceVariant)
                          .copyWith(fontSize: 14),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF444444)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.primaryFixed),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Color(0xFF161E00), size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Location + Email side cards ────────────────────────────────────────────
  Widget _buildSideCards() {
    return Column(
      children: [
        _LocationCard(),
        const SizedBox(height: 12),
        _EmailSupportCard(),
      ],
    );
  }

  // ── Quick Solutions ────────────────────────────────────────────────────────
  Widget _buildQuickSolutions() {
    final items = [
      _QuickItem(icon: Icons.security_outlined, label: LanguageManager.translate('Reset Security Key', 'Güvenlik Anahtarını Sıfırla')),
      _QuickItem(icon: Icons.account_balance_outlined, label: LanguageManager.translate('International Limits', 'Uluslararası Limitler')),
      _QuickItem(icon: Icons.token_outlined, label: LanguageManager.translate('Crypto Whitelist', 'Kripto Beyaz Listesi')),
      _QuickItem(icon: Icons.receipt_long_outlined, label: LanguageManager.translate('Tax Statements', 'Vergi Beyannameleri')),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(LanguageManager.translate('Quick Solutions', 'Hızlı Çözümler'), style: AppTextStyles.headlineMd()),
            GestureDetector(
              onTap: () => HapticFeedback.lightImpact(),
              child: Text(
                LanguageManager.translate('VIEW ALL RESOURCES', 'TÜM KAYNAKLARI GÖR'),
                style: AppTextStyles.labelMd(color: AppColors.primaryFixed)
                    .copyWith(letterSpacing: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: items.map((item) => _QuickItemCard(item: item)).toList(),
        ),
      ],
    );
  }

  // ── Toast ──────────────────────────────────────────────────────────────────
  Widget _buildToast() {
    return Positioned(
      top: 76,
      right: 20,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        offset: _toastVisible ? Offset.zero : const Offset(2, 0),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _toastVisible ? 1.0 : 0.0,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primaryFixed.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulsingDot(),
                const SizedBox(width: 10),
                Text(
                  LanguageManager.translate('Secure Connection Established', 'Güvenli Bağlantı Kuruldu'),
                  style: AppTextStyles.labelMd(color: AppColors.primary)
                      .copyWith(letterSpacing: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Video Call Card
// ══════════════════════════════════════════════════════════════════════════════
class _VideoCallCard extends StatefulWidget {
  const _VideoCallCard({required this.isLoading, required this.onStart});
  final bool isLoading;
  final VoidCallback onStart;

  @override
  State<_VideoCallCard> createState() => _VideoCallCardState();
}

class _VideoCallCardState extends State<_VideoCallCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.08, end: 0.25).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, _) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF333333)),
          boxShadow: [
            BoxShadow(
              color:
                  AppColors.primaryFixed.withValues(alpha: _glowAnim.value * 0.6),
              blurRadius: 24,
              spreadRadius: -4,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Ambient glow top-right
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primaryFixed.withValues(alpha: _glowAnim.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Now badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color:
                                AppColors.primaryFixed.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        children: [
                          _PulsingDot(),
                          const SizedBox(width: 6),
                          Text(
                            LanguageManager.translate('AVAILABLE NOW', 'ŞİMDİ MÜSAİT'),
                            style: AppTextStyles.labelSm(
                                    color: AppColors.primaryFixed)
                                .copyWith(letterSpacing: 1.0),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.video_call_outlined,
                        color: AppColors.primaryFixed, size: 32),
                  ],
                ),
                const SizedBox(height: 16),

                Text(
                  LanguageManager.translate('Private Banker\nVideo Call', 'Özel Bankacı\nGörüntülü Arama'),
                  style: AppTextStyles.headlineLg()
                      .copyWith(fontSize: 26, letterSpacing: -0.8, height: 1.2),
                ),
                const SizedBox(height: 10),

                Text(
                  LanguageManager.translate(
                    'Direct access to your dedicated wealth manager for portfolio reviews or strategic advice via encrypted UHD link.',
                    'Portföy incelemeleri veya stratejik tavsiyeler için şifreli UHD bağlantısıyla özel varlık yöneticinize doğrudan erişim.',
                  ),
                  style: AppTextStyles.bodyMd(
                          color: AppColors.onSurfaceVariant)
                      .copyWith(fontSize: 14),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: widget.onStart,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: widget.isLoading
                          ? AppColors.primaryFixed.withValues(alpha: 0.7)
                          : AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isLoading)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF161E00),
                            ),
                          )
                        else ...[
                          Text(
                            LanguageManager.translate('START SESSION', 'GÖRÜŞMEYİ BAŞLAT'),
                            style: AppTextStyles.labelMd(
                                    color: const Color(0xFF161E00))
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Color(0xFF161E00), size: 16),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Phone Card
// ══════════════════════════════════════════════════════════════════════════════
class _PhoneCard extends StatefulWidget {
  const _PhoneCard();

  @override
  State<_PhoneCard> createState() => _PhoneCardState();
}

class _PhoneCardState extends State<_PhoneCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFF141414) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hovered
                ? AppColors.primaryFixed.withValues(alpha: 0.4)
                : const Color(0xFF333333),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.call_outlined,
                color: AppColors.primaryFixed, size: 28),
            const SizedBox(height: 10),
            Text(LanguageManager.translate('Direct Phone Line', 'Doğrudan Telefon Hattı'), style: AppTextStyles.headlineMd()),
            const SizedBox(height: 6),
            Text(
              LanguageManager.translate(
                'Call our global 24/7 dedicated elite hotline for immediate assistance.',
                'Hızlı destek için 7/24 hizmet veren küresel özel elite yardım hattımızı arayın.',
              ),
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              LanguageManager.translate('International Toll-Free', 'Uluslararası Ücretsiz'),
              style: AppTextStyles.labelMd(color: AppColors.primary)
                  .copyWith(letterSpacing: 0.3),
            ),
            const SizedBox(height: 4),
            Text(
              '+1 800 ELITE 00',
              style: AppTextStyles.headlineMd().copyWith(
                color: AppColors.primaryFixed,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Location Card
// ══════════════════════════════════════════════════════════════════════════════
class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageManager.translate('GLOBAL HEADQUARTERS', 'KÜRESEL GENEL MERKEZ'),
            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                .copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_outlined,
                    color: AppColors.primaryFixed, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(LanguageManager.translate('London, UK', 'Londra, İngiltere'), style: AppTextStyles.headlineMd()),
                  const SizedBox(height: 2),
                  Text(
                    'One Canary Wharf, Floor 82\nLondon, E14 5AB',
                    style: AppTextStyles.bodyMd(
                            color: AppColors.onSurfaceVariant)
                        .copyWith(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // London map image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCwwzuq0cIK3aUJMbO2b4XPr7AS0ERF770s-Qo61LqBm-vqm5-4x5vywpGVLVBUYqadQWxJiqrNUJiYKj1XkBx43na1rH0FZ5Pz2o8hlxL3t39VX_iCmC1_5o--7N7lLnTPbd5ofuWpdKwen6Bxp8hPCIb_0m5X_QVbasegeBNMNxCT2wSG1SQhOelZuQd6ejeoHUN9HMkx7181-zAXlwEgkLBdSTtarUjIpcfANE8oaVisjqIXIUbk_RuJ65SB90q1dVA2iR_hINXI',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.surfaceContainerHigh,
                    child: const Center(
                      child: Icon(Icons.location_city_outlined,
                          color: AppColors.onSurfaceVariant, size: 32),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Email Support Card
// ══════════════════════════════════════════════════════════════════════════════
class _EmailSupportCard extends StatelessWidget {
  const _EmailSupportCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF333333)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LanguageManager.translate('DIGITAL CORRESPONDENCE', 'DİJİTAL YAZIŞMA'),
            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                .copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: 12),
          _EmailRow(
            label: LanguageManager.translate('General Inquiry', 'Genel Bilgi Talebi'),
            email: 'concierge@fintechelite.com',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 8),
          _EmailRow(
            label: LanguageManager.translate('Private Wealth', 'Özel Varlık Yönetimi'),
            email: 'private@fintechelite.com',
            icon: Icons.lock_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _EmailRow extends StatefulWidget {
  const _EmailRow({
    required this.label,
    required this.email,
    required this.icon,
  });
  final String label;
  final String email;
  final IconData icon;

  @override
  State<_EmailRow> createState() => _EmailRowState();
}

class _EmailRowState extends State<_EmailRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? AppColors.primaryFixed
                  : AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.labelSm(
                              color: AppColors.onSurfaceVariant)
                          .copyWith(letterSpacing: 0.3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.email,
                      style: AppTextStyles.labelMd(
                              color: AppColors.primaryFixed)
                          .copyWith(letterSpacing: 0.2),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                widget.icon,
                color: _hovered
                    ? AppColors.primaryFixed
                    : AppColors.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Quick Item Card
// ══════════════════════════════════════════════════════════════════════════════
class _QuickItem {
  const _QuickItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _QuickItemCard extends StatefulWidget {
  const _QuickItemCard({required this.item});
  final _QuickItem item;

  @override
  State<_QuickItemCard> createState() => _QuickItemCardState();
}

class _QuickItemCardState extends State<_QuickItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => HapticFeedback.lightImpact(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primaryFixed.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? AppColors.primaryFixed.withValues(alpha: 0.5)
                  : AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                color: _hovered
                    ? AppColors.primaryFixed
                    : AppColors.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.item.label,
                  style: AppTextStyles.bodyMd(color: AppColors.primary)
                      .copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Chat Bubble
// ══════════════════════════════════════════════════════════════════════════════
class _ChatMsg {
  const _ChatMsg({
    required this.text,
    required this.isUser,
    required this.time,
  });
  final String text;
  final bool isUser;
  final String time;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.msg});
  final _ChatMsg msg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: msg.isUser
                  ? AppColors.primaryFixed.withValues(alpha: 0.10)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft:
                    msg.isUser ? const Radius.circular(12) : Radius.zero,
                bottomRight:
                    msg.isUser ? Radius.zero : const Radius.circular(12),
              ),
              border: Border.all(
                color: msg.isUser
                    ? AppColors.primaryFixed.withValues(alpha: 0.2)
                    : AppColors.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: msg.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  style: AppTextStyles.bodyMd(
                    color: msg.isUser ? AppColors.primaryFixed : AppColors.primary,
                  ).copyWith(fontSize: 14, height: 1.5),
                ),
                if (msg.time.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    msg.time,
                    style: AppTextStyles.labelSm(
                            color: AppColors.onSurfaceVariant)
                        .copyWith(fontSize: 9),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Typing Indicator
// ══════════════════════════════════════════════════════════════════════════════
class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Opacity(
                    opacity: (_anim.value - i * 0.15).clamp(0.3, 1.0),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryFixed,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Pulsing dot
// ══════════════════════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Opacity(
        opacity: _anim.value,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primaryFixed,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
