import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings._(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
    Locale('zh'),
    Locale('ar'),
  ];

  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    _AppStringsDelegate(),
  ];

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    assert(strings != null, 'AppStrings not found in context');
    return strings!;
  }

  static const _values = <String, Map<String, String>>{
    'es': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'Correo',
      'emailHint': 'tu@email.com',
      'password': 'Contrasena',
      'newPassword': 'Contrasena nueva',
      'passwordHint': 'Minimo 6 caracteres',
      'signIn': 'Entrar',
      'createAccount': 'Crear cuenta',
      'createAccountPrompt': 'No tienes cuenta? Crear cuenta',
      'existingAccountPrompt': 'Ya tienes cuenta? Iniciar sesion',
      'forgotPassword': 'He olvidado mi contrasena',
      'recoveryEmailSent': 'Te hemos enviado un enlace para restablecer la contrasena a {email}.',
      'magicLink': 'Entrar con magic link',
      'socialAccess': 'Acceso social',
      'continueGoogle': 'Continuar con Google',
      'googleUnavailable': 'Google no disponible',
      'continueApple': 'Continuar con Apple',
      'appleUnavailable': 'Apple no disponible',
      'devBypass': 'Entrar con bypass',
      'recentAccounts': 'Cuentas recientes',
      'recentQuickAccess': 'Usar este correo como acceso rapido',
      'removeRecent': 'Quitar de recientes',
      'enterEmail': 'Introduce tu correo para continuar.',
      'emailCooldown': 'Espera {seconds} s antes de volver a pedir otro enlace.',
      'emailSent': 'Te hemos enviado un enlace de acceso a {email}. Revisa tu correo.',
      'accountCreated': 'Cuenta creada. Revisa tu correo para confirmar el acceso si Supabase te lo solicita.',
      'resendAvailable': 'Reenvio disponible en {seconds}s',
      'language': 'Idioma',
      'chooseLanguage': 'Elegir idioma',
      'languageSelector': 'ES',
    },
    'en': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'Email',
      'emailHint': 'you@email.com',
      'password': 'Password',
      'newPassword': 'New password',
      'passwordHint': 'At least 6 characters',
      'signIn': 'Sign in',
      'createAccount': 'Create account',
      'createAccountPrompt': 'No account yet? Create one',
      'existingAccountPrompt': 'Already have an account? Sign in',
      'forgotPassword': 'I forgot my password',
      'recoveryEmailSent': 'We sent a password reset link to {email}.',
      'magicLink': 'Sign in with magic link',
      'socialAccess': 'Social access',
      'continueGoogle': 'Continue with Google',
      'googleUnavailable': 'Google unavailable',
      'continueApple': 'Continue with Apple',
      'appleUnavailable': 'Apple unavailable',
      'devBypass': 'Enter with bypass',
      'recentAccounts': 'Recent accounts',
      'recentQuickAccess': 'Use this email for quick access',
      'removeRecent': 'Remove from recent',
      'enterEmail': 'Enter your email to continue.',
      'emailCooldown': 'Wait {seconds}s before requesting another link.',
      'emailSent': 'We sent a sign-in link to {email}. Check your inbox.',
      'accountCreated': 'Account created. Check your email if Supabase asks you to confirm access.',
      'resendAvailable': 'Resend available in {seconds}s',
      'language': 'Language',
      'chooseLanguage': 'Choose language',
      'languageSelector': 'EN',
    },
    'de': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'E-Mail',
      'emailHint': 'du@email.com',
      'password': 'Passwort',
      'newPassword': 'Neues Passwort',
      'passwordHint': 'Mindestens 6 Zeichen',
      'signIn': 'Anmelden',
      'createAccount': 'Konto erstellen',
      'createAccountPrompt': 'Noch kein Konto? Erstelle eins',
      'existingAccountPrompt': 'Du hast schon ein Konto? Anmelden',
      'forgotPassword': 'Ich habe mein Passwort vergessen',
      'recoveryEmailSent': 'Wir haben einen Link zum Zurucksetzen des Passworts an {email} gesendet.',
      'magicLink': 'Mit Magic Link anmelden',
      'socialAccess': 'Sozialer Zugang',
      'continueGoogle': 'Mit Google fortfahren',
      'googleUnavailable': 'Google nicht verfugbar',
      'continueApple': 'Mit Apple fortfahren',
      'appleUnavailable': 'Apple nicht verfugbar',
      'devBypass': 'Mit Bypass fortfahren',
      'recentAccounts': 'Letzte Konten',
      'recentQuickAccess': 'Diese E-Mail fur Schnellzugriff verwenden',
      'removeRecent': 'Aus Verlauf entfernen',
      'enterEmail': 'Gib deine E-Mail ein, um fortzufahren.',
      'emailCooldown': 'Warte {seconds}s, bevor du einen neuen Link anforderst.',
      'emailSent': 'Wir haben einen Zugangslink an {email} gesendet. Prufe dein Postfach.',
      'accountCreated': 'Konto erstellt. Prufe deine E-Mail, falls Supabase eine Bestatigung verlangt.',
      'resendAvailable': 'Erneut senden in {seconds}s moglich',
      'language': 'Sprache',
      'chooseLanguage': 'Sprache wahlen',
      'languageSelector': 'DE',
    },
    'fr': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'E-mail',
      'emailHint': 'toi@email.com',
      'password': 'Mot de passe',
      'newPassword': 'Nouveau mot de passe',
      'passwordHint': 'Au moins 6 caracteres',
      'signIn': 'Se connecter',
      'createAccount': 'Creer un compte',
      'createAccountPrompt': 'Pas encore de compte ? Cree-en un',
      'existingAccountPrompt': 'Tu as deja un compte ? Connecte-toi',
      'forgotPassword': 'J’ai oublie mon mot de passe',
      'recoveryEmailSent': 'Nous avons envoye un lien de reinitialisation a {email}.',
      'magicLink': 'Se connecter avec un magic link',
      'socialAccess': 'Acces social',
      'continueGoogle': 'Continuer avec Google',
      'googleUnavailable': 'Google indisponible',
      'continueApple': 'Continuer avec Apple',
      'appleUnavailable': 'Apple indisponible',
      'devBypass': 'Entrer avec bypass',
      'recentAccounts': 'Comptes recents',
      'recentQuickAccess': 'Utiliser cet e-mail pour un acces rapide',
      'removeRecent': 'Retirer des recents',
      'enterEmail': 'Saisis ton e-mail pour continuer.',
      'emailCooldown': 'Attends {seconds}s avant de demander un nouveau lien.',
      'emailSent': 'Nous avons envoye un lien d’acces a {email}. Verifie ta boite mail.',
      'accountCreated': 'Compte cree. Verifie ton e-mail si Supabase demande une confirmation.',
      'resendAvailable': 'Renvoi disponible dans {seconds}s',
      'language': 'Langue',
      'chooseLanguage': 'Choisir la langue',
      'languageSelector': 'FR',
    },
    'it': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'Email',
      'emailHint': 'tu@email.com',
      'password': 'Password',
      'newPassword': 'Nuova password',
      'passwordHint': 'Almeno 6 caratteri',
      'signIn': 'Accedi',
      'createAccount': 'Crea account',
      'createAccountPrompt': 'Non hai un account? Creane uno',
      'existingAccountPrompt': 'Hai gia un account? Accedi',
      'forgotPassword': 'Ho dimenticato la password',
      'recoveryEmailSent': 'Abbiamo inviato un link per reimpostare la password a {email}.',
      'magicLink': 'Accedi con magic link',
      'socialAccess': 'Accesso social',
      'continueGoogle': 'Continua con Google',
      'googleUnavailable': 'Google non disponibile',
      'continueApple': 'Continua con Apple',
      'appleUnavailable': 'Apple non disponibile',
      'devBypass': 'Entra con bypass',
      'recentAccounts': 'Account recenti',
      'recentQuickAccess': 'Usa questa email per un accesso rapido',
      'removeRecent': 'Rimuovi dai recenti',
      'enterEmail': 'Inserisci la tua email per continuare.',
      'emailCooldown': 'Attendi {seconds}s prima di richiedere un nuovo link.',
      'emailSent': 'Abbiamo inviato un link di accesso a {email}. Controlla la tua posta.',
      'accountCreated': 'Account creato. Controlla la tua email se Supabase richiede una conferma.',
      'resendAvailable': 'Reinvio disponibile tra {seconds}s',
      'language': 'Lingua',
      'chooseLanguage': 'Scegli lingua',
      'languageSelector': 'IT',
    },
    'zh': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': '邮箱',
      'emailHint': 'you@email.com',
      'password': '密码',
      'newPassword': '新密码',
      'passwordHint': '至少 6 个字符',
      'signIn': '登录',
      'createAccount': '创建账户',
      'createAccountPrompt': '还没有账户？立即创建',
      'existingAccountPrompt': '已经有账户？去登录',
      'forgotPassword': '我忘记了密码',
      'recoveryEmailSent': '我们已向 {email} 发送密码重置链接。',
      'magicLink': '使用 Magic Link 登录',
      'socialAccess': '社交登录',
      'continueGoogle': '使用 Google 继续',
      'googleUnavailable': 'Google 不可用',
      'continueApple': '使用 Apple 继续',
      'appleUnavailable': 'Apple 不可用',
      'devBypass': '使用 bypass 进入',
      'recentAccounts': '最近账户',
      'recentQuickAccess': '使用此邮箱快速访问',
      'removeRecent': '从最近记录中移除',
      'enterEmail': '请输入邮箱以继续。',
      'emailCooldown': '请等待 {seconds} 秒后再请求新的链接。',
      'emailSent': '我们已向 {email} 发送登录链接。请检查邮箱。',
      'accountCreated': '账户已创建。如 Supabase 要求确认，请检查你的邮箱。',
      'resendAvailable': '{seconds} 秒后可重新发送',
      'language': '语言',
      'chooseLanguage': '选择语言',
      'languageSelector': '中文',
    },
    'ar': {
      'appName': 'WindWisher',
      'taglinePrimary': 'The full kiteboarding experience.',
      'taglineSecondary': 'Plan the wind. Chase the session. Share the ride.',
      'loginHeadline': 'Sign in',
      'createAccountHeadline': 'Create account',
      'email': 'البريد الالكتروني',
      'emailHint': 'you@email.com',
      'password': 'كلمة المرور',
      'newPassword': 'كلمة مرور جديدة',
      'passwordHint': '6 احرف على الاقل',
      'signIn': 'تسجيل الدخول',
      'createAccount': 'انشاء حساب',
      'createAccountPrompt': 'ليس لديك حساب؟ انشئ واحدا',
      'existingAccountPrompt': 'لديك حساب بالفعل؟ سجل الدخول',
      'magicLink': 'الدخول عبر Magic Link',
      'socialAccess': 'الدخول الاجتماعي',
      'continueGoogle': 'المتابعة مع Google',
      'googleUnavailable': 'Google غير متاح',
      'continueApple': 'المتابعة مع Apple',
      'appleUnavailable': 'Apple غير متاح',
      'devBypass': 'الدخول عبر bypass',
      'recentAccounts': 'الحسابات الاخيرة',
      'recentQuickAccess': 'استخدم هذا البريد للدخول السريع',
      'removeRecent': 'ازالة من الاخيرة',
      'enterEmail': 'ادخل بريدك الالكتروني للمتابعة.',
      'emailCooldown': 'انتظر {seconds} ثانية قبل طلب رابط جديد.',
      'emailSent': 'لقد ارسلنا رابط دخول إلى {email}. تحقق من بريدك.',
      'accountCreated': 'تم انشاء الحساب. تحقق من بريدك اذا طلب Supabase تاكيد الوصول.',
      'resendAvailable': 'إعادة الإرسال متاحة خلال {seconds} ث',
      'language': 'اللغة',
      'chooseLanguage': 'اختر اللغة',
      'languageSelector': 'AR',
    },
  };

  String _value(String key) {
    final languageCode = _values.containsKey(locale.languageCode)
        ? locale.languageCode
        : 'es';
    return _values[languageCode]![key] ?? _values['es']![key]!;
  }

  String get appName => _value('appName');
  String get taglinePrimary => _value('taglinePrimary');
  String get taglineSecondary => _value('taglineSecondary');
  String get loginHeadline => _value('loginHeadline');
  String get createAccountHeadline => _value('createAccountHeadline');
  String get email => _value('email');
  String get emailHint => _value('emailHint');
  String get password => _value('password');
  String get newPassword => _value('newPassword');
  String get passwordHint => _value('passwordHint');
  String get signIn => _value('signIn');
  String get createAccount => _value('createAccount');
  String get createAccountPrompt => _value('createAccountPrompt');
  String get existingAccountPrompt => _value('existingAccountPrompt');
  String get forgotPassword => _value('forgotPassword');
  String get magicLink => _value('magicLink');
  String get socialAccess => _value('socialAccess');
  String get continueGoogle => _value('continueGoogle');
  String get googleUnavailable => _value('googleUnavailable');
  String get continueApple => _value('continueApple');
  String get appleUnavailable => _value('appleUnavailable');
  String get devBypass => _value('devBypass');
  String get recentAccounts => _value('recentAccounts');
  String get recentQuickAccess => _value('recentQuickAccess');
  String get removeRecent => _value('removeRecent');
  String get enterEmail => _value('enterEmail');
  String get accountCreated => _value('accountCreated');
  String get language => _value('language');
  String get chooseLanguage => _value('chooseLanguage');
  String get languageSelector => _value('languageSelector');

  String emailCooldown(int seconds) =>
      _value('emailCooldown').replaceAll('{seconds}', '$seconds');

  String emailSent(String email) =>
      _value('emailSent').replaceAll('{email}', email);

  String recoveryEmailSent(String email) =>
      _value('recoveryEmailSent').replaceAll('{email}', email);

  String resendAvailable(int seconds) =>
      _value('resendAvailable').replaceAll('{seconds}', '$seconds');

  String languageName(String languageCode) {
    switch (languageCode) {
      case 'es':
        return 'Español';
      case 'en':
        return 'English';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'zh':
        return '中文';
      case 'ar':
        return 'العربية';
      default:
        return languageCode.toUpperCase();
    }
  }
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppStrings.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings._(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppStrings> old) => false;
}
