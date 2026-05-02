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
        else
          ..._filteredSpots.map(_buildSpotCard),
      ],
      const SizedBox(height: 96),
    ];
  }

  Widget _buildSpotsHeaderCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spots', style: textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Aqui mostraremos spots guardados y meteo activa.',
              style: textTheme.bodyMedium,
            ),
            if (!_hasAdvancedSpotAccess) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Plan user: maximo 2 spots oficiales. Sin spots custom y sin edicion o borrado.',
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySpotsCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'Todavia no has agregado spots. Usa el boton + para anadir el primero.',
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            key: const Key('spots-filter-all'),
            label: 'Todos',
            value: _SpotFilter.all,
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildFilterChip(
            key: const Key('spots-filter-official'),
            label: 'Oficiales',
            value: _SpotFilter.official,
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildFilterChip(
            key: const Key('spots-filter-custom'),
            label: 'Custom',
            value: _SpotFilter.custom,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required Key key,
    required String label,
    required _SpotFilter value,
  }) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) => _setFilter(value),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      key: const Key('spots-search-input'),
      controller: _searchController,
      onChanged: _setSearchQuery,
      decoration: InputDecoration(
        labelText: 'Buscar spots',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                onPressed: _clearSearchQuery,
                tooltip: 'Limpiar busqueda',
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }

  List<Widget> _buildPendingActionCard(TextTheme textTheme) {
    if (_pendingCardAction == _PendingCardAction.none) {
      return const [];
    }
    return [
      const SizedBox(height: AppSpacing.sm),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_pendingActionLabel(), style: textTheme.bodyMedium),
              if (_isMultiMode) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${_selectedSpotNames.length} seleccionados',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    TextButton(
                      onPressed: _cancelPendingActionMode,
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilledButton(
                      onPressed: _applyPendingBatchAction,
                      child: const Text('Aplicar'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSortChip(
            key: const Key('spots-sort-recent'),
            label: 'Recientes',
            value: _SpotSort.recent,
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildSortChip(
            key: const Key('spots-sort-az'),
            label: 'A-Z',
            value: _SpotSort.az,
          ),
          const SizedBox(width: AppSpacing.xs),
          _buildSortChip(
            key: const Key('spots-sort-za'),
            label: 'Z-A',
            value: _SpotSort.za,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip({
    required Key key,
    required String label,
    required _SpotSort value,
  }) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: _sort == value,
      onSelected: (_) => _setSort(value),
    );
  }

  Widget _buildNoFilteredSpotsCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          'No hay spots para este filtro.',
          style: textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildSpotCard(_SpotItem spot) {
    final hasBackground = _canRenderLocalImage(spot.backgroundImagePath);
    return Padding(
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
                ),
              ),
            if (hasBackground) _buildSpotCardGradient(),
            _buildSpotTile(spot, hasBackground),
          ],
        ),
      ),
    );
  }

  Widget _buildSpotCardGradient() {
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

  Widget _buildSpotTile(_SpotItem spot, bool hasBackground) {
    return ListTile(
      selected: _selectedSpotNames.contains(spot.name),
      leading: const Icon(Icons.place_outlined),
      title: Text(spot.name),
      subtitle: _buildSpotTileSubtitle(spot, hasBackground),
      trailing: _isMultiMode ? _buildSelectionIcon(spot, hasBackground) : null,
      onTap: () => _handleCardTap(spot),
      textColor: hasBackground ? Colors.white : null,
      iconColor: hasBackground ? Colors.white : null,
    );
  }

  Widget _buildSpotTileSubtitle(_SpotItem spot, bool hasBackground) {
    final nearbyWebcamCount = _nearbyWebcamCount(spot);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(spot.area),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            if (spot.isCustom) _buildCustomChip(hasBackground),
            if (nearbyWebcamCount > 0) _buildWebcamChip(hasBackground),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomChip(bool hasBackground) {
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

  Widget _buildWebcamChip(bool hasBackground) {
    return Chip(
      backgroundColor: hasBackground
          ? Colors.black.withValues(alpha: 0.4)
          : null,
      label: Icon(
        Icons.videocam_rounded,
        size: 16,
        color: hasBackground ? Colors.white : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildSelectionIcon(_SpotItem spot, bool hasBackground) {
    return Icon(
      _selectedSpotNames.contains(spot.name)
          ? Icons.check_circle
          : Icons.radio_button_unchecked,
      color: hasBackground ? Colors.white : null,
    );
  }
}
