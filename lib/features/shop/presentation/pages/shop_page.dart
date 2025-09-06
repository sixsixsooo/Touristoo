import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/game_providers.dart';
import '../../../../core/services/audio_service.dart';
import '../widgets/shop_header_widget.dart';
import '../widgets/skins_section_widget.dart';
import '../widgets/coin_packs_section_widget.dart';
import '../../../ads/presentation/widgets/banner_ad_widget.dart';
import '../../../ads/presentation/widgets/rewarded_ad_button.dart';
import '../../../ads/presentation/widgets/interstitial_ad_manager.dart';

class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final player = ref.watch(playerProvider);
    final audioService = ref.read(audioServiceProvider);

    return InterstitialAdManager(
      showAdOnShopOpen: true,
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        context.go('/home');
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Shop',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        audioService.playButtonSound();
                        // TODO: Show purchase history
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Shop Header
              ShopHeaderWidget(player: player),
              
              const SizedBox(height: 16),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Skins'),
                    Tab(text: 'Coins'),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Skins Tab
                    SkinsSectionWidget(
                      onSkinPurchased: (skinId) {
                        audioService.playButtonSound();
                        ref.read(playerProvider.notifier).unlockSkin(skinId);
                        ref.read(playerProvider.notifier).changeSkin(skinId);
                      },
                      onSkinSelected: (skinId) {
                        audioService.playButtonSound();
                        ref.read(playerProvider.notifier).changeSkin(skinId);
                      },
                    ),
                    
                    // Coins Tab
                    CoinPacksSectionWidget(
                      onPurchase: (packId, price) {
                        audioService.playButtonSound();
                        // TODO: Implement coin pack purchase
                        _showPurchaseDialog(context, packId, price);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context, String packId, int price) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Purchase Coins'),
        content: Text('Buy $packId for $price coins?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Process purchase
            },
            child: cons