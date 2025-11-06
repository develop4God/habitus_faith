// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '信仰习惯';

  @override
  String get start => '开始';

  @override
  String get readBible => '阅读圣经';

  @override
  String get myHabits => '我的习惯';

  @override
  String get noHabits => '还没有习惯';

  @override
  String get streak => '连续';

  @override
  String get days => '天';

  @override
  String get best => '最佳';

  @override
  String get addHabit => '添加习惯';

  @override
  String get deleteHabit => '删除习惯';

  @override
  String deleteHabitConfirm(String habitName) {
    return '确定要删除\"$habitName\"吗？';
  }

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get name => '名称';

  @override
  String get description => '描述';

  @override
  String get add => '添加';

  @override
  String get welcomeToHabitusFaith => '欢迎来到信仰习惯';

  @override
  String get selectUpToThreeHabits => '选择最多3个习惯开始您的旅程';

  @override
  String get continueButton => '继续';

  @override
  String get selectAtLeastOne => '请至少选择一个习惯';

  @override
  String get maxThreeHabits => '您最多可以选择3个习惯';

  @override
  String get spiritual => '灵性';

  @override
  String get physical => '身体';

  @override
  String get mental => '心理';

  @override
  String get relational => '关系';

  @override
  String get habitCompleted => '习惯完成！🎉';

  @override
  String get tapToComplete => '点击完成';

  @override
  String get completed => '已完成';

  @override
  String get currentStreak => '当前连续';

  @override
  String get longestStreak => '最长连续';

  @override
  String get thisWeek => '本周';

  @override
  String get predefinedHabit_morningPrayer_name => '晨祷';

  @override
  String get predefinedHabit_morningPrayer_description => '以祷告和感恩开始您的一天';

  @override
  String get predefinedHabit_bibleReading_name => '读经';

  @override
  String get predefinedHabit_bibleReading_description => '每天阅读和默想神的话语';

  @override
  String get predefinedHabit_worship_name => '敬拜';

  @override
  String get predefinedHabit_worship_description => '花时间敬拜和赞美';

  @override
  String get predefinedHabit_gratitude_name => '感恩日记';

  @override
  String get predefinedHabit_gratitude_description => '写下您感恩的事情';

  @override
  String get predefinedHabit_exercise_name => '锻炼';

  @override
  String get predefinedHabit_exercise_description => '照顾您的身体，神的殿';

  @override
  String get predefinedHabit_healthyEating_name => '健康饮食';

  @override
  String get predefinedHabit_healthyEating_description => '用健康食物滋养您的身体';

  @override
  String get predefinedHabit_sleep_name => '优质睡眠';

  @override
  String get predefinedHabit_sleep_description => '好好休息以恢复精力';

  @override
  String get predefinedHabit_meditation_name => '冥想';

  @override
  String get predefinedHabit_meditation_description => '练习正念和反思';

  @override
  String get predefinedHabit_learning_name => '学习';

  @override
  String get predefinedHabit_learning_description => '在知识和智慧中成长';

  @override
  String get predefinedHabit_creativity_name => '创意时间';

  @override
  String get predefinedHabit_creativity_description => '通过创意活动表达自己';

  @override
  String get predefinedHabit_familyTime_name => '家庭时光';

  @override
  String get predefinedHabit_familyTime_description => '与亲人共度美好时光';

  @override
  String get predefinedHabit_service_name => '服务行动';

  @override
  String get predefinedHabit_service_description => '以爱和同情服务他人';

  @override
  String get onboardingErrorMessage =>
      'Failed to save habits. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get selected => 'Selected';

  @override
  String get category => '类别';

  @override
  String get difficulty => '难度';

  @override
  String get emoji => '表情符号';

  @override
  String get color => '颜色';

  @override
  String get optional => '可选';

  @override
  String get edit => '编辑';

  @override
  String get uncheck => '取消勾选';

  @override
  String get save => '保存';

  @override
  String get editHabit => '编辑习惯';

  @override
  String get defaultColor => '默认';

  @override
  String get statistics => '统计';

  @override
  String get settings => '设置';

  @override
  String get language => '语言';

  @override
  String get notifications => '通知';

  @override
  String get notificationSettings => '通知设置';

  @override
  String get languageSettings => '语言设置';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageInfo => '应用程序将使用所选语言显示所有文本和界面元素。';

  @override
  String get notificationsEnabled => '通知已启用';

  @override
  String get notificationsDisabled => '通知已禁用';

  @override
  String get notificationTimeUpdated => '通知时间已更新为';

  @override
  String get enableNotifications => '启用通知';

  @override
  String get notificationsOn => '通知已开启';

  @override
  String get notificationsOff => '通知已关闭';

  @override
  String get receiveReminderNotifications => '接收每日提醒通知';

  @override
  String get notificationTime => '通知时间';

  @override
  String get selectNotificationTime => '选择通知时间';

  @override
  String get currentTime => '当前时间';

  @override
  String get notificationInfo => '您将在所选时间收到每日提醒以完成您的习惯。';

  @override
  String get highRiskWarning => '今天有高风险放弃这个习惯！';

  @override
  String riskPercentage(int percent) {
    return '$percent% 放弃的概率';
  }

  @override
  String get completeNow => '立即完成';

  @override
  String abandonmentNudgeTitle(String habitName) {
    return '减少习惯\"$habitName\"?';
  }

  @override
  String abandonmentNudgeBody(int minutes) {
    return '减少到$minutes分钟？我们注意到您可能会放弃这个习惯';
  }

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get versesSaved => '经文已保存';

  @override
  String get loadingBooks => '正在加载书卷...';

  @override
  String get selectBook => '选择书卷';

  @override
  String get selectBookAndChapter => '选择书卷和章节';

  @override
  String get habitsCompleted => '已完成的习惯：';

  @override
  String habitsCompletedCount(int completed, int total) {
    return '$completed / $total';
  }

  @override
  String error(String message) {
    return '错误: $message';
  }

  @override
  String get generateMicroHabits => '生成微习惯';

  @override
  String get aiGeneratedHabits => 'AI生成的习惯';

  @override
  String get yourGoal => '你的目标';

  @override
  String get goalHint => '你想改进什么？（例如：更持续地祷告）';

  @override
  String get goalRequired => '请输入你的目标';

  @override
  String get goalTooShort => '目标至少需要10个字符';

  @override
  String get goalTooLong => '目标不能超过200个字符';

  @override
  String get failurePattern => '你通常什么时候失败？（可选）';

  @override
  String get failurePatternHint => '例如：在忙碌的早晨我会忘记';

  @override
  String get generateHabits => '生成习惯';

  @override
  String get generating => '生成中...';

  @override
  String get generatingHabits => '正在为你生成个性化微习惯...';

  @override
  String get generatedHabitsTitle => '你的个性化微习惯';

  @override
  String get selectHabitsToAdd => '选择要添加到跟踪的习惯：';

  @override
  String get saveSelected => '保存选中的';

  @override
  String get saving => '保存中...';

  @override
  String habitsAdded(int count) {
    return '成功添加了$count个习惯！';
  }

  @override
  String estimatedTime(int minutes) {
    return '约$minutes分钟';
  }

  @override
  String get bibleVerse => '圣经经文';

  @override
  String get purpose => '目的';

  @override
  String remaining(int count) {
    return '剩余$count次';
  }

  @override
  String monthlyLimit(int limit) {
    return '每月限制：$limit次生成';
  }

  @override
  String get rateLimitReached => '已达到每月限制。请下个月再试。';

  @override
  String get generationFailed => '生成习惯失败。请重试。';

  @override
  String get apiTimeout => '请求超时。请检查你的连接并重试。';

  @override
  String get invalidInput => '输入无效。请检查你的目标并重试。';

  @override
  String get noHabitsSelected => '请至少选择一个习惯来保存';

  @override
  String get tryAgain => '重试';

  @override
  String generationsRemaining(int count) {
    return '本月剩余$count次生成';
  }

  @override
  String get poweredByGemini => '由Gemini AI驱动';

  @override
  String get chooseYourExperience => '选择您的体验';

  @override
  String get displayModeDescription => '选择您想如何使用 Habitus Faith';

  @override
  String get compactMode => '紧凑模式';

  @override
  String get compactModeDescription => '每日习惯跟踪的基本功能';

  @override
  String get compactModeFeature1 => '简洁的极简界面';

  @override
  String get compactModeFeature2 => '快速习惯跟踪';

  @override
  String get compactModeFeature3 => '基础统计';

  @override
  String get advancedMode => '高级模式';

  @override
  String get advancedModeDescription => '具有见解和分析的完整体验';

  @override
  String get advancedModeFeature1 => '详细的习惯分析';

  @override
  String get advancedModeFeature2 => 'AI驱动的见解';

  @override
  String get advancedModeFeature3 => '高级自定义';

  @override
  String get changeAnytime => '您可以随时在偏好设置中更改此设置';

  @override
  String get selectMode => '选择模式';

  @override
  String get displayMode => '显示模式';

  @override
  String displayModeUpdated(String mode) {
    return '显示模式已更新为 $mode';
  }

  @override
  String get compactModeSubtitle => '紧凑列表 - 点击查看详情';

  @override
  String get advancedModeSubtitle => '完整跟踪可见';

  @override
  String get addManually => '手动添加';

  @override
  String get createCustomHabit => '创建一个自定义习惯';

  @override
  String get generateWithAI => '使用AI生成';

  @override
  String get aiCustomHabits => '使用AI的自定义习惯';

  @override
  String get previewHabitName => '习惯名称';

  @override
  String get previewHabitDescription => '习惯描述';

  @override
  String get total => '总计';
}
