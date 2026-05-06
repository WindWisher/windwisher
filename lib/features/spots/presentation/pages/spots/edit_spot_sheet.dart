part of 'spots_page.dart';

class _EditSpotSheet extends StatefulWidget {
  const _EditSpotSheet({required this.spot});

  final _SpotItem spot;

  @override
  State<_EditSpotSheet> createState() => _EditSpotSheetState();
}

class _EditSpotSheetState extends State<_EditSpotSheet> {
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _areaController;
  String? _backgroundImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.spot.name);
    _areaController = TextEditingController(text: widget.spot.area);
    _backgroundImagePath = widget.spot.backgroundImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _pickBackgroundImage(ImageSource source) async {
    final picked = await _imagePicker.pickImage(source: source, maxWidth: 2200);
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      _backgroundImagePath = picked.path;
    });
  }

  void _removeBackgroundImage() {
    setState(() {
      _backgroundImagePath = null;
    });
  }

  void _save() {
    final nextName = _nameController.text.trim();
    final nextArea = _areaController.text.trim();
    if (nextName.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      _SpotItem(
        name: widget.spot.isCustom ? nextName : widget.spot.name,
        area: widget.spot.isCustom
            ? (nextArea.isEmpty ? 'Sin zona definida' : nextArea)
            : widget.spot.area,
        isCustom: widget.spot.isCustom,
        createdAt: widget.spot.createdAt,
        latitude: widget.spot.latitude,
        longitude: widget.spot.longitude,
        aemetMunicipalityCode: widget.spot.aemetMunicipalityCode,
        aemetBeachCode: widget.spot.aemetBeachCode,
        aemetBeachCodes: widget.spot.aemetBeachCodes,
        backgroundImagePath: _backgroundImagePath,
        capabilities: widget.spot.capabilities,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md + inset,
      ),
      child: _SpotEditSheetContent(
        spot: widget.spot,
        nameController: _nameController,
        areaController: _areaController,
        backgroundImagePath: _backgroundImagePath,
        onPickBackgroundImage: _pickBackgroundImage,
        onRemoveBackgroundImage: _removeBackgroundImage,
        onSave: _save,
      ),
    );
  }
}
