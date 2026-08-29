import 'package:windwisher/features/spots/infrastructure/services/aemet_coastal_forecast_client.dart';
import 'package:windwisher/features/spots/application/services/spot_forecast_model_order.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_beach_forecast_client.dart';

class SpotForecastModelInfo {
  const SpotForecastModelInfo({
    required this.title,
    required this.description,
    required this.scope,
    required this.resolution,
    required this.horizon,
  });

  final String title;
  final String description;
  final String scope;
  final String resolution;
  final String horizon;
}

SpotForecastModelInfo getSpotForecastModelInfo({
  required String provider,
  required String model,
}) {
  switch (provider) {
    case 'Open-Meteo':
      switch (model) {
        case 'Best match':
          return const SpotForecastModelInfo(
            title: 'Best match',
            description:
                'Seleccion automatica de Open-Meteo. Escoge el modelo que considera mas adecuado para esta ubicacion y momento.',
            scope: 'Automatico multi-modelo',
            resolution: 'Variable segun zona',
            horizon: 'Hasta 16 dias',
          );
        case 'AROME Seamless':
          return const SpotForecastModelInfo(
            title: 'AROME Seamless',
            description:
                'Salida Meteo-France combinada para mantener continuidad espacial y temporal. Suele ser una opcion practica y estable cerca del Mediterraneo occidental.',
            scope: 'Alta resolucion continua',
            resolution: 'Aprox. 1.5-2.5 km',
            horizon: 'Corto plazo, hasta 2-4 dias',
          );
        case 'ARPEGE Europe':
          return const SpotForecastModelInfo(
            title: 'ARPEGE Europe',
            description:
                'Modelo regional europeo de Meteo-France. Buen equilibrio entre cobertura y detalle para spots de la costa este peninsular.',
            scope: 'Regional europeo',
            resolution: 'Aprox. 11 km',
            horizon: 'Hasta 4 dias',
          );
        case 'ECMWF':
          return const SpotForecastModelInfo(
            title: 'ECMWF',
            description:
                'Modelo global de referencia muy solido en situacion sinoptica. Menos fino localmente, pero muy fiable como baseline.',
            scope: 'Global',
            resolution: 'Aprox. 9-25 km',
            horizon: 'Hasta 15 dias',
          );
        case 'AROME France':
          return const SpotForecastModelInfo(
            title: 'AROME France',
            description:
                'Modelo de alta resolucion de Meteo-France centrado en Francia y zonas cercanas. Muy detallado, aunque con cobertura mas limitada.',
            scope: 'Alta resolucion regional',
            resolution: 'Aprox. 1.5-2.5 km',
            horizon: 'Hasta 2 dias',
          );
        case 'ICON':
          return const SpotForecastModelInfo(
            title: 'ICON',
            description:
                'Modelo europeo de DWD. Suele funcionar bien como comparativa para viento y evolucion general en costa mediterranea.',
            scope: 'Regional/global segun variante',
            resolution: 'Aprox. 2-11 km',
            horizon: 'Hasta 7.5 dias',
          );
        case 'ARPEGE Seamless':
          return const SpotForecastModelInfo(
            title: 'ARPEGE Seamless',
            description:
                'Version continua de la familia ARPEGE. Prioriza una experiencia estable cuando cambian area de cobertura u horizonte temporal.',
            scope: 'Regional continuo',
            resolution: 'Variable segun tramo',
            horizon: 'Hasta 4 dias',
          );
        case 'ARPEGE World':
          return const SpotForecastModelInfo(
            title: 'ARPEGE World',
            description:
                'Version global de ARPEGE. Aporta cobertura amplia, pero normalmente con menos detalle local para spots costeros concretos.',
            scope: 'Global',
            resolution: 'Aprox. 25 km',
            horizon: 'Hasta 4 dias',
          );
        case 'GFS':
          return const SpotForecastModelInfo(
            title: 'GFS',
            description:
                'Modelo global de NOAA muy usado como referencia general. Util para comparar, aunque suele ser menos fino en brisas y efectos locales.',
            scope: 'Global',
            resolution: 'Aprox. 11-25 km',
            horizon: 'Hasta 16 dias',
          );
      }
    case 'AEMET':
      switch (model) {
        case kAemetMunicipalForecastModel:
          return const SpotForecastModelInfo(
            title: kAemetMunicipalForecastModel,
            description:
                'Prediccion horaria municipal oficial de AEMET tal como se publica en OpenData. No expone un modelo numerico seleccionable por separado en esta fuente.',
            scope: 'Municipio',
            resolution: 'Horaria agregada por AEMET',
            horizon: 'Corto plazo municipal',
          );
        case kAemetBeachForecastModel:
          return const SpotForecastModelInfo(
            title: kAemetBeachForecastModel,
            description:
                'Prediccion oficial de playa de AEMET. Resume cielo, viento, oleaje, temperatura maxima, agua, sensacion termica y UV para la playa concreta.',
            scope: 'Playa especifica',
            resolution: 'Diaria con manana/tarde',
            horizon: 'Hasta 4 dias',
          );
        case kAemetCoastalForecastModel:
          return const SpotForecastModelInfo(
            title: kAemetCoastalForecastModel,
            description:
                'Boletin maritimo costero oficial de AEMET por tramo litoral. Resume viento, estado de la mar, avisos y tendencia para la costa asociada al spot.',
            scope: 'Zona costera regional',
            resolution: 'Texto por tramo costero',
            horizon: 'Aprox. 24 horas + tendencia',
          );
        case kAemetPortusAtmosphereForecastModel:
        case kLegacyAemetPortusAtmosphereForecastModel:
          return const SpotForecastModelInfo(
            title: kAemetPortusAtmosphereForecastModel,
            description:
                'Prediccion de viento publicada por Puertos del Estado con campos meteorologicos facilitados por AEMET. WindWisher consume el punto de malla atmosferico mas cercano al spot.',
            scope: 'Malla costera de Puertos del Estado',
            resolution: '1 hora',
            horizon: 'Corto plazo segun Puertos del Estado',
          );
      }
      if (isAemetBeachForecastModelLabel(model)) {
        return SpotForecastModelInfo(
          title: model,
          description:
              'Prediccion oficial de playa de AEMET para la playa concreta seleccionada dentro del spot.',
          scope: 'Playa especifica',
          resolution: 'Diaria con manana/tarde',
          horizon: 'Hasta 4 dias',
        );
      }
    case 'Meteoblue':
      switch (model) {
        case 'Basic':
          return const SpotForecastModelInfo(
            title: 'Basic',
            description:
                'Paquete forecast de meteoblue orientado a uso general. En esta integracion WindWisher consume viento, racha, direccion, temperatura, lluvia y, cuando llegan, variables marinas del mismo proveedor.',
            scope: 'Forecast horario meteoblue',
            resolution: '1 hora',
            horizon: 'Hasta 7 dias',
          );
        case 'Current':
          return const SpotForecastModelInfo(
            title: 'Current',
            description:
                'Instantanea actual del proveedor Meteoblue. Resume el estado mas cercano al momento presente y si el dato llega como observado o estimado.',
            scope: 'Condicion actual',
            resolution: 'Instante actual',
            horizon: 'Ahora',
          );
        case 'Day':
          return const SpotForecastModelInfo(
            title: 'Day',
            description:
                'Resumen diario agregado de Meteoblue. Ideal para comparar min/max, viento medio, lluvia y predictabilidad entre dias.',
            scope: 'Resumen diario',
            resolution: '1 dia',
            horizon: 'Hasta 7 dias',
          );
        case 'Sea':
          return const SpotForecastModelInfo(
            title: 'Sea',
            description:
                'Serie marina horaria de Meteoblue. Separa surf, swell, mar de viento, periodos y direccion para lectura costera mas fina.',
            scope: 'Mar horario',
            resolution: '1 hora',
            horizon: 'Hasta 7 dias',
          );
      }
    case 'Meteosource':
      switch (model) {
        case 'Hourly':
          return const SpotForecastModelInfo(
            title: 'Hourly',
            description:
                'Powered by Meteosource.\nForecast horario puntual para una ubicacion concreta. En esta integracion se consumen temperatura, viento, racha, direccion, presion, nubosidad y precipitacion.',
            scope: 'Punto horario',
            resolution: '1 hora',
            horizon: 'Hasta 24 horas en free tier',
          );
        case 'Current':
          return const SpotForecastModelInfo(
            title: 'Current',
            description:
                'Powered by Meteosource.\nCondicion actual puntual. Resume temperatura, viento, nubosidad, precipitacion y estado del cielo en este momento.',
            scope: 'Condicion actual',
            resolution: 'Instante actual',
            horizon: 'Ahora',
          );
        case 'Day':
          return const SpotForecastModelInfo(
            title: 'Day',
            description:
                'Powered by Meteosource.\nResumen diario con min/max termica, viento medio, precipitacion total y texto descriptivo por dia.',
            scope: 'Resumen diario',
            resolution: '1 dia',
            horizon: 'Hasta 7 dias',
          );
      }
    case 'Meteostat':
      switch (model) {
        case 'Hourly':
          return const SpotForecastModelInfo(
            title: 'Hourly',
            description:
                'Serie horaria puntual de Meteostat via RapidAPI. En esta integracion se consumen temperatura, precipitacion, direccion, viento medio, racha y presion atmosferica.',
            scope: 'Punto horario',
            resolution: '1 hora',
            horizon: 'Hasta 7 dias en esta integracion',
          );
        case 'Day':
          return const SpotForecastModelInfo(
            title: 'Day',
            description:
                'Resumen diario de Meteostat via RapidAPI. Aporta media, min/max termica, viento medio, racha, presion, precipitacion y minutos de sol.',
            scope: 'Resumen diario',
            resolution: '1 dia',
            horizon: 'Hasta 7 dias en esta integracion',
          );
      }
    case 'Windguru':
      switch (model) {
        case 'Widget':
          return const SpotForecastModelInfo(
            title: 'Widget Windguru',
            description:
                'Widget embebido de Windguru para lectura rapida del forecast del spot configurado.',
            scope: 'Widget externo',
            resolution: 'Segun Windguru',
            horizon: 'Segun Windguru',
          );
      }
    case 'Windy.app':
      switch (model) {
        case 'Widget':
          return const SpotForecastModelInfo(
            title: 'Widgets Windy.app',
            description:
                'Mapa interactivo y tabla de prevision embebidos para las coordenadas exactas del spot.',
            scope: 'Widgets externos',
            resolution: 'Segun Windy.app',
            horizon: 'Segun Windy.app',
          );
      }
  }

  return SpotForecastModelInfo(
    title: model,
    description:
        'Modelo de prevision seleccionado para comparar viento, racha y tendencia en este spot.',
    scope: 'No especificado',
    resolution: 'No especificada',
    horizon: 'No especificado',
  );
}
