import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../utils/app_theme.dart';

/// 작은 배너 광고 위젯 (320x50)
class SmallBannerAdWidget extends StatefulWidget {
  const SmallBannerAdWidget({super.key});

  @override
  State<SmallBannerAdWidget> createState() => _SmallBannerAdWidgetState();
}

class _SmallBannerAdWidgetState extends State<SmallBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService().createSmallBanner(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('작은 배너 로드 실패: $error');
        ad.dispose();
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

/// 큰 배너 광고 위젯 (300x250) - 디자인 적용
class LargeBannerAdWidget extends StatefulWidget {
  final bool showLabel;

  const LargeBannerAdWidget({
    super.key,
    this.showLabel = true,
  });

  @override
  State<LargeBannerAdWidget> createState() => _LargeBannerAdWidgetState();
}

class _LargeBannerAdWidgetState extends State<LargeBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService().createLargeBanner(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('큰 배너 로드 실패: $error');
        ad.dispose();
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      // 로딩 중 플레이스홀더
      return Container(
        width: 300,
        height: 250,
        decoration: BoxDecoration(
          color: AppColors.darkGray.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.darkGray.withValues(alpha: 0.5),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabel)
              Container(
                width: _bannerAd!.size.width.toDouble(),
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.darkGray.withValues(alpha: 0.8),
                      AppColors.darkGray.withValues(alpha: 0.6),
                    ],
                  ),
                ),
                child: const Text(
                  '광고',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ],
        ),
      ),
    );
  }
}

/// 적응형 배너 위젯 (화면 너비에 맞춤)
class AdaptiveBannerAdWidget extends StatefulWidget {
  const AdaptiveBannerAdWidget({super.key});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bannerAd == null) {
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    final width = MediaQuery.of(context).size.width;
    _bannerAd = await AdService().createAdaptiveBanner(
      width: width,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() => _isLoaded = true);
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('적응형 배너 로드 실패: $error');
        ad.dispose();
      },
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox(height: 60);
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        color: AppColors.darkGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
