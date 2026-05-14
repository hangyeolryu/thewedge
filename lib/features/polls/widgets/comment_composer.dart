import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/comments_provider.dart';

class CommentComposer extends ConsumerStatefulWidget {
  final String pollId;
  final String? answerChangeFromId;
  final String? answerChangeToId;
  final String? hintText;

  const CommentComposer({
    super.key,
    required this.pollId,
    this.answerChangeFromId,
    this.answerChangeToId,
    this.hintText,
  });

  @override
  ConsumerState<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<CommentComposer> {
  final _controller = TextEditingController();
  bool _submitting = false;
  double? _toxicityWarning;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() { _submitting = true; _toxicityWarning = null; });

    try {
      final svc = ref.read(commentServiceProvider);

      // Pre-moderate
      final pre = await svc.preModerate(text);
      if (pre.status == 'blocked') {
        setState(() {
          _submitting = false;
          _toxicityWarning = pre.maxScore;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('댓글이 커뮤니티 가이드라인을 위반합니다. 표현을 다듬어 주세요.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }
      if (pre.status == 'blurred') {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('댓글 검토'),
            content: const Text(
              '이 댓글은 다른 사용자에게 불쾌감을 줄 수 있는 표현이 포함되어 있습니다. '
              '게시되면 경고 표시와 함께 가려진 채로 보입니다.\n\n그래도 게시하시겠습니까?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('수정하기'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('게시',
                    style: TextStyle(color: AppColors.warning)),
              ),
            ],
          ),
        );
        if (confirm != true) {
          setState(() => _submitting = false);
          return;
        }
      }

      await svc.postComment(
        pollId: widget.pollId,
        text: text,
        answerChangeFromId: widget.answerChangeFromId,
        answerChangeToId: widget.answerChangeToId,
      );
      _controller.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 4,
                minLines: 1,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '의견을 남겨주세요...',
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
                onChanged: (_) {
                  if (_toxicityWarning != null) {
                    setState(() => _toxicityWarning = null);
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _submitting ? null : _submit,
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
