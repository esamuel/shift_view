import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Shift View',
      'settingsTitle': 'Settings',
      'hourlyWage': 'Hourly Wage',
      'taxDeduction': 'Tax Deduction (%)',
      'baseHoursWeekday': 'Base Hours (Weekday)',
      'baseHoursSpecialDay': 'Base Hours (Special Day)',
      'startWorkWeekOnSunday': 'Start work week on Sunday',
      'shiftManagerTitle': 'Shift Manager',
      'reportsTitle': 'Reports',
      'infoButtonTitle': 'Info',
      'overtimeRulesTitle': 'Overtime Rules',
      'addToHomeScreen': 'Add to Home Screen',
      'addToHomeScreenTitle': 'How to Add to Home Screen',
      'addToHomeScreeniOS':
          'For iOS: Tap the share button in Safari, then select "Add to Home Screen".',
      'addToHomeScreenAndroid':
          'For Android: Tap the menu button in Chrome, then select "Add to home screen".',
      'ok': 'OK',
      'addNewShift': 'Add New Shift',
      'selectDate': 'Select Date',
      'startTime': 'Start Time',
      'endTime': 'End Time',
      'addShift': 'Add Shift',
      'existingShifts': 'Existing Shifts',
      'currentMonth': 'Current Month',
      'allShifts': 'All Shifts',
      'weeklyView': 'Weekly View',
      'monthlyView': 'Monthly View',
      'language': 'Language',
      'country': 'Country',
      'manageOvertimeRules': 'Manage Overtime Rules',
      'saveSettings': 'Save Settings',
      'noShiftsThisMonth': 'No shifts found for the current month',
      'noShiftsYet': 'No shifts added yet',
      'countryUS': 'United States (USD)',
      'countryGB': 'United Kingdom (GBP)',
      'countryEU': 'European Union (EUR)',
      'countryIL': 'Israel (ILS)',
      'countryRU': 'Russia (RUB)',
      'monday_full': 'Monday',
      'tuesday_full': 'Tuesday',
      'wednesday_full': 'Wednesday',
      'thursday_full': 'Thursday',
      'friday_full': 'Friday',
      'saturday_full': 'Saturday',
      'sunday_full': 'Sunday',
    },
    'es': {
      'appTitle': 'Vista de Turnos',
      'settingsTitle': 'Configuración',
      'hourlyWage': 'Salario por Hora',
      'taxDeduction': 'Deducción de Impuestos (%)',
      'baseHoursWeekday': 'Horas Base (Día Laboral)',
      'baseHoursSpecialDay': 'Horas Base (Día Especial)',
      'startWorkWeekOnSunday': 'Comenzar semana laboral el domingo',
      'shiftManagerTitle': 'Gestor de Turnos',
      'reportsTitle': 'Informes',
      'infoButtonTitle': 'Información',
      'overtimeRulesTitle': 'Reglas de Horas Extra',
      'addToHomeScreen': 'Añadir a Pantalla de Inicio',
      'addToHomeScreenTitle': 'Cómo Añadir a Pantalla de Inicio',
      'addToHomeScreeniOS':
          'Para iOS: Toca el botón compartir en Safari, luego selecciona "Añadir a Pantalla de Inicio".',
      'addToHomeScreenAndroid':
          'Para Android: Toca el botón de menú en Chrome, luego selecciona "Añadir a pantalla de inicio".',
      'ok': 'Aceptar',
      'addNewShift': 'Añadir Nuevo Turno',
      'selectDate': 'Seleccionar Fecha',
      'startTime': 'Hora de Inicio',
      'endTime': 'Hora de Fin',
      'addShift': 'Añadir Turno',
      'existingShifts': 'Turnos Existentes',
      'currentMonth': 'Mes Actual',
      'allShifts': 'Todos los Turnos',
      'weeklyView': 'Vista Semanal',
      'monthlyView': 'Vista Mensual',
      'language': 'Idioma',
      'country': 'País',
      'manageOvertimeRules': 'Gestionar Reglas de Horas Extra',
      'saveSettings': 'Guardar Configuración',
      'noShiftsThisMonth': 'No hay turnos para el mes actual',
      'noShiftsYet': 'Aún no hay turnos añadidos',
      'countryUS': 'Estados Unidos (USD)',
      'countryGB': 'Reino Unido (GBP)',
      'countryEU': 'Unión Europea (EUR)',
      'countryIL': 'Israel (ILS)',
      'countryRU': 'Rusia (RUB)',
      'monday_full': 'Lunes',
      'tuesday_full': 'Martes',
      'wednesday_full': 'Miércoles',
      'thursday_full': 'Jueves',
      'friday_full': 'Viernes',
      'saturday_full': 'Sábado',
      'sunday_full': 'Domingo',
    },
    'fr': {
      'appTitle': 'Vue des Quarts',
      'settingsTitle': 'Paramètres',
      'hourlyWage': 'Salaire Horaire',
      'taxDeduction': 'Déduction Fiscale (%)',
      'baseHoursWeekday': 'Heures de Base (Jour de Semaine)',
      'baseHoursSpecialDay': 'Heures de Base (Jour Spécial)',
      'startWorkWeekOnSunday': 'Commencer la semaine de travail le dimanche',
      'shiftManagerTitle': 'Gestionnaire de Quarts',
      'reportsTitle': 'Rapports',
      'infoButtonTitle': 'Info',
      'overtimeRulesTitle': 'Règles des Heures Supplémentaires',
      'addToHomeScreen': 'Ajouter à l\'écran d\'accueil',
      'addToHomeScreenTitle': 'Comment Ajouter à l\'écran d\'accueil',
      'addToHomeScreeniOS':
          'Pour iOS : Appuyez sur le bouton partager dans Safari, puis sélectionnez "Ajouter à l\'écran d\'accueil".',
      'addToHomeScreenAndroid':
          'Pour Android : Appuyez sur le bouton menu dans Chrome, puis sélectionnez "Ajouter à l\'écran d\'accueil".',
      'ok': 'OK',
      'addNewShift': 'Ajouter un Nouveau Quart',
      'selectDate': 'Sélectionner la Date',
      'startTime': 'Heure de Début',
      'endTime': 'Heure de Fin',
      'addShift': 'Ajouter un Quart',
      'existingShifts': 'Quarts Existants',
      'currentMonth': 'Mois en Cours',
      'allShifts': 'Tous les Quarts',
      'weeklyView': 'Vue Hebdomadaire',
      'monthlyView': 'Vue Mensuelle',
      'language': 'Langue',
      'country': 'Pays',
      'manageOvertimeRules': 'Gérer les Règles des Heures Supplémentaires',
      'saveSettings': 'Enregistrer les Paramètres',
      'noShiftsThisMonth': 'Aucun quart trouvé pour le mois en cours',
      'noShiftsYet': 'Aucun quart ajouté pour le moment',
      'countryUS': 'États-Unis (USD)',
      'countryGB': 'Royaume-Uni (GBP)',
      'countryEU': 'Union Européenne (EUR)',
      'countryIL': 'Israël (ILS)',
      'countryRU': 'Russie (RUB)',
      'monday_full': 'Lundi',
      'tuesday_full': 'Mardi',
      'wednesday_full': 'Mercredi',
      'thursday_full': 'Jeudi',
      'friday_full': 'Vendredi',
      'saturday_full': 'Samedi',
      'sunday_full': 'Dimanche',
    },
    'de': {
      'monday_full': 'Montag',
      'tuesday_full': 'Dienstag',
      'wednesday_full': 'Mittwoch',
      'thursday_full': 'Donnerstag',
      'friday_full': 'Freitag',
      'saturday_full': 'Samstag',
      'sunday_full': 'Sonntag',
    },
    'ru': {
      'appTitle': 'Просмотр Смен',
      'settingsTitle': 'Настройки',
      'hourlyWage': 'Почасовая Оплата',
      'taxDeduction': 'Налоговый Вычет (%)',
      'baseHoursWeekday': 'Базовые Часы (Будни)',
      'baseHoursSpecialDay': 'Базовые Часы (Особый День)',
      'startWorkWeekOnSunday': 'Начинать рабочую неделю с воскресенья',
      'shiftManagerTitle': 'Управление Сменами',
      'reportsTitle': 'Отчеты',
      'infoButtonTitle': 'Информация',
      'overtimeRulesTitle': 'Правила Сверхурочных',
      'addToHomeScreen': 'Добавить на Главный Экран',
      'addToHomeScreenTitle': 'Как Добавить на Главный Экран',
      'addToHomeScreeniOS':
          'Для iOS: Нажмите кнопку "Поделиться" в Safari, затем выберите "На экран «Домой»".',
      'addToHomeScreenAndroid':
          'Для Android: Нажмите кнопку меню в Chrome, затем выберите "Добавить на главный экран".',
      'ok': 'OK',
      'addNewShift': 'Добавить Новую Смену',
      'selectDate': 'Выбрать Дату',
      'startTime': 'Время Начала',
      'endTime': 'Время Окончания',
      'addShift': 'Добавить Смену',
      'existingShifts': 'Существующие Смены',
      'currentMonth': 'Текущий Месяц',
      'allShifts': 'Все Смены',
      'weeklyView': 'Недельный Вид',
      'monthlyView': 'Месячный Вид',
      'language': 'Язык',
      'country': 'Страна',
      'manageOvertimeRules': 'Управление Правилами Сверхурочных',
      'saveSettings': 'Сохранить Настройки',
      'noShiftsThisMonth': 'Нет смен в текущем месяце',
      'noShiftsYet': 'Смены еще не добавлены',
      'countryUS': 'США (USD)',
      'countryGB': 'Великобритания (GBP)',
      'countryEU': 'Европейский Союз (EUR)',
      'countryIL': 'Израиль (ILS)',
      'countryRU': 'Россия (RUB)',
      'monday_full': 'Понедельник',
      'tuesday_full': 'Вторник',
      'wednesday_full': 'Среда',
      'thursday_full': 'Четверг',
      'friday_full': 'Пятница',
      'saturday_full': 'Суббота',
      'sunday_full': 'Воскресенье',
    },
    'he': {
      'appTitle': 'צפייה במשמרות',
      'settingsTitle': 'הגדרות',
      'hourlyWage': 'שכר לשעה',
      'taxDeduction': 'ניכוי מס (%)',
      'baseHoursWeekday': 'שעות בסיס (יום חול)',
      'baseHoursSpecialDay': 'שעות בסיס (יום מיוחד)',
      'startWorkWeekOnSunday': 'התחל שבוע עבודה ביום ראשון',
      'shiftManagerTitle': 'ניהול משמרות',
      'reportsTitle': 'דוחות',
      'infoButtonTitle': 'מידע',
      'overtimeRulesTitle': 'כללי שעות נוספות',
      'addToHomeScreen': 'הוסף למסך הבית',
      'addToHomeScreenTitle': 'כיצד להוסיף למסך הבית',
      'addToHomeScreeniOS':
          'עבור iOS: הקש על כפתור השיתוף בספארי, ואז בחר "הוסף למסך הבית".',
      'addToHomeScreenAndroid':
          'עבור אנדרואיד: הקש על כפתור התפריט בכרום, ואז בחר "הוסף למסך הבית".',
      'ok': 'אישור',
      'addNewShift': 'הוסף משמרת חדשה',
      'selectDate': 'בחר תאריך',
      'startTime': 'שעת התחלה',
      'endTime': 'שעת סיום',
      'addShift': 'הוסף משמרת',
      'existingShifts': 'משמרות קיימות',
      'currentMonth': 'חודש נוכחי',
      'allShifts': 'כל המשמרות',
      'weeklyView': 'תצוגה שבועית',
      'monthlyView': 'תצוגה חודשית',
      'language': 'שפה',
      'country': 'מדינה',
      'manageOvertimeRules': 'נהל כללי שעות נוספות',
      'saveSettings': 'שמור הגדרות',
      'noShiftsThisMonth': 'לא נמצאו משמרות בחודש הנוכחי',
      'noShiftsYet': 'טרם נוספו משמרות',
      'countryUS': 'ארצות הברית (USD)',
      'countryGB': 'בריטניה (GBP)',
      'countryEU': 'האיחוד האירופי (EUR)',
      'countryIL': 'ישראל (ILS)',
      'countryRU': 'רוסיה (RUB)',
      'monday_full': 'שני',
      'tuesday_full': 'שלישי',
      'wednesday_full': 'רביעי',
      'thursday_full': 'חמישי',
      'friday_full': 'שישי',
      'saturday_full': 'שבת',
      'sunday_full': 'ראשון',
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get settingsTitle =>
      _localizedValues[locale.languageCode]!['settingsTitle']!;
  String get shiftManagerTitle =>
      _localizedValues[locale.languageCode]!['shiftManagerTitle']!;
  String get reportsTitle =>
      _localizedValues[locale.languageCode]!['reportsTitle']!;
  String get infoButtonTitle =>
      _localizedValues[locale.languageCode]!['infoButtonTitle']!;
  String get overtimeRulesTitle =>
      _localizedValues[locale.languageCode]!['overtimeRulesTitle']!;
  String get addToHomeScreen =>
      _localizedValues[locale.languageCode]!['addToHomeScreen']!;
  String get addToHomeScreenTitle =>
      _localizedValues[locale.languageCode]!['addToHomeScreenTitle']!;
  String get addToHomeScreeniOS =>
      _localizedValues[locale.languageCode]!['addToHomeScreeniOS']!;
  String get addToHomeScreenAndroid =>
      _localizedValues[locale.languageCode]!['addToHomeScreenAndroid']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get addNewShift =>
      _localizedValues[locale.languageCode]!['addNewShift']!;
  String get selectDate =>
      _localizedValues[locale.languageCode]!['selectDate']!;
  String get startTime => _localizedValues[locale.languageCode]!['startTime']!;
  String get endTime => _localizedValues[locale.languageCode]!['endTime']!;
  String get addShift => _localizedValues[locale.languageCode]!['addShift']!;
  String get existingShifts =>
      _localizedValues[locale.languageCode]!['existingShifts']!;
  String get currentMonth =>
      _localizedValues[locale.languageCode]!['currentMonth']!;
  String get allShifts => _localizedValues[locale.languageCode]!['allShifts']!;
  String get weeklyView =>
      _localizedValues[locale.languageCode]!['weeklyView']!;
  String get monthlyView =>
      _localizedValues[locale.languageCode]!['monthlyView']!;
  String get baseHoursWeekday =>
      _localizedValues[locale.languageCode]!['baseHoursWeekday']!;
  String get baseHoursSpecialDay =>
      _localizedValues[locale.languageCode]!['baseHoursSpecialDay']!;
  String get startWorkWeekOnSunday =>
      _localizedValues[locale.languageCode]!['startWorkWeekOnSunday']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get country => _localizedValues[locale.languageCode]!['country']!;
  String get manageOvertimeRules =>
      _localizedValues[locale.languageCode]!['manageOvertimeRules']!;
  String get saveSettings =>
      _localizedValues[locale.languageCode]!['saveSettings']!;
  String get countryUS => _localizedValues[locale.languageCode]!['countryUS']!;
  String get countryGB => _localizedValues[locale.languageCode]!['countryGB']!;
  String get countryEU => _localizedValues[locale.languageCode]!['countryEU']!;
  String get countryIL => _localizedValues[locale.languageCode]!['countryIL']!;
  String get countryRU => _localizedValues[locale.languageCode]!['countryRU']!;
  String get hourlyWage =>
      _localizedValues[locale.languageCode]!['hourlyWage']!;
  String get taxDeduction =>
      _localizedValues[locale.languageCode]!['taxDeduction']!;
  String get noShiftsThisMonth =>
      _localizedValues[locale.languageCode]!['noShiftsThisMonth']!;
  String get noShiftsYet =>
      _localizedValues[locale.languageCode]!['noShiftsYet']!;
  String get monday_full =>
      _localizedValues[locale.languageCode]!['monday_full']!;
  String get tuesday_full =>
      _localizedValues[locale.languageCode]!['tuesday_full']!;
  String get wednesday_full =>
      _localizedValues[locale.languageCode]!['wednesday_full']!;
  String get thursday_full =>
      _localizedValues[locale.languageCode]!['thursday_full']!;
  String get friday_full =>
      _localizedValues[locale.languageCode]!['friday_full']!;
  String get saturday_full =>
      _localizedValues[locale.languageCode]!['saturday_full']!;
  String get sunday_full =>
      _localizedValues[locale.languageCode]!['sunday_full']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'he', 'es', 'de', 'ru', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
