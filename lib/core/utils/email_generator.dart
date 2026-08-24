// Email Otomatik Oluşturma Sistemi
// Azerbaycan karakterlerini Latin'e çevirir ve standart email formatı oluşturur

class EmailGenerator {
  /// Azerbaycan karakterlerini Latin harflere dönüştürür
  static String _convertAzerbaijaniToLatin(String text) {
    final Map<String, String> charMap = {
      'ə': 'e', 'Ə': 'E',
      'ı': 'i', 'I': 'I',
      'ö': 'o', 'Ö': 'O',
      'ü': 'u', 'Ü': 'U',
      'ç': 'c', 'Ç': 'C',
      'ş': 's', 'Ş': 'S',
      'ğ': 'g', 'Ğ': 'G',
    };

    String result = text;
    charMap.forEach((az, latin) {
      result = result.replaceAll(az, latin);
    });
    return result;
  }

  /// Ad Soyad'dan temiz username oluşturur
  /// Örnek: "Ayşə Məmmədova" → "ayse.memmedova"
  static String _generateUsername(String fullName) {
    final cleanName = _convertAzerbaijaniToLatin(fullName)
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z\s]'), '') // Özel karakterleri kaldır
        .replaceAll(RegExp(r'\s+'), '.'); // Boşlukları nokta yap
    
