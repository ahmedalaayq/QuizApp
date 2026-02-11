class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int requiredCount;
  final String category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredCount,
    required this.category,
  });

  static List<Achievement> getAllAchievements() {
    return [
      Achievement(
        id: 'first_assessment',
        title: 'البداية',
        description: 'أكمل أول اختبار',
        icon: '🎯',
        requiredCount: 1,
        category: 'assessments',
      ),
      Achievement(
        id: 'five_assessments',
        title: 'المثابر',
        description: 'أكمل 5 اختبارات',
        icon: '🏃',
        requiredCount: 5,
        category: 'assessments',
      ),
      Achievement(
        id: 'ten_assessments',
        title: 'الملتزم',
        description: 'أكمل 10 اختبارات',
        icon: '💪',
        requiredCount: 10,
        category: 'assessments',
      ),
      Achievement(
        id: 'twenty_assessments',
        title: 'الخبير',
        description: 'أكمل 20 اختبار',
        icon: '🌟',
        requiredCount: 20,
        category: 'assessments',
      ),
      Achievement(
        id: 'week_streak',
        title: 'أسبوع متواصل',
        description: 'أكمل اختبار كل يوم لمدة أسبوع',
        icon: '🔥',
        requiredCount: 7,
        category: 'streak',
      ),
      Achievement(
        id: 'all_types',
        title: 'المتنوع',
        description: 'جرب جميع أنواع الاختبارات',
        icon: '🎨',
        requiredCount: 2,
        category: 'variety',
      ),
      Achievement(
        id: 'improvement',
        title: 'التحسن',
        description: 'حقق تحسن في النتائج',
        icon: '📈',
        requiredCount: 1,
        category: 'progress',
      ),
      Achievement(
        id: 'share_result',
        title: 'المشارك',
        description: 'شارك نتيجة اختبار',
        icon: '📤',
        requiredCount: 1,
        category: 'social',
      ),
    ];
  }
}
