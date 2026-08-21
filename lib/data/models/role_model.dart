// Rol və Səlahiyyət Modeli
// Sistemdə istifadəçi rollarını və səlahiyyətlərini idarə edir

class Permission {
  final String id;
  final String name;
  final String description;
  final String category;

  const Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
  };

  factory Permission.fromJson(Map<String, dynamic> json) => Permission(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    category: json['category'] ?? '',
  );
}

class Role {
  final String id;
  final String name;
  final String description;
  final List<String> permissionIds; // Permission ID siyahısı
  final bool isDefault; // Sistem default rolu?
  final bool isDeletable; // Silinə bilər?
  final DateTime createdAt;

  Role({
    required this.id,
    required this.name,
    required this.description,
    this.permissionIds = const [],
    this.isDefault = false,
    this.isDeletable = true,
    required this.createdAt,
  });

  Role copyWith({
    String? name,
    String? description,
    List<String>? permissionIds,
    bool? isDefault,
    bool? isDeletable,
  }) {
    return Role(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      permissionIds: permissionIds ?? this.permissionIds,
      isDefault: isDefault ?? this.isDefault,
      isDeletable: isDeletable ?? this.isDeletable,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'permissionIds': permissionIds,
    'isDefault': isDefault,
    'isDeletable': isDeletable,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    permissionIds: List<String>.from(json['permissionIds'] ?? []),
    isDefault: json['isDefault'] ?? false,
    isDeletable: json['isDeletable'] ?? true,
    createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
  );
}

// Default Səlahiyyətlər
class DefaultPermissions {
  static const List<Permission> all = [
    // Şagird İdarəetməsi
    Permission(
      id: 'view_students',
      name: 'Şagird Baxışı',
      description: 'Şagird siyahısını və detallarını görə bilər',
      category: 'Şagird İdarəetməsi',
    ),
    Permission(
      id: 'add_students',
      name: 'Şagird Əlavə Etmə',
      description: 'Yeni şagird qeydiyyatı yara bilər',
      category: 'Şagird İdarəetməsi',
    ),
    Permission(
      id: 'edit_students',
      name: 'Şagird Redaktəsi',
      description: 'Mövcud şagird məlumatlarını redaktə edə bilər',
      category: 'Şagird İdarəetməsi',
    ),
    Permission(
      id: 'delete_students',
      name: 'Şagird Silmə',
      description: 'Şagird qeydini silə bilər',
      category: 'Şagird İdarəetməsi',
    ),

    // Qiymət İdarəetməsi
    Permission(
      id: 'view_grades',
      name: 'Qiymət Baxışı',
      description: 'Şagird qiymətlərini görə bilər',
      category: 'Qiymət İdarəetməsi',
    ),
    Permission(
      id: 'add_grades',
      name: 'Qiymət Daxil Etmə',
      description: 'Şagirdlərə qiymət daxil edə bilər',
      category: 'Qiymət İdarəetməsi',
    ),
    Permission(
      id: 'edit_grades',
      name: 'Qiymət Redaktəsi',
      description: 'Mövcud qiymətləri redaktə edə bilər',
      category: 'Qiymət İdarəetməsi',
    ),
    Permission(
      id: 'delete_grades',
      name: 'Qiymət Silmə',
      description: 'Daxil edilən qiymətləri silə bilər',
      category: 'Qiymət İdarəetməsi',
    ),

    // Davamiyyət İdarəetməsi
    Permission(
      id: 'view_attendance',
      name: 'Davamiyyət Baxışı',
      description: 'Davamiyyət qeydlərini görə bilər',
      category: 'Davamiyyət İdarəetməsi',
    ),
    Permission(
      id: 'add_attendance',
      name: 'Davamiyyət Daxil Etmə',
      description: 'Davamiyyət qeydi daxil edə bilər',
      category: 'Davamiyyət İdarəetməsi',
    ),
    Permission(
      id: 'edit_attendance',
      name: 'Davamiyyət Redaktəsi',
      description: 'Davamiyyət qeydlərini redaktə edə bilər',
      category: 'Davamiyyət İdarəetməsi',
    ),
    Permission(
      id: 'delete_attendance',
      name: 'Davamiyyət Silmə',
      description: 'Davamiyyət qeydlərini silə bilər',
      category: 'Davamiyyət İdarəetməsi',
    ),

    // İstifadəçi İdarəetməsi
    Permission(
      id: 'view_users',
      name: 'İstifadəçi Baxışı',
      description: 'Sistem istifadəçilərini görə bilər',
      category: 'İstifadəçi İdarəetməsi',
    ),
    Permission(
      id: 'add_users',
      name: 'İstifadəçi Əlavə Etmə',
      description: 'Yeni istifadəçi (işçi) hesabı yara bilər',
      category: 'İstifadəçi İdarəetməsi',
    ),
    Permission(
      id: 'edit_users',
      name: 'İstifadəçi Redaktəsi',
      description: 'İstifadəçi məlumatlarını redaktə edə bilər',
      category: 'İstifadəçi İdarəetməsi',
    ),
    Permission(
      id: 'delete_users',
      name: 'İstifadəçi Silmə',
      description: 'İstifadəçi hesabını silə bilər',
      category: 'İstifadəçi İdarəetməsi',
    ),

    // Sinif İdarəetməsi
    Permission(
      id: 'view_classes',
      name: 'Sinif Baxışı',
      description: 'Sinif siyahısını görə bilər',
      category: 'Sinif İdarəetməsi',
    ),
    Permission(
      id: 'manage_classes',
      name: 'Sinif İdarəetməsi',
      description: 'Sinif yara, redaktə edə, silə bilər',
      category: 'Sinif İdarəetməsi',
    ),
    Permission(
      id: 'assign_teachers',
      name: 'Müəllim Təyin Etmə',
      description: 'Siniflərə müəllim təyin edə bilər',
      category: 'Sinif İdarəetməsi',
    ),

    // Dərs Cədvəli İdarəetməsi
    Permission(
      id: 'view_timetable',
      name: 'Dərs Cədvəli Baxışı',
      description: 'Dərs cədvəlini görə bilər',
      category: 'Dərs Cədvəli',
    ),
    Permission(
      id: 'manage_timetable',
      name: 'Dərs Cədvəli İdarəetməsi',
      description: 'Dərs cədvəli yara və redaktə edə bilər',
      category: 'Dərs Cədvəli',
    ),

    // Hesabat və Təhlil
    Permission(
      id: 'view_reports',
      name: 'Hesabat Baxışı',
      description: 'Sistem hesabatlarını görə bilər',
      category: 'Hesabatlar',
    ),
    Permission(
      id: 'export_reports',
      name: 'Hesabat İxracı',
      description: 'Hesabatları Excel/PDF olaraq yükləyə bilər',
      category: 'Hesabatlar',
    ),

    // Tibbi Qeydlər
    Permission(
      id: 'view_medical',
      name: 'Tibbi Qeyd Baxışı',
      description: 'Şagird sağlamlıq qeydlərini görə bilər',
      category: 'Səhiyyə',
    ),
    Permission(
      id: 'manage_medical',
      name: 'Tibbi Qeyd İdarəetməsi',
      description: 'Sağlamlıq qeydləri əlavə edə və redaktə edə bilər',
      category: 'Səhiyyə',
    ),

    // Kitabxana
    Permission(
      id: 'view_library',
      name: 'Kitabxana Baxışı',
      description: 'Kitabxana kitablarını görə bilər',
      category: 'Kitabxana',
    ),
    Permission(
      id: 'manage_library',
      name: 'Kitabxana İdarəetməsi',
      description: 'Kitab əlavə edə, borc vermə əməliyyatları edə bilər',
      category: 'Kitabxana',
    ),

    // Yeməkxana
    Permission(
      id: 'view_cafeteria',
      name: 'Yeməkxana Menyusu Baxışı',
      description: 'Yeməkxana menyusunu görə bilər',
      category: 'Yeməkxana',
    ),
    Permission(
      id: 'manage_cafeteria',
      name: 'Yeməkxana İdarəetməsi',
      description: 'Yeməkxana menyusunu redaktə edə bilər',
      category: 'Yeməkxana',
    ),

    // İnventar (QR Ticket)
    Permission(
      id: 'view_inventory',
      name: 'İnventar Baxışı',
      description: 'İnventar qeydlərini görə bilər',
      category: 'İnventar',
    ),
    Permission(
      id: 'manage_inventory',
      name: 'İnventar İdarəetməsi',
      description: 'İnventar QR ticket yara və idarə edə bilər',
      category: 'İnventar',
    ),

    // Dəstək (Helpdesk)
    Permission(
      id: 'view_tickets',
      name: 'Dəstək Tələbləri Baxışı',
      description: 'Helpdesk tələblərini görə bilər',
      category: 'Dəstək',
    ),
    Permission(
      id: 'manage_tickets',
      name: 'Dəstək Tələbləri İdarəetməsi',
      description: 'Dəstək tələblərini cavablandıra və bağlaya bilər',
      category: 'Dəstək',
    ),

    // Sistem Ayarları
    Permission(
      id: 'view_settings',
      name: 'Ayarları Baxış',
      description: 'Sistem ayarlarını görə bilər',
      category: 'Sistem',
    ),
    Permission(
      id: 'manage_settings',
      name: 'Ayarları İdarəetmə',
      description: 'Sistem ayarlarını dəyişdirə bilər',
      category: 'Sistem',
    ),

    // Rol İdarəetməsi
    Permission(
      id: 'view_roles',
      name: 'Rol Baxışı',
      description: 'Rolları görə bilər',
      category: 'Rol İdarəetməsi',
    ),
    Permission(
      id: 'manage_roles',
      name: 'Rol İdarəetməsi',
      description: 'Rol yara, redaktə edə, silə bilər',
      category: 'Rol İdarəetməsi',
    ),

    // ========================================
    // 🌐 WEB PANEL ÖZELLİKLERİ (API Entegrasyonu)
    // ⚠️ Bu izinler gerçek API gelince aktif olacak
    // ========================================

    // Maliyyə (Finance) - Sadəcə Admin
    Permission(
      id: 'view_finance',
      name: 'Maliyyə Baxışı',
      description: 'Maliyyə məlumatlarını görə bilər',
      category: 'Maliyyə',
    ),
    Permission(
      id: 'manage_student_invoices',
      name: 'Tələbə Müqavilələri',
      description: 'Tələbə müqavilələrini idarə edə bilər',
      category: 'Maliyyə',
    ),
    Permission(
      id: 'manage_payroll',
      name: 'Əmək Haqqı Hesablanması',
      description: 'Əmək haqqı hesablamalarını idarə edə bilər',
      category: 'Maliyyə',
    ),
    Permission(
      id: 'view_salary_list',
      name: 'Maaş Siyahısı',
      description: 'Əməkdaş maaşlarını görə bilər',
      category: 'Maliyyə',
    ),
    Permission(
      id: 'manage_general_ledger',
      name: 'Gəlir/Xərc İdarəetməsi',
      description: 'Ümumi gəlir və xərclərə nəzarət',
      category: 'Maliyyə',
    ),

    // Əməkdaş İdarəetməsi (Employee)
    Permission(
      id: 'view_employees',
      name: 'Əməkdaş Baxışı',
      description: 'Əməkdaş siyahısını görə bilər',
      category: 'Əməkdaş İdarəetməsi',
    ),
    Permission(
      id: 'manage_employees',
      name: 'Əməkdaş İdarəetməsi',
      description: 'Əməkdaş əlavə edə, redaktə edə bilər',
      category: 'Əməkdaş İdarəetməsi',
    ),
    Permission(
      id: 'view_contracts',
      name: 'Müqavilə Baxışı',
      description: 'İş müqavilələrini görə bilər',
      category: 'Əməkdaş İdarəetməsi',
    ),
    Permission(
      id: 'manage_contracts',
      name: 'Müqavilə İdarəetməsi',
      description: 'İş müqavilələrini idarə edə bilər',
      category: 'Əməkdaş İdarəetməsi',
    ),
    Permission(
      id: 'view_employee_attendance',
      name: 'İşçi Davamiyyəti',
      description: 'İşçi davamiyyətini görə bilər',
      category: 'Əməkdaş İdarəetməsi',
    ),

    // Anbar (Warehouse)
    Permission(
      id: 'view_warehouse',
      name: 'Anbar Baxışı',
      description: 'Anbar məlumatlarını görə bilər',
      category: 'Anbar',
    ),
    Permission(
      id: 'manage_inventorizations',
      name: 'İnventarizasiya',
      description: 'Anbar inventarizasiyasını edə bilər',
      category: 'Anbar',
    ),

    // İmtahan İdarəetməsi (Exams)
    Permission(
      id: 'view_exams',
      name: 'İmtahan Baxışı',
      description: 'İmtahan siyahısını görə bilər',
      category: 'İmtahan',
    ),
    Permission(
      id: 'manage_exams',
      name: 'İmtahan İdarəetməsi',
      description: 'İmtahan təşkil edə və idarə edə bilər',
      category: 'İmtahan',
    ),
    Permission(
      id: 'view_exam_results',
      name: 'İmtahan Nəticələri',
      description: 'İmtahan nəticələrini görə bilər',
      category: 'İmtahan',
    ),
    Permission(
      id: 'enter_exam_results',
      name: 'Nəticə Daxil Etmə',
      description: 'İmtahan nəticələrini daxil edə bilər',
      category: 'İmtahan',
    ),

    // Struktur İdarəetməsi (Structure) - Sadəcə Admin
    Permission(
      id: 'view_structure',
      name: 'Struktur Baxışı',
      description: 'Təşkilat strukturunu görə bilər',
      category: 'Struktur',
    ),
    Permission(
      id: 'manage_companies',
      name: 'Məktəb İdarəsi',
      description: 'Məktəb/Şirkət məlumatlarını idarə edə bilər',
      category: 'Struktur',
    ),
    Permission(
      id: 'manage_filials',
      name: 'Filial İdarəetməsi',
      description: 'Filialları idarə edə bilər',
      category: 'Struktur',
    ),

    // Statistika
    Permission(
      id: 'view_statistics',
      name: 'Statistika Baxışı',
      description: 'Sistem statistikalarını görə bilər',
      category: 'Statistika',
    ),
    Permission(
      id: 'view_quality_control',
      name: 'Keyfiyyətə Nəzarət',
      description: 'Keyfiyyət nəzarət hesabatlarını görə bilər',
      category: 'Statistika',
    ),
    Permission(
      id: 'view_performance_stats',
      name: 'Performans Statistikası',
      description: 'Şagird performans statistikasını görə bilər',
      category: 'Statistika',
    ),

    // Tapşırıq və Kurikulum
    Permission(
      id: 'manage_assignments',
      name: 'Tapşırıq İdarəetməsi',
      description: 'Tapşırıq yara və yoxlaya bilər',
      category: 'Akademik',
    ),
    Permission(
      id: 'manage_curriculum',
      name: 'Kurikulum İdarəetməsi',
      description: 'Tədris proqramını idarə edə bilər',
      category: 'Akademik',
    ),
    Permission(
      id: 'manage_clubs',
      name: 'Dərnək İdarəetməsi',
      description: 'Şagird dərnəklərini idarə edə bilər',
      category: 'Akademik',
    ),

    // 📱 Mobil Xüsusi Özellikler
    Permission(
      id: 'view_digital_id',
      name: 'Digital ID Kartı',
      description: 'Şagird digital kimlik kartını görə bilər',
      category: 'Mobil Xüsusi',
    ),
    Permission(
      id: 'access_meet_idrak',
      name: 'Meet İdrak Girişi',
      description: 'Video görüşlərə qoşula bilər',
      category: 'Mobil Xüsusi',
    ),
    Permission(
      id: 'create_meet_room',
      name: 'Görüş Otağı Yaratma',
      description: 'Yeni video görüş otağı yara bilər',
      category: 'Mobil Xüsusi',
    ),
    Permission(
      id: 'scan_qr_attendance',
      name: 'QR Davamiyyət Oxutma',
      description: 'QR kod ilə davamiyyət qeyd edə bilər',
      category: 'Mobil Xüsusi',
    ),
  ];

