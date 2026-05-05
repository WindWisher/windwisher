part of 'spots_page.dart';

class _AddSpotSheet extends StatefulWidget {
  const _AddSpotSheet({
    required this.existingSpotNames,
    required this.allowCustomMode,
  });

  final Set<String> existingSpotNames;
  final bool allowCustomMode;

  @override
  State<_AddSpotSheet> createState() => _AddSpotSheetState();
}

class _AddSpotSheetState extends State<_AddSpotSheet> {
  final _imagePicker = ImagePicker();
  final _nameController = TextEditingController();
  final _areaController = TextEditingController();
  List<_AvailableSpot> _suggestedSpots = const <_AvailableSpot>[];
  _AvailableSpot? _selectedOfficialSpot;
  _CustomSpotPoint? _customPoint;
  bool _customMode = false;
  String? _backgroundImagePath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    final query = _nameController.text.trim().toLowerCase();
    _clearSelectedOfficialSpotIfNeeded(query);

    if (query.isEmpty) {
      if (_suggestedSpots.isNotEmpty) {
        setState(() {
          _suggestedSpots = const <_AvailableSpot>[];
          _error = null;
        });
      }
      return;
    }

    setState(() {
      _suggestedSpots = _findSuggestedSpots(query);
      _error = null;
    });
  }

  void _clearSelectedOfficialSpotIfNeeded(String query) {
    final selectedOfficialSpot = _selectedOfficialSpot;
    if (!_shouldClearSelectedOfficialSpot(
      selectedOfficialSpot: selectedOfficialSpot,
      query: query,
    )) {
      return;
    }
    _selectedOfficialSpot = null;
  }

  List<_AvailableSpot> _findSuggestedSpots(String query) {
    return _findAvailableSpotSuggestions(
      query: query,
      existingSpotNames: widget.existingSpotNames,
    );
  }

  void _selectSuggestedSpot(_AvailableSpot spot) {
    _nameController.text = spot.name;
    _areaController.text = spot.area;
    _nameController.selection = TextSelection.collapsed(
      offset: _nameController.text.length,
    );

    setState(() {
      _selectedOfficialSpot = spot;
      _suggestedSpots = const <_AvailableSpot>[];
      _error = null;
      _customPoint = null;
      _customMode = false;
      _backgroundImagePath = null;
    });
  }

  Future<void> _pickCustomPoint() async {
    setState(() {
      _customMode = true;
      _error = null;
    });
    final picked = await showDialog<_CustomSpotPoint>(
      context: context,
      builder: (context) => _CustomMapPickerDialog(initialPoint: _customPoint),
    );

    if (!mounted || picked == null) {
      return;
    }

    setState(() {
      _customPoint = picked;
      _selectedOfficialSpot = null;
      _error = null;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = 'Spot personalizado';
      }
      _suggestedSpots = const <_AvailableSpot>[];
    });
  }

  Future<void> _pickBackgroundImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, maxWidth: 2200);
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _backgroundImagePath = picked.path;
      _error = null;
    });
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final area = _areaController.text.trim();
    final selectedOfficialSpot = _selectedOfficialSpot;
    final error = _validateSpotForAdd(
      name: name,
      allowCustomMode: widget.allowCustomMode,
      existingSpotNames: widget.existingSpotNames,
      selectedOfficialSpot: selectedOfficialSpot,
      customPoint: _customPoint,
    );

    if (error != null) {
      setState(() {
        _error = error;
      });
      return;
    }

    Navigator.of(context).pop(
      _buildAddedSpotItem(
        name: name,
        area: area,
        selectedOfficialSpot: selectedOfficialSpot,
        customPoint: _customPoint,
        backgroundImagePath: _backgroundImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final snapshot = _SpotAddSheetStateSnapshot(
      name: _nameController.text.trim(),
      selectedOfficialSpot: _selectedOfficialSpot,
      customPoint: _customPoint,
      customMode: _customMode,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      child: _SpotAddSheetContent(
        allowCustomMode: widget.allowCustomMode,
        snapshot: snapshot,
        customMode: _customMode,
        customPoint: _customPoint,
        backgroundImagePath: _backgroundImagePath,
        nameController: _nameController,
        areaController: _areaController,
        suggestedSpots: _suggestedSpots,
        error: _error,
        onPickCustomPoint: _pickCustomPoint,
        onPickBackgroundImage: _pickBackgroundImage,
        onRemoveBackgroundImage: () {
          setState(() {
            _backgroundImagePath = null;
          });
        },
        onSuggestedSpotSelected: _selectSuggestedSpot,
        onSave: _save,
      ),
    );
  }
}
