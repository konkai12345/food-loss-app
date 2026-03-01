import 'package:flutter/material.dart';
import '../themes/natural_eco_theme_fixed.dart';

class NaturalEcoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final bool isExpiring;
  final bool isExpired;
  final Widget? trailing;

  const NaturalEcoCard({
    Key? key,
    required this.child,
    this.margin,
    this.padding,
    this.onTap,
    this.isExpiring = false,
    this.isExpired = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    
    if (isExpired) {
      decoration = NaturalEcoThemeFixed.expiredCardDecoration;
    } else if (isExpiring) {
      decoration = NaturalEcoThemeFixed.expiringCardDecoration;
    } else {
      decoration = NaturalEcoThemeFixed.cardDecoration;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: decoration,
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: padding ?? const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: child),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class NaturalEcoStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;

  const NaturalEcoStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: NaturalEcoThemeFixed.statCardDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: iconColor ?? NaturalEcoThemeFixed.primaryGreen,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: NaturalEcoThemeFixed.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class NaturalEcoButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;

  const NaturalEcoButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: backgroundColor != null 
            ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
            : NaturalEcoThemeFixed.primaryGradient,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? NaturalEcoThemeFixed.primaryGreen).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: textColor ?? Colors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class NaturalEcoChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onDelete;

  const NaturalEcoChip({
    Key? key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? NaturalEcoThemeFixed.lightGrey,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: NaturalEcoThemeFixed.woodBrown.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: textColor ?? NaturalEcoThemeFixed.darkGrey,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? NaturalEcoThemeFixed.darkGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: 14,
                color: textColor ?? NaturalEcoThemeFixed.darkGrey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NaturalEcoExpiryBadge extends StatelessWidget {
  final int daysUntilExpiry;
  final bool isExpired;

  const NaturalEcoExpiryBadge({
    Key? key,
    required this.daysUntilExpiry,
    this.isExpired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String text;

    if (isExpired) {
      backgroundColor = NaturalEcoThemeFixed.darkGrey;
      textColor = Colors.white;
      text = '期限切れ';
    } else if (daysUntilExpiry <= 2) {
      backgroundColor = const Color(0xFFFF9800);
      textColor = Colors.white;
      text = '残り${daysUntilExpiry}日';
    } else {
      backgroundColor = NaturalEcoThemeFixed.primaryGreen;
      textColor = Colors.white;
      text = '残り${daysUntilExpiry}日';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class NaturalEcoCategoryIcon extends StatelessWidget {
  final String category;
  final double size;

  const NaturalEcoCategoryIcon({
    Key? key,
    required this.category,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (category.toLowerCase()) {
      case '野菜':
        iconData = Icons.eco;
        iconColor = NaturalEcoThemeFixed.primaryGreen;
        break;
      case '果物':
        iconData = Icons.apple;
        iconColor = const Color(0xFFFF5722);
        break;
      case '肉類':
        iconData = Icons.restaurant;
        iconColor = NaturalEcoThemeFixed.woodBrown;
        break;
      case '魚介類':
        iconData = Icons.set_meal;
        iconColor = NaturalEcoThemeFixed.skyBlue;
        break;
      case '乳製品':
        iconData = Icons.egg;
        iconColor = NaturalEcoThemeFixed.lightBrown;
        break;
      case '調味料':
        iconData = Icons.opacity;
        iconColor = NaturalEcoThemeFixed.darkGreen;
        break;
      default:
        iconData = Icons.category;
        iconColor = NaturalEcoThemeFixed.mediumGrey;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: iconColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        size: size * 0.6,
        color: iconColor,
      ),
    );
  }
}

class NaturalEcoLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const NaturalEcoLoadingIndicator({
    Key? key,
    this.message,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: NaturalEcoThemeFixed.primaryGradient,
              borderRadius: BorderRadius.circular(size / 2),
              boxShadow: [
                BoxShadow(
                  color: NaturalEcoThemeFixed.primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class NaturalEcoEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? action;

  const NaturalEcoEmptyState({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: NaturalEcoThemeFixed.lightGrey,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: NaturalEcoThemeFixed.woodBrown.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: NaturalEcoThemeFixed.mediumGrey,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: NaturalEcoThemeFixed.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class NaturalEcoBackground extends StatelessWidget {
  final Widget child;

  const NaturalEcoBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            NaturalEcoThemeFixed.linenBackground,
            NaturalEcoThemeFixed.linenBackground.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // 木目調のテクスチャ効果
          Positioned.fill(
            child: CustomPaint(
              painter: WoodTexturePainter(),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class WoodTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = NaturalEcoThemeFixed.woodBrown.withOpacity(0.02)
      ..style = PaintingStyle.fill;

    // 木目の線を描画
    for (int i = 0; i < 20; i++) {
      final y = (size.height / 20) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 垂直の木目
    for (int i = 0; i < 30; i++) {
      final x = (size.width / 30) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 10, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
