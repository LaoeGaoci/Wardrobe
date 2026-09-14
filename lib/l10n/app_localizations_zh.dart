// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Wardrobe';

  @override
  String get wardrobe => '衣柜';

  @override
  String get friends => '好友';

  @override
  String get profile => '我的';

  @override
  String get profileTitle => '个人中心';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get delete => '删除';

  @override
  String get reload => '重新加载';

  @override
  String get close => '关闭';

  @override
  String get preferences => '偏好设置';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '接收穿搭提醒';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '使用深色外观';

  @override
  String get appSection => '应用';

  @override
  String get language => '语言';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '确定要退出登录吗？';

  @override
  String get aboutDescription => '你的个人数字衣橱。';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get createAccount => '创建账号';

  @override
  String get loginSubtitle => '登录你的衣柜，继续管理你的穿搭';

  @override
  String get registerSubtitle => '创建账号，开始整理你的专属衣柜';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get email => '邮箱';

  @override
  String get emailHint => '请输入邮箱地址';

  @override
  String get emailRequired => '请输入邮箱';

  @override
  String get invalidEmail => '请输入有效的邮箱地址';

  @override
  String get verificationCode => '验证码';

  @override
  String get verificationCodeHint => '请输入验证码';

  @override
  String get getVerificationCode => '获取验证码';

  @override
  String get verificationCodeRequired => '请输入验证码';

  @override
  String get invalidVerificationCode => '验证码错误';

  @override
  String get verificationCodeLength => '验证码应为 6 位';

  @override
  String get verificationCodeSent => '验证码已发送';

  @override
  String get password => '密码';

  @override
  String get passwordHintLogin => '请输入密码';

  @override
  String get passwordHintRegister => '设置密码（至少 8 位）';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get passwordMinLength => '密码至少需要 8 位';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get noAccountRegister => '还没有账号？立即注册';

  @override
  String get haveAccountLogin => '已有账号？返回登录';

  @override
  String get operationFailed => '操作失败，请稍后重试';

  @override
  String get myWardrobe => '我的衣柜';

  @override
  String get searchClothing => '搜索衣物';

  @override
  String get noClothing => '暂无衣物';

  @override
  String get rearCameraNotFound => '未找到后置摄像头';

  @override
  String get wardrobeLoadFailed => '衣柜加载失败';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryTop => '上衣';

  @override
  String get categoryCoat => '外套';

  @override
  String get categoryDownJacket => '羽绒服';

  @override
  String get categoryPants => '裤子';

  @override
  String get categoryHat => '帽子';

  @override
  String get categoryShoes => '鞋子';

  @override
  String get categoryAccessories => '配饰';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonAutumn => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get captureClothing => '拍摄衣物';

  @override
  String cameraOpenFailed(String error) {
    return '无法打开摄像头：$error';
  }

  @override
  String takePhotoFailed(String error) {
    return '拍照失败：$error';
  }

  @override
  String get addClothing => '添加衣物';

  @override
  String get name => '名称';

  @override
  String get nameExample => '例如：白色T恤';

  @override
  String get clothingNameRequired => '请输入衣物名称';

  @override
  String get nameMax100 => '名称不能超过100个字符';

  @override
  String get brand => '品牌';

  @override
  String get optional => '可选';

  @override
  String get leaveBlank => '可留空';

  @override
  String get brandMax100 => '品牌不能超过100个字符';

  @override
  String get category => '分类';

  @override
  String get color => '颜色';

  @override
  String get colorExample => '例如：白色';

  @override
  String get colorRequired => '请输入颜色';

  @override
  String get season => '季节';

  @override
  String get price => '价格';

  @override
  String get validPrice => '请输入有效价格';

  @override
  String get createClothing => '创建衣物';

  @override
  String get retakePhoto => '重新拍摄';

  @override
  String get visibility => '可见性';

  @override
  String get privateLabel => 'Private';

  @override
  String get privateSubtitle => '只有你可以看到';

  @override
  String get publicLabel => 'Public';

  @override
  String get publicSubtitle => '好友可以看到';

  @override
  String saveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get clothingDetails => '衣物详情';

  @override
  String get notSet => '未设置';

  @override
  String get editCard => '编辑卡片';

  @override
  String get replaceClothingImage => '更换衣物图片';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String imageSelectFailed(String error) {
    return '选择图片失败：$error';
  }

  @override
  String get saving => '正在保存';

  @override
  String get saveChanges => '保存修改';

  @override
  String get clothingImage => '衣物图片';

  @override
  String get changeImage => '更换图片';

  @override
  String get reselectImage => '重新选择图片';

  @override
  String get friendRequests => '好友申请';

  @override
  String get requestRejected => '已拒绝好友申请';

  @override
  String becameFriends(String username) {
    return '$username 已成为你的好友';
  }

  @override
  String get noFriendRequests => '暂无好友申请';

  @override
  String get accept => '同意';

  @override
  String get reject => '拒绝';

  @override
  String get onlyFriendsCanRecommend => '只有好友之间才能进行衣物推荐';

  @override
  String get selectAtLeastOne => '请至少选择一件衣物';

  @override
  String get recommendationSent => '衣物推荐已发送';

  @override
  String friendWardrobe(String username) {
    return '$username的衣柜';
  }

  @override
  String get recommend => '推荐';

  @override
  String get selectClothing => '请选择衣物';

  @override
  String recommendItemCount(int count) {
    return '推荐 $count 件衣物';
  }

  @override
  String get noPublicClothing => '这个衣柜暂时没有公开衣物';

  @override
  String get onlyPublicVisible => '只有设置为 Public 的衣物才能被好友看到。';

  @override
  String recommendationFor(String username) {
    return '给 $username 的推荐';
  }

  @override
  String selectedItems(int count) {
    return '已选择 $count 件衣物';
  }

  @override
  String get recommendationMessageHint => '捎一句话吧，例如：这星期天气转凉了，记得穿这些衣服。';

  @override
  String get recommendationMessageRequired => '请输入推荐留言';

  @override
  String get sendRecommendation => '发送推荐';

  @override
  String get recommendationHistory => '推荐记录';

  @override
  String get searchUserOrEmail => '搜索用户名或邮箱';

  @override
  String get noUserFound => '没有找到用户';

  @override
  String get trySearchUserOrEmail => '可以尝试搜索用户名或邮箱';

  @override
  String get noFriends => '还没有好友';

  @override
  String get searchAndAddFriends => '搜索用户并添加好友吧';

  @override
  String get statusFriend => '好友';

  @override
  String get statusRequested => '已申请';

  @override
  String get statusPending => '待处理';

  @override
  String get receivedRecommendations => '收到的推荐';

  @override
  String get sentRecommendations => '发出的推荐';

  @override
  String get noReceivedRecommendations => '还没有收到推荐';

  @override
  String get receivedRecommendationsHint => '好友给你发送的衣物推荐会出现在这里';

  @override
  String get noSentRecommendations => '还没有发出推荐';

  @override
  String get sentRecommendationsHint => '你给好友发送过的衣物推荐会出现在这里';

  @override
  String get read => '已读';

  @override
  String get unread => '未读';

  @override
  String get recipientRead => '对方已读';

  @override
  String get recipientUnread => '对方未读';

  @override
  String clothingCount(int count) {
    return '$count 件衣物';
  }

  @override
  String sentTo(String username) {
    return '发送给 $username';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String recommendationFrom(String username) {
    return '来自 $username 的推荐';
  }

  @override
  String recommendationTo(String username) {
    return '发送给 $username 的推荐';
  }

  @override
  String get recommendedClothing => '推荐衣物';

  @override
  String itemCount(int count) {
    return '$count 件';
  }

  @override
  String get recommendationClothingMissing => '推荐的衣物已经不存在了';

  @override
  String get userProfile => '用户介绍';

  @override
  String get addFriend => '添加好友';

  @override
  String get introduceYourself => '介绍一下自己吧';

  @override
  String get sendRequest => '发送申请';

  @override
  String get requestSentTitle => '申请已发送';

  @override
  String get requestSentBody => '好友申请已经发送，等待对方同意。';

  @override
  String get setRemark => '设置备注';

  @override
  String get remarkHint => '请输入好友备注';

  @override
  String get deleteFriend => '删除好友';

  @override
  String deleteFriendConfirm(String username) {
    return '确定要删除 $username 吗？';
  }

  @override
  String get pendingCancelNotFound => '未找到待取消的好友申请';

  @override
  String get alreadyFriends => '你们已经是好友';

  @override
  String get friendRequestSent => '好友申请已发送';

  @override
  String get waitingApproval => '等待对方同意';

  @override
  String get receivedFriendRequest => '收到好友申请';

  @override
  String get friendRequestReceivedSubtitle => '对方已经向你发送了好友申请';

  @override
  String get notFriendsYet => '还不是好友';

  @override
  String get canSendFriendRequest => '可以发送好友申请';

  @override
  String get cancelRequest => '取消申请';

  @override
  String get processFriendRequests => '前往处理好友申请';

  @override
  String get viewWardrobe => '查看衣柜';

  @override
  String remarkValue(String remark) {
    return '备注：$remark';
  }

  @override
  String get removeFriend => '删除好友';

  @override
  String recommendationLoadFailed(String error) {
    return '推荐加载失败：$error';
  }

  @override
  String recommendationLetterFrom(String username) {
    return '来自 $username 的推荐信';
  }

  @override
  String get tapOpenLetter => '点击拆开这封推荐信';

  @override
  String unreadRecommendations(int count) {
    return '还有 $count 封未读推荐';
  }

  @override
  String get receivedClothingRecommendation => '你收到一封衣物推荐';

  @override
  String senderSentLetter(String username) {
    return '$username 给你寄来了一封信';
  }

  @override
  String get openLetter => '拆开信件';

  @override
  String get storingLetter => '正在收好';

  @override
  String get keepLetter => '收好这封信';

  @override
  String get sessionExpired => '登录状态已失效，请重新登录';

  @override
  String get userNotFound => '用户不存在';

  @override
  String get emailAlreadyExists => '该邮箱已经注册';

  @override
  String get emailOrUsernameAlreadyExists => '该邮箱或用户名已经被使用';

  @override
  String get invalidEmailOrPassword => '邮箱或密码错误';

  @override
  String get usernameAlreadyExists => '该用户名已被使用';

  @override
  String get usernameRequired => '用户名不能为空';

  @override
  String get passwordMaxLength => '密码不能超过 128 位';

  @override
  String get cannotAddSelf => '不能添加自己为好友';

  @override
  String get userAlreadyFriend => '对方已经是你的好友';

  @override
  String get friendRequestAlreadySent => '好友申请已经发送';

  @override
  String get userAlreadySentRequest => '对方已经向你发送好友申请，请先处理';

  @override
  String get friendRequestNotFound => '好友申请不存在或已经处理';

  @override
  String get friendNotFound => '好友关系不存在';

  @override
  String get userNotFriend => '对方不是你的好友';

  @override
  String get friendRequestMessageRequired => '请输入好友申请信息';

  @override
  String get cannotAccessSelfFriendApi => '不能通过好友接口访问自己的衣柜';

  @override
  String get friendClothingUnavailable => '好友衣物不存在或不可见';

  @override
  String get clothingImageNotFound => '衣物图片不存在';

  @override
  String get cannotRecommendSelf => '不能给自己发送推荐';

  @override
  String get onlyRecommendFriends => '只能给好友发送衣物推荐';

  @override
  String get recommendationItemsUnavailable => '部分衣物已经不存在、已设为私密或不属于该好友';

  @override
  String get recommendationMessageTooLong => '推荐留言不能超过 200 个字符';

  @override
  String get onlyFriendWardrobeItems => '只能推荐好友衣柜中的衣物';

  @override
  String get onlyPublicItems => '只能推荐好友公开的衣物';

  @override
  String get recommendationNotFound => '推荐不存在或你没有查看权限';

  @override
  String get recommendationItemNotFound => '推荐中的衣物已经不存在';

  @override
  String get recommendationImageNotFound => '推荐中的衣物图片已经不存在';

  @override
  String get serverDataInvalid => '服务器返回的数据格式不正确';

  @override
  String get accountSection => '账户';

  @override
  String get deleteAccount => '注销账户';

  @override
  String get deleteAccountSubtitle => '永久删除账户及相关数据';

  @override
  String get deleteAccountDescription => '注销后，你的个人资料、衣物、好友关系和推荐记录将被永久删除，且无法恢复。';

  @override
  String deleteAccountEmailPrompt(String email) {
    return '请输入邮箱 $email 以确认注销账户。';
  }

  @override
  String get deleteAccountEmailHint => '请输入当前账户邮箱';

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get resetYourPassword => '重置密码';

  @override
  String get forgotPasswordSubtitle => '输入注册邮箱，我们会向你的邮箱发送验证码';

  @override
  String get passwordResetCodeSent => '如果该邮箱已注册，验证码已发送，请检查邮箱';

  @override
  String get newPassword => '新密码';

  @override
  String get newPasswordHint => '请输入新密码（至少 8 位）';

  @override
  String get newPasswordRequired => '请输入新密码';

  @override
  String get confirmPassword => '确认新密码';

  @override
  String get confirmPasswordHint => '请再次输入新密码';

  @override
  String get confirmPasswordRequired => '请确认新密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get resetPassword => '重置密码';

  @override
  String get passwordResetSuccess => '密码重置成功，请使用新密码登录';

  @override
  String get invalidOrExpiredVerificationCode => '验证码无效或已过期';

  @override
  String get tooManyVerificationAttempts => '验证码错误次数过多，请重新获取验证码';

  @override
  String get verificationCodeRequestTooFrequent => '请求过于频繁，请稍后再获取验证码';

  @override
  String get verificationEmailSendFailed => '验证码邮件发送失败，请稍后重试';

  @override
  String get newPasswordMustBeDifferent => '新密码不能与当前密码相同';

  @override
  String get currentPasswordIncorrect => '当前密码错误';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'Wardrobe';

  @override
  String get wardrobe => '衣柜';

  @override
  String get friends => '好友';

  @override
  String get profile => '我的';

  @override
  String get profileTitle => '个人中心';

  @override
  String get settings => '设置';

  @override
  String get about => '关于';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get delete => '删除';

  @override
  String get reload => '重新加载';

  @override
  String get close => '关闭';

  @override
  String get preferences => '偏好设置';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '接收穿搭提醒';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '使用深色外观';

  @override
  String get appSection => '应用';

  @override
  String get language => '语言';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirm => '确定要退出登录吗？';

  @override
  String get aboutDescription => '你的个人数字衣橱。';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get createAccount => '创建账号';

  @override
  String get loginSubtitle => '登录你的衣柜，继续管理你的穿搭';

  @override
  String get registerSubtitle => '创建账号，开始整理你的专属衣柜';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get email => '邮箱';

  @override
  String get emailHint => '请输入邮箱地址';

  @override
  String get emailRequired => '请输入邮箱';

  @override
  String get invalidEmail => '请输入有效的邮箱地址';

  @override
  String get verificationCode => '验证码';

  @override
  String get verificationCodeHint => '请输入验证码';

  @override
  String get getVerificationCode => '获取验证码';

  @override
  String get verificationCodeRequired => '请输入验证码';

  @override
  String get invalidVerificationCode => '验证码错误';

  @override
  String get verificationCodeLength => '验证码应为 6 位';

  @override
  String get verificationCodeSent => '验证码已发送，请检查邮箱';

  @override
  String get password => '密码';

  @override
  String get passwordHintLogin => '请输入密码';

  @override
  String get passwordHintRegister => '设置密码（至少 8 位）';

  @override
  String get passwordRequired => '请输入密码';

  @override
  String get passwordMinLength => '密码至少需要 8 位';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get noAccountRegister => '还没有账号？立即注册';

  @override
  String get haveAccountLogin => '已有账号？返回登录';

  @override
  String get operationFailed => '操作失败，请稍后重试';

  @override
  String get myWardrobe => '我的衣柜';

  @override
  String get searchClothing => '搜索衣物';

  @override
  String get noClothing => '暂无衣物';

  @override
  String get rearCameraNotFound => '未找到后置摄像头';

  @override
  String get wardrobeLoadFailed => '衣柜加载失败';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryTop => '上衣';

  @override
  String get categoryCoat => '外套';

  @override
  String get categoryDownJacket => '羽绒服';

  @override
  String get categoryPants => '裤子';

  @override
  String get categoryHat => '帽子';

  @override
  String get categoryShoes => '鞋子';

  @override
  String get categoryAccessories => '配饰';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonAutumn => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get captureClothing => '拍摄衣物';

  @override
  String cameraOpenFailed(String error) {
    return '无法打开摄像头：$error';
  }

  @override
  String takePhotoFailed(String error) {
    return '拍照失败：$error';
  }

  @override
  String get addClothing => '添加衣物';

  @override
  String get name => '名称';

  @override
  String get nameExample => '例如：白色T恤';

  @override
  String get clothingNameRequired => '请输入衣物名称';

  @override
  String get nameMax100 => '名称不能超过100个字符';

  @override
  String get brand => '品牌';

  @override
  String get optional => '可选';

  @override
  String get leaveBlank => '可留空';

  @override
  String get brandMax100 => '品牌不能超过100个字符';

  @override
  String get category => '分类';

  @override
  String get color => '颜色';

  @override
  String get colorExample => '例如：白色';

  @override
  String get colorRequired => '请输入颜色';

  @override
  String get season => '季节';

  @override
  String get price => '价格';

  @override
  String get validPrice => '请输入有效价格';

  @override
  String get createClothing => '创建衣物';

  @override
  String get retakePhoto => '重新拍摄';

  @override
  String get visibility => '可见性';

  @override
  String get privateLabel => 'Private';

  @override
  String get privateSubtitle => '只有你可以看到';

  @override
  String get publicLabel => 'Public';

  @override
  String get publicSubtitle => '好友可以看到';

  @override
  String saveFailed(String error) {
    return '保存失败：$error';
  }

  @override
  String get clothingDetails => '衣物详情';

  @override
  String get notSet => '未设置';

  @override
  String get editCard => '编辑卡片';

  @override
  String get replaceClothingImage => '更换衣物图片';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String imageSelectFailed(String error) {
    return '选择图片失败：$error';
  }

  @override
  String get saving => '正在保存';

  @override
  String get saveChanges => '保存修改';

  @override
  String get clothingImage => '衣物图片';

  @override
  String get changeImage => '更换图片';

  @override
  String get reselectImage => '重新选择图片';

  @override
  String get friendRequests => '好友申请';

  @override
  String get requestRejected => '已拒绝好友申请';

  @override
  String becameFriends(String username) {
    return '$username 已成为你的好友';
  }

  @override
  String get noFriendRequests => '暂无好友申请';

  @override
  String get accept => '同意';

  @override
  String get reject => '拒绝';

  @override
  String get onlyFriendsCanRecommend => '只有好友之间才能进行衣物推荐';

  @override
  String get selectAtLeastOne => '请至少选择一件衣物';

  @override
  String get recommendationSent => '衣物推荐已发送';

  @override
  String friendWardrobe(String username) {
    return '$username的衣柜';
  }

  @override
  String get recommend => '推荐';

  @override
  String get selectClothing => '请选择衣物';

  @override
  String recommendItemCount(int count) {
    return '推荐 $count 件衣物';
  }

  @override
  String get noPublicClothing => '这个衣柜暂时没有公开衣物';

  @override
  String get onlyPublicVisible => '只有设置为 Public 的衣物才能被好友看到。';

  @override
  String recommendationFor(String username) {
    return '给 $username 的推荐';
  }

  @override
  String selectedItems(int count) {
    return '已选择 $count 件衣物';
  }

  @override
  String get recommendationMessageHint => '捎一句话吧，例如：这星期天气转凉了，记得穿这些衣服。';

  @override
  String get recommendationMessageRequired => '请输入推荐留言';

  @override
  String get sendRecommendation => '发送推荐';

  @override
  String get recommendationHistory => '推荐记录';

  @override
  String get searchUserOrEmail => '搜索用户名或邮箱';

  @override
  String get noUserFound => '没有找到用户';

  @override
  String get trySearchUserOrEmail => '可以尝试搜索用户名或邮箱';

  @override
  String get noFriends => '还没有好友';

  @override
  String get searchAndAddFriends => '搜索用户并添加好友吧';

  @override
  String get statusFriend => '好友';

  @override
  String get statusRequested => '已申请';

  @override
  String get statusPending => '待处理';

  @override
  String get receivedRecommendations => '收到的推荐';

  @override
  String get sentRecommendations => '发出的推荐';

  @override
  String get noReceivedRecommendations => '还没有收到推荐';

  @override
  String get receivedRecommendationsHint => '好友给你发送的衣物推荐会出现在这里';

  @override
  String get noSentRecommendations => '还没有发出推荐';

  @override
  String get sentRecommendationsHint => '你给好友发送过的衣物推荐会出现在这里';

  @override
  String get read => '已读';

  @override
  String get unread => '未读';

  @override
  String get recipientRead => '对方已读';

  @override
  String get recipientUnread => '对方未读';

  @override
  String clothingCount(int count) {
    return '$count 件衣物';
  }

  @override
  String sentTo(String username) {
    return '发送给 $username';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String recommendationFrom(String username) {
    return '来自 $username 的推荐';
  }

  @override
  String recommendationTo(String username) {
    return '发送给 $username 的推荐';
  }

  @override
  String get recommendedClothing => '推荐衣物';

  @override
  String itemCount(int count) {
    return '$count 件';
  }

  @override
  String get recommendationClothingMissing => '推荐的衣物已经不存在了';

  @override
  String get userProfile => '用户介绍';

  @override
  String get addFriend => '添加好友';

  @override
  String get introduceYourself => '介绍一下自己吧';

  @override
  String get sendRequest => '发送申请';

  @override
  String get requestSentTitle => '申请已发送';

  @override
  String get requestSentBody => '好友申请已经发送，等待对方同意。';

  @override
  String get setRemark => '设置备注';

  @override
  String get remarkHint => '请输入好友备注';

  @override
  String get deleteFriend => '删除好友';

  @override
  String deleteFriendConfirm(String username) {
    return '确定要删除 $username 吗？';
  }

  @override
  String get pendingCancelNotFound => '未找到待取消的好友申请';

  @override
  String get alreadyFriends => '你们已经是好友';

  @override
  String get friendRequestSent => '好友申请已发送';

  @override
  String get waitingApproval => '等待对方同意';

  @override
  String get receivedFriendRequest => '收到好友申请';

  @override
  String get friendRequestReceivedSubtitle => '对方已经向你发送了好友申请';

  @override
  String get notFriendsYet => '还不是好友';

  @override
  String get canSendFriendRequest => '可以发送好友申请';

  @override
  String get cancelRequest => '取消申请';

  @override
  String get processFriendRequests => '前往处理好友申请';

  @override
  String get viewWardrobe => '查看衣柜';

  @override
  String remarkValue(String remark) {
    return '备注：$remark';
  }

  @override
  String get removeFriend => '删除好友';

  @override
  String recommendationLoadFailed(String error) {
    return '推荐加载失败：$error';
  }

  @override
  String recommendationLetterFrom(String username) {
    return '来自 $username 的推荐信';
  }

  @override
  String get tapOpenLetter => '点击拆开这封推荐信';

  @override
  String unreadRecommendations(int count) {
    return '还有 $count 封未读推荐';
  }

  @override
  String get receivedClothingRecommendation => '你收到一封衣物推荐';

  @override
  String senderSentLetter(String username) {
    return '$username 给你寄来了一封信';
  }

  @override
  String get openLetter => '拆开信件';

  @override
  String get storingLetter => '正在收好';

  @override
  String get keepLetter => '收好这封信';

  @override
  String get sessionExpired => '登录状态已失效，请重新登录';

  @override
  String get userNotFound => '用户不存在';

  @override
  String get emailAlreadyExists => '该邮箱已经注册';

  @override
  String get emailOrUsernameAlreadyExists => '该邮箱或用户名已经被使用';

  @override
  String get invalidEmailOrPassword => '邮箱或密码错误';

  @override
  String get usernameAlreadyExists => '该用户名已被使用';

  @override
  String get usernameRequired => '用户名不能为空';

  @override
  String get passwordMaxLength => '密码不能超过 128 位';

  @override
  String get cannotAddSelf => '不能添加自己为好友';

  @override
  String get userAlreadyFriend => '对方已经是你的好友';

  @override
  String get friendRequestAlreadySent => '好友申请已经发送';

  @override
  String get userAlreadySentRequest => '对方已经向你发送好友申请，请先处理';

  @override
  String get friendRequestNotFound => '好友申请不存在或已经处理';

  @override
  String get friendNotFound => '好友关系不存在';

  @override
  String get userNotFriend => '对方不是你的好友';

  @override
  String get friendRequestMessageRequired => '请输入好友申请信息';

  @override
  String get cannotAccessSelfFriendApi => '不能通过好友接口访问自己的衣柜';

  @override
  String get friendClothingUnavailable => '好友衣物不存在或不可见';

  @override
  String get clothingImageNotFound => '衣物图片不存在';

  @override
  String get cannotRecommendSelf => '不能给自己发送推荐';

  @override
  String get onlyRecommendFriends => '只能给好友发送衣物推荐';

  @override
  String get recommendationItemsUnavailable => '部分衣物已经不存在、已设为私密或不属于该好友';

  @override
  String get recommendationMessageTooLong => '推荐留言不能超过 200 个字符';

  @override
  String get onlyFriendWardrobeItems => '只能推荐好友衣柜中的衣物';

  @override
  String get onlyPublicItems => '只能推荐好友公开的衣物';

  @override
  String get recommendationNotFound => '推荐不存在或你没有查看权限';

  @override
  String get recommendationItemNotFound => '推荐中的衣物已经不存在';

  @override
  String get recommendationImageNotFound => '推荐中的衣物图片已经不存在';

  @override
  String get serverDataInvalid => '服务器返回的数据格式不正确';

  @override
  String get accountSection => '账户';

  @override
  String get deleteAccount => '注销账户';

  @override
  String get deleteAccountSubtitle => '永久删除账户及相关数据';

  @override
  String get deleteAccountDescription => '注销后，你的个人资料、衣物、好友关系和推荐记录将被永久删除，且无法恢复。';

  @override
  String deleteAccountEmailPrompt(String email) {
    return '请输入邮箱 $email 以确认注销账户。';
  }

  @override
  String get deleteAccountEmailHint => '请输入当前账户邮箱';

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get resetYourPassword => '重置密码';

  @override
  String get forgotPasswordSubtitle => '输入注册邮箱，我们会向你的邮箱发送验证码';

  @override
  String get passwordResetCodeSent => '如果该邮箱已注册，验证码已发送，请检查邮箱';

  @override
  String get newPassword => '新密码';

  @override
  String get newPasswordHint => '请输入新密码（至少 8 位）';

  @override
  String get newPasswordRequired => '请输入新密码';

  @override
  String get confirmPassword => '确认新密码';

  @override
  String get confirmPasswordHint => '请再次输入新密码';

  @override
  String get confirmPasswordRequired => '请确认新密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get resetPassword => '重置密码';

  @override
  String get passwordResetSuccess => '密码重置成功，请使用新密码登录';

  @override
  String get invalidOrExpiredVerificationCode => '验证码无效或已过期';

  @override
  String get tooManyVerificationAttempts => '验证码错误次数过多，请重新获取验证码';

  @override
  String get verificationCodeRequestTooFrequent => '请求过于频繁，请稍后再获取验证码';

  @override
  String get verificationEmailSendFailed => '验证码邮件发送失败，请稍后重试';

  @override
  String get newPasswordMustBeDifferent => '新密码不能与当前密码相同';

  @override
  String get currentPasswordIncorrect => '当前密码错误';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Wardrobe';

  @override
  String get wardrobe => '衣櫃';

  @override
  String get friends => '好友';

  @override
  String get profile => '我的';

  @override
  String get profileTitle => '個人中心';

  @override
  String get settings => '設定';

  @override
  String get about => '關於';

  @override
  String get save => '儲存';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get delete => '删除';

  @override
  String get reload => '重新載入';

  @override
  String get close => '關閉';

  @override
  String get preferences => '偏好設定';

  @override
  String get notifications => '通知';

  @override
  String get notificationsSubtitle => '接收穿搭提醒';

  @override
  String get darkMode => '深色模式';

  @override
  String get darkModeSubtitle => '使用深色外觀';

  @override
  String get appSection => '應用程式';

  @override
  String get language => '語言';

  @override
  String get logout => '登出';

  @override
  String get logoutConfirm => '確定要登出嗎？';

  @override
  String get aboutDescription => '你的個人數位衣櫃。';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get welcomeBack => '歡迎回來';

  @override
  String get createAccount => '建立帳號';

  @override
  String get loginSubtitle => '登入你的衣櫃，繼續管理你的穿搭';

  @override
  String get registerSubtitle => '建立帳號，開始整理你的專屬衣櫃';

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get email => '電子郵件';

  @override
  String get emailHint => '請輸入電子郵件地址';

  @override
  String get emailRequired => '請輸入電子郵件';

  @override
  String get invalidEmail => '請輸入有效的電子郵件地址';

  @override
  String get verificationCode => '驗證碼';

  @override
  String get verificationCodeHint => '請輸入驗證碼';

  @override
  String get getVerificationCode => '取得驗證碼';

  @override
  String get verificationCodeRequired => '請輸入驗證碼';

  @override
  String get invalidVerificationCode => '驗證碼錯誤';

  @override
  String get verificationCodeLength => '驗證碼應為 6 位';

  @override
  String get verificationCodeSent => '驗證碼已傳送，請檢查信箱';

  @override
  String get password => '密碼';

  @override
  String get passwordHintLogin => '請輸入密碼';

  @override
  String get passwordHintRegister => '設定密碼（至少 8 位）';

  @override
  String get passwordRequired => '請輸入密碼';

  @override
  String get passwordMinLength => '密碼至少需要 8 位';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get noAccountRegister => '還沒有帳號？立即註冊';

  @override
  String get haveAccountLogin => '已有帳號？返回登入';

  @override
  String get operationFailed => '操作失敗，請稍後再試';

  @override
  String get myWardrobe => '我的衣櫃';

  @override
  String get searchClothing => '搜尋衣物';

  @override
  String get noClothing => '暫無衣物';

  @override
  String get rearCameraNotFound => '找不到後置相機';

  @override
  String get wardrobeLoadFailed => '衣櫃載入失敗';

  @override
  String get categoryAll => '全部';

  @override
  String get categoryTop => '上衣';

  @override
  String get categoryCoat => '外套';

  @override
  String get categoryDownJacket => '羽絨外套';

  @override
  String get categoryPants => '褲子';

  @override
  String get categoryHat => '帽子';

  @override
  String get categoryShoes => '鞋子';

  @override
  String get categoryAccessories => '配件';

  @override
  String get seasonSpring => '春季';

  @override
  String get seasonSummer => '夏季';

  @override
  String get seasonAutumn => '秋季';

  @override
  String get seasonWinter => '冬季';

  @override
  String get captureClothing => '拍攝衣物';

  @override
  String cameraOpenFailed(String error) {
    return '無法開啟相機：$error';
  }

  @override
  String takePhotoFailed(String error) {
    return '拍照失敗：$error';
  }

  @override
  String get addClothing => '新增衣物';

  @override
  String get name => '名稱';

  @override
  String get nameExample => '例如：白色T恤';

  @override
  String get clothingNameRequired => '請輸入衣物名稱';

  @override
  String get nameMax100 => '名稱不能超過100個字元';

  @override
  String get brand => '品牌';

  @override
  String get optional => '選填';

  @override
  String get leaveBlank => '可留空';

  @override
  String get brandMax100 => '品牌不能超過100個字元';

  @override
  String get category => '分类';

  @override
  String get color => '顏色';

  @override
  String get colorExample => '例如：白色';

  @override
  String get colorRequired => '請輸入顏色';

  @override
  String get season => '季节';

  @override
  String get price => '價格';

  @override
  String get validPrice => '請輸入有效價格';

  @override
  String get createClothing => '建立衣物';

  @override
  String get retakePhoto => '重新拍摄';

  @override
  String get visibility => '可見性';

  @override
  String get privateLabel => 'Private';

  @override
  String get privateSubtitle => '只有你可以看到';

  @override
  String get publicLabel => 'Public';

  @override
  String get publicSubtitle => '好友可以看到';

  @override
  String saveFailed(String error) {
    return '儲存失敗：$error';
  }

  @override
  String get clothingDetails => '衣物詳情';

  @override
  String get notSet => '未設定';

  @override
  String get editCard => '編輯卡片';

  @override
  String get replaceClothingImage => '更換衣物圖片';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '從相簿選擇';

  @override
  String imageSelectFailed(String error) {
    return '選擇圖片失敗：$error';
  }

  @override
  String get saving => '正在儲存';

  @override
  String get saveChanges => '儲存修改';

  @override
  String get clothingImage => '衣物图片';

  @override
  String get changeImage => '更換圖片';

  @override
  String get reselectImage => '重新選擇圖片';

  @override
  String get friendRequests => '好友申請';

  @override
  String get requestRejected => '已拒絕好友申請';

  @override
  String becameFriends(String username) {
    return '$username 已成為你的好友';
  }

  @override
  String get noFriendRequests => '暫無好友申請';

  @override
  String get accept => '同意';

  @override
  String get reject => '拒绝';

  @override
  String get onlyFriendsCanRecommend => '只有好友之間才能進行衣物推薦';

  @override
  String get selectAtLeastOne => '請至少選擇一件衣物';

  @override
  String get recommendationSent => '衣物推薦已傳送';

  @override
  String friendWardrobe(String username) {
    return '$username的衣櫃';
  }

  @override
  String get recommend => '推荐';

  @override
  String get selectClothing => '請選擇衣物';

  @override
  String recommendItemCount(int count) {
    return '推荐 $count 件衣物';
  }

  @override
  String get noPublicClothing => '這個衣櫃暫時沒有公開衣物';

  @override
  String get onlyPublicVisible => '只有設定為 Public 的衣物才能被好友看到。';

  @override
  String recommendationFor(String username) {
    return '给 $username 的推荐';
  }

  @override
  String selectedItems(int count) {
    return '已选择 $count 件衣物';
  }

  @override
  String get recommendationMessageHint => '留一句話吧，例如：這星期天氣轉涼了，記得穿這些衣服。';

  @override
  String get recommendationMessageRequired => '請輸入推薦留言';

  @override
  String get sendRecommendation => '傳送推薦';

  @override
  String get recommendationHistory => '推薦紀錄';

  @override
  String get searchUserOrEmail => '搜尋使用者名稱或電子郵件';

  @override
  String get noUserFound => '找不到使用者';

  @override
  String get trySearchUserOrEmail => '可以嘗試搜尋使用者名稱或電子郵件';

  @override
  String get noFriends => '还没有好友';

  @override
  String get searchAndAddFriends => '搜尋使用者並新增好友吧';

  @override
  String get statusFriend => '好友';

  @override
  String get statusRequested => '已申請';

  @override
  String get statusPending => '待處理';

  @override
  String get receivedRecommendations => '收到的推薦';

  @override
  String get sentRecommendations => '發出的推薦';

  @override
  String get noReceivedRecommendations => '还没有收到推荐';

  @override
  String get receivedRecommendationsHint => '好友傳送給你的衣物推薦會出現在這裡';

  @override
  String get noSentRecommendations => '还没有发出推荐';

  @override
  String get sentRecommendationsHint => '你傳送給好友的衣物推薦會出現在這裡';

  @override
  String get read => '已读';

  @override
  String get unread => '未读';

  @override
  String get recipientRead => '对方已读';

  @override
  String get recipientUnread => '对方未读';

  @override
  String clothingCount(int count) {
    return '$count 件衣物';
  }

  @override
  String sentTo(String username) {
    return '傳送給 $username';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String recommendationFrom(String username) {
    return '來自 $username 的推薦';
  }

  @override
  String recommendationTo(String username) {
    return '傳送給 $username 的推薦';
  }

  @override
  String get recommendedClothing => '推荐衣物';

  @override
  String itemCount(int count) {
    return '$count 件';
  }

  @override
  String get recommendationClothingMissing => '推薦的衣物已經不存在了';

  @override
  String get userProfile => '使用者介紹';

  @override
  String get addFriend => '新增好友';

  @override
  String get introduceYourself => '介紹一下自己吧';

  @override
  String get sendRequest => '傳送申請';

  @override
  String get requestSentTitle => '申請已傳送';

  @override
  String get requestSentBody => '好友申請已經傳送，等待對方同意。';

  @override
  String get setRemark => '設定備註';

  @override
  String get remarkHint => '請輸入好友備註';

  @override
  String get deleteFriend => '刪除好友';

  @override
  String deleteFriendConfirm(String username) {
    return '確定要刪除 $username 嗎？';
  }

  @override
  String get pendingCancelNotFound => '找不到待取消的好友申請';

  @override
  String get alreadyFriends => '你们已经是好友';

  @override
  String get friendRequestSent => '好友申請已傳送';

  @override
  String get waitingApproval => '等待对方同意';

  @override
  String get receivedFriendRequest => '收到好友申請';

  @override
  String get friendRequestReceivedSubtitle => '對方已經向你傳送好友申請';

  @override
  String get notFriendsYet => '还不是好友';

  @override
  String get canSendFriendRequest => '可以傳送好友申請';

  @override
  String get cancelRequest => '取消申請';

  @override
  String get processFriendRequests => '前往處理好友申請';

  @override
  String get viewWardrobe => '查看衣櫃';

  @override
  String remarkValue(String remark) {
    return '備註：$remark';
  }

  @override
  String get removeFriend => '刪除好友';

  @override
  String recommendationLoadFailed(String error) {
    return '推薦載入失敗：$error';
  }

  @override
  String recommendationLetterFrom(String username) {
    return '來自 $username 的推薦信';
  }

  @override
  String get tapOpenLetter => '點擊拆開這封推薦信';

  @override
  String unreadRecommendations(int count) {
    return '還有 $count 封未讀推薦';
  }

  @override
  String get receivedClothingRecommendation => '你收到一封衣物推薦';

  @override
  String senderSentLetter(String username) {
    return '$username 給你寄來了一封信';
  }

  @override
  String get openLetter => '拆開信件';

  @override
  String get storingLetter => '正在收好';

  @override
  String get keepLetter => '收好這封信';

  @override
  String get sessionExpired => '登入狀態已失效，請重新登入';

  @override
  String get userNotFound => '使用者不存在';

  @override
  String get emailAlreadyExists => '此電子郵件已經註冊';

  @override
  String get emailOrUsernameAlreadyExists => '此電子郵件或使用者名稱已被使用';

  @override
  String get invalidEmailOrPassword => '電子郵件或密碼錯誤';

  @override
  String get usernameAlreadyExists => '此使用者名稱已被使用';

  @override
  String get usernameRequired => '使用者名稱不能為空';

  @override
  String get passwordMaxLength => '密码不能超过 128 位';

  @override
  String get cannotAddSelf => '不能將自己加為好友';

  @override
  String get userAlreadyFriend => '对方已经是你的好友';

  @override
  String get friendRequestAlreadySent => '好友申請已經傳送';

  @override
  String get userAlreadySentRequest => '對方已經向你傳送好友申請，請先處理';

  @override
  String get friendRequestNotFound => '好友申請不存在或已經處理';

  @override
  String get friendNotFound => '好友關係不存在';

  @override
  String get userNotFriend => '對方不是你的好友';

  @override
  String get friendRequestMessageRequired => '請輸入好友申請資訊';

  @override
  String get cannotAccessSelfFriendApi => '不能透過好友介面存取自己的衣櫃';

  @override
  String get friendClothingUnavailable => '好友衣物不存在或不可見';

  @override
  String get clothingImageNotFound => '衣物图片不存在';

  @override
  String get cannotRecommendSelf => '不能給自己傳送推薦';

  @override
  String get onlyRecommendFriends => '只能給好友傳送衣物推薦';

  @override
  String get recommendationItemsUnavailable => '部分衣物已經不存在、已設為私密或不屬於該好友';

  @override
  String get recommendationMessageTooLong => '推薦留言不能超過 200 個字元';

  @override
  String get onlyFriendWardrobeItems => '只能推薦好友衣櫃中的衣物';

  @override
  String get onlyPublicItems => '只能推薦好友公開的衣物';

  @override
  String get recommendationNotFound => '推薦不存在或你沒有查看權限';

  @override
  String get recommendationItemNotFound => '推薦中的衣物已經不存在';

  @override
  String get recommendationImageNotFound => '推薦中的衣物圖片已經不存在';

  @override
  String get serverDataInvalid => '伺服器回傳的資料格式不正確';

  @override
  String get accountSection => '帳戶';

  @override
  String get deleteAccount => '註銷帳戶';

  @override
  String get deleteAccountSubtitle => '永久刪除帳戶及相關資料';

  @override
  String get deleteAccountDescription => '註銷後，你的個人資料、衣物、好友關係和推薦記錄將被永久刪除，且無法復原。';

  @override
  String deleteAccountEmailPrompt(String email) {
    return '請輸入電子郵件 $email 以確認註銷帳戶。';
  }

  @override
  String get deleteAccountEmailHint => '請輸入目前帳戶電子郵件';

  @override
  String get forgotPasswordTitle => '忘記密碼';

  @override
  String get resetYourPassword => '重設密碼';

  @override
  String get forgotPasswordSubtitle => '輸入註冊電子郵件，我們會向你的信箱傳送驗證碼';

  @override
  String get passwordResetCodeSent => '如果此電子郵件已註冊，驗證碼已傳送，請檢查信箱';

  @override
  String get newPassword => '新密碼';

  @override
  String get newPasswordHint => '請輸入新密碼（至少 8 位）';

  @override
  String get newPasswordRequired => '請輸入新密碼';

  @override
  String get confirmPassword => '確認新密碼';

  @override
  String get confirmPasswordHint => '請再次輸入新密碼';

  @override
  String get confirmPasswordRequired => '請確認新密碼';

  @override
  String get passwordsDoNotMatch => '兩次輸入的密碼不一致';

  @override
  String get resetPassword => '重設密碼';

  @override
  String get passwordResetSuccess => '密碼重設成功，請使用新密碼登入';

  @override
  String get invalidOrExpiredVerificationCode => '驗證碼無效或已過期';

  @override
  String get tooManyVerificationAttempts => '驗證碼錯誤次數過多，請重新取得驗證碼';

  @override
  String get verificationCodeRequestTooFrequent => '請求過於頻繁，請稍後再取得驗證碼';

  @override
  String get verificationEmailSendFailed => '驗證碼郵件傳送失敗，請稍後再試';

  @override
  String get newPasswordMustBeDifferent => '新密碼不能與目前密碼相同';

  @override
  String get currentPasswordIncorrect => '目前密碼錯誤';
}
