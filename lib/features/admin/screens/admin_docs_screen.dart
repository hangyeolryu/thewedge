import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../widgets/admin_scaffold.dart';

class AdminDocsScreen extends ConsumerWidget {
  const AdminDocsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdminScaffold(
      title: '관리자 가이드',
      activeRoute: '/admin/docs',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('관리자 가이드', style: AppTextStyles.h1),
                const SizedBox(height: 8),
                Text(
                  '더 왜지? 운영에 필요한 모든 것을 정리해 두었어요.',
                  style: AppTextStyles.bodySm,
                ),
                const SizedBox(height: 40),

                _DocSection(
                  emoji: '🚀',
                  title: '시작하기',
                  items: [
                    _DocItem(
                      title: '관리자 계정 추가',
                      body:
                          'Firebase Console → Remote Config → admin_emails (JSON)에 본인 이메일을 추가하세요. '
                          '예: ["you@effeffcorp.com", "ops@effeffcorp.com"]\n\n'
                          '저장 후 "변경 사항 게시" 버튼을 눌러야 적용됩니다. 변경 후 최대 5분 내 반영.',
                    ),
                    _DocItem(
                      title: '로그인',
                      body:
                          '/admin/signin 페이지에서 Google 계정으로 로그인하세요. '
                          '허용 목록에 등록된 이메일만 통과합니다.',
                    ),
                  ],
                ),

                _DocSection(
                  emoji: '📝',
                  title: '투표 만들기',
                  items: [
                    _DocItem(
                      title: '좋은 질문 작성법',
                      body:
                          '• 양극단의 의견이 나뉠 만한 가치관 질문이 좋아요.\n'
                          '• 너무 정치색이 강한 질문은 피하세요. 사회·라이프스타일 위주로.\n'
                          '• 최대 200자, 짧고 명확하게.\n'
                          '• 예: "결혼은 꼭 해야 한다고 생각하시나요?"',
                    ),
                    _DocItem(
                      title: '카테고리 선택',
                      body:
                          '7가지 중 가장 가까운 하나를 선택하세요: '
                          '💡 가치관, ❤️ 관계, 💼 직장·커리어, 🌐 사회·이슈, '
                          '🎨 문화·취미, 💰 경제, 📌 기타.',
                    ),
                    _DocItem(
                      title: '선택지 (2~6개 권장)',
                      body:
                          '• 단일 선택(라디오) / 복수 선택(체크박스) 중 선택\n'
                          '• 선택지가 너무 많으면 분포가 흐려져요. 2~6개 권장.\n'
                          '• 중립 선택지("잘 모르겠다") 추가 권장.',
                    ),
                    _DocItem(
                      title: '마감 시간',
                      body:
                          '보통 3~7일이 적절합니다. 너무 짧으면 참여가 부족하고, '
                          '너무 길면 의견 변화 데이터가 분산됩니다. '
                          '마감 후에도 의견 변경은 계속 추적됩니다.',
                    ),
                    _DocItem(
                      title: '대표 이미지',
                      body:
                          '가로 16:9, 최소 1200px 권장. 5MB 이하의 JPG/PNG만 업로드 가능.',
                    ),
                  ],
                ),

                _DocSection(
                  emoji: '🛡',
                  title: '댓글 검토',
                  items: [
                    _DocItem(
                      title: '자동 필터링 작동 원리',
                      body:
                          'Google Perspective API가 모든 댓글을 0~1 점수로 평가합니다.\n'
                          '• 0.60 이상 → 자동 흐림(blurred), 사용자가 탭해야 보임\n'
                          '• 0.85 이상 → 자동 차단(blocked), 노출 안 됨\n\n'
                          '3명 이상 신고 시 자동으로 흐림 처리됩니다.',
                    ),
                    _DocItem(
                      title: '검토 큐 활용법',
                      body:
                          '/admin/moderation 페이지에서 자동 가려진 댓글을 검토하세요.\n'
                          '• 복원: 오탐(false positive)인 경우 다시 노출\n'
                          '• 차단: 명백한 악성 댓글은 영구 차단\n'
                          '• 삭제: 완전 삭제 (복구 불가)',
                    ),
                  ],
                ),

                _DocSection(
                  emoji: '⏰',
                  title: '마감 & 결과',
                  items: [
                    _DocItem(
                      title: '자동 스냅샷',
                      body:
                          'Cloud Function이 5분마다 실행되어 마감된 투표의 결과를 자동 박제합니다. '
                          '박제된 결과는 다시 바뀌지 않아요.',
                    ),
                    _DocItem(
                      title: '수동 스냅샷',
                      body:
                          '대시보드의 ⋮ 메뉴 → "지금 마감 결과 박제" 버튼으로 즉시 박제 가능. '
                          '한 번 박제하면 되돌릴 수 없습니다.',
                    ),
                    _DocItem(
                      title: '의견 변경 그래프',
                      body:
                          '마감 후 의견 변경이 1건 이상 발생하면 결과 화면 하단에 '
                          '시간대별 답변 분포 변화 그래프가 자동으로 표시됩니다.',
                    ),
                  ],
                ),

                _DocSection(
                  emoji: '🎥',
                  title: '유튜브 라이브 연동',
                  items: [
                    _DocItem(
                      title: '딥링크 만들기',
                      body:
                          '라이브 방송 중 시청자가 바로 투표하도록 아래 형식의 링크를 공유하세요:\n\n'
                          '  thewedge://poll/<pollId>\n'
                          '  https://thewedge.app/polls/<pollId>\n\n'
                          'pollId는 투표 수정 화면 URL에서 확인할 수 있어요.',
                    ),
                    _DocItem(
                      title: '라이브 알림 전송',
                      body:
                          '특정 투표를 구독한 사용자에게 알림을 보내려면 '
                          'Cloud Functions의 FCM 토픽 "poll_<pollId>"로 메시지를 발행하세요.',
                    ),
                  ],
                ),

                _DocSection(
                  emoji: '📊',
                  title: '통계 & 분석',
                  items: [
                    _DocItem(
                      title: '플랫폼 통계',
                      body:
                          '/admin/stats에서 전체 가입자, 투표 수, 참여 수, 댓글 건강도를 확인할 수 있어요. '
                          '실시간으로 새로고침해서 변동을 추적하세요.',
                    ),
                    _DocItem(
                      title: '사용자 페르소나',
                      body:
                          '각 사용자는 투표 패턴에 따라 7가지 성향 중 하나로 분류됩니다: '
                          '🌱 새싹, 💚 열린마음, 🔥 열정파, ❄️ 냉정파, 👁 관찰자, ⚖️ 균형파, 💪 소신파.',
                    ),
                  ],
                ),

                const SizedBox(height: 60),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassSurface(tint: AppColors.accent),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent,
                          color: AppColors.accentLight),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '추가 문의는 contact@effeffcorp.com 로 보내주세요.',
                          style: AppTextStyles.body,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/admin'),
                        child: const Text('대시보드로'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DocSection extends StatelessWidget {
  final String emoji;
  final String title;
  final List<_DocItem> items;

  const _DocSection({
    required this.emoji,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: glassSurface(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(i.title, style: AppTextStyles.h3),
                      const SizedBox(height: 10),
                      Text(i.body, style: AppTextStyles.body),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _DocItem {
  final String title;
  final String body;
  const _DocItem({required this.title, required this.body});
}
