part of 'spots_page.dart';

extension _SpotsListSection on SpotsPageState {
  List<Widget> _buildSpotsListSection(TextTheme textTheme) {
    final topWidgets = <Widget>[
      _buildSpotsHeaderCard(textTheme),
      const SizedBox(height: AppSpacing.sm),
    ];

    if (_spots.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList.list(
            children: [
              ...topWidgets,
              _buildEmptySpotsCard(textTheme),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ];
    }

    final controls = <Widget>[
      ...topWidgets,
      _buildViewToggle(),
      const SizedBox(height: AppSpacing.sm),
      _buildSearchField(),
      ..._buildPendingActionCard(textTheme),
      const SizedBox(height: AppSpacing.sm),
      _buildSortChips(),
      const SizedBox(height: AppSpacing.sm),
    ];

    if (_filteredSpots.isEmpty) {
      return [
        SliverPadding(
          padding: const EdgeInsets.all(AppSpacing.md),
          sliver: SliverList.list(
            children: [
              ...controls,
              _buildNoFilteredSpotsCard(textTheme),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ];
    }

    final canReorder = _sort == _SpotSort.manual && !_isMultiMode;
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          0,
        ),
        sliver: SliverList.list(children: controls),
      ),
      if (canReorder)
        _buildReorderableSpotsSliver()
      else
        _buildSpotsSliverList(),
      const SliverToBoxAdapter(child: SizedBox(height: 96)),
    ];
  }

  Widget _buildSpotsHeaderCard(TextTheme textTheme) {
    return _SpotsHeaderCard(hasAdvancedSpotAccess: _hasAdvancedSpotAccess);
  }

  Widget _buildEmptySpotsCard(TextTheme textTheme) {
    return const _EmptySpotsCard();
  }

  Widget _buildViewToggle() {
    return _SpotViewToggle(selectedView: _viewMode, onSelected: _setViewMode);
  }

  Widget _buildSearchField({VoidCallback? onTap}) {
    return _SpotSearchField(
      controller: _searchController,
      query: _searchQuery,
      onChanged: _setSearchQuery,
      onClear: _clearSearchQuery,
      onTap: onTap,
    );
  }

  List<Widget> _buildPendingActionCard(TextTheme textTheme) {
    if (_pendingCardAction == _PendingCardAction.none) {
      return const [];
    }
    return [
      const SizedBox(height: AppSpacing.sm),
      _SpotPendingActionCard(
        label: _pendingActionLabel(),
        isMultiMode: _isMultiMode,
        selectedCount: _selectedSpotNames.length,
        onCancel: _cancelPendingActionMode,
        onApply: _applyPendingBatchAction,
      ),
    ];
  }

  String _pendingActionLabel() {
    return switch (_pendingCardAction) {
      _PendingCardAction.edit =>
        'Modo editar: toca un spot custom para editarlo',
      _PendingCardAction.deleteMany =>
        'Modo eliminar varios: selecciona spots y aplica',
      _PendingCardAction.none => '',
    };
  }

  Widget _buildSortChips() {
    return _SpotSortChips(selectedSort: _sort, onSelected: _setSort);
  }

  Widget _buildNoFilteredSpotsCard(TextTheme textTheme) {
    return const _NoFilteredSpotsCard();
  }

  Widget _buildSpotCard(_SpotItem spot) {
    final hasBackground = _canRenderLocalImage(spot.backgroundImagePath);
    return _SpotCard(
      spot: spot,
      hasBackground: hasBackground,
      isSelected: _selectedSpotNames.contains(spot.name),
      isMultiMode: _isMultiMode,
      onTap: () => _handleCardTap(spot),
      onShowMap: _canShowSpotMap(spot) ? () => _showSpotMapDialog(spot) : null,
    );
  }

  Widget _buildSpotsSliverList() {
    final spots = _filteredSpots;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverList.builder(
        itemCount: spots.length,
        itemBuilder: (context, index) => _buildSpotCard(spots[index]),
      ),
    );
  }

  Widget _buildReorderableSpotsSliver() {
    final spots = _filteredSpots;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      sliver: SliverReorderableList(
        itemCount: spots.length,
        onReorder: _handleSpotReorder,
        autoScrollerVelocityScalar: 70,
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            child: RepaintBoundary(child: child),
          );
        },
        itemBuilder: (context, index) {
          final spot = spots[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey('spot-card-${_spotOrderKey(spot)}'),
            index: index,
            child: _buildSpotCard(spot),
          );
        },
      ),
    );
  }
}
