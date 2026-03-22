import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfileData initialData;

  const EditProfilePage({super.key, required this.initialData});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();

  late final TextEditingController _displayName;
  late final TextEditingController _handle;
  late final TextEditingController _publicTagline;
  late final TextEditingController _bio;
  late final TextEditingController _level;
  late final TextEditingController _ranking;
  late final TextEditingController _baseSpot;
  String? _avatarPath;
  String? _bannerPath;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _displayName = TextEditingController(text: data.displayName);
    _handle = TextEditingController(text: data.handle);
    _publicTagline = TextEditingController(text: data.publicTagline);
    _bio = TextEditingController(text: data.bio);
    _level = TextEditingController(text: data.level);
    _ranking = TextEditingController(text: data.ranking);
    _baseSpot = TextEditingController(text: data.baseSpot);
    _avatarPath = data.avatarLocalPath;
    _bannerPath = data.bannerLocalPath;
  }

  @override
  void dispose() {
    _displayName.dispose();
    _handle.dispose();
    _publicTagline.dispose();
    _bio.dispose();
    _level.dispose();
    _ranking.dispose();
    _baseSpot.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      UserProfileData(
        displayName: _displayName.text.trim(),
        handle: _handle.text.trim(),
        publicTagline: _publicTagline.text.trim(),
        bio: _bio.text.trim(),
        level: _level.text.trim(),
        sessions: widget.initialData.sessions,
        ranking: _ranking.text.trim(),
        baseSpot: _baseSpot.text.trim(),
        totalSessions: widget.initialData.totalSessions,
        waterHours: widget.initialData.waterHours,
        jumps: widget.initialData.jumps,
        topJump: widget.initialData.topJump,
        bestSpot: widget.initialData.bestSpot,
        latestSession: widget.initialData.latestSession,
        latestComment: widget.initialData.latestComment,
        featuredThread: widget.initialData.featuredThread,
        avatarLocalPath: _avatarPath,
        bannerLocalPath: _bannerPath,
      ),
    );
  }

  Future<void> _pickProfileMedia({required bool isBanner}) async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    final savedPath = await _storeProfileMedia(picked, isBanner: isBanner);
    if (!mounted) {
      return;
    }
    setState(() {
      if (isBanner) {
        _bannerPath = savedPath;
      } else {
        _avatarPath = savedPath;
      }
    });
  }

  Future<String> _storeProfileMedia(
    XFile file, {
    required bool isBanner,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}profile_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final dot = file.path.lastIndexOf('.');
    final extension = (dot < 0 || dot == file.path.length - 1)
        ? ''
        : file.path.substring(dot);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}${isBanner ? 'banner' : 'avatar'}_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int lines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        minLines: lines,
        maxLines: lines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
        actions: [TextButton(onPressed: _save, child: const Text('Guardar'))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Foto y banner'),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _bannerPath == null
                            ? LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ],
                              )
                            : null,
                        image: _bannerPath == null
                            ? null
                            : DecorationImage(
                                image: FileImage(File(_bannerPath!)),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _pickProfileMedia(isBanner: true),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Editar banner'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: _avatarPath == null
                            ? null
                            : FileImage(File(_avatarPath!)),
                        child: _avatarPath == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      OutlinedButton.icon(
                        onPressed: () => _pickProfileMedia(isBanner: false),
                        icon: const Icon(Icons.account_circle_outlined),
                        label: const Text('Editar foto'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _field('Nombre', _displayName),
          _field('Handle', _handle),
          _field('Tagline publica', _publicTagline, lines: 2),
          _field('Bio', _bio, lines: 3),
          _field('Nivel', _level),
          _field('Ranking', _ranking),
          _field('Spot base', _baseSpot),
          FilledButton(onPressed: _save, child: const Text('Guardar cambios')),
        ],
      ),
    );
  }
}

class ProfileStatsDetailsPage extends StatelessWidget {
  final UserProfileData profile;

  const ProfileStatsDetailsPage({super.key, required this.profile});

  int _toInt(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  double _toDouble(String value) {
    final parsed = value.replaceAll(RegExp(r'[^0-9\.]'), '');
    return double.tryParse(parsed) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final sessions = _toInt(profile.totalSessions);
    final hours = _toInt(profile.waterHours);
    final jumps = _toInt(profile.jumps);
    final topJump = _toDouble(profile.topJump);
    final avgSession = sessions == 0 ? 0 : (hours / sessions);
    final avgJumps = sessions == 0 ? 0 : (jumps / sessions);
    final estCalories = hours * 420;

    Widget kpi(String label, String value) {
      return Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(value, style: textTheme.titleLarge),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('KPIs del perfil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.xs,
            mainAxisSpacing: AppSpacing.xs,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.55,
            children: [
              kpi('Sesiones', '$sessions'),
              kpi('Horas en agua', '${hours}h'),
              kpi('Saltos', '$jumps'),
              kpi('Top salto', '${topJump.toStringAsFixed(1)}m'),
              kpi('Promedio por sesion', '${avgSession.toStringAsFixed(1)}h'),
              kpi('Saltos por sesion', avgJumps.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rendimiento y contexto', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _ProfileStatsRow(
                    label: 'Nivel declarado',
                    value: profile.level,
                  ),
                  _ProfileStatsRow(
                    label: 'Ranking local',
                    value: profile.ranking,
                  ),
                  _ProfileStatsRow(label: 'Spot base', value: profile.baseSpot),
                  _ProfileStatsRow(
                    label: 'Mejor spot',
                    value: profile.bestSpot,
                  ),
                  _ProfileStatsRow(
                    label: 'Calorias estimadas',
                    value: '$estCalories kcal',
                  ),
                  _ProfileStatsRow(
                    label: 'Hilo destacado',
                    value: profile.featuredThread,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatsRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class PublicProfilePreviewPage extends StatelessWidget {
  final UserProfileData profile;
  final String title;

  const PublicProfilePreviewPage({
    super.key,
    required this.profile,
    this.title = 'Vista publica',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: profile.bannerLocalPath == null
                            ? LinearGradient(
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  Theme.of(
                                    context,
                                  ).colorScheme.secondaryContainer,
                                ],
                              )
                            : null,
                        image: profile.bannerLocalPath == null
                            ? null
                            : DecorationImage(
                                image: FileImage(
                                  File(profile.bannerLocalPath!),
                                ),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue,
                        backgroundImage: profile.avatarLocalPath == null
                            ? null
                            : FileImage(File(profile.avatarLocalPath!)),
                        child: profile.avatarLocalPath == null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: textTheme.titleLarge,
                            ),
                            Text(profile.handle, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Seguir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(profile.bio),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Chip(label: Text(profile.level)),
                      Chip(label: Text(profile.baseSpot)),
                      Chip(label: Text('${profile.sessions} sesiones')),
                      Chip(label: Text('Top salto ${profile.topJump}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actividad publica reciente',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.bolt_rounded),
                    title: Text('Nueva sesion en ${profile.baseSpot}'),
                    subtitle: Text(profile.latestSession),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.forum_outlined),
                    title: const Text('Comentario en Comunidad'),
                    subtitle: Text(profile.latestComment),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
