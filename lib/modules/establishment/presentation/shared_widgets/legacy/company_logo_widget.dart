import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:symmetry_establishment/modules/establishment/presentation/shared_widgets/legacy/company_logo_service.dart';
import 'package:symmetry_establishment/app/resources/value_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
/// Drop-in logo widget used by ALL app bars.
///
/// • Listens to [CompanyLogoService] via ValueNotifier — zero extra rebuilds
/// • Shows shimmer while loading, network image when ready, fallback on error
/// • Detects SVG by URL extension only (.svg) — ignores unreliable logoType
/// • Tap navigates to /home
/// • Fetches the logo automatically once, in initState — not tied to build
///
/// Usage (in any AppBar):
///   child: const CompanyLogoWidget(),
// ─────────────────────────────────────────────────────────────────────────────
class CompanyLogoWidget extends StatefulWidget {
  const CompanyLogoWidget({
    super.key,
    this.width = AppSize.s181,
    this.height = 60,
    this.navigateOnTap = true,
  });

  final double width;
  final double height;
  final bool navigateOnTap;

  @override
  State<CompanyLogoWidget> createState() => _CompanyLogoWidgetState();
}

class _CompanyLogoWidgetState extends State<CompanyLogoWidget> {
  final CompanyLogoService _service = CompanyLogoService.instance;

  @override
  void initState() {
    super.initState();
    // Fire the fetch exactly once when this widget enters the tree, instead
    // of from inside build()/idle-case, which re-scheduled a callback on
    // every rebuild while idle and depended on render timing.
    if (_service.statusNotifier.value == LogoStatus.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _service.init(context);
      });
    }
  }

  // ── SVG detection — URL extension only, never trust logoType ─────────────
  bool _isSvg(String url) {
    return url.toLowerCase().split('?').first.endsWith('.svg');
  }

  // ── Fallback asset ────────────────────────────────────────────────────────
  Widget _fallback() => Image.asset(
    'images/logo_login.png',
    width: widget.width,
    height: widget.height,
    fit: BoxFit.fill,
  );

  // ── Main logo from network ────────────────────────────────────────────────
  Widget _networkLogo(String url) {
    if (_isSvg(url)) {
      return SvgPicture.network(
        url,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.fill,
        placeholderBuilder: (_) => _Shimmer(width: widget.width, height: widget.height),
        errorBuilder: (_, error, __) {
          debugPrint('CompanyLogoWidget – SVG error: $error');
          return _fallback();
        },
      );
    }

    return Image.network(
      url,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.fill,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return _Shimmer(width: widget.width, height: widget.height);
      },
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: widget.navigateOnTap
          ? () => Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        ModalRoute.withName('/home'),
      )
          : null,
      child: SizedBox(
        width: widget.width,
        child: ValueListenableBuilder<LogoStatus>(
          valueListenable: _service.statusNotifier,
          builder: (context, status, _) {
            switch (status) {
            // ── Still loading ─────────────────────────────────────────────
              case LogoStatus.idle:
              case LogoStatus.loading:
                return _Shimmer(width: widget.width, height: widget.height);

            // ── Loaded ────────────────────────────────────────────────────
              case LogoStatus.loaded:
                final url = _service.cachedLogo?[0].logoUrl;
                if (url == null || url.trim().isEmpty) return _fallback();
                return _networkLogo(url);

            // ── Error ─────────────────────────────────────────────────────
              case LogoStatus.error:
                return _fallback();
            }
          },
        ),
      ),
    );
  }
}

// ── Lightweight shimmer ───────────────────────────────────────────────────────
class _Shimmer extends StatefulWidget {
  const _Shimmer({required this.width, required this.height});

  final double width;
  final double height;

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}