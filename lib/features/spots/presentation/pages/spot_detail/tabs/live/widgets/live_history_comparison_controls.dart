part of '../../../spot_detail_page.dart';

class _LiveHistoryComparisonControls extends StatelessWidget {
  const _LiveHistoryComparisonControls({
    required this.providers,
    required this.selectedProvider,
    required this.models,
    required this.selectedModel,
    required this.canLoad,
    required this.isLoading,
    required this.onProviderChanged,
    required this.onModelChanged,
    required this.onLoad,
  });

  final List<String> providers;
  final String? selectedProvider;
  final List<String> models;
  final String? selectedModel;
  final bool canLoad;
  final bool isLoading;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<String> onModelChanged;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: selectedProvider,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Proveedor forecast',
              hintText: 'Seleccionar',
              isDense: true,
            ),
            items: providers
                .map(
                  (provider) => DropdownMenuItem<String>(
                    value: provider,
                    child: Text(provider),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) {
              if (value != null && value != selectedProvider) {
                onProviderChanged(value);
              }
            },
          ),
        ),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
            initialValue: selectedModel,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Modelo forecast',
              hintText: 'Seleccionar',
              isDense: true,
            ),
            items: models
                .map(
                  (model) => DropdownMenuItem<String>(
                    value: model,
                    child: Text(model),
                  ),
                )
                .toList(growable: false),
            onChanged: models.isEmpty
                ? null
                : (value) {
                    if (value != null && value != selectedModel) {
                      onModelChanged(value);
                    }
                  },
          ),
        ),
        OutlinedButton.icon(
          onPressed: isLoading || !canLoad ? null : onLoad,
          icon: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.compare_arrows_rounded),
          label: Text(
            isLoading ? 'Cargando comparativa' : 'Cargar comparativa',
          ),
        ),
      ],
    );
  }
}
