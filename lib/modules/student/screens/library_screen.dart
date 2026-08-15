import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/library_model.dart';

class LibraryScreen extends StatefulWidget {
  final bool isTeacherView;

  const LibraryScreen({super.key, this.isTeacherView = false});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _selectedCategory = 'Hamısı';
  final TextEditingController _searchCtrl = TextEditingController();

  final List<String> _categories = ['Hamısı', 'Dərslik', 'IB Resurs', 'Bədii', 'Elmi', 'Xarici Dil'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allBooks = appState.books;

    final filtered = allBooks.where((book) {
      final matchesCategory = _selectedCategory == 'Hamısı' || book.category == _selectedCategory;
      final matchesSearch = book.title.toLowerCase().contains(_searchCtrl.text.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchCtrl.text.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    final currentUser = appState.currentUser;
    final canAddBook = currentUser?.role == UserRole.teacher || currentUser?.role == UserRole.admin;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isTeacherView ? 'Müəllim Resurs & E-Kitabxana' : 'İdrak E-Kitabxana'),
        actions: canAddBook
            ? [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  tooltip: 'Yeni Kitab Əlavə Et',
                  onPressed: () => _showAddBookDialog(context, appState),
                ),
              ]
            : null,
      ),
      floatingActionButton: canAddBook
          ? FloatingActionButton.extended(
              onPressed: () => _showAddBookDialog(context, appState),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.bookmark_add_rounded, color: Colors.white),
              label: const Text('Yeni Kitab Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Kitab adı, müəllif və ya ISBN axtar...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Books Catalog Grid / List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.menu_book_rounded, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('Bu kateqoriyada kitab tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 12, bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final book = filtered[index];
                      return _buildBookCard(context, appState, book);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, AppState appState, BookItem book) {
    final dateFormat = DateFormat('dd.MM.yyyy');

    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover with safe fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 75,
              height: 110,
              color: AppColors.primary.withAlpha(20),
              child: Image.network(
                book.coverUrl,
                width: 75,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 75,
                    height: 110,
                    color: AppColors.primary.withAlpha(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 28),
                        SizedBox(height: 4),
                        Text('İDRAK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: book.category,
                      color: AppColors.primaryAccent,
                      fontSize: 10,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.gold, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Text(
                  '${book.pageCount} səhifə • Dil: ${book.language}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),

                // Borrow / Read Actions
                Row(
                  children: [
                    if (book.type == BookType.ebook || book.type == BookType.both)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          ),
                          onPressed: () {
                            _showEBookReader(context, book);
                          },
                          icon: const Icon(Icons.menu_book_rounded, size: 16),
                          label: const Text('E-Oxu (PDF)', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: book.isBorrowedByMe ? Colors.teal : AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        ),
                        onPressed: () {
                          appState.toggleBorrowBook(book.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                book.isBorrowedByMe
                                    ? '"${book.title}" kitabxanaya qaytarıldı.'
                                    : '"${book.title}" 14 günlük icarəyə götürüldü!',
                              ),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: Icon(book.isBorrowedByMe ? Icons.check_circle_outline : Icons.bookmark_add_rounded, size: 16),
                        label: Text(
                          book.isBorrowedByMe ? 'İcarədədir' : 'İcarəyə Götür',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),

                if (book.isBorrowedByMe && book.returnDeadline != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Qaytarma tarixi: ${dateFormat.format(book.returnDeadline!)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddBookDialog(BuildContext context, AppState appState) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final pageCtrl = TextEditingController(text: '200');
    final descCtrl = TextEditingController();
    String category = 'Dərslik';
    String language = 'Azərbaycan';
    BookType bookType = BookType.both;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Kitabxanaya Yeni Kitab Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Kitabın Adı *')),
                    const SizedBox(height: 10),
                    TextField(controller: authorCtrl, decoration: const InputDecoration(labelText: 'Müəllif *')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Kateqoriya'),
                      items: _categories.where((c) => c != 'Hamısı').map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: language,
                            decoration: const InputDecoration(labelText: 'Dil'),
                            items: ['Azərbaycan', 'İngilis', 'Rus', 'Alman', 'Fransız'].map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                            onChanged: (v) => setDialogState(() => language = v!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(controller: pageCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Səhifə')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<BookType>(
                      initialValue: bookType,
                      decoration: const InputDecoration(labelText: 'Format'),
                      items: const [
                        DropdownMenuItem(value: BookType.both, child: Text('Həm E-Kitab, Həm Fiziki')),
                        DropdownMenuItem(value: BookType.ebook, child: Text('Yalnız E-Kitab (PDF)')),
                        DropdownMenuItem(value: BookType.physical, child: Text('Yalnız Fiziki Nüsxə')),
                      ],
                      onChanged: (v) => setDialogState(() => bookType = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Qısa Məzmun')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  onPressed: () {
                    if (titleCtrl.text.isNotEmpty && authorCtrl.text.isNotEmpty) {
                      final newBook = BookItem(
                        id: 'bk-${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        author: authorCtrl.text.trim(),
                        category: category,
                        coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
                        type: bookType,
                        pageCount: int.tryParse(pageCtrl.text) ?? 200,
                        language: language,
                        availableCopies: 10,
                        description: descCtrl.text.trim().isEmpty ? 'İdrak Liseyi kitabxana fondundan tədris vəsaiti.' : descCtrl.text.trim(),
                      );
                      appState.addBook(newBook);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kitab uğurla kitabxanaya əlavə edildi!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Əlavə Et'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEBookReader(BuildContext context, BookItem book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      book.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF7F0), // Paper-like warm reading color
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'FƏSİL 1: GİRİŞ VƏ ƏSAS ANLAYIŞLAR',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          book.description,
                          style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'İdrak Liseyinin elektron kitabxana fondundan istifadə edirsiniz. Müəllif hüquqları qorunur. Bu vəsait dərslərdə interaktiv tədris materialı kimi istifadə olunur. Qeydlər aparmaq və əlfəcin əlavə etmək üçün yuxarıdakı alətlərdən istifadə edin.',
                          style: TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Səhifə 1 / ${book.pageCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_back_ios_rounded, size: 16)),
                      IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
