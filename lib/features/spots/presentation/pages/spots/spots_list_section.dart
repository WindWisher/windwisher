part of 'spots_page.dart';

extension _SpotsListSection on SpotsPageState {
  List<Widget> _buildSpotsListSection(TextTheme textTheme) {
    return [
      _buildSpotsHeaderCard(textTheme),
      const SizedBox(height: AppSpacing.sm),
      if (_spots.isEmpty)
        _buildEmptySpotsCard(textTheme)
      else ...[
        _buildFilterChips(),
        const SizedBox(height: AppSpacing.sm),
        _buildSearchField(),
        ..._buildPendingActionCard(textTheme),
        const SizedBox(height: AppSpacing.sm),
        _buildSortChips(),
        const SizedBox(height: AppSpacing.sm),
        if (_filteredSpots.isEmpty)
          _buildNoFilteredSpotsCard(textTheme)
        else if (_sort == _SpotSort.manual && !_isMultiMode)
          _buildReorderableSpotsList()
        else
          ..._filteredSpots.map(_buildSpotCard),
      ],
      const SizedBox(height: 96),
    ];
  }

  Widget _buildSpotsHeaderCard(TextTheme textTheme) {
    return _SpotsHeaderCard(hasAdvancedSpotAccess: _hasAdvancedSpotAccess);
  }

  Widget _buildEmptySpotsCard(TextTheme textTheme) {
    return const _EmptySpotsCard();
  }

  Widget _buildFilterChips() {
    return _SpotFilterChips(selectedFilter: _filter, onSelected: _setFilter);
  }

  Widget _buildSearchField() {
    return _SpotSearchField(
      controller: _searchController,
      query: _searchQuery,
      onChanged: _setSearchQuery,
      onClear: _clearSearchQuery,
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
      nearbyWebcamCount: _nearbyWebcamCount(spot),
      isSelected: _selectedSpotNames.contains(spot.name),
      isMultiMode: _isMultiMode,
      onTap: () => _handleCardTap(spot),
    );
  }

  Widget _buildReorderableSpotsList() {
    final spots = _filteredSpots;
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      itemCount: spots.length,
      onReorder: _handleSpotReorder,
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
    );
  }
}
