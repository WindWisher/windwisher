part of '../../../spot_detail_page.dart';

const double _windguruWidgetHeight = 520;

const String _windguruWidgetHtml = '''<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin: 0; padding: 0; background: #ffffff; }
  </style>
</head>
<body>
  <script id="wg_fwdg_48858_52_1773264003952">
    (function (window, document) {
      var loader = function () {
        var arg = ["s=48858", "m=52", "mw=84", "uid=wg_fwdg_48858_52_1773264003952", "wj=knots", "tj=c", "waj=m", "tij=cm", "odh=0", "doh=24", "fhours=240", "hrsm=1", "vt=forecasts", "lng=es", "p=WINDSPD,GUST,MWINDSPD,SMER,HTSGW,PERPW,DIRPW,PWEN,SWELL1,SWPER1,SWEN1,SWDIR1,SWELL2,SWEN2,SWPER2,SWDIR2,WVHGT,WVPER,WVEN,WVDIR,TMPE,TMP,WCHILL,CDC,TCDC,APCP1s,RH,RATING"];
        var script = document.createElement("script");
        var tag = document.getElementsByTagName("script")[0];
        script.src = "https://www.windguru.cz/js/widget.php?" + (arg.join("&"));
        tag.parentNode.insertBefore(script, tag);
      };
      window.addEventListener ? window.addEventListener("load", loader, false) : window.attachEvent("onload", loader);
    })(window, document);
  </script>
</body>
</html>
''';
