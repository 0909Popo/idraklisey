import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/assignment_model.dart';
import '../../../services/cloudinary_service.dart';

class HomeworkSubmissionScreen extends StatefulWidget {
  final HomeworkAssignment assignment;

  const HomeworkSubmissionScreen({super.key, required this.assignment});

  @override
  State<HomeworkSubmissionScreen> createState() => _HomeworkSubmissionScreenState();
}

class _HomeworkSubmissionScreenState extends State<HomeworkSubmissionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final List<String> _capturedPages = [];
  bool _isSubmitting = false;
  bool _isCapturing = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _captureFromCamera() async {
    setState(() => _isCapturing = true);
    final url = await CloudinaryService.pickAndUploadFromCamera(
      folder: 'idrak/homework',
      imageQuality: 80,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (mounted) {
      setState(() => _isCapturing = false);
      if (url != null) {
        setState(() => _capturedPages.add(url));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_capturedPages.length}-ci dəftər səhifəsi yükləndi!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isCapturing = true);
    final urls = await CloudinaryService.pickMultipleAndUpload(
      folder: 'idrak/homework',
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (mounted) {
      setState(() {
        _isCapturing = false;
        _capturedPages.addAll(urls);
      });
      if (urls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${urls.length} səhifə qalereyadan yükləndi!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStudent = appState.student;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    // Fetch this specific student's submission
    final mySubmission = widget.assignment.getSubmissionForStudent(currentStudent.id);
    final isAlreadySubmitted = mySubmission != null;
    final isGraded = mySubmission?.score != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tapşırıq & Kamera Təhvili'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Assignment Header Info Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(
                        label: widget.assignment.subject,
                        color: AppColors.goldLight,
                        backgroundColor: Colors.white24,
                      ),
                      Text(
                        'Son Tarix: ${dateFormat.format(widget.assignment.dueDate)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.assignment.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person_rounded, color: AppColors.goldLight, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Müəllim: ${widget.assignment.teacherName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        'Şagird: ${currentStudent.fullName}',
                        style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Teacher Instructions & PDF Doc
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Müəllimin Tapşırıq Təlimatı',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.assignment.instructions,
                    style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
                  ),
                  if (widget.assignment.attachmentDocUrl != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(50)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.assignment.attachmentDocUrl!,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const Text('Dərs vəsaiti & PDF Təlimat', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${widget.assignment.attachmentDocUrl} açıldı.')),
                              );
                            },
                            icon: const Icon(Icons.visibility_rounded, size: 16),
                            label: const Text('Bax'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Submission or Review Area (Personal to this Student)
            if (isAlreadySubmitted) ...[
              CustomCard(
                backgroundColor: const Color(0xFFF0FDF4),
                border: Border.all(color: AppColors.success),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Tapşırığınız Təhvil Verilib!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success),
                            ),
                          ],
                        ),
                        if (isGraded && mySubmission.score != null)
                          StatusBadge(
                            label: '${mySubmission.score!.toInt()} Bal',
                            color: AppColors.primary,
                            fontSize: 12,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Təhvil tarixi: ${dateFormat.format(mySubmission.submittedAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),

                    if (mySubmission.studentNote != null && mySubmission.studentNote!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Sizin qeydiniz: "${mySubmission.studentNote}"',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                      ),
                    ],

                    if (isGraded) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Müəllim Qiymətləndirməsi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${mySubmission.score} / 100 Bal', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 15)),
                              ],
                            ),
                            if (mySubmission.teacherComment != null && mySubmission.teacherComment!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text('Müəllim rəyi: "${mySubmission.teacherComment}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.hourglass_empty_rounded, color: AppColors.warning, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tapşırığınız müəllim tərəfindən yoxlanışdadır. Qiymətləndirilən kimi burada və valideyn panelində görünəcək.',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              // Fast Camera Homework Submission Section
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.camera_alt_rounded, color: AppColors.primaryAccent, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Kamera ilə Sürətli Tapşırıq Təhvili',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Fiziki dəftərinizdə həll etdiyiniz səhifələri kamera ilə çəkin və müəllimə göndərin.',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Scanned Pages Gallery
                    if (_capturedPages.isNotEmpty) ...[
                      SizedBox(
                        height: 110,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _capturedPages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 85,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryAccent, width: 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(_capturedPages[index], fit: BoxFit.cover),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  left: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Səh ${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 14,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _capturedPages.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Camera & Gallery Buttons
                    if (_isCapturing)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppColors.primary),
                              SizedBox(height: 8),
                              Text('Foto yüklənir...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _captureFromCamera,
                              icon: const Icon(Icons.photo_camera_rounded, color: AppColors.primary),
                              label: Text(_capturedPages.isEmpty ? 'Kameranı Aç və Çək' : '+ Növbəti Səhifəni Çək'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library_rounded, color: AppColors.goldDark),
                              label: const Text('Qalereyadan Seç'),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Student Note Input
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Müəllim üçün qeyd (İstəyə bağlı)',
                        hintText: 'Məsələn: 18-ci məsələdə 2 müxtəlif üsul tətbiq etmişəm...',
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _capturedPages.isEmpty || _isSubmitting
                            ? null
                            : () {
                                setState(() => _isSubmitting = true);
                                appState.submitHomework(
                                  assignmentId: widget.assignment.id,
                                  studentId: currentStudent.id,
                                  studentName: currentStudent.fullName,
                                  images: _capturedPages,
                                  note: _noteController.text.trim(),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ev tapşırığınız uğurla təhvil verildi!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.send_rounded),
                        label: const Text('Tapşırığı Müəllimə Təhvil Ver'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
