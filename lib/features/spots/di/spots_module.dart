import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_catalog_use_cases.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_forecast_use_cases.dart';
import 'package:windwisher/features/spots/application/use_cases/spots_remote_media_use_cases.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/composite/composite_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/in_memory/in_memory_spots_forecast_cache_store.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/in_memory/in_memory_spots_catalog_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/in_memory/in_memory_spots_remote_media_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/portus/portus_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/supabase/supabase_spots_catalog_adapter.dart';
import 'package:windwisher/core/config/env/env_config.dart';

class SpotsModule {
  const SpotsModule({
    required this.getSpots,
    required this.saveSpot,
    required this.deleteSpotByName,
    required this.getSpotForecast,
    required this.getSpotWebcams,
    required this.getWebcamReferencePages,
  });

  final GetSpotsUseCase getSpots;
  final SaveSpotUseCase saveSpot;
  final DeleteSpotByNameUseCase deleteSpotByName;
  final GetSpotForecastUseCase getSpotForecast;
  final GetSpotWebcamsUseCase getSpotWebcams;
  final GetWebcamReferencePagesUseCase getWebcamReferencePages;

  factory SpotsModule.inMemory() {
    final catalogPort = InMemorySpotsCatalogAdapter();
    final cacheStore = InMemorySpotsForecastCacheStore();
    final forecastPort = CompositeSpotsForecastAdapter(
      openMeteoAdapter: OpenMeteoSpotsForecastAdapter(),
      aemetAdapter: AemetSpotsForecastAdapter(cacheStore: cacheStore),
      meteoblueAdapter: MeteoblueSpotsForecastAdapter(),
      meteosourceAdapter: MeteosourceSpotsForecastAdapter(),
      meteostatAdapter: MeteostatSpotsForecastAdapter(),
      portusAdapter: PortusSpotsForecastAdapter(),
    );
    final remoteMediaPort = InMemorySpotsRemoteMediaAdapter();
    return SpotsModule(
      getSpots: GetSpotsUseCase(catalogPort),
      saveSpot: SaveSpotUseCase(catalogPort),
      deleteSpotByName: DeleteSpotByNameUseCase(catalogPort),
      getSpotForecast: GetSpotForecastUseCase(forecastPort),
      getSpotWebcams: GetSpotWebcamsUseCase(remoteMediaPort),
      getWebcamReferencePages: GetWebcamReferencePagesUseCase(remoteMediaPort),
    );
  }

  factory SpotsModule.localFile({
    String forecastCacheFileName = 'spots_forecast_cache_v1.json',
  }) {
    final catalogPort = InMemorySpotsCatalogAdapter();
    final cacheStore = LocalFileSpotsForecastCacheStore(
      fileName: forecastCacheFileName,
    );
    final forecastPort = CompositeSpotsForecastAdapter(
      openMeteoAdapter: OpenMeteoSpotsForecastAdapter(),
      aemetAdapter: AemetSpotsForecastAdapter(cacheStore: cacheStore),
      meteoblueAdapter: MeteoblueSpotsForecastAdapter(),
      meteosourceAdapter: MeteosourceSpotsForecastAdapter(),
      meteostatAdapter: MeteostatSpotsForecastAdapter(),
      portusAdapter: PortusSpotsForecastAdapter(),
    );
    final remoteMediaPort = InMemorySpotsRemoteMediaAdapter();
    return SpotsModule(
      getSpots: GetSpotsUseCase(catalogPort),
      saveSpot: SaveSpotUseCase(catalogPort),
      deleteSpotByName: DeleteSpotByNameUseCase(catalogPort),
      getSpotForecast: GetSpotForecastUseCase(forecastPort),
      getSpotWebcams: GetSpotWebcamsUseCase(remoteMediaPort),
      getWebcamReferencePages: GetWebcamReferencePagesUseCase(remoteMediaPort),
    );
  }

  factory SpotsModule.auto({
    String forecastCacheFileName = 'spots_forecast_cache_v1.json',
  }) {
    final catalogPort = EnvConfig.supabaseConfigured
        ? SupabaseSpotsCatalogAdapter()
        : InMemorySpotsCatalogAdapter();
    final cacheStore = kIsWeb
        ? InMemorySpotsForecastCacheStore()
        : LocalFileSpotsForecastCacheStore(fileName: forecastCacheFileName);
    final forecastPort = CompositeSpotsForecastAdapter(
      openMeteoAdapter: OpenMeteoSpotsForecastAdapter(),
      aemetAdapter: AemetSpotsForecastAdapter(cacheStore: cacheStore),
      meteoblueAdapter: MeteoblueSpotsForecastAdapter(),
      meteosourceAdapter: MeteosourceSpotsForecastAdapter(),
      meteostatAdapter: MeteostatSpotsForecastAdapter(),
      portusAdapter: PortusSpotsForecastAdapter(),
    );
    final remoteMediaPort = InMemorySpotsRemoteMediaAdapter();
    return SpotsModule(
      getSpots: GetSpotsUseCase(catalogPort),
      saveSpot: SaveSpotUseCase(catalogPort),
      deleteSpotByName: DeleteSpotByNameUseCase(catalogPort),
      getSpotForecast: GetSpotForecastUseCase(forecastPort),
      getSpotWebcams: GetSpotWebcamsUseCase(remoteMediaPort),
      getWebcamReferencePages: GetWebcamReferencePagesUseCase(remoteMediaPort),
    );
  }
}
