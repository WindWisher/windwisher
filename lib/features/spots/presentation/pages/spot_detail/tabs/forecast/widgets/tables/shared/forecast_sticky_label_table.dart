import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ForecastStickyLabelTable extends StatefulWidget {
  const ForecastStickyLabelTable({
    super.key,
    required this.rows,
    required this.labelColumnWidth,
    required this.valueColumnWidth,
    this.border,
    this.physics = const BouncingScrollPhysics(),
  });

  final List<TableRow> rows;
  final double labelColumnWidth;
  final double valueColumnWidth;
  final TableBorder? border;
  final ScrollPhysics physics;

  @override
  State<ForecastStickyLabelTable> createState() => _StickyTableState();
}

class _StickyTableState extends State<ForecastStickyLabelTable> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rows.isEmpty) return const SizedBox.shrink();
    final columns = widget.rows.first.children.length;
    if (columns == 0 || widget.rows.any((r) => r.children.length != columns)) {
      throw ArgumentError(
        'Forecast rows must have the same nonzero cell count',
      );
    }
    final horizontalTable = SingleChildScrollView(
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      physics: widget.physics,
      child: AnimatedBuilder(
        animation: _scroll,
        builder: (context, _) => _ForecastGrid(
          columns: columns,
          labelWidth: widget.labelColumnWidth,
          valueWidth: widget.valueColumnWidth,
          offset: _scroll.hasClients ? _scroll.offset : 0,
          background: Theme.of(context).colorScheme.surface,
          border: widget.border,
          children: [
            for (final row in widget.rows)
              for (final cell in row.children)
                DecoratedBox(
                  decoration: row.decoration ?? const BoxDecoration(),
                  child: cell,
                ),
          ],
        ),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) => constraints.hasBoundedHeight
          ? SingleChildScrollView(child: horizontalTable)
          : horizontalTable,
    );
  }
}

class _ForecastGrid extends MultiChildRenderObjectWidget {
  const _ForecastGrid({
    required this.columns,
    required this.labelWidth,
    required this.valueWidth,
    required this.offset,
    required this.background,
    required this.border,
    required super.children,
  });

  final int columns;
  final double labelWidth, valueWidth, offset;
  final Color background;
  final TableBorder? border;

  @override
  _RenderForecastGrid createRenderObject(BuildContext context) =>
      _RenderForecastGrid()..configure(
        columns,
        labelWidth,
        valueWidth,
        offset,
        background,
        border,
      );

  @override
  void updateRenderObject(BuildContext context, _RenderForecastGrid render) {
    render.configure(
      columns,
      labelWidth,
      valueWidth,
      offset,
      background,
      border,
    );
  }
}

class _ForecastCellParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderForecastGrid extends RenderBox
    with
        ContainerRenderObjectMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        >,
        RenderBoxContainerDefaultsMixin<
          RenderBox,
          ContainerBoxParentData<RenderBox>
        > {
  int _columns = 1;
  double _labelWidth = 1, _valueWidth = 1, _offset = 0;
  Color _background = Colors.white;
  TableBorder? _border;
  final _rowTops = <double>[];

  void configure(
    int columns,
    double labelWidth,
    double valueWidth,
    double offset,
    Color background,
    TableBorder? border,
  ) {
    if (_columns != columns ||
        _labelWidth != labelWidth ||
        _valueWidth != valueWidth) {
      _columns = columns;
      _labelWidth = labelWidth;
      _valueWidth = valueWidth;
      markNeedsLayout();
    }
    _offset = offset;
    _background = background;
    _border = border;
    var index = 0;
    for (final child in getChildrenAsList()) {
      if (index++ % _columns == 0) {
        final data = child.parentData! as ContainerBoxParentData<RenderBox>;
        data.offset = Offset(_offset, data.offset.dy);
      }
    }
    markNeedsPaint();
    markNeedsSemanticsUpdate();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! ContainerBoxParentData<RenderBox>) {
      child.parentData = _ForecastCellParentData();
    }
  }

  @override
  void performLayout() {
    final cells = getChildrenAsList();
    _rowTops.clear();
    var y = 0.0;
    for (var start = 0; start < cells.length; start += _columns) {
      var height = 0.0;
      // Measure every cell before assigning one shared height to the whole row.
      for (var column = 0; column < _columns; column++) {
        final cell = cells[start + column];
        cell.layout(
          BoxConstraints.tightFor(
            width: column == 0 ? _labelWidth : _valueWidth,
          ),
          parentUsesSize: true,
        );
        height = math.max(height, cell.size.height);
      }
      _rowTops.add(y);
      for (var column = 0; column < _columns; column++) {
        final cell = cells[start + column];
        cell.layout(
          BoxConstraints.tightFor(
            width: column == 0 ? _labelWidth : _valueWidth,
            height: height,
          ),
          parentUsesSize: true,
        );
        final data = cell.parentData! as ContainerBoxParentData<RenderBox>;
        data.offset = Offset(
          column == 0 ? _offset : _labelWidth + (column - 1) * _valueWidth,
          y,
        );
      }
      y += height;
    }
    size = constraints.constrain(
      Size(_labelWidth + (_columns - 1) * _valueWidth, y),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final cells = getChildrenAsList();
    for (var i = 0; i < cells.length; i++) {
      if (i % _columns != 0) {
        final data = cells[i].parentData! as ContainerBoxParentData<RenderBox>;
        context.paintChild(cells[i], offset + data.offset);
      }
    }
    _border?.paint(
      context.canvas,
      offset & size,
      rows: _rowTops.skip(1),
      columns: [
        for (var i = 0; i < _columns - 1; i++) _labelWidth + i * _valueWidth,
      ],
    );
    // Labels paint last so scrolling values cannot cover the pinned column.
    final labelRect =
        (offset + Offset(_offset, 0)) & Size(_labelWidth, size.height);
    context.canvas.drawRect(labelRect, Paint()..color = _background);
    for (var i = 0; i < cells.length; i += _columns) {
      final data = cells[i].parentData! as ContainerBoxParentData<RenderBox>;
      context.paintChild(cells[i], offset + data.offset);
    }
    _border?.paint(
      context.canvas,
      labelRect,
      rows: _rowTops.skip(1),
      columns: const [],
    );
    final divider = _border?.verticalInside;
    if (divider != null && divider.style != BorderStyle.none) {
      context.canvas.drawLine(
        labelRect.topRight,
        labelRect.bottomRight,
        divider.toPaint(),
      );
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final cells = getChildrenAsList();
    final indices = [
      for (var i = 0; i < cells.length; i += _columns) i,
      for (var i = cells.length - 1; i >= 0; i--)
        if (i % _columns != 0) i,
    ];
    for (final i in indices) {
      final data = cells[i].parentData! as ContainerBoxParentData<RenderBox>;
      if (result.addWithPaintOffset(
        offset: data.offset,
        position: position,
        hitTest: (result, position) =>
            cells[i].hitTest(result, position: position),
      )) {
        return true;
      }
    }
    return false;
  }
}
