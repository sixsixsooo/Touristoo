import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/ads_service.dart';
import '../../../../core/services/audio_service.dart';

class RewardedAdButton extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onRewardEarned;
  final Color? backgroundColor;
  final Color? textColor;
  final bool enabled;

  const RewardedAdButton({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onRewardEarned,
    this.backgroundColor,
    this.textColor,
    this.enabled = true,
  });

  @override
  ConsumerState<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  bool _isLoading = false;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRewardedAd();
  }

  Future<void> _loadRewardedAd() async {
    final adsService = ref.read(adsServiceProvider);
    
    await adsService.loadRewardedAd(
      onAdRewarded: () {
        widget.onRewardEarned();
        _showRewardDialog();
      },
      onAdClosed: () {
        setState(() {
          _isLoading = false;
        });
      },
      onAdFailedToLoad: (error) {
        setState(() {
          _isAdLoaded = false;
          _isLoading = false;
        });
        _showErrorDialog(error);
      },
    );
    
    setState(() {
      _isAdLoaded = adsService.isRewardedLoaded;
    });
  }

  Future<void> _showRewardedAd() async {
    if (!_isAdLoaded) {
      _showErrorDialog('Реклама не загружена');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final adsService = ref.read(adsServiceProvider);
    final success = await adsService.showRewardedAd();
    
    if (!success) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Не удалось показать рекламу');
    }
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Награда получена!'),
          ],
        ),
        content: Text(
          'Вы получили награду за просмотр рекламы!',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отлично'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Ошибка'),
          ],
        ),
        content: Text(
          error,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = ref.read(audioServiceProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: (!widget.enabled || _isLoading || !_isAdLoaded) 
            ? null 
            : () {
                audioService.playButtonSound();
                _showRewardedAd();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor ?? const Color(0xFF7B68EE),
          foregroundColor: widget.textColor ?? Colors.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.description.isNotEmpty)
                          Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              opacity: 0.8,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.play_arrow, size: 20),
                ],
              ),
      ),
    );
  }
}