  // Kateqoriyaya görə qrupla
  static Map<String, List<Permission>> get byCategory {
    final Map<String, List<Permission>> grouped = {};
    for (final permission in all) {
      if (!grouped.containsKey(permission.category)) {
        grouped[permission.category] = [];
      }
      grouped[permission.category]!.add(permission);
    }
    return grouped;
  }
}

// Default Rollar (10 Ədəd)
class DefaultRoles {
  static List<Role> createAll() {
    final now = DateTime.now();
    
    return [
      // 1. Admin - Bütün səlahiyyətlər
      Role(
        id: 'role-admin',
        name: 'Admin',
        description: 'Sistem inzibatçısı - Bütün səlahiyyətlər',
        permissionIds: DefaultPermissions.all.map((p) => p.id).toList(),
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 2. Müdür - Admin kimi amma rol idarəetməsi yoxdur
      Role(
        id: 'role-mudur',
        name: 'Müdür',
        description: 'Məktəb müdürü - Geniş səlahiyyətlər',
        permissionIds: DefaultPermissions.all
            .where((p) => !p.id.startsWith('manage_roles'))
            .map((p) => p.id)
            .toList(),
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 3. Müdür Müavini - Orta səviyyə idarəetmə
      Role(
        id: 'role-mudur-muavini',
        name: 'Müdür Müavini',
        description: 'Müdür köməkçisi - İdarəetmə səlahiyyətləri',
        permissionIds: [
          'view_students', 'add_students', 'edit_students',
          'view_users', 'view_grades', 'view_attendance', 'edit_attendance',
          'view_classes', 'manage_classes', 'assign_teachers',
          'view_timetable', 'manage_timetable',
          'view_reports', 'export_reports',
          'view_medical', 'view_library', 'view_cafeteria',
          'view_inventory', 'view_tickets', 'manage_tickets',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 4. Müəllim - Tədris səlahiyyətləri
      Role(
        id: 'role-ogretmen',
        name: 'Müəllim',
        description: 'Müəllim - Qiymət və davamiyyət idarəetməsi',
        permissionIds: [
          'view_students',
          'view_grades', 'add_grades', 'edit_grades',
          'view_attendance', 'add_attendance', 'edit_attendance',
          'view_classes',
          'view_timetable',
          'view_reports',
          'view_medical',
          'view_library',
          'view_cafeteria',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 5. IT Çalışanı - Texniki dəstək və sistem
      Role(
        id: 'role-it',
        name: 'IT Çalışanı',
        description: 'IT işçisi - Texniki dəstək və sistem idarəetməsi',
        permissionIds: [
          'view_users', 'add_users', 'edit_users',
          'view_students', 'view_classes',
          'view_inventory', 'manage_inventory',
          'view_tickets', 'manage_tickets',
          'view_settings', 'manage_settings',
          'view_timetable',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 6. Helpdesk - Dəstək tələbi idarəetməsi
      Role(
        id: 'role-helpdesk',
        name: 'Helpdesk',
        description: 'Yardım masası - Dəstək tələbləri',
        permissionIds: [
          'view_students',
          'view_users',
          'view_tickets', 'manage_tickets',
          'view_inventory',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 7. Psixoloq - Şagird məsləhətçiliyi
      Role(
        id: 'role-psikolog',
        name: 'Psixoloq',
        description: 'Rəhbər müəllim - Şagird izləməsi',
        permissionIds: [
          'view_students',
          'view_grades',
          'view_attendance',
          'view_classes',
          'view_reports',
          'view_medical',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 8. Tibbi Çalışan - Sağlıq qeydləri
      Role(
        id: 'role-tibbi',
        name: 'Tibbi Çalışan',
        description: 'Səhiyyə işçisi - Tibbi qeyd idarəetməsi',
        permissionIds: [
          'view_students',
          'view_medical', 'manage_medical',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 9. Kitabxanaçı - Kitabxana əməliyyatları
      Role(
        id: 'role-kutuphaneci',
        name: 'Kitabxanaçı',
        description: 'Kitabxana işçisi - Kitab idarəetməsi',
        permissionIds: [
          'view_students',
          'view_library', 'manage_library',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),

      // 10. Təhlükəsizlik - Məhdud giriş
      Role(
        id: 'role-guvenlik',
        name: 'Təhlükəsizlik',
        description: 'Mühafizə işçisi - QR/Barkod oxuma',
        permissionIds: [
          'view_students',
          'view_inventory',
        ],
        isDefault: true,
        isDeletable: false,
        createdAt: now,
      ),
    ];
  }
}
