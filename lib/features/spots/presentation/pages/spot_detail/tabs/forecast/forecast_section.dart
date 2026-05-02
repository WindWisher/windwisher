part of '../../spot_detail_page.dart';

extension _SpotDetailForecastSection on _SpotDetailPageState {
  Widget _buildForecastProviderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _forecastProvider,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Proveedor meteo',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Open-Meteo', child: Text('Open-Meteo')),
        DropdownMenuItem(value: 'AEMET', child: Text('AEMET')),
        DropdownMenuItem(value: 'Windguru', child: Text('Windguru')),
        DropdownMenuItem(value: 'Meteoblue', child: Text('Meteoblue')),
        DropdownMenuItem(value: 'Meteosource', child: Text('Meteosource')),
        DropdownMenuItem<String>(value: 'Meteostat', child: Text('Meteostat')),
      ],
      onChanged: (value) {
        if (value == null) {
          return;
        }
        _handleForecastProviderChanged(value);
      },
    );
  }

  Widget _buildForecastModelControls() {
    if (_usesWindguruProvider()) {
      return const SizedBox.shrink();
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final modelDropdown = DropdownButtonFormField<String>(
          initialValue:
              _modelsForProvider(_forecastProvider).contains(_forecastModel)
              ? _forecastModel
              : _modelsForProvider(_forecastProvider).first,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Modelo de prevision',
            border: OutlineInputBorder(),
          ),
          selectedItemBuilder: (context) {
            return _modelsForProvider(_forecastProvider).map((model) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  model,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: _modelsForProvider(_forecastProvider).map((model) {
            final recommendation = getSpotForecastModelRecommendation(
              spotName: widget.name,
              provider: _forecastProvider,
              model: model,
            );
            return DropdownMenuItem<String>(
              value: model,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Text(
                      model,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (recommendation != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Chip(
                      label: Text(recommendation.badgeLabel),
                      labelStyle: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      side: BorderSide.none,
                      backgroundColor: recommendation.badgeLabel == 'Top'
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.tertiaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            _handleForecastModelChanged(value);
          },
        );

        final infoButton = IconButton(
          tooltip: 'Info del modelo',
          onPressed: _showForecastModelInfoDialog,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.info_outline_rounded),
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: modelDropdown),
            const SizedBox(width: AppSpacing.xs),
            infoButton,
          ],
        );
      },
    );
  }

  Widget _buildWindMapButton() {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<_ForecastLoadResult>(
      future: _forecastRowsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final result = snapshot.data;
        if (result == null || !_canBuildWindMapFromForecastResult(result)) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openWindMap,
            icon: const Icon(Icons.air_outlined),
            label: const Text('Mapa de viento'),
          ),
        );
      },
    );
  }

  Widget _buildWindMapButtonBlock() {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        const SizedBox(height: AppSpacing.sm),
        _buildWindMapButton(),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildForecastSectionBody() {
    if (_usesWindguruProvider()) {
      return _buildWindguruForecastSection();
    }
    if (_usesAemetBeachForecastModel()) {
      return _buildAemetBeachForecastSection();
    }
    if (_usesAemetCoastalForecastModel()) {
      return _buildAemetCoastalForecastSection();
    }
    return FutureBuilder<_ForecastLoadResult>(
      future: _forecastRowsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _ForecastLoadResult(
              rows: const <_ForecastRow>[],
              source: _ForecastDataSource.fallback,
              message: 'No se han podido cargar datos.',
            );
        return _buildForecastSupplementOrTable(result);
      },
    );
  }

  Widget _buildForecastSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForecastProviderDropdown(),
          const SizedBox(height: AppSpacing.sm),
          if (!_usesWindguruProvider()) ...[_buildForecastModelControls()],
          _buildWindMapButtonBlock(),
          _buildForecastSectionBody(),
        ],
      ),
    );
  }
}