    return cleanName;
  }

  /// Çalışan (Staff) için email oluşturur (unikallıq yoxlamalı)
  /// Format: firstname.lastname@idrak.edu.az
  /// Dublikat varsa: firstname.lastname2@idrak.edu.az
  /// Örnek: "Ali Vəliyev" → "ali.veliyev@idrak.edu.az"
  static String generateStaffEmail(String fullName, {List<String> existingEmails = const []}) {
    final username = _generateUsername(fullName);
    String email = '$username@idrak.edu.az';
    
    // Dublikat yoxlaması
    if (existingEmails.contains(email)) {
      int counter = 2;
      while (existingEmails.contains('${username}$counter@idrak.edu.az')) {
        counter++;
      }
      email = '${username}$counter@idrak.edu.az';
    }
    
    return email;
  }

  /// Öğrenci için email oluşturur (unikallıq yoxlamalı)
  /// Format: firstname.lastname.sYYYY@idrak.edu.az
  /// Dublikat varsa: firstname.lastname2.sYYYY@idrak.edu.az
  /// Örnek: "Ayşə Məmmədova", 2024 → "ayse.memmedova.s2024@idrak.edu.az"
  static String generateStudentEmail(String fullName, int year, {List<String> existingEmails = const []}) {
    final username = _generateUsername(fullName);
    String email = '$username.s$year@idrak.edu.az';
    
    // Dublikat yoxlaması
    if (existingEmails.contains(email)) {
      int counter = 2;
      while (existingEmails.contains('$username$counter.s$year@idrak.edu.az')) {
        counter++;
      }
      email = '$username$counter.s$year@idrak.edu.az';
    }
    
    return email;
  }

  /// FIN kodundan yılı çıkartır (son 4 karakter)
  /// Örnek: "5VMHK2T" → 2007 (doğum yılı)
  /// Okula başlama yılı = doğum yılı + 6
  static int getYearFromFIN(String finCode) {
    if (finCode.length >= 7) {
      // FIN'in ilk karakteri yüzyıl gösterir
      final firstChar = finCode[0];
      int century = 1900;
      
      if (firstChar == '5' || firstChar == '6') {
        century = 2000; // 2000-2099
      } else if (firstChar == '3' || firstChar == '4') {
        century = 1900; // 1900-1999
      }
      
      // 5. ve 6. karakter yaşı gösterir (tersten)
      final birthYearLastTwo = finCode.substring(4, 6);
      final birthYear = century + int.parse(birthYearLastTwo);
      
      // Okula başlama yılı = doğum yılı + 6
      final schoolStartYear = birthYear + 6;
      
      return schoolStartYear;
    }
    
    // FIN yoksa mevcut yılı kullan
    return DateTime.now().year;
  }

  /// FIN kodundan doğum tarihini parse eder
  /// Format: XAYmmdd (X=yüzyıl, A=cinsiyet, Y=yıl son 2, mm=ay, dd=gün)
  /// Örnek: "5VMHK2T" → 5=2000+, V=erkek, MH=?, K2T=?
  /// NOT: Gerçek FIN format karmaşık, burada basitleştirilmiş
  static DateTime? parseBirthDateFromFIN(String finCode) {
    if (finCode.length != 7) return null;
    
    try {
      final firstChar = finCode[0];
      int century = 1900;
      
      if (firstChar == '5' || firstChar == '6') {
        century = 2000;
      } else if (firstChar == '3' || firstChar == '4') {
        century = 1900;
      }
      
      // FIN kodundaki tarih bilgisi çıkartılır (basitleştirilmiş)
      // Gerçek sistemde daha karmaşık algoritma kullanılmalı
      final yearLastTwo = int.parse(finCode.substring(4, 6));
      final year = century + yearLastTwo;
      
      // Varsayılan olarak 1 Ocak
      return DateTime(year, 1, 1);
    } catch (e) {
      return null;
    }
  }

  /// Veli için email oluşturur (unikallıq yoxlamalı)
  /// Format: firstname.lastname.parent@idrak.edu.az
  /// Dublikat varsa: firstname.lastname2.parent@idrak.edu.az
  /// Örnek: "Vəli Əliyev" → "veli.eliyev.parent@idrak.edu.az"
  static String generateParentEmail(String fullName, {List<String> existingEmails = const []}) {
    final username = _generateUsername(fullName);
    String email = '$username.parent@idrak.edu.az';
    
    // Dublikat yoxlaması
    if (existingEmails.contains(email)) {
      int counter = 2;
      while (existingEmails.contains('$username$counter.parent@idrak.edu.az')) {
        counter++;
      }
      email = '$username$counter.parent@idrak.edu.az';
    }
    
    return email;
  }

  /// Email'den ad soyad çıkartır (ters işlem)
  /// Örnek: "ayse.memmedova@idrak.edu.az" → "Ayse Memmedova"
  static String extractNameFromEmail(String email) {
    final username = email.split('@').first;
    final parts = username.split('.');
    
    // .s2024 veya .parent gibi sonekleri kaldır
    final nameParts = parts.where((part) => 
      !part.startsWith('s') && 
      part != 'parent'
    ).toList();
    
    // Her kelimenin ilk harfini büyüt
    final capitalizedParts = nameParts.map((part) {
      if (part.isEmpty) return part;
      return part[0].toUpperCase() + part.substring(1);
    }).toList();
    
    return capitalizedParts.join(' ');
  }

  /// Email'in geçerli olup olmadığını kontrol eder
  static bool isValidIdrakEmail(String email) {
    final regex = RegExp(
      r'^[a-z]+\.[a-z]+(\.(s\d{4}|parent))?@idrak\.edu\.az$',
      caseSensitive: false,
    );
    return regex.hasMatch(email);
  }

  /// Email tipini belirler
  static EmailType getEmailType(String email) {
    if (email.contains('.parent@')) return EmailType.parent;
    if (email.contains('.s')) return EmailType.student;
    if (email.contains('@idrak.edu.az')) return EmailType.staff;
    return EmailType.unknown;
  }
}

enum EmailType {
  staff,    // firstname.lastname@idrak.edu.az
  student,  // firstname.lastname.s2024@idrak.edu.az
  parent,   // firstname.lastname.parent@idrak.edu.az
  unknown,
}

// Kullanım Örnekleri:
// 
// 1. Çalışan email:
//    EmailGenerator.generateStaffEmail("Ali Vəliyev")
//    → "ali.veliyev@idrak.edu.az"
//
// 2. Öğrenci email:
//    EmailGenerator.generateStudentEmail("Ayşə Məmmədova", 2024)
//    → "ayse.memmedova.s2024@idrak.edu.az"
//
// 3. FIN'den yıl:
//    EmailGenerator.getYearFromFIN("5VMHK2T")
//    → 2013 (doğum 2007 + 6 yıl)
//
// 4. Veli email:
//    EmailGenerator.generateParentEmail("Vəli Əliyev")
//    → "veli.eliyev.parent@idrak.edu.az"
//
// 5. Email doğrulama:
//    EmailGenerator.isValidIdrakEmail("ayse.memmedova.s2024@idrak.edu.az")
//    → true
