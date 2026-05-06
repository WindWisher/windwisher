// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastTableSection on _SpotDetailPageState {
  Widget _compactLabelCell(String text, {double? minHeight}) {
    return Container(
      alignment: Alignment.centerLeft,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: minHeight == null ? 8 : 4,
      ),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  bool _isForecastDayStart(List<_ForecastRow> rows, int index) {
    if (index == 0) {
      return true;
    }
    final current = rows[index].slotTime;
    final previous = rows[index - 1].slotTime;
    return current.year != previous.year ||
        current.month != previous.month ||
        current.day != previous.day;
  }

  Widget _forecastHourCell(
    List<_ForecastRow> rows,
    int index, {
    double? minHeight,
  }) {
    final isDayStart = _isForecastDayStart(rows, index);

    return _forecastColumnCell(
      isDayStart: isDayStart,
      child: _compactValueCell(
        rows[index].hour,
        bold: true,
        minHeight: minHeight,
      ),
    );
  }

  Widget _forecastColumnCell({
    required bool isDayStart,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: isDayStart ? colorScheme.primary : Colors.transparent,
            width: isDayStart ? 4 : 0,
          ),
        ),
      ),
      child: child,
    );
  }

  Widget _compactValueCell(
    String text, {
    Color? color,
    bool bold = false,
    Color? textColor,
    double? minHeight,
  }) {
    return Container(
      alignment: Alignment.center,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 6,
        vertical: minHeight == null ? 8 : 4,
      ),
      color: color,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _compactDirectionCell(int degrees, {double? minHeight}) {
    final normalizedDegrees = _normalizeDegrees(degrees.toDouble());
    return Container(
      alignment: Alignment.center,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: 4,
        vertical: minHeight == null ? 6 : 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: ((normalizedDegrees - 45 + 180) * math.pi) / 180,
            child: const Icon(Icons.near_me_rounded, size: 18),
          ),
          const SizedBox(height: 2),
          Text(
            _degreesToCardinal(normalizedDegrees),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _compactNullableDirectionCell(int? degrees, {double? minHeight}) {
    if (degrees == null) {
      return _compactValueCell('-', minHeight: minHeight);
    }
    return _compactDirectionCell(degrees, minHeight: minHeight);
  }

  TableRow _forecastMetricRow({
    required String label,
    required List<_ForecastRow> rows,
    required String Function(_ForecastRow row) valueText,
    Color? Function(_ForecastRow row)? color,
    Color? Function(_ForecastRow row)? textColor,
    bool bold = false,
    double? minHeight,
  }) {
    return TableRow(
      children: [
        _compactLabelCell(label, minHeight: minHeight),
        ...rows.asMap().entries.map(
          (entry) => _forecastColumnCell(
            isDayStart: _isForecastDayStart(rows, entry.key),
            child: _compactValueCell(
              valueText(entry.value),
              color: color?.call(entry.value),
              textColor: textColor?.call(entry.value),
              bold: bold,
              minHeight: minHeight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastRangeSelector({
    _ForecastRange? selectedRange,
    ValueChanged<_ForecastRange>? onRangeChanged,
  }) {
    return _ForecastRangeSelector(
      ranges: _availableForecastRanges(_forecastProvider),
      selectedRange: selectedRange ?? _forecastRange,
      onRangeChanged: (range) {
        if (onRangeChanged != null) {
          onRangeChanged(range);
        } else {
          setState(() {
            _forecastRange = range;
          });
        }
      },
    );
  }

  Widget _buildWindguruStyleTable({
    List<_ForecastRow>? rowsOverride,
    _ForecastRange? selectedRange,
    bool showRangeSelector = true,
    bool showResolutionSelector = false,
    bool showFullscreenButton = true,
    bool expandToFill = false,
    double? fullscreenRowHeight,
    _ForecastResolution? fullscreenResolution,
    ValueChanged<_ForecastRange>? onRangeChanged,
    ValueChanged<_ForecastResolution>? onResolutionChanged,
    VoidCallback? onOpenFullscreen,
  }) {
    final rows =
        rowsOverride ?? _rowsForSelectedForecastRange(_forecastProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final selectedResolution = fullscreenResolution == null
        ? null
        : _effectiveForecastResolution(
            selectedRange ?? _forecastRange,
            fullscreenResolution,
          );
    final columnWidth = _forecastColumnWidth(selectedResolution);

    final tableScroll = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Table(
        defaultColumnWidth: FixedColumnWidth(columnWidth),
        border: TableBorder(
          horizontalInside: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.7),
            width: 0.6,
          ),
          verticalInside: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.45),
            width: 0.5,
          ),
        ),
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
            ),
            children: [
              _compactLabelCell('Hora', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastHourCell(
                  rows,
                  entry.key,
                  minHeight: fullscreenRowHeight,
                ),
              ),
            ],
          ),
          _forecastMetricRow(
            label: 'Viento',
            rows: rows,
            valueText: (row) => '${row.windKnots}',
            color: (row) => _windColor(row.windKnots),
            bold: true,
            minHeight: fullscreenRowHeight,
          ),
          if (rows.any((row) => row.gustKnots != null))
            _forecastMetricRow(
              label: 'Racha',
              rows: rows,
              valueText: (row) =>
                  _nullableMetricText(row.gustKnots?.toString()),
              color: (row) =>
                  row.gustKnots == null ? null : _windColor(row.gustKnots!),
              minHeight: fullscreenRowHeight,
            ),
          TableRow(
            children: [
              _compactLabelCell('Dir', minHeight: fullscreenRowHeight),
              ...rows.asMap().entries.map(
                (entry) => _forecastColumnCell(
                  isDayStart: _isForecastDayStart(rows, entry.key),
                  child: _compactDirectionCell(
                    entry.value.windDeg,
                    minHeight: fullscreenRowHeight,
                  ),
                ),
              ),
            ],
          ),
          if (rows.any((row) => row.waveM != null))
            _forecastMetricRow(
              label: 'Olas',
              rows: rows,
              valueText: (row) =>
                  _nullableMetricText(row.waveM?.toStringAsFixed(1)),
              color: (row) => row.waveM == null
                  ? null
                  : const Color(0xFFB3E5FC).withValues(alpha: 0.75),
              minHeight: fullscreenRowHeight,
            ),
          if (rows.any((row) => row.wavePeriodSeconds != null))
            _forecastMetricRow(
              label: 'Periodo',
              rows: rows,
              valueText: (row) => _nullableMetricText(
                row.wavePeriodSeconds?.toStringAsFixed(1),
              ),
              minHeight: fullscreenRowHeight,
            ),
          if (rows.any((row) => row.waveDirDeg != null))
            TableRow(
              children: [
                _compactLabelCell('Dir ola', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactNullableDirectionCell(
                      entry.value.waveDirDeg,
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.pressureHpa != null))
            _forecastMetricRow(
              label: 'Presion',
              rows: rows,
              valueText: (row) =>
                  _nullableMetricText(row.pressureHpa?.toString()),
              textColor: (row) => row.pressureHpa == null
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.55)
                  : colorScheme.onSurfaceVariant,
              minHeight: fullscreenRowHeight,
            ),
          if (rows.any((row) => row.waterTempC != null))
            TableRow(
              children: [
                _compactLabelCell('Agua', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      _nullableMetricText(
                        entry.value.waterTempC == null
                            ? null
                            : '${entry.value.waterTempC}${_SpotDetailPageState._degreeSymbol}',
                      ),
                      color: entry.value.waterTempC == null
                          ? null
                          : _waterTempColor(entry.value.waterTempC!),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.currentMps != null))
            TableRow(
              children: [
                _compactLabelCell('Corr.', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      _nullableMetricText(
                        entry.value.currentMps?.toStringAsFixed(2),
                      ),
                      color: entry.value.currentMps == null
                          ? null
                          : const Color(0xFF80CBC4).withValues(alpha: 0.65),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.currentDirDeg != null))
            TableRow(
              children: [
                _compactLabelCell('Dir corr.', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactNullableDirectionCell(
                      entry.value.currentDirDeg,
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.salinityPsu != null))
            TableRow(
              children: [
                _compactLabelCell('Sal.', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      _nullableMetricText(
                        entry.value.salinityPsu?.toStringAsFixed(1),
                      ),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.tempC != null))
            TableRow(
              children: [
                _compactLabelCell('Aire', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      _nullableMetricText(
                        entry.value.tempC == null
                            ? null
                            : '${entry.value.tempC}${_SpotDetailPageState._degreeSymbol}',
                      ),
                      color: entry.value.tempC == null
                          ? null
                          : _airTempColor(entry.value.tempC!),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.cloudCoverPct != null))
            TableRow(
              children: [
                _compactLabelCell('Nubes', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      _nullableMetricText(
                        entry.value.cloudCoverPct == null
                            ? null
                            : '${entry.value.cloudCoverPct}%',
                      ),
                      color: entry.value.cloudCoverPct == null
                          ? null
                          : colorScheme.surfaceContainerHighest.withValues(
                              alpha: 0.24,
                            ),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
          if (rows.any((row) => row.rainMm != null))
            TableRow(
              children: [
                _compactLabelCell('Lluvia', minHeight: fullscreenRowHeight),
                ...rows.asMap().entries.map(
                  (entry) => _forecastColumnCell(
                    isDayStart: _isForecastDayStart(rows, entry.key),
                    child: _compactValueCell(
                      entry.value.rainMm == null
                          ? '-'
                          : entry.value.rainMm! > 0
                          ? entry.value.rainMm!.toStringAsFixed(1)
                          : '-',
                      color: entry.value.rainMm == null
                          ? null
                          : _rainColor(
                              entry.value.rainMm!,
                            ).withValues(alpha: 0.8),
                      minHeight: fullscreenRowHeight,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );

    return Stack(
      fit: expandToFill ? StackFit.expand : StackFit.loose,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(expandToFill ? 0 : 16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: expandToFill ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRangeSelector)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: _buildForecastRangeSelector(
                    selectedRange: selectedRange,
                    onRangeChanged: onRangeChanged,
                  ),
                ),
              if (showResolutionSelector)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: _ForecastResolutionSelector(
                    resolutions: _allowedForecastResolutions(
                      selectedRange ?? _forecastRange,
                    ),
                    selectedResolution:
                        selectedResolution ??
                        _preferredForecastResolution(
                          selectedRange ?? _forecastRange,
                        ),
                    onResolutionChanged: onResolutionChanged,
                  ),
                ),
              if (showRangeSelector) const Divider(height: 1),
              if (expandToFill) Expanded(child: tableScroll) else tableScroll,
            ],
          ),
        ),
        if (showFullscreenButton)
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: onOpenFullscreen,
              tooltip: 'Ampliar tabla',
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          ),
      ],
    );
  }
}
