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
    final selectedOfficialSpot = _selectedOfficialSpot;
    if (selectedOfficialSpot != null &&
        selectedOfficialSpot.name.toLowerCase() != query) {
      _selectedOfficialSpot = null;
    }
    if (query.isEmpty) {
      if (_suggestedSpots.isNotEmpty) {
        setState(() {
          _suggestedSpots = const <_AvailableSpot>[];
          _error = null;
        });
      }
      return;
    }

    final next = _availableSpots
        .where(
          (spot) =>
              spot.name.toLowerCase().contains(query) &&
              !widget.existingSpotNames.contains(spot.name.toLowerCase()),
        )
        .take(5)
        .toList();

    setState(() {
      _suggestedSpots = next;
      _error = null;
    });
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
    final normalized = (selectedOfficialSpot?.name ?? name).toLowerCase();

    if (name.isEmpty) {
      setState(() {
        _error = 'El nombre del spot es obligatorio';
      });
      return;
    }

    if (widget.existingSpotNames.contains(normalized)) {
      setState(() {
        _error = 'Ese spot ya esta agregado';
      });
      return;
    }

    if (selectedOfficialSpot == null && _customPoint == null) {
      setState(() {
        _error = widget.allowCustomMode
            ? 'Para un spot personalizado debes seleccionar coordenadas.'
            : 'Debes seleccionar uno de los spots oficiales sugeridos.';
      });
      return;
    }

    if (!widget.allowCustomMode &&
        (selectedOfficialSpot == null || _customPoint != null)) {
      setState(() {
        _error = 'Con el plan user solo puedes guardar spots oficiales.';
      });
      return;
    }

    Navigator.of(context).pop(
      _SpotItem(
        name: selectedOfficialSpot?.name ?? name,
        area: area.isEmpty ? 'Sin zona definida' : area,
        isCustom: _customPoint != null || selectedOfficialSpot == null,
        createdAt: DateTime.now(),
        latitude: _customPoint?.latitude ?? selectedOfficialSpot?.latitude,
        longitude: _customPoint?.longitude ?? selectedOfficialSpot?.longitude,
        aemetMunicipalityCode: selectedOfficialSpot?.aemetMunicipalityCode,
        aemetBeachCode: selectedOfficialSpot?.aemetBeachCode,
        aemetBeachCodes:
            selectedOfficialSpot?.aemetBeachCodes ?? const <String>[],
        backgroundImagePath: _backgroundImagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final name = _nameController.text.trim();
    final selectedOfficialSpot = _selectedOfficialSpot;
    final hasSelectedOfficialSpot =
        name.isNotEmpty && selectedOfficialSpot != null;
    final requiresCoordinates = name.isNotEmpty && !hasSelectedOfficialSpot;
    final canSave =
        name.isNotEmpty && (!requiresCoordinates || _customPoint != null);
    final allowTextFields = !_customMode || _customPoint != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + bottomInset,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SpotAddHeader(
              allowCustomMode: widget.allowCustomMode,
              onPickCustomPoint: _pickCustomPoint,
            ),
            _SpotAddStatusMessages(
              customPoint: _customPoint,
              selectedOfficialSpot: selectedOfficialSpot,
              hasSelectedOfficialSpot: hasSelectedOfficialSpot,
              requiresCoordinates: requiresCoordinates,
              allowTextFields: allowTextFields,
            ),
            if (allowTextFields && _customMode) ...[
              const SizedBox(height: AppSpacing.sm),
              _SpotBackgroundImagePicker(
                imagePath: _backgroundImagePath,
                onPick: _pickBackgroundImage,
                onRemove: () {
                  setState(() {
                    _backgroundImagePath = null;
                  });
                },
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _SpotAddFormFields(
              nameController: _nameController,
              areaController: _areaController,
              allowTextFields: allowTextFields,
              suggestedSpots: _suggestedSpots,
              onSuggestedSpotSelected: _selectSuggestedSpot,
              onSubmitted: _save,
            ),
            _SpotAddErrorMessage(error: _error),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: canSave ? _save : null,
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Guardar spot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
