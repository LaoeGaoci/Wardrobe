import 'package:flutter/widgets.dart';

import 'l10n.dart';

/// Localizes the stable API errors and the Chinese friendly messages that
/// FriendService / RecommendationService currently expose.
///
/// Unknown errors are intentionally returned unchanged so useful server
/// diagnostics are not silently discarded.
String localizedErrorMessage(BuildContext context, String message) {
  final l10n = context.l10n;

  switch (message) {
    case 'Unauthorized':
    case '登录状态已失效，请重新登录':
      return l10n.sessionExpired;

    case 'User not found':
    case '用户不存在':
    case '接收推荐的用户不存在':
      return l10n.userNotFound;

    case 'Invalid email address':
    case '请输入有效的邮箱地址':
      return l10n.invalidEmail;

    case 'Invalid verification code':
    case '验证码错误':
      return l10n.invalidVerificationCode;

    case 'Email already exists':
    case '该邮箱已经注册':
      return l10n.emailAlreadyExists;

    case 'Email or username already exists':
    case '该邮箱或用户名已经被使用':
      return l10n.emailOrUsernameAlreadyExists;

    case 'Invalid email or password':
    case '邮箱或密码错误':
      return l10n.invalidEmailOrPassword;

    case 'Username already exists':
    case '该用户名已被使用':
      return l10n.usernameAlreadyExists;

    case 'Username cannot be empty':
    case 'Username is required':
    case '用户名不能为空':
      return l10n.usernameRequired;

    case 'Password must be at least 8 characters':
    case '密码至少需要 8 位':
      return l10n.passwordMinLength;

    case 'Password must be at most 128 characters':
    case '密码不能超过 128 位':
      return l10n.passwordMaxLength;

    case 'Cannot add yourself as a friend':
    case '不能添加自己为好友':
      return l10n.cannotAddSelf;

    case 'User is already your friend':
    case '对方已经是你的好友':
      return l10n.userAlreadyFriend;

    case 'Friend request already sent':
    case '好友申请已经发送':
      return l10n.friendRequestAlreadySent;

    case 'This user has already sent you a friend request':
    case '对方已经向你发送好友申请，请先处理':
      return l10n.userAlreadySentRequest;

    case 'Friend request not found':
    case '好友申请不存在或已经处理':
      return l10n.friendRequestNotFound;

    case 'Friend not found':
    case '好友关系不存在':
      return l10n.friendNotFound;

    case 'User is not your friend':
    case '对方不是你的好友':
      return l10n.userNotFriend;

    case 'Friend request message is required':
    case '请输入好友申请信息':
      return l10n.friendRequestMessageRequired;

    case 'Cannot access yourself through friend API':
    case '不能通过好友接口访问自己的衣柜':
      return l10n.cannotAccessSelfFriendApi;

    case 'Clothing not found':
    case '好友衣物不存在或不可见':
      return l10n.friendClothingUnavailable;

    case 'Clothing image not found':
    case '衣物图片不存在':
      return l10n.clothingImageNotFound;

    case 'Cannot recommend clothing to yourself':
    case '不能给自己发送推荐':
      return l10n.cannotRecommendSelf;

    case 'You can only recommend clothing to friends':
    case '只能给好友发送衣物推荐':
      return l10n.onlyRecommendFriends;

    case 'One or more clothing items are unavailable':
    case '部分衣物已经不存在、已设为私密或不属于该好友':
      return l10n.recommendationItemsUnavailable;

    case 'At least one clothing item is required':
    case '请至少选择一件衣物':
      return l10n.selectAtLeastOne;

    case 'Recommendation message is required':
    case '请输入推荐留言':
      return l10n.recommendationMessageRequired;

    case '推荐留言不能超过 200 个字符':
      return l10n.recommendationMessageTooLong;

    case '只能推荐好友衣柜中的衣物':
      return l10n.onlyFriendWardrobeItems;

    case '只能推荐好友公开的衣物':
      return l10n.onlyPublicItems;

    case 'Recommendation not found':
    case '推荐不存在或你没有查看权限':
      return l10n.recommendationNotFound;

    case 'Recommendation clothing not found':
    case '推荐中的衣物已经不存在':
      return l10n.recommendationItemNotFound;

    case 'Recommendation clothing image not found':
    case '推荐中的衣物图片已经不存在':
      return l10n.recommendationImageNotFound;

    case '服务器返回的衣物列表格式不正确':
    case '服务器返回的衣物数据格式不正确':
    case '服务器返回的好友列表格式不正确':
    case '服务器返回的好友申请格式不正确':
    case '服务器返回的好友衣柜格式不正确':
    case '服务器返回的好友数据格式不正确':
    case '服务器返回的推荐列表格式不正确':
    case '服务器返回的推荐数据格式不正确':
    case '服务器返回的未读推荐数量格式不正确':
      return l10n.serverDataInvalid;

    default:
      return message;
  }
}
