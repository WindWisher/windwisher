part of '../spots_page.dart';

class _SpotCard extends StatelessWidget {
  const _SpotCard({
    required this.spot,
    required this.hasBackground,
    required this.isSelected,
    required this.isMultiMode,
    required this.onTap,
    required this.onShowMap,
  });

  final _SpotItem spot;
  final bool hasBackground;
  final bool isSelected;
  final bool isMultiMode;
  final VoidCallback onTap;
  final VoidCallback? onShowMap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (hasBackground)
                Positioned.fill(
                  child: Image.file(
                    File(spot.backgroundImagePath!),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                  ),
                ),
              if (hasBackground) const _SpotCardGradient(),
              _SpotTile(
                spot: spot,
                hasBackground: hasBackground,
                isSelected: isSelected,
                isMultiMode: isMultiMode,
                onTap: onTap,
                onShowMap: onShowMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotCardGradient extends StatelessWidget {
  const _SpotCardGradient();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black.withValues(alpha: 0.45),
              Colors.black.withValues(alpha: 0.2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({
    required this.spot,
    required this.hasBackground,
    required this.isSelected,
    required this.isMultiMode,
    required this.onTap,
    required this.onShowMap,
  });

  final _SpotItem spot;
  final bool hasBackground;
  final bool isSelected;
  final bool isMultiMode;
  final VoidCallback onTap;
  final VoidCallback? onShowMap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: isSelected,
      leading: const Icon(Icons.place_outlined),
      title: Text(spot.name),
      subtitle: _SpotTileSubtitle(spot: spot, hasBackground: hasBackground),
      trailing: isMultiMode
          ? _SpotSelectionIcon(
              isSelected: isSelected,
              hasBackground: hasBackground,
            )
          : _SpotMapButton(hasBackground: hasBackground, onPressed: onShowMap),
      onTap: onTap,
      textColor: hasBackground ? Colors.white : null,
      iconColor: hasBackground ? Colors.white : null,
    );
  }
}

class _SpotTileSubtitle extends StatelessWidget {
  const _SpotTileSubtitle({required this.spot, required this.hasBackground});

  final _SpotItem spot;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(spot.area),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (spot.isCustom) _SpotCustomChip(hasBackground: hasBackground),
          ],
        ),
      ],
    );
  }
}

class _SpotCustomChip extends StatelessWidget {
  const _SpotCustomChip({required this.hasBackground});

  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: hasBackground
          ? Colors.black.withValues(alpha: 0.4)
          : null,
      label: Text(
        'Custom',
        style: hasBackground ? const TextStyle(color: Colors.white) : null,
      ),
    );
  }
}

class _SpotSelectionIcon extends StatelessWidget {
  const _SpotSelectionIcon({
    required this.isSelected,
    required this.hasBackground,
  });

  final bool isSelected;
  final bool hasBackground;

  @override
  Widget build(BuildContext context) {
    return Icon(
      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
      color: hasBackground ? Colors.white : null,
    );
  }
}

class _SpotMapButton extends StatelessWidget {
  const _SpotMapButton({required this.hasBackground, required this.onPressed});

  final bool hasBackground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (onPressed == null) {
      return const SizedBox.shrink();
    }
    return IconButton.filledTonal(
      tooltip: 'Ver ubicacion',
      onPressed: onPressed,
      icon: Icon(
        Icons.map_outlined,
        color: hasBackground ? Colors.white : null,
      ),
      style: IconButton.styleFrom(
        backgroundColor: hasBackground
            ? Colors.black.withValues(alpha: 0.35)
            : null,
      ),
    );
  }
}
