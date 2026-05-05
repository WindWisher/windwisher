part of '../spots_page.dart';

class _SpotSearchField extends StatelessWidget {
  const _SpotSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('spots-search-input'),
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Buscar spots',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                tooltip: 'Limpiar busqueda',
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}
