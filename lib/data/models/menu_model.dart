class MenuItem {
  final String name;
  final String category; // "Əsas Yemək", "Şorba", "Salat", "Şirniyyat / İçki"
  final int calories;
  final String weightGram;
  final List<String> allergens; // "Qlüten", "Süd", "Yumurta"
  final String imageUrl;

  MenuItem({
    required this.name,
    required this.category,
    required this.calories,
    required this.weightGram,
    required this.allergens,
    required this.imageUrl,
  });
}

class DailyMenu {
  final String dayName; // "Bazar ertəsi"
  final DateTime date;
  final String mealTime; // "Nahar (12:30 - 13:30)"
  final List<MenuItem> items;
  final int totalCalories;

  DailyMenu({
    required this.dayName,
    required this.date,
    required this.mealTime,
    required this.items,
    required this.totalCalories,
  });
}
