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
  String get onboardingWelcomeMessage => '我们将根据您的偏好帮助您个性化您的首批习惯。';

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
  String get aiGeneratedHabits => '自动生成的习惯';

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
  String get advancedModeFeature2 => '高级和个性化见解。';

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
  String get generateWithAI => '自动生成';

  @override
  String get aiCustomHabits => '自动个性化习惯';

  @override
  String get previewHabitName => '习惯名称';

  @override
  String get previewHabitDescription => '习惯描述';

  @override
  String get total => '总计';

  @override
  String get mlPredictionFailed => '无法计算放弃风险';

  @override
  String get mlModelNotLoaded => '预测模型不可用。请重启应用。';

  @override
  String mlInsufficientData(int days) {
    return '预测需要至少$days天的数据';
  }

  @override
  String backgroundSyncFailed(String reason) {
    return '同步失败：$reason';
  }

  @override
  String get backgroundSyncNetwork => '没有网络连接。更改将在在线时同步。';

  @override
  String get backgroundSyncPermission => '后台同步已禁用。请在设置中启用。';

  @override
  String get workmanagerActive => '后台同步活动中';

  @override
  String get workmanagerRestricted => '后台同步可能受电池优化限制';

  @override
  String get workmanagerDisabled => '系统设置中已禁用后台同步';

  @override
  String get patternWeekend => '您倾向于跳过周末。尝试设置提醒？';

  @override
  String get patternEvening => '晚上完成率较低。考虑早晨的习惯？';

  @override
  String optimalTimeFound(String time) {
    return '您最佳完成时间是$time';
  }

  @override
  String get networkTimeout => '请求超时。检查您的连接。';

  @override
  String get firebasePermissionDenied => '访问被拒绝。请重新登录。';

  @override
  String get errorUnknown => '发生意外错误。请重试。';

  @override
  String get devBannerTitle => '开发工具';

  @override
  String devBannerLastSync(String time) {
    return '最后同步：$time';
  }

  @override
  String devBannerMlStatus(String status) {
    return '机器学习模型：$status';
  }

  @override
  String devBannerWorkmanager(String status) {
    return '后台：$status';
  }

  @override
  String devBannerFastTime(String multiplier, String date) {
    return '时间：$multiplier倍（模拟：$date）';
  }

  @override
  String get riskLevelLow => '低风险';

  @override
  String get riskLevelMedium => '中风险';

  @override
  String get riskLevelHigh => '高风险';

  @override
  String get predictorRunning => '正在分析习惯...';

  @override
  String get predictorComplete => '分析完成';

  @override
  String get syncInProgress => '同步中...';

  @override
  String get syncComplete => '同步完成';

  @override
  String get mlModelLoaded => '已加载';

  @override
  String get mlModelLoading => '加载中...';

  @override
  String get mlModelError => '错误';

  @override
  String get chooseHabitType => '你想添加哪种类型的习惯？';

  @override
  String get chooseFromPredefined => '选择一个预设习惯';

  @override
  String get manual => '手动';

  @override
  String get custom => '自定义';

  @override
  String get defaultHabit => '预设';

  @override
  String get addHabitDiscoverySubtitle => '选择如何添加新习惯：你可以创建自定义习惯，或选择一个预设习惯快速开始。';

  @override
  String get requiredFieldLabel => '必填';

  @override
  String get back => '返回';

  @override
  String get selectAll => '全选';

  @override
  String get copy => '复制';

  @override
  String get copyHabit => '您想要复制此任务吗？';

  @override
  String copyHabitConfirm(String habitName) {
    return '您确定要复制\"$habitName\"吗？';
  }

  @override
  String get introMessage => '最大的改变始于坚持...';

  @override
  String get usefulTip => '实用提示';

  @override
  String get habitsTip => '滑动以查看您的习惯操作';

  @override
  String get understood => '明白了';

  @override
  String get bible => '圣经';

  @override
  String get home => '首页';

  @override
  String get reminderConfig => 'Reminder Configuration';

  @override
  String get recurrenceConfig => 'Daily Repetitions';

  @override
  String get repeat => 'Repeat';

  @override
  String get setCycleForPlan => 'Set a cycle for your plan';

  @override
  String get subtasks => 'Subtasks';

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get minutesBefore => 'Minutes before';

  @override
  String get interval => 'Interval';

  @override
  String get endDate => 'End date';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String everyXDays(int count) {
    return 'Every $count day(s)';
  }

  @override
  String everyXWeeks(int count) {
    return 'Every $count week(s)';
  }

  @override
  String everyXMonths(int count) {
    return 'Every $count month(s)';
  }

  @override
  String get noRepetition => 'No repetition';

  @override
  String get reminder => 'Reminder';

  @override
  String get repetition => 'Repetition';

  @override
  String get eventTime => 'Event time (HH:MM)';

  @override
  String get invalidMinutes => 'Please enter a valid number between 1 and 1440';

  @override
  String get invalidInterval => 'Interval must be at least 1';

  @override
  String get habitTracking => 'Habit Tracking';

  @override
  String get routine => '常规';

  @override
  String get today => '今天';

  @override
  String get morning_prayer => 'Morning Prayer';

  @override
  String get bible_reading => 'Bible Reading';

  @override
  String get evening_prayer => 'Evening Prayer';

  @override
  String get worship_music => 'Worship Music';

  @override
  String get gratitude_journal => 'Gratitude Journal';

  @override
  String get scripture_meditation => 'Scripture Meditation';

  @override
  String get fasting => 'Fasting';

  @override
  String get serve_others => 'Serve Others';

  @override
  String get bible_study_group => 'Bible Study Group';

  @override
  String get prayer_walk => 'Prayer Walk';

  @override
  String get scripture_memorization => 'Scripture Memorization';

  @override
  String get intercessory_prayer => 'Intercessory Prayer';

  @override
  String get devotional_reading => 'Devotional Reading';

  @override
  String get confession_repentance => 'Confession & Repentance';

  @override
  String get praise_thanksgiving => 'Praise & Thanksgiving';

  @override
  String get sabbath_rest => 'Sabbath Rest';

  @override
  String get digital_detox_prayer => 'Digital Detox & Prayer';

  @override
  String get christian_podcast => 'Christian Podcast';

  @override
  String get family_devotion => 'Family Devotion';

  @override
  String get spiritual_reading => 'Spiritual Reading';

  @override
  String get daily_walk => 'Daily Walk';

  @override
  String get morning_exercise => 'Morning Exercise';

  @override
  String get yoga_stretching => 'Yoga/Stretching';

  @override
  String get healthy_breakfast => 'Healthy Breakfast';

  @override
  String get hydration_routine => 'Hydration Routine';

  @override
  String get running_jogging => 'Running/Jogging';

  @override
  String get strength_training => 'Strength Training';

  @override
  String get bike_cycling => 'Biking/Cycling';

  @override
  String get healthy_meal_prep => 'Healthy Meal Prep';

  @override
  String get swimming => 'Swimming';

  @override
  String get dance_movement => 'Dance/Movement';

  @override
  String get sports_recreation => 'Sports/Recreation';

  @override
  String get posture_breaks => 'Posture Breaks';

  @override
  String get outdoor_nature => 'Outdoor/Nature Time';

  @override
  String get evening_walk => 'Evening Walk';

  @override
  String get mindfulness_meditation => 'Mindfulness Meditation';

  @override
  String get journaling => 'Journaling';

  @override
  String get deep_work_focus => 'Deep Work/Focus';

  @override
  String get reading_learning => 'Reading/Learning';

  @override
  String get digital_detox => 'Digital Detox';

  @override
  String get planning_review => 'Planning & Review';

  @override
  String get breathing_exercises => 'Breathing Exercises';

  @override
  String get creative_hobby => 'Creative Hobby';

  @override
  String get call_friend_family => 'Call Friend/Family';

  @override
  String get quality_time_loved_ones => 'Quality Time with Loved Ones';

  @override
  String get addNote => '添加笔记';

  @override
  String get noteHint => '进展如何？分享您的想法...';

  @override
  String get viewNote => '查看笔记';

  @override
  String get shareNote => '分享';

  @override
  String get noteAdded => '笔记已添加';

  @override
  String get addNoteDialog => '添加笔记';

  @override
  String get completeWithNote => '完成并添加笔记';

  @override
  String get addEmoji => '添加表情符号';

  @override
  String get hideEmojis => '隐藏表情符号';
}
