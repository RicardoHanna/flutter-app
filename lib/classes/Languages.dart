class Language {
  final int id;
  final String name;
  final String nameInArabic;
  final String languageCode;

  Language({required this.id, required this.name, required this.languageCode,required this.nameInArabic});

  static List<Language> languageList() {
    return <Language>[
      Language(id: 1, name: "English", languageCode: 'en',nameInArabic: 'إنجليزي'),
      Language(id: 2, name: "Arabic", languageCode: 'ar',nameInArabic: 'عربي'),
    ];
  }
}
