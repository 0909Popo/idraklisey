/// 🌐 API Configuration
/// ⚠️ IMPORTANT: Bu dosya gerçek API alındığında güncellenecek
///
/// Şu an MOCK MODE - Firebase ve local data kullanılıyor
/// Gerçek sistem API'si hazır olunca:
/// 1. BASE_URL güncelle
/// 2. USE_MOCK_DATA = false yap
/// 3. Response model'leri API contract'a göre düzenle

class ApiConfig {
  // ========================================
  // 🔧 CONFIGURATION FLAGS
  // ========================================
  
  /// Mock data kullanılsın mı? (Gerçek API hazır olunca false yap)
  static const bool USE_MOCK_DATA = true;
  
  /// Network logları gösterilsin mi?
  static const bool ENABLE_LOGGING = true;
  
  /// Request timeout süresi (saniye)
  static const int TIMEOUT_SECONDS = 30;

  // ========================================
  // 🌐 BASE URLS
  // ========================================
  
  /// Gerçek sistem base URL'i (Web sitesinden alındı)
  static const String PRODUCTION_BASE_URL = 'https://new.idrak.edu.az';
  
  /// Test/Development URL (varsa)
  static const String DEV_BASE_URL = 'https://dev.idrak.edu.az';
  
  /// Şu an kullanılan URL
  static String get baseUrl => PRODUCTION_BASE_URL;

  // ========================================
  // 📡 API ENDPOINTS
  // ========================================
  
  // Auth Endpoints
  static const String LOGIN = '/panel/auth/login';
  static const String LOGOUT = '/panel/auth/logout';
  static const String PROFILE = '/panel/profile';
  static const String SET_LANGUAGE = '/panel/general/set_lang';
  
  // Notifications
  static const String GET_LATEST_NOTIFICATIONS = '/panel/notifications/get-latest';
  static const String ALL_NOTIFICATIONS = '/panel/notifications';
  
  // Academic - Students
  static const String STUDENTS = '/panel/academic/students';
  static const String GRADUATIONS = '/panel/academic/graduations';
  static const String TRANSITION_EXCEPTIONS = '/panel/academic/transitions/exceptions';
  
  // Academic - Teachers & Classes
  static const String CLASSES = '/panel/academic/teachers/classes';
  static const String TEACHERS = '/panel/academic/teachers/teachers';
  static const String SCHEDULING = '/panel/academic/scheduling';
  
  // Academic - Operations
  static const String ATTENDANCE = '/panel/academic/operations/attendance';
  static const String EXCUSES = '/panel/academic/homeroom/excuses';
  static const String ASSIGNMENTS = '/panel/academic/operations/assignments';
  static const String CURRICULUMS = '/panel/academic/operations/curriculums/manage';
  static const String CLUBS = '/panel/academic/clubs';
  
  // Academic - Foundations
  static const String ACADEMIC_YEARS = '/panel/academic/foundations/academic-years';
  static const String STATUSES = '/panel/academic/foundations/statuses';
  static const String SUBJECTS = '/panel/academic/foundations/subjects';
  static const String ROOMS = '/panel/academic/foundations/rooms';
  static const String TIME_SLOTS = '/panel/academic/foundations/time-slots';
  static const String NOTES = '/panel/academic/notes';
  
  // Employee Management
  static const String EMPLOYEES = '/panel/employee/employees';
  static const String CONTRACTS = '/panel/employee/contracts';
  static const String EMPLOYEE_DOCUMENTS = '/panel/employee/employee_documents';
  static const String EMPLOYEE_ATTENDANCE = '/panel/employee/attendances';
  
  // Calendar
  static const String CALENDAR = '/panel/teqvim/teqvims';
  
  // Finance
  static const String STUDENT_INVOICES = '/panel/academic/finance/student-invoices';
  static const String PAYROLL = '/panel/academic/finance/payroll';
  static const String SALARY_LIST = '/panel/academic/finance/payroll/salary-list';
  static const String TAX_RULES = '/panel/academic/finance/tax_rules';
  static const String GENERAL_LEDGER = '/panel/academic/finance/general-ledger';
  
  // Finance Dictionary
  static const String EXTERNAL_ENTITIES = '/panel/academic/finance/dictionary/external-entities';
  static const String NOTE_TEMPLATES = '/panel/academic/finance/dictionary/note-templates';
  static const String TRANSPORT_RATES = '/panel/academic/finance/dictionary/transport-rates';
  static const String FINANCE_CATEGORIES = '/panel/academic/finance/dictionary/categories';
  
  // Warehouse
  static const String INVENTORIZATIONS = '/panel/warehouse_actions/inventorizations';
  static const String CANTEEN = '/panel/warehouse_actions/canteen';
  
  // Exams
  static const String EXAM_CATEGORIES = '/panel/exams/exam_categories';
  static const String EXAMS = '/panel/exams/exams';
  static const String EXAM_RESULTS = '/panel/exams/results';
  static const String STUDENT_APPLICATIONS = '/panel/exams/student_first_time_applications';
  
  // Support Tickets
  static const String TICKETS = '/panel/tickets';
  static const String TICKET_CATEGORIES = '/panel/tickets/categories';
  
  // Library
  static const String LIBRARY_CATEGORIES = '/panel/academic/library/categories';
  static const String BOOKS = '/panel/academic/library/books';
  static const String BOOK_LOANS = '/panel/academic/library/loans';
  static const String BOOK_RESERVATIONS = '/panel/academic/library/book-reservations';
  
  // Statistics
  static const String QUALITY_CONTROL = '/panel/statistics/quality-control';
  static const String ATTENDANCE_STATS = '/panel/statistics/attendance';
  static const String PERFORMANCE_STATS = '/panel/academic/teachers/statistics/performance';
  static const String ASSIGNMENT_STATS = '/panel/academic/teachers/statistics/assignments';
  static const String ADMISSION_STATS = '/panel/academic/teachers/statistics/admissions';
  static const String LEAVER_STATS = '/panel/academic/teachers/statistics/leavers';
  static const String MONTHLY_STATS = '/panel/statistics/monthly';
  static const String WAREHOUSE_STATS = '/panel/academic/teachers/statistics/warehouse';
  static const String WORKLOAD_REPORT = '/panel/academic/teachers/teachers/workload-report-v2';
  
  // Structure
  static const String COMPANIES = '/panel/structure/companies';
  static const String FILIALS = '/panel/structure/filials';
  static const String WAREHOUSES = '/panel/structure/warehouses';
  static const String STRUCTURES = '/panel/structure/structures';
  static const String DOCUMENT_TYPES = '/panel/structure/document_types';
  static const String DOCUMENT_TEMPLATES = '/panel/structure/document_templates';

  // ========================================
  // 🔐 HEADERS
  // ========================================
  
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Requested-With': 'XMLHttpRequest',
  };
  
  /// Session cookie header ekle (gerçek API kullanırken)
  static Map<String, String> getAuthHeaders(String? sessionToken) {
    final headers = Map<String, String>.from(defaultHeaders);
    if (sessionToken != null && sessionToken.isNotEmpty) {
      headers['Cookie'] = sessionToken;
    }
    return headers;
  }
}
