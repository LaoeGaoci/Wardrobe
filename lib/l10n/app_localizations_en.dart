// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wardrobe';

  @override
  String get wardrobe => 'Wardrobe';

  @override
  String get friends => 'Friends';

  @override
  String get profile => 'Me';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get reload => 'Reload';

  @override
  String get close => 'Close';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive outfit reminders';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use dark appearance';

  @override
  String get appSection => 'App';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get aboutDescription => 'Your personal digital wardrobe.';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get createAccount => 'Create account';

  @override
  String get loginSubtitle =>
      'Sign in to your wardrobe and keep managing your outfits.';

  @override
  String get registerSubtitle =>
      'Create an account and start organizing your personal wardrobe.';

  @override
  String get login => 'Log In';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get emailRequired => 'Please enter your email';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get verificationCodeHint => 'Enter the verification code';

  @override
  String get getVerificationCode => 'Get code';

  @override
  String get verificationCodeRequired => 'Please enter the verification code';

  @override
  String get invalidVerificationCode => 'Invalid verification code';

  @override
  String get verificationCodeLength => 'The verification code must be 6 digits';

  @override
  String get verificationCodeSent => 'Verification code sent';

  @override
  String get password => 'Password';

  @override
  String get passwordHintLogin => 'Enter your password';

  @override
  String get passwordHintRegister => 'Set a password (at least 8 characters)';

  @override
  String get passwordRequired => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccountRegister => 'Don\'t have an account? Register now';

  @override
  String get haveAccountLogin => 'Already have an account? Back to login';

  @override
  String get operationFailed => 'Operation failed. Please try again later.';

  @override
  String get myWardrobe => 'My Wardrobe';

  @override
  String get searchClothing => 'Search clothes';

  @override
  String get noClothing => 'No clothes yet';

  @override
  String get rearCameraNotFound => 'Rear camera not found';

  @override
  String get wardrobeLoadFailed => 'Failed to load wardrobe';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryTop => 'Tops';

  @override
  String get categoryCoat => 'Coats';

  @override
  String get categoryDownJacket => 'Down Jackets';

  @override
  String get categoryPants => 'Pants';

  @override
  String get categoryHat => 'Hats';

  @override
  String get categoryShoes => 'Shoes';

  @override
  String get categoryAccessories => 'Accessories';

  @override
  String get seasonSpring => 'Spring';

  @override
  String get seasonSummer => 'Summer';

  @override
  String get seasonAutumn => 'Autumn';

  @override
  String get seasonWinter => 'Winter';

  @override
  String get captureClothing => 'Photograph Clothing';

  @override
  String cameraOpenFailed(String error) {
    return 'Unable to open camera: $error';
  }

  @override
  String takePhotoFailed(String error) {
    return 'Failed to take photo: $error';
  }

  @override
  String get addClothing => 'Add Clothing';

  @override
  String get name => 'Name';

  @override
  String get nameExample => 'e.g. White T-shirt';

  @override
  String get clothingNameRequired => 'Please enter a clothing name';

  @override
  String get nameMax100 => 'Name cannot exceed 100 characters';

  @override
  String get brand => 'Brand';

  @override
  String get optional => 'Optional';

  @override
  String get leaveBlank => 'Optional';

  @override
  String get brandMax100 => 'Brand cannot exceed 100 characters';

  @override
  String get category => 'Category';

  @override
  String get color => 'Color';

  @override
  String get colorExample => 'e.g. White';

  @override
  String get colorRequired => 'Please enter a color';

  @override
  String get season => 'Season';

  @override
  String get price => 'Price';

  @override
  String get validPrice => 'Please enter a valid price';

  @override
  String get createClothing => 'Create Clothing';

  @override
  String get retakePhoto => 'Retake Photo';

  @override
  String get visibility => 'Visibility';

  @override
  String get privateLabel => 'Private';

  @override
  String get privateSubtitle => 'Only you can see it';

  @override
  String get publicLabel => 'Public';

  @override
  String get publicSubtitle => 'Friends can see it';

  @override
  String saveFailed(String error) {
    return 'Failed to save: $error';
  }

  @override
  String get clothingDetails => 'Clothing Details';

  @override
  String get notSet => 'Not set';

  @override
  String get editCard => 'Edit Card';

  @override
  String get replaceClothingImage => 'Replace clothing image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String imageSelectFailed(String error) {
    return 'Failed to select image: $error';
  }

  @override
  String get saving => 'Saving';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get clothingImage => 'Clothing Image';

  @override
  String get changeImage => 'Change Image';

  @override
  String get reselectImage => 'Choose Another Image';

  @override
  String get friendRequests => 'Friend Requests';

  @override
  String get requestRejected => 'Friend request rejected';

  @override
  String becameFriends(String username) {
    return '$username is now your friend';
  }

  @override
  String get noFriendRequests => 'No friend requests';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get onlyFriendsCanRecommend =>
      'Only friends can send clothing recommendations';

  @override
  String get selectAtLeastOne => 'Please select at least one clothing item';

  @override
  String get recommendationSent => 'Clothing recommendation sent';

  @override
  String friendWardrobe(String username) {
    return '$username\'s Wardrobe';
  }

  @override
  String get recommend => 'Recommend';

  @override
  String get selectClothing => 'Select clothing';

  @override
  String recommendItemCount(int count) {
    return 'Recommend $count items';
  }

  @override
  String get noPublicClothing => 'This wardrobe has no public clothing yet';

  @override
  String get onlyPublicVisible =>
      'Only Public clothing can be viewed by friends.';

  @override
  String recommendationFor(String username) {
    return 'Recommendation for $username';
  }

  @override
  String selectedItems(int count) {
    return '$count items selected';
  }

  @override
  String get recommendationMessageHint =>
      'Leave a note, for example: It\'s getting cooler this week, remember to wear these.';

  @override
  String get recommendationMessageRequired =>
      'Please enter a recommendation message';

  @override
  String get sendRecommendation => 'Send Recommendation';

  @override
  String get recommendationHistory => 'Recommendation History';

  @override
  String get searchUserOrEmail => 'Search username or email';

  @override
  String get noUserFound => 'No users found';

  @override
  String get trySearchUserOrEmail => 'Try searching by username or email';

  @override
  String get noFriends => 'No friends yet';

  @override
  String get searchAndAddFriends => 'Search for users and add some friends';

  @override
  String get statusFriend => 'Friend';

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusPending => 'Pending';

  @override
  String get receivedRecommendations => 'Received';

  @override
  String get sentRecommendations => 'Sent';

  @override
  String get noReceivedRecommendations => 'No recommendations received yet';

  @override
  String get receivedRecommendationsHint =>
      'Clothing recommendations from friends will appear here';

  @override
  String get noSentRecommendations => 'No recommendations sent yet';

  @override
  String get sentRecommendationsHint =>
      'Clothing recommendations you sent to friends will appear here';

  @override
  String get read => 'Read';

  @override
  String get unread => 'Unread';

  @override
  String get recipientRead => 'Read by recipient';

  @override
  String get recipientUnread => 'Unread by recipient';

  @override
  String clothingCount(int count) {
    return '$count items';
  }

  @override
  String sentTo(String username) {
    return 'Sent to $username';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count minutes ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count hours ago';
  }

  @override
  String recommendationFrom(String username) {
    return 'Recommendation from $username';
  }

  @override
  String recommendationTo(String username) {
    return 'Recommendation sent to $username';
  }

  @override
  String get recommendedClothing => 'Recommended Clothing';

  @override
  String itemCount(int count) {
    return '$count items';
  }

  @override
  String get recommendationClothingMissing =>
      'The recommended clothing no longer exists';

  @override
  String get userProfile => 'User Profile';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get introduceYourself => 'Introduce yourself';

  @override
  String get sendRequest => 'Send Request';

  @override
  String get requestSentTitle => 'Request Sent';

  @override
  String get requestSentBody =>
      'Your friend request has been sent. Waiting for approval.';

  @override
  String get setRemark => 'Set Remark';

  @override
  String get remarkHint => 'Enter a remark for this friend';

  @override
  String get deleteFriend => 'Remove Friend';

  @override
  String deleteFriendConfirm(String username) {
    return 'Are you sure you want to remove $username?';
  }

  @override
  String get pendingCancelNotFound => 'No pending friend request was found';

  @override
  String get alreadyFriends => 'You are already friends';

  @override
  String get friendRequestSent => 'Friend request sent';

  @override
  String get waitingApproval => 'Waiting for approval';

  @override
  String get receivedFriendRequest => 'Friend request received';

  @override
  String get friendRequestReceivedSubtitle =>
      'This user has sent you a friend request';

  @override
  String get notFriendsYet => 'Not friends yet';

  @override
  String get canSendFriendRequest => 'You can send a friend request';

  @override
  String get cancelRequest => 'Cancel Request';

  @override
  String get processFriendRequests => 'Review Friend Requests';

  @override
  String get viewWardrobe => 'View Wardrobe';

  @override
  String remarkValue(String remark) {
    return 'Remark: $remark';
  }

  @override
  String get removeFriend => 'Remove Friend';

  @override
  String recommendationLoadFailed(String error) {
    return 'Failed to load recommendations: $error';
  }

  @override
  String recommendationLetterFrom(String username) {
    return 'Recommendation letter from $username';
  }

  @override
  String get tapOpenLetter => 'Tap to open this recommendation';

  @override
  String unreadRecommendations(int count) {
    return '$count unread recommendations';
  }

  @override
  String get receivedClothingRecommendation =>
      'You received a clothing recommendation';

  @override
  String senderSentLetter(String username) {
    return '$username sent you a letter';
  }

  @override
  String get openLetter => 'Open Letter';

  @override
  String get storingLetter => 'Saving';

  @override
  String get keepLetter => 'Keep This Letter';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get userNotFound => 'User not found';

  @override
  String get emailAlreadyExists => 'This email is already registered';

  @override
  String get emailOrUsernameAlreadyExists =>
      'This email or username is already in use';

  @override
  String get invalidEmailOrPassword => 'Incorrect email or password';

  @override
  String get usernameAlreadyExists => 'This username is already in use';

  @override
  String get usernameRequired => 'Username cannot be empty';

  @override
  String get passwordMaxLength => 'Password cannot exceed 128 characters';

  @override
  String get cannotAddSelf => 'You cannot add yourself as a friend';

  @override
  String get userAlreadyFriend => 'This user is already your friend';

  @override
  String get friendRequestAlreadySent => 'Friend request already sent';

  @override
  String get userAlreadySentRequest =>
      'This user has already sent you a friend request. Please review it first.';

  @override
  String get friendRequestNotFound =>
      'Friend request not found or already processed';

  @override
  String get friendNotFound => 'Friend relationship not found';

  @override
  String get userNotFriend => 'This user is not your friend';

  @override
  String get friendRequestMessageRequired =>
      'Please enter a friend request message';

  @override
  String get cannotAccessSelfFriendApi =>
      'You cannot access your own wardrobe through the friend API';

  @override
  String get friendClothingUnavailable =>
      'Friend clothing does not exist or is not visible';

  @override
  String get clothingImageNotFound => 'Clothing image not found';

  @override
  String get cannotRecommendSelf =>
      'You cannot send a recommendation to yourself';

  @override
  String get onlyRecommendFriends =>
      'You can only recommend clothing to friends';

  @override
  String get recommendationItemsUnavailable =>
      'Some clothing no longer exists, is private, or does not belong to this friend';

  @override
  String get recommendationMessageTooLong =>
      'Recommendation message cannot exceed 200 characters';

  @override
  String get onlyFriendWardrobeItems =>
      'You can only recommend clothing from your friend\'s wardrobe';

  @override
  String get onlyPublicItems => 'You can only recommend public clothing';

  @override
  String get recommendationNotFound =>
      'Recommendation not found or you do not have permission to view it';

  @override
  String get recommendationItemNotFound =>
      'A recommended clothing item no longer exists';

  @override
  String get recommendationImageNotFound =>
      'A recommended clothing image no longer exists';

  @override
  String get serverDataInvalid => 'The server returned invalid data';

  @override
  String get accountSection => 'Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountSubtitle =>
      'Permanently delete your account and related data';

  @override
  String get deleteAccountDescription =>
      'Your profile, clothing, friendships, and recommendation history will be permanently deleted. This action cannot be undone.';

  @override
  String deleteAccountEmailPrompt(String email) {
    return 'Enter $email to confirm account deletion.';
  }

  @override
  String get deleteAccountEmailHint => 'Enter your account email';
}
