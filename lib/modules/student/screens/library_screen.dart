import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
        elevation: 0,
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
              backgroundColor: AppColors.primaryAccent,
              icon: const Icon(Icons.bookmark_add_outlined, color: Colors.white),
              label: const Text('Yeni Kitab Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Kitab adı, müəllif və ya ISBN axtar...',
                    hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: InkWell(
                          onTap: () => setState(() => _selectedCategory = cat),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryAccent : AppColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 11.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Books Catalog List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, size: 56, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('Bu kateqoriyada kitab tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    physics: const BouncingScrollPhysics(),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 75,
              height: 105,
              color: AppColors.primaryAccent.withAlpha(20),
              child: Image.network(
                book.coverUrl,
                width: 75,
                height: 105,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 75,
                    height: 105,
                    color: AppColors.primaryAccent.withAlpha(20),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book_outlined, color: AppColors.primaryAccent, size: 24),
                        SizedBox(height: 4),
                        Text('İDRAK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.primaryAccent)),
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
                      fontSize: 9.5,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.goldDark, size: 16),
                        const SizedBox(width: 2),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  book.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  book.author,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.pageCount} səhifə • Dil: ${book.language}',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),

                // Borrow / Read Actions
                Row(
                  children: [
                    if (book.type == BookType.ebook || book.type == BookType.both)
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            _showEBookReader(context, book);
                          },
                          icon: const Icon(Icons.menu_book_outlined, size: 14),
                          label: const Text('E-Oxu', style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: book.isBorrowedByMe ? AppColors.success : AppColors.primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                        icon: Icon(book.isBorrowedByMe ? Icons.check_circle_outline : Icons.bookmark_add_outlined, size: 14, color: Colors.white),
                        label: Text(
                          book.isBorrowedByMe ? 'İcarədədir' : 'İcarəyə Götür',
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),

                if (book.isBorrowedByMe && book.returnDeadline != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Qaytarma tarixi: ${dateFormat.format(book.returnDeadline!)}',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.warning, fontWeight: FontWeight.bold),
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
                      items: _categories
                          .where((c) => c != 'Hamısı')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Səhifə Sayı'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Qısa Təsvir / Xülasə'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ləğv Et'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (titleCtrl.text.trim().isEmpty || authorCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Zəhmət olmasa kitab adı və müəllifi daxil edin!')),
                      );
                      return;
                    }
                    final newBook = BookItem(
                      id: 'bk_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      author: authorCtrl.text.trim(),
                      category: category,
                      description: descCtrl.text.trim().isNotEmpty
                          ? descCtrl.text.trim()
                          : 'İdrak Liseyi rəsmi tədris vəsaiti.',
                      coverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400',
                      type: bookType,
                      pageCount: int.tryParse(pageCtrl.text.trim()) ?? 150,
                      rating: 4.8,
                      language: language,
                      availableCopies: 5,
                    );
                    appState.addBook(newBook);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('"${newBook.title}" kitabxanaya əlavə edildi!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: const Text('Əlavə Et', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(book.author, style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.picture_as_pdf_outlined, size: 56, color: Colors.red.shade400),
                      const SizedBox(height: 14),
                      Text(
                        'Rəqəmsal Dərslik / PDF Önizləmə',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${book.pageCount} səhifəlik rəsmi PDF nüsxəsi daxili oxucuya yüklənir...',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('E-Kitab offline oxumaq üçün keşləndi.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                        icon: const Icon(Icons.download_outlined, color: Colors.white, size: 16),
                        label: const Text('Offline Saxla və Oxu', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
