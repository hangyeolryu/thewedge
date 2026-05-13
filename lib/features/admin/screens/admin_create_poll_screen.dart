import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../polls/models/poll_model.dart';
import '../../polls/providers/polls_provider.dart';

class AdminCreatePollScreen extends ConsumerStatefulWidget {
  final String? pollId; // null = create, non-null = edit
  const AdminCreatePollScreen({super.key, this.pollId});

  @override
  ConsumerState<AdminCreatePollScreen> createState() =>
      _AdminCreatePollScreenState();
}

class _AdminCreatePollScreenState
    extends ConsumerState<AdminCreatePollScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  PollAnswerType _answerType = PollAnswerType.radio;
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  File? _imageFile;
  String? _existingImageUrl;
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.pollId != null) _loadExistingPoll();
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _answerControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExistingPoll() async {
    // Poll loaded via provider — handled in build via ref.watch
  }

  void _populateFromPoll(Poll poll) {
    if (_loaded) return;
    _loaded = true;
    _questionController.text = poll.question;
    _answerType = poll.answerType;
    _deadline = poll.deadline;
    _existingImageUrl = poll.imageUrl;
    _answerControllers.clear();
    for (final a in poll.answers) {
      _answerControllers.add(TextEditingController(text: a.text));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline),
    );
    if (time == null) return;
    setState(() {
      _deadline = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _addAnswer() {
    setState(() => _answerControllers.add(TextEditingController()));
  }

  void _removeAnswer(int index) {
    if (_answerControllers.length <= 2) return;
    setState(() {
      _answerControllers[index].dispose();
      _answerControllers.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final answerTexts = _answerControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (answerTexts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택지를 최소 2개 입력해주세요.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final service = ref.read(pollServiceProvider);
      String? imageUrl = _existingImageUrl;
      if (_imageFile != null) {
        imageUrl = await service.uploadPollImage(_imageFile!);
      }

      if (widget.pollId == null) {
        await service.createPoll(
          question: _questionController.text.trim(),
          answerTexts: answerTexts,
          answerType: _answerType,
          deadline: _deadline,
          imageUrl: imageUrl,
        );
      } else {
        await service.updatePoll(
          pollId: widget.pollId!,
          question: _questionController.text.trim(),
          answerTexts: answerTexts,
          answerType: _answerType,
          deadline: _deadline,
          imageUrl: imageUrl,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(widget.pollId == null ? '투표가 생성되었습니다.' : '투표가 수정되었습니다.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If editing, load existing poll
    if (widget.pollId != null) {
      ref.watch(pollByIdProvider(widget.pollId!)).whenData(
            (poll) {
              if (poll != null) _populateFromPoll(poll);
            },
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pollId == null ? '투표 만들기' : '투표 수정'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker
              const _SectionLabel('대표 이미지 (선택)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.border, style: BorderStyle.solid),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!), fit: BoxFit.cover)
                        : _existingImageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_existingImageUrl!),
                                fit: BoxFit.cover)
                            : null,
                  ),
                  child: _imageFile == null && _existingImageUrl == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: AppColors.textTertiary),
                            SizedBox(height: 8),
                            Text('이미지 선택',
                                style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        )
                      : Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _imageFile = null;
                                _existingImageUrl = null;
                              }),
                              child: Container(
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              // Question
              const _SectionLabel('질문 *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: '국민에게 물어볼 질문을 입력하세요.',
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '질문을 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              // Answer type
              const _SectionLabel('선택 방식'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _TypeToggle(
                    label: '단일 선택 (라디오)',
                    selected: _answerType == PollAnswerType.radio,
                    onTap: () =>
                        setState(() => _answerType = PollAnswerType.radio),
                  ),
                  const SizedBox(width: 10),
                  _TypeToggle(
                    label: '복수 선택 (체크박스)',
                    selected: _answerType == PollAnswerType.checkbox,
                    onTap: () =>
                        setState(() => _answerType = PollAnswerType.checkbox),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Answers
              Row(
                children: [
                  const _SectionLabel('선택지 *'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addAnswer,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('추가'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_answerControllers.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _answerControllers[index],
                          decoration: InputDecoration(
                            hintText: '선택지 ${index + 1}',
                            prefixIcon: Icon(
                              _answerType == PollAnswerType.radio
                                  ? Icons.radio_button_unchecked
                                  : Icons.check_box_outline_blank,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          validator: (v) => index < 2 && (v == null || v.trim().isEmpty)
                              ? '선택지를 입력해주세요.'
                              : null,
                        ),
                      ),
                      if (_answerControllers.length > 2) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _removeAnswer(index),
                          icon: const Icon(Icons.remove_circle_outline,
                              color: AppColors.error),
                        ),
                      ],
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
              // Deadline
              const _SectionLabel('마감 일시 *'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDeadline,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('yyyy년 MM월 dd일 HH:mm').format(_deadline),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right,
                          color: AppColors.textTertiary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          widget.pollId == null ? '투표 생성하기' : '투표 수정하기',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.accent.withOpacity(0.08)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
              color: selected ? AppColors.accent : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
