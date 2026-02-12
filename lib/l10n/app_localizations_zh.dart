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
  String get yes => '确定';

  @override
  String get habitAlreadyCompletedStartAgain => '该习惯已完成。是否要重新开始计时？';

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
  String get predefinedHabit_washDishes_name => '洗碗';

  @override
  String get predefinedHabit_washDishes_description => '保持厨房清洁有序';

  @override
  String get predefinedHabit_cleanRoom_name => '打扫房间';

  @override
  String get predefinedHabit_cleanRoom_description => '整理和组织您的空间';

  @override
  String get predefinedHabit_doLaundry_name => '洗衣服';

  @override
  String get predefinedHabit_doLaundry_description => '洗涤和折叠衣物';

  @override
  String get predefinedHabit_organizeSpace_name => '整理空间';

  @override
  String get predefinedHabit_organizeSpace_description => '清理和整理您的生活区域';

  @override
  String get predefinedHabit_cleanBathroom_name => '打扫浴室';

  @override
  String get predefinedHabit_cleanBathroom_description => '保持浴室清洁卫生';

  @override
  String get predefinedHabit_cookMeal_name => '做饭';

  @override
  String get predefinedHabit_cookMeal_description => '准备健康的家常菜';

  @override
  String get predefinedHabit_vacuumFloors_name => '吸尘';

  @override
  String get predefinedHabit_vacuumFloors_description => '保持地板清洁无尘';

  @override
  String get predefinedHabit_makeBreakfast_name => '做早餐';

  @override
  String get predefinedHabit_makeBreakfast_description => '以营养餐开始新的一天';

  @override
  String get predefinedHabit_bedMaking_name => '整理床铺';

  @override
  String get predefinedHabit_bedMaking_description => '每天整理床铺开始新的一天';

  @override
  String get predefinedHabit_helpKidsHomework_name => '帮助孩子做作业';

  @override
  String get predefinedHabit_helpKidsHomework_description => '支持孩子的学习';

  @override
  String get onboardingErrorMessage => '保存习惯失败。请重试。';

  @override
  String get retry => '重试';

  @override
  String get selected => '已选择';

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
  String get habitEdited => '习惯已成功编辑';

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
  String confirmNotificationQuestion(String time) {
    return '您想将通知时间设置为 $time 吗？';
  }

  @override
  String get buttonConfirmHour => '确认时间';

  @override
  String get buttonEdit => '编辑';

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
    return '至少需要 $days 天的数据进行预测';
  }

  @override
  String backgroundSyncFailed(String reason) {
    return '同步失败：$reason';
  }

  @override
  String get backgroundSyncNetwork => '无网络连接。更改将在联网后同步。';

  @override
  String get backgroundSyncPermission => '后台同步已禁用。请在设置中启用。';

  @override
  String get workmanagerActive => '后台同步已激活';

  @override
  String get workmanagerRestricted => '后台同步可能受电池优化限制';

  @override
  String get workmanagerDisabled => '后台同步已在系统设置中禁用';

  @override
  String get patternWeekend => '您经常在周末跳过习惯。建议设置提醒？';

  @override
  String get patternEvening => '晚上完成率较低。建议尝试早晨习惯。';

  @override
  String optimalTimeFound(String time) {
    return '已找到最佳完成时间 $time';
  }

  @override
  String get networkTimeout => '网络超时。请检查您的连接。';

  @override
  String get firebasePermissionDenied => 'Firebase访问被拒绝。请重新登录。';

  @override
  String get errorUnknown => '发生未知错误。请重试。';

  @override
  String get devBannerTitle => '开发工具栏';

  @override
  String devBannerLastSync(String time) {
    return '最后同步：$time';
  }

  @override
  String devBannerMlStatus(String status) {
    return 'ML模型：$status';
  }

  @override
  String devBannerWorkmanager(String status) {
    return '后台管理器：$status';
  }

  @override
  String devBannerFastTime(String multiplier, String date) {
    return '时间：${multiplier}x（模拟：$date）';
  }

  @override
  String get riskLevelLow => '低风险';

  @override
  String get riskLevelMedium => '中等风险';

  @override
  String get riskLevelHigh => '高风险';

  @override
  String get predictorRunning => '习惯分析进行中...';

  @override
  String get predictorComplete => '习惯分析已完成。';

  @override
  String get syncInProgress => '同步进行中...';

  @override
  String get syncComplete => '同步完成。';

  @override
  String get mlModelLoaded => '已加载';

  @override
  String get mlModelLoading => '加载中...';

  @override
  String get mlModelError => '错误';

  @override
  String get chooseHabitType => '您想添加哪种类型的习惯？';

  @override
  String get chooseFromPredefined => '选择预设习惯';

  @override
  String get manual => '手动';

  @override
  String get custom => '自定义';

  @override
  String get defaultHabit => '预设';

  @override
  String get addHabitDiscoverySubtitle => '选择如何添加新习惯：可自定义或选择预设习惯快速开始。';

  @override
  String get requiredFieldLabel => '必填';

  @override
  String get back => '返回';

  @override
  String get selectAll => '全选';

  @override
  String get copy => '复制';

  @override
  String get copyHabit => '要复制任务吗？';

  @override
  String copyHabitConfirm(String habitName) {
    return '确定要复制“$habitName”吗？';
  }

  @override
  String get introMessage => '最大的改变，始于坚持...';

  @override
  String get todaysVerse => '今日经文';

  @override
  String get todaysHabits => '今日习惯';

  @override
  String get allHabitsCompleted => '🎉 今日所有习惯已完成！';

  @override
  String dayStreak(int count) {
    return '连续 $count 天';
  }

  @override
  String get startJourney => '今天开始你的旅程';

  @override
  String get buildConsistency => '让我们今天开始坚持！💪';

  @override
  String get greatProgress => '进步很大！继续加油！🔥';

  @override
  String habitsRemaining(int count) {
    return '还剩 $count 个习惯';
  }

  @override
  String get longestStreakCard => '最长连续';

  @override
  String get weeklyConsistencyCard => '每周坚持';

  @override
  String get swipeToComplete => '点击或左滑完成';

  @override
  String get usefulTip => '实用提示';

  @override
  String get habitsTip => '滑动查看习惯操作';

  @override
  String get understood => '明白了';

  @override
  String get bible => '圣经';

  @override
  String get home => '首页';

  @override
  String get reminderConfig => '提醒设置';

  @override
  String get recurrenceConfig => '每天重复';

  @override
  String get repeat => '重复提醒';

  @override
  String get setCycleForPlan => '为你的计划设置周期';

  @override
  String get subtasks => '子任务';

  @override
  String get addSubtask => '添加子任务';

  @override
  String get minutesBefore => '提前分钟数';

  @override
  String get interval => '间隔';

  @override
  String get endDate => '结束日期';

  @override
  String get daily => '每日';

  @override
  String get weekly => '每周';

  @override
  String get monthly => '每月';

  @override
  String everyXDays(int count) {
    return '每 $count 天';
  }

  @override
  String everyXWeeks(int count) {
    return '每 $count 周';
  }

  @override
  String everyXMonths(int count) {
    return '每 $count 月';
  }

  @override
  String get noRepetition => '无重复';

  @override
  String get reminder => '提醒';

  @override
  String get repetition => '重复';

  @override
  String get eventTime => '事件时间 (HH:MM)';

  @override
  String get invalidMinutes => '请输入1到1440之间的有效数字';

  @override
  String get invalidInterval => '间隔必须至少为1';

  @override
  String get habitTracking => '习惯跟踪';

  @override
  String get routine => '日常';

  @override
  String get today => '今天';

  @override
  String get flashTask => '快速任务';

  @override
  String get flashTaskSubtitle => '快速添加只需名称和表情符号的任务';

  @override
  String get morning_prayer => '晨祷';

  @override
  String get bible_reading => '读经';

  @override
  String get evening_prayer => '晚祷';

  @override
  String get worship_music => '敬拜音乐';

  @override
  String get gratitude_journal => '感恩日记';

  @override
  String get scripture_meditation => '经文默想';

  @override
  String get fasting => '禁食';

  @override
  String get serve_others => '服务他人';

  @override
  String get bible_study_group => '查经小组';

  @override
  String get prayer_walk => '祷告行走';

  @override
  String get scripture_memorization => '经文背诵';

  @override
  String get intercessory_prayer => '代祷';

  @override
  String get devotional_reading => '灵修阅读';

  @override
  String get confession_repentance => '认罪悔改';

  @override
  String get praise_thanksgiving => '赞美与感恩';

  @override
  String get sabbath_rest => '安息日休息';

  @override
  String get digital_detox_prayer => '数字排毒与祷告';

  @override
  String get christian_podcast => '基督教播客';

  @override
  String get family_devotion => '家庭灵修';

  @override
  String get spiritual_reading => '属灵阅读';

  @override
  String get daily_walk => '每日步行';

  @override
  String get morning_exercise => '晨练';

  @override
  String get yoga_stretching => '瑜伽拉伸';

  @override
  String get healthy_breakfast => '健康早餐';

  @override
  String get hydration_routine => '补水习惯';

  @override
  String get running_jogging => '跑步/慢跑';

  @override
  String get strength_training => '力量训练';

  @override
  String get bike_cycling => '骑行';

  @override
  String get healthy_meal_prep => '健康餐准备';

  @override
  String get swimming => '游泳';

  @override
  String get dance_movement => '舞蹈/运动';

  @override
  String get sports_recreation => '体育/娱乐';

  @override
  String get posture_breaks => '姿势休息';

  @override
  String get outdoor_nature => '户外/自然时间';

  @override
  String get evening_walk => '夜间步行';

  @override
  String get mindfulness_meditation => '正念冥想';

  @override
  String get journaling => '写日记';

  @override
  String get deep_work_focus => '深度工作/专注';

  @override
  String get reading_learning => '阅读/学习';

  @override
  String get digital_detox => '数字排毒';

  @override
  String get planning_review => '计划与回顾';

  @override
  String get breathing_exercises => '呼吸练习';

  @override
  String get creative_hobby => '创意爱好';

  @override
  String get call_friend_family => '联系朋友/家人';

  @override
  String get quality_time_loved_ones => '与亲人共度美好时光';

  @override
  String get addNote => '添加备注';

  @override
  String get noteHint => '输入您的备注...';

  @override
  String get viewNote => '查看备注';

  @override
  String get shareNote => '分享备注';

  @override
  String get noteAdded => '备注已添加';

  @override
  String get addNoteDialog => '添加备注对话框';

  @override
  String get completeWithNote => '完成并添加备注';

  @override
  String get addEmoji => '添加表情符号';

  @override
  String get hideEmojis => '隐藏表情符号';

  @override
  String get onboardingSelectAtLeastOneGoal => '请选择至少一个目标';

  @override
  String get onboardingPreparingHabits => '正在准备您的习惯...';

  @override
  String get onboardingKeepAtLeastOneHabit => '至少保留一个习惯';

  @override
  String get onboardingCouldNotCreateHabits => '无法创建习惯。请重试。';

  @override
  String get planYourDay => '规划您的一天';

  @override
  String get skipHabit => '跳过习惯';

  @override
  String get markAsNotCompleted => '未完成';

  @override
  String get skippedHabit => '已跳过';

  @override
  String get failedHabit => '失败';

  @override
  String get repeatReminder => '重复提醒';

  @override
  String get habitSkipped => '习惯已跳过';

  @override
  String get habitMarkedAsNotCompleted => '习惯已标记为未完成';

  @override
  String get habitDeleted => '习惯已删除';

  @override
  String get habitCreated => '习惯创建成功';

  @override
  String get dailyReflection => '每日反思';

  @override
  String get myReflection => '我的反思';

  @override
  String get globalNote => '全局备注';

  @override
  String get globalNoteHint => '为今天添加备注...';

  @override
  String get dailyHabits => '每日习惯';

  @override
  String get addReflection => '添加反思';

  @override
  String get completeHabitToReflect => '完成习惯以添加反思';

  @override
  String get notificationOptions => '通知选项';

  @override
  String get turnOffNotification => '关闭通知';

  @override
  String get turnOffNotificationDesc => '禁用此习惯的每日提醒';

  @override
  String get changeNotificationTime => '更改时间';

  @override
  String get changeNotificationTimeDesc => '更新您想要被提醒的时间';

  @override
  String get notificationTurnedOff => '通知已关闭';

  @override
  String get notificationTimeChanged => '通知时间已更新';

  @override
  String get invalidNotificationConfig => '通知配置无效。请重新设置通知。';

  @override
  String get readVerseFirst => '先读经文';

  @override
  String get reflection => '反思';

  @override
  String get forMeditation => '默想要点';

  @override
  String get prayer => '祷告';

  @override
  String get todayLabel => '今天';

  @override
  String get tomorrowLabel => '明天';

  @override
  String get aboutUs => '关于我们';

  @override
  String get aboutUsTitle => 'Habitus Faith';

  @override
  String get aboutUsSubtitle => '通过日常习惯建立信心';

  @override
  String get aboutUsDescription =>
      'Habitus Faith 是一款旨在通过持续的日常习惯帮助您在属灵旅程中成长的应用程序。我们相信，每天重复的小而有意的行动可以改变您的生活并加深您与神的关系。';

  @override
  String get ourMission => '我们的使命';

  @override
  String get ourMissionText => '赋予全球信徒建立可持续的属灵习惯的能力，一次一天地加强他们的信心。';

  @override
  String get features => '功能';

  @override
  String get featureHabitTracking => '习惯跟踪';

  @override
  String get featureHabitTrackingDesc => '轻松跟踪您的属灵、身体、心理和社交习惯。';

  @override
  String get featureBibleReading => '阅读圣经';

  @override
  String get featureBibleReadingDesc => '访问完整的圣经，具有书签和经文保存功能。';

  @override
  String get featureDailyDevotionals => '每日灵修';

  @override
  String get featureDailyDevotionalsDesc => '接收每日属灵反思，启发并引导您。';

  @override
  String get featureAiCoach => 'AI 习惯教练';

  @override
  String get featureAiCoachDesc => '根据您的目标生成个性化微习惯。';

  @override
  String get contactUs => '联系我们';

  @override
  String get contactUsText => '我们很乐意听取您的意见！您的反馈有助于我们改进并更好地为您服务。';

  @override
  String get email => '电子邮件';

  @override
  String get version => '版本';

  @override
  String get madeWithLove => '由 Develop4God 用 ❤️ 制作\n \n愿荣耀归于神';

  @override
  String get faithJourney => '信仰旅程';

  @override
  String get faithJourneyDescription => '追踪你的进度，赢取信仰点并解锁徽章！';

  @override
  String get startTimer => '开始计时';

  @override
  String get timerRunning => '计时进行中';

  @override
  String get timeToFocus => '专注时间';

  @override
  String get focusComplete => '专注时段完成！';

  @override
  String get goalReached => '目标达成！';

  @override
  String get timer => '计时器';
}
