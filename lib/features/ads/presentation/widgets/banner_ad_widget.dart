import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yandex_mobileads/yandex_mobileads.dart';

import '../../../../core/services/ads_service.dart';

class BannerAdWidget extends ConsumerStatefulWidget {
  final double? height;
  final EdgeInsets? margin;
  final Color? backgroundColor;

  const BannerAdWidget({
    super.key,
    this.height,
    this.margin,
    this.backgroundColor,
  });

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerAd() async {
    final adsService = ref.read(adsServiceProvider);
    
    await adsService.loadBannerAd(
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _bannerAd = adsService.getBannerAd();
            _isAdLoaded = true;
            _isLoading = false;
          });
        }
      },
      onAdFailedToLoad: (error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _isLoading = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: widget.height ?? 50,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: widget.height ?? 50,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _errorMessage ?? 'Реклама недоступна',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return Container(
      height: widget.height ?? 50,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
