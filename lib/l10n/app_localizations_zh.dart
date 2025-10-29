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
}
