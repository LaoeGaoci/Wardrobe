import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get appTitle;

  /// No description provided for @wardrobe.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get wardrobe;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get profile;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive friend requests, clothing recommendations and system notifications'**
  String get notificationsSubtitle;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission is required to receive friend requests, clothing recommendations and system notifications.'**
  String get notificationPermissionRequired;

  /// No description provided for @openSystemNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open system settings'**
  String get openSystemNotificationSettings;

  /// No description provided for @notificationSettingsOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Android app settings. Please enable Wardrobe notifications manually in system settings.'**
  String get notificationSettingsOpenFailed;

  /// No description provided for @notificationFriendRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'New friend request'**
  String get notificationFriendRequestTitle;

  /// No description provided for @notificationFriendRequestBody.
  ///
  /// In en, this message translates to:
  /// **'You received a new friend request'**
  String get notificationFriendRequestBody;

  /// No description provided for @notificationRecommendationTitle.
  ///
  /// In en, this message translates to:
  /// **'New clothing recommendation'**
  String get notificationRecommendationTitle;

  /// No description provided for @notificationRecommendationBody.
  ///
  /// In en, this message translates to:
  /// **'A friend sent you a clothing recommendation'**
  String get notificationRecommendationBody;

  /// No description provided for @notificationSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'Wardrobe'**
  String get notificationSystemTitle;

  /// No description provided for @notificationSystemBody.
  ///
  /// In en, this message translates to:
  /// **'You received a new system notification'**
  String get notificationSystemBody;

  /// No description provided for @notificationOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open notification content. Please try again later.'**
  String get notificationOpenFailed;

  /// No description provided for @systemNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'System notification'**
  String get systemNotificationTitle;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose app appearance'**
  String get themeSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal digital wardrobe.'**
  String get aboutDescription;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your wardrobe and keep managing your outfits.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account and start organizing your personal wardrobe.'**
  String get registerSubtitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @verificationCode.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verificationCode;

  /// No description provided for @verificationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code'**
  String get verificationCodeHint;

  /// No description provided for @getVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Get code'**
  String get getVerificationCode;

  /// No description provided for @verificationCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get verificationCodeRequired;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// No description provided for @verificationCodeLength.
  ///
  /// In en, this message translates to:
  /// **'The verification code must be 6 digits'**
  String get verificationCodeLength;

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent. Please check your inbox'**
  String get verificationCodeSent;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHintLogin;

  /// No description provided for @passwordHintRegister.
  ///
  /// In en, this message translates to:
  /// **'Set a password (at least 8 characters)'**
  String get passwordHintRegister;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccountRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register now'**
  String get noAccountRegister;

  /// No description provided for @haveAccountLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Back to login'**
  String get haveAccountLogin;

  /// No description provided for @operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please try again later.'**
  String get operationFailed;

  /// No description provided for @myWardrobe.
  ///
  /// In en, this message translates to:
  /// **'My Wardrobe'**
  String get myWardrobe;

  /// No description provided for @searchClothing.
  ///
  /// In en, this message translates to:
  /// **'Search clothes'**
  String get searchClothing;

  /// No description provided for @noClothing.
  ///
  /// In en, this message translates to:
  /// **'No clothes yet'**
  String get noClothing;

  /// No description provided for @rearCameraNotFound.
  ///
  /// In en, this message translates to:
  /// **'Rear camera not found'**
  String get rearCameraNotFound;

  /// No description provided for @wardrobeLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wardrobe'**
  String get wardrobeLoadFailed;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryDownJacket.
  ///
  /// In en, this message translates to:
  /// **'Down Jackets'**
  String get categoryDownJacket;

  /// No description provided for @categoryHat.
  ///
  /// In en, this message translates to:
  /// **'Hats'**
  String get categoryHat;

  /// No description provided for @seasonAll.
  ///
  /// In en, this message translates to:
  /// **'All Seasons'**
  String get seasonAll;

  /// No description provided for @seasonSpringAutumn.
  ///
  /// In en, this message translates to:
  /// **'Spring / Autumn'**
  String get seasonSpringAutumn;

  /// No description provided for @seasonAutumnWinter.
  ///
  /// In en, this message translates to:
  /// **'Autumn / Winter'**
  String get seasonAutumnWinter;

  /// No description provided for @seasonSpring.
  ///
  /// In en, this message translates to:
  /// **'Spring'**
  String get seasonSpring;

  /// No description provided for @seasonSummer.
  ///
  /// In en, this message translates to:
  /// **'Summer'**
  String get seasonSummer;

  /// No description provided for @seasonAutumn.
  ///
  /// In en, this message translates to:
  /// **'Autumn'**
  String get seasonAutumn;

  /// No description provided for @seasonWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get seasonWinter;

  /// No description provided for @captureClothing.
  ///
  /// In en, this message translates to:
  /// **'Photograph Clothing'**
  String get captureClothing;

  /// No description provided for @cameraOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to open camera: {error}'**
  String cameraOpenFailed(String error);

  /// No description provided for @takePhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to take photo: {error}'**
  String takePhotoFailed(String error);

  /// No description provided for @addClothing.
  ///
  /// In en, this message translates to:
  /// **'Add Clothing'**
  String get addClothing;

  /// No description provided for @brand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get brand;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @leaveBlank.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get leaveBlank;

  /// No description provided for @brandMax100.
  ///
  /// In en, this message translates to:
  /// **'Brand cannot exceed 100 characters'**
  String get brandMax100;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @colorExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. White'**
  String get colorExample;

  /// No description provided for @colorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a color'**
  String get colorRequired;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Season'**
  String get season;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @validPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get validPrice;

  /// No description provided for @createClothing.
  ///
  /// In en, this message translates to:
  /// **'Create Clothing'**
  String get createClothing;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get retakePhoto;

  /// No description provided for @visibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get visibility;

  /// No description provided for @privateLabel.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get privateLabel;

  /// No description provided for @privateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only you can see it'**
  String get privateSubtitle;

  /// No description provided for @publicLabel.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get publicLabel;

  /// No description provided for @publicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Friends can see it'**
  String get publicSubtitle;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save: {error}'**
  String saveFailed(String error);

  /// No description provided for @clothingDetails.
  ///
  /// In en, this message translates to:
  /// **'Clothing Details'**
  String get clothingDetails;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'Edit Card'**
  String get editCard;

  /// No description provided for @replaceClothingImage.
  ///
  /// In en, this message translates to:
  /// **'Replace clothing image'**
  String get replaceClothingImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @imageSelectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image: {error}'**
  String imageSelectFailed(String error);

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get saving;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @clothingImage.
  ///
  /// In en, this message translates to:
  /// **'Clothing Image'**
  String get clothingImage;

  /// No description provided for @changeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get changeImage;

  /// No description provided for @reselectImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Another Image'**
  String get reselectImage;

  /// No description provided for @friendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get friendRequests;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Friend request rejected'**
  String get requestRejected;

  /// No description provided for @becameFriends.
  ///
  /// In en, this message translates to:
  /// **'{username} is now your friend'**
  String becameFriends(String username);

  /// No description provided for @noFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'No friend requests'**
  String get noFriendRequests;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @onlyFriendsCanRecommend.
  ///
  /// In en, this message translates to:
  /// **'Only friends can send clothing recommendations'**
  String get onlyFriendsCanRecommend;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one clothing item'**
  String get selectAtLeastOne;

  /// No description provided for @recommendationSent.
  ///
  /// In en, this message translates to:
  /// **'Clothing recommendation sent'**
  String get recommendationSent;

  /// No description provided for @friendWardrobe.
  ///
  /// In en, this message translates to:
  /// **'{username}\'s Wardrobe'**
  String friendWardrobe(String username);

  /// No description provided for @recommend.
  ///
  /// In en, this message translates to:
  /// **'Recommend'**
  String get recommend;

  /// No description provided for @selectClothing.
  ///
  /// In en, this message translates to:
  /// **'Select clothing'**
  String get selectClothing;

  /// No description provided for @recommendItemCount.
  ///
  /// In en, this message translates to:
  /// **'Recommend {count} items'**
  String recommendItemCount(int count);

  /// No description provided for @noPublicClothing.
  ///
  /// In en, this message translates to:
  /// **'This wardrobe has no public clothing yet'**
  String get noPublicClothing;

  /// No description provided for @onlyPublicVisible.
  ///
  /// In en, this message translates to:
  /// **'Only Public clothing can be viewed by friends.'**
  String get onlyPublicVisible;

  /// No description provided for @recommendationFor.
  ///
  /// In en, this message translates to:
  /// **'Recommendation for {username}'**
  String recommendationFor(String username);

  /// No description provided for @selectedItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items selected'**
  String selectedItems(int count);

  /// No description provided for @recommendationMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Leave a note, for example: It\'s getting cooler this week, remember to wear these.'**
  String get recommendationMessageHint;

  /// No description provided for @recommendationMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a recommendation message'**
  String get recommendationMessageRequired;

  /// No description provided for @sendRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Send Recommendation'**
  String get sendRecommendation;

  /// No description provided for @recommendationHistory.
  ///
  /// In en, this message translates to:
  /// **'Recommendation History'**
  String get recommendationHistory;

  /// No description provided for @searchUserOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Search username or email'**
  String get searchUserOrEmail;

  /// No description provided for @noUserFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUserFound;

  /// No description provided for @trySearchUserOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Try searching by username or email'**
  String get trySearchUserOrEmail;

  /// No description provided for @noFriends.
  ///
  /// In en, this message translates to:
  /// **'No friends yet'**
  String get noFriends;

  /// No description provided for @searchAndAddFriends.
  ///
  /// In en, this message translates to:
  /// **'Search for users and add some friends'**
  String get searchAndAddFriends;

  /// No description provided for @statusFriend.
  ///
  /// In en, this message translates to:
  /// **'Friend'**
  String get statusFriend;

  /// No description provided for @statusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @receivedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedRecommendations;

  /// No description provided for @sentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sentRecommendations;

  /// No description provided for @noReceivedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations received yet'**
  String get noReceivedRecommendations;

  /// No description provided for @receivedRecommendationsHint.
  ///
  /// In en, this message translates to:
  /// **'Clothing recommendations from friends will appear here'**
  String get receivedRecommendationsHint;

  /// No description provided for @noSentRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations sent yet'**
  String get noSentRecommendations;

  /// No description provided for @sentRecommendationsHint.
  ///
  /// In en, this message translates to:
  /// **'Clothing recommendations you sent to friends will appear here'**
  String get sentRecommendationsHint;

  /// No description provided for @read.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// No description provided for @unread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get unread;

  /// No description provided for @recipientRead.
  ///
  /// In en, this message translates to:
  /// **'Read by recipient'**
  String get recipientRead;

  /// No description provided for @recipientUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread by recipient'**
  String get recipientUnread;

  /// No description provided for @clothingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String clothingCount(int count);

  /// No description provided for @sentTo.
  ///
  /// In en, this message translates to:
  /// **'Sent to {username}'**
  String sentTo(String username);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hours ago'**
  String hoursAgo(int count);

  /// No description provided for @recommendationFrom.
  ///
  /// In en, this message translates to:
  /// **'Recommendation from {username}'**
  String recommendationFrom(String username);

  /// No description provided for @recommendationTo.
  ///
  /// In en, this message translates to:
  /// **'Recommendation sent to {username}'**
  String recommendationTo(String username);

  /// No description provided for @recommendedClothing.
  ///
  /// In en, this message translates to:
  /// **'Recommended Clothing'**
  String get recommendedClothing;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @recommendationClothingMissing.
  ///
  /// In en, this message translates to:
  /// **'The recommended clothing no longer exists'**
  String get recommendationClothingMissing;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @addFriend.
  ///
  /// In en, this message translates to:
  /// **'Add Friend'**
  String get addFriend;

  /// No description provided for @introduceYourself.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself'**
  String get introduceYourself;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send Request'**
  String get sendRequest;

  /// No description provided for @requestSentTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Sent'**
  String get requestSentTitle;

  /// No description provided for @requestSentBody.
  ///
  /// In en, this message translates to:
  /// **'Your friend request has been sent. Waiting for approval.'**
  String get requestSentBody;

  /// No description provided for @setRemark.
  ///
  /// In en, this message translates to:
  /// **'Set Remark'**
  String get setRemark;

  /// No description provided for @remarkHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a remark for this friend'**
  String get remarkHint;

  /// No description provided for @deleteFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get deleteFriend;

  /// No description provided for @deleteFriendConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {username}?'**
  String deleteFriendConfirm(String username);

  /// No description provided for @pendingCancelNotFound.
  ///
  /// In en, this message translates to:
  /// **'No pending friend request was found'**
  String get pendingCancelNotFound;

  /// No description provided for @alreadyFriends.
  ///
  /// In en, this message translates to:
  /// **'You are already friends'**
  String get alreadyFriends;

  /// No description provided for @friendRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Friend request sent'**
  String get friendRequestSent;

  /// No description provided for @waitingApproval.
  ///
  /// In en, this message translates to:
  /// **'Waiting for approval'**
  String get waitingApproval;

  /// No description provided for @receivedFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'Friend request received'**
  String get receivedFriendRequest;

  /// No description provided for @friendRequestReceivedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This user has sent you a friend request'**
  String get friendRequestReceivedSubtitle;

  /// No description provided for @notFriendsYet.
  ///
  /// In en, this message translates to:
  /// **'Not friends yet'**
  String get notFriendsYet;

  /// No description provided for @canSendFriendRequest.
  ///
  /// In en, this message translates to:
  /// **'You can send a friend request'**
  String get canSendFriendRequest;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelRequest;

  /// No description provided for @processFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'Review Friend Requests'**
  String get processFriendRequests;

  /// No description provided for @viewWardrobe.
  ///
  /// In en, this message translates to:
  /// **'View Wardrobe'**
  String get viewWardrobe;

  /// No description provided for @remarkValue.
  ///
  /// In en, this message translates to:
  /// **'Remark: {remark}'**
  String remarkValue(String remark);

  /// No description provided for @removeFriend.
  ///
  /// In en, this message translates to:
  /// **'Remove Friend'**
  String get removeFriend;

  /// No description provided for @recommendationLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recommendations: {error}'**
  String recommendationLoadFailed(String error);

  /// No description provided for @recommendationLetterFrom.
  ///
  /// In en, this message translates to:
  /// **'Recommendation letter from {username}'**
  String recommendationLetterFrom(String username);

  /// No description provided for @tapOpenLetter.
  ///
  /// In en, this message translates to:
  /// **'Tap to open this recommendation'**
  String get tapOpenLetter;

  /// No description provided for @unreadRecommendations.
  ///
  /// In en, this message translates to:
  /// **'{count} unread recommendations'**
  String unreadRecommendations(int count);

  /// No description provided for @receivedClothingRecommendation.
  ///
  /// In en, this message translates to:
  /// **'You received a clothing recommendation'**
  String get receivedClothingRecommendation;

  /// No description provided for @senderSentLetter.
  ///
  /// In en, this message translates to:
  /// **'{username} sent you a letter'**
  String senderSentLetter(String username);

  /// No description provided for @openLetter.
  ///
  /// In en, this message translates to:
  /// **'Open Letter'**
  String get openLetter;

  /// No description provided for @storingLetter.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get storingLetter;

  /// No description provided for @keepLetter.
  ///
  /// In en, this message translates to:
  /// **'Keep This Letter'**
  String get keepLetter;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered'**
  String get emailAlreadyExists;

  /// No description provided for @emailOrUsernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This email or username is already in use'**
  String get emailOrUsernameAlreadyExists;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get invalidEmailOrPassword;

  /// No description provided for @usernameAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This username is already in use'**
  String get usernameAlreadyExists;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username cannot be empty'**
  String get usernameRequired;

  /// No description provided for @passwordMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Password cannot exceed 128 characters'**
  String get passwordMaxLength;

  /// No description provided for @cannotAddSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot add yourself as a friend'**
  String get cannotAddSelf;

  /// No description provided for @userAlreadyFriend.
  ///
  /// In en, this message translates to:
  /// **'This user is already your friend'**
  String get userAlreadyFriend;

  /// No description provided for @friendRequestAlreadySent.
  ///
  /// In en, this message translates to:
  /// **'Friend request already sent'**
  String get friendRequestAlreadySent;

  /// No description provided for @userAlreadySentRequest.
  ///
  /// In en, this message translates to:
  /// **'This user has already sent you a friend request. Please review it first.'**
  String get userAlreadySentRequest;

  /// No description provided for @friendRequestNotFound.
  ///
  /// In en, this message translates to:
  /// **'Friend request not found or already processed'**
  String get friendRequestNotFound;

  /// No description provided for @friendNotFound.
  ///
  /// In en, this message translates to:
  /// **'Friend relationship not found'**
  String get friendNotFound;

  /// No description provided for @userNotFriend.
  ///
  /// In en, this message translates to:
  /// **'This user is not your friend'**
  String get userNotFriend;

  /// No description provided for @friendRequestMessageRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a friend request message'**
  String get friendRequestMessageRequired;

  /// No description provided for @cannotAccessSelfFriendApi.
  ///
  /// In en, this message translates to:
  /// **'You cannot access your own wardrobe through the friend API'**
  String get cannotAccessSelfFriendApi;

  /// No description provided for @friendClothingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Friend clothing does not exist or is not visible'**
  String get friendClothingUnavailable;

  /// No description provided for @clothingImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Clothing image not found'**
  String get clothingImageNotFound;

  /// No description provided for @cannotRecommendSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot send a recommendation to yourself'**
  String get cannotRecommendSelf;

  /// No description provided for @onlyRecommendFriends.
  ///
  /// In en, this message translates to:
  /// **'You can only recommend clothing to friends'**
  String get onlyRecommendFriends;

  /// No description provided for @recommendationItemsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some clothing no longer exists, is private, or does not belong to this friend'**
  String get recommendationItemsUnavailable;

  /// No description provided for @recommendationMessageTooLong.
  ///
  /// In en, this message translates to:
  /// **'Recommendation message cannot exceed 200 characters'**
  String get recommendationMessageTooLong;

  /// No description provided for @onlyFriendWardrobeItems.
  ///
  /// In en, this message translates to:
  /// **'You can only recommend clothing from your friend\'s wardrobe'**
  String get onlyFriendWardrobeItems;

  /// No description provided for @onlyPublicItems.
  ///
  /// In en, this message translates to:
  /// **'You can only recommend public clothing'**
  String get onlyPublicItems;

  /// No description provided for @recommendationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Recommendation not found or you do not have permission to view it'**
  String get recommendationNotFound;

  /// No description provided for @recommendationItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'A recommended clothing item no longer exists'**
  String get recommendationItemNotFound;

  /// No description provided for @recommendationImageNotFound.
  ///
  /// In en, this message translates to:
  /// **'A recommended clothing image no longer exists'**
  String get recommendationImageNotFound;

  /// No description provided for @serverDataInvalid.
  ///
  /// In en, this message translates to:
  /// **'The server returned invalid data'**
  String get serverDataInvalid;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account and related data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Your profile, clothing, friendships, and recommendation history will be permanently deleted. This action cannot be undone.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter {email} to confirm account deletion.'**
  String deleteAccountEmailPrompt(String email);

  /// No description provided for @deleteAccountEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your account email'**
  String get deleteAccountEmailHint;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @resetYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get resetYourPassword;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email and we will send you a verification code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @passwordResetCodeSent.
  ///
  /// In en, this message translates to:
  /// **'If this email is registered, a verification code has been sent. Please check your inbox.'**
  String get passwordResetCodeSent;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @newPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a new password (at least 8 characters)'**
  String get newPasswordHint;

  /// No description provided for @newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get newPasswordRequired;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the new password again'**
  String get confirmPasswordHint;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully. Please sign in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @invalidOrExpiredVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'The verification code is invalid or has expired'**
  String get invalidOrExpiredVerificationCode;

  /// No description provided for @tooManyVerificationAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect verification attempts. Please request a new code.'**
  String get tooManyVerificationAttempts;

  /// No description provided for @verificationCodeRequestTooFrequent.
  ///
  /// In en, this message translates to:
  /// **'Please wait before requesting another verification code'**
  String get verificationCodeRequestTooFrequent;

  /// No description provided for @verificationEmailSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the verification email. Please try again later.'**
  String get verificationEmailSendFailed;

  /// No description provided for @newPasswordMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'The new password must be different from the current password'**
  String get newPasswordMustBeDifferent;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'The current password is incorrect'**
  String get currentPasswordIncorrect;

  /// No description provided for @storageLocation.
  ///
  /// In en, this message translates to:
  /// **'Storage location'**
  String get storageLocation;

  /// No description provided for @storageLocationExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. home, dormitory'**
  String get storageLocationExample;

  /// No description provided for @storageLocationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a storage location'**
  String get storageLocationRequired;

  /// No description provided for @storageLocationMax100.
  ///
  /// In en, this message translates to:
  /// **'Storage location cannot exceed 100 characters'**
  String get storageLocationMax100;

  /// No description provided for @selectCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategoryTitle;

  /// No description provided for @searchCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get searchCategoryHint;

  /// No description provided for @noCategoryResults.
  ///
  /// In en, this message translates to:
  /// **'No matching categories'**
  String get noCategoryResults;

  /// No description provided for @editClothing.
  ///
  /// In en, this message translates to:
  /// **'Edit Clothing'**
  String get editClothing;

  /// No description provided for @deleteClothing.
  ///
  /// In en, this message translates to:
  /// **'Delete Clothing'**
  String get deleteClothing;

  /// No description provided for @deletingClothing.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingClothing;

  /// No description provided for @deleteClothingFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete clothing. Please try again later.'**
  String get deleteClothingFailed;

  /// No description provided for @deleteClothingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this {category}?\n\nStorage location: {location}\nThis action cannot be undone.'**
  String deleteClothingConfirm(String category, String location);

  /// No description provided for @categoryGroupTops.
  ///
  /// In en, this message translates to:
  /// **'Tops'**
  String get categoryGroupTops;

  /// No description provided for @categoryGroupBottoms.
  ///
  /// In en, this message translates to:
  /// **'Bottoms'**
  String get categoryGroupBottoms;

  /// No description provided for @categoryGroupOnePiece.
  ///
  /// In en, this message translates to:
  /// **'One-piece'**
  String get categoryGroupOnePiece;

  /// No description provided for @categoryGroupSets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get categoryGroupSets;

  /// No description provided for @categoryGroupUnderwear.
  ///
  /// In en, this message translates to:
  /// **'Underwear'**
  String get categoryGroupUnderwear;

  /// No description provided for @categoryGroupFootwear.
  ///
  /// In en, this message translates to:
  /// **'Footwear'**
  String get categoryGroupFootwear;

  /// No description provided for @categoryGroupAccessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get categoryGroupAccessories;

  /// No description provided for @categoryTshirt.
  ///
  /// In en, this message translates to:
  /// **'T-Shirt'**
  String get categoryTshirt;

  /// No description provided for @categoryShirt.
  ///
  /// In en, this message translates to:
  /// **'Shirt'**
  String get categoryShirt;

  /// No description provided for @categoryPolo.
  ///
  /// In en, this message translates to:
  /// **'Polo Shirt'**
  String get categoryPolo;

  /// No description provided for @categoryTank.
  ///
  /// In en, this message translates to:
  /// **'Tank Top / Camisole'**
  String get categoryTank;

  /// No description provided for @categorySweatshirt.
  ///
  /// In en, this message translates to:
  /// **'Sweatshirt / Hoodie'**
  String get categorySweatshirt;

  /// No description provided for @categoryKnitwear.
  ///
  /// In en, this message translates to:
  /// **'Sweater / Knitwear'**
  String get categoryKnitwear;

  /// No description provided for @categoryCardigan.
  ///
  /// In en, this message translates to:
  /// **'Cardigan'**
  String get categoryCardigan;

  /// No description provided for @categoryVest.
  ///
  /// In en, this message translates to:
  /// **'Vest'**
  String get categoryVest;

  /// No description provided for @categoryBlazer.
  ///
  /// In en, this message translates to:
  /// **'Blazer'**
  String get categoryBlazer;

  /// No description provided for @categoryJacket.
  ///
  /// In en, this message translates to:
  /// **'Jacket'**
  String get categoryJacket;

  /// No description provided for @categoryTrench.
  ///
  /// In en, this message translates to:
  /// **'Trench Coat'**
  String get categoryTrench;

  /// No description provided for @categoryLongCoat.
  ///
  /// In en, this message translates to:
  /// **'Coat'**
  String get categoryLongCoat;

  /// No description provided for @categoryPaddedJacket.
  ///
  /// In en, this message translates to:
  /// **'Padded Jacket'**
  String get categoryPaddedJacket;

  /// No description provided for @categoryShellJacket.
  ///
  /// In en, this message translates to:
  /// **'Shell Jacket'**
  String get categoryShellJacket;

  /// No description provided for @categoryLeatherJacket.
  ///
  /// In en, this message translates to:
  /// **'Leather Jacket'**
  String get categoryLeatherJacket;

  /// No description provided for @categorySunProtective.
  ///
  /// In en, this message translates to:
  /// **'Sun-protective Jacket'**
  String get categorySunProtective;

  /// No description provided for @categoryOtherTops.
  ///
  /// In en, this message translates to:
  /// **'Other Tops'**
  String get categoryOtherTops;

  /// No description provided for @categoryJeans.
  ///
  /// In en, this message translates to:
  /// **'Jeans'**
  String get categoryJeans;

  /// No description provided for @categoryDressPants.
  ///
  /// In en, this message translates to:
  /// **'Dress Pants'**
  String get categoryDressPants;

  /// No description provided for @categoryCasualPants.
  ///
  /// In en, this message translates to:
  /// **'Casual Pants'**
  String get categoryCasualPants;

  /// No description provided for @categoryCargoPants.
  ///
  /// In en, this message translates to:
  /// **'Cargo Pants'**
  String get categoryCargoPants;

  /// No description provided for @categorySweatpants.
  ///
  /// In en, this message translates to:
  /// **'Sweatpants'**
  String get categorySweatpants;

  /// No description provided for @categoryLeggings.
  ///
  /// In en, this message translates to:
  /// **'Leggings'**
  String get categoryLeggings;

  /// No description provided for @categoryWideLegPants.
  ///
  /// In en, this message translates to:
  /// **'Wide-leg Pants'**
  String get categoryWideLegPants;

  /// No description provided for @categoryShorts.
  ///
  /// In en, this message translates to:
  /// **'Shorts'**
  String get categoryShorts;

  /// No description provided for @categorySkirt.
  ///
  /// In en, this message translates to:
  /// **'Skirt'**
  String get categorySkirt;

  /// No description provided for @categoryCulottes.
  ///
  /// In en, this message translates to:
  /// **'Culottes / Skort'**
  String get categoryCulottes;

  /// No description provided for @categoryOtherBottoms.
  ///
  /// In en, this message translates to:
  /// **'Other Bottoms'**
  String get categoryOtherBottoms;

  /// No description provided for @categoryDress.
  ///
  /// In en, this message translates to:
  /// **'Dress'**
  String get categoryDress;

  /// No description provided for @categoryGown.
  ///
  /// In en, this message translates to:
  /// **'Formal Gown'**
  String get categoryGown;

  /// No description provided for @categoryJumpsuit.
  ///
  /// In en, this message translates to:
  /// **'Jumpsuit'**
  String get categoryJumpsuit;

  /// No description provided for @categoryRomper.
  ///
  /// In en, this message translates to:
  /// **'Romper'**
  String get categoryRomper;

  /// No description provided for @categoryOveralls.
  ///
  /// In en, this message translates to:
  /// **'Overalls'**
  String get categoryOveralls;

  /// No description provided for @categoryPinafore.
  ///
  /// In en, this message translates to:
  /// **'Pinafore Dress'**
  String get categoryPinafore;

  /// No description provided for @categoryBodysuit.
  ///
  /// In en, this message translates to:
  /// **'Bodysuit'**
  String get categoryBodysuit;

  /// No description provided for @categoryOtherOnePiece.
  ///
  /// In en, this message translates to:
  /// **'Other One-piece'**
  String get categoryOtherOnePiece;

  /// No description provided for @categorySuitSet.
  ///
  /// In en, this message translates to:
  /// **'Suit Set'**
  String get categorySuitSet;

  /// No description provided for @categoryCasualSet.
  ///
  /// In en, this message translates to:
  /// **'Casual Set'**
  String get categoryCasualSet;

  /// No description provided for @categoryTracksuit.
  ///
  /// In en, this message translates to:
  /// **'Tracksuit'**
  String get categoryTracksuit;

  /// No description provided for @categoryKnitSet.
  ///
  /// In en, this message translates to:
  /// **'Knit Set'**
  String get categoryKnitSet;

  /// No description provided for @categoryPajamaSet.
  ///
  /// In en, this message translates to:
  /// **'Pajama Set'**
  String get categoryPajamaSet;

  /// No description provided for @categoryLoungewear.
  ///
  /// In en, this message translates to:
  /// **'Loungewear'**
  String get categoryLoungewear;

  /// No description provided for @categorySwimwear.
  ///
  /// In en, this message translates to:
  /// **'Swimwear'**
  String get categorySwimwear;

  /// No description provided for @categoryOtherSets.
  ///
  /// In en, this message translates to:
  /// **'Other Sets'**
  String get categoryOtherSets;

  /// No description provided for @categoryBra.
  ///
  /// In en, this message translates to:
  /// **'Bra'**
  String get categoryBra;

  /// No description provided for @categoryBriefs.
  ///
  /// In en, this message translates to:
  /// **'Underwear'**
  String get categoryBriefs;

  /// No description provided for @categoryUndershirt.
  ///
  /// In en, this message translates to:
  /// **'Undershirt'**
  String get categoryUndershirt;

  /// No description provided for @categoryBaseLayerTop.
  ///
  /// In en, this message translates to:
  /// **'Base-layer Top'**
  String get categoryBaseLayerTop;

  /// No description provided for @categoryBaseLayerBottom.
  ///
  /// In en, this message translates to:
  /// **'Base-layer Bottom'**
  String get categoryBaseLayerBottom;

  /// No description provided for @categoryLongJohns.
  ///
  /// In en, this message translates to:
  /// **'Long Johns'**
  String get categoryLongJohns;

  /// No description provided for @categoryThermalPants.
  ///
  /// In en, this message translates to:
  /// **'Thermal Pants'**
  String get categoryThermalPants;

  /// No description provided for @categoryShapewear.
  ///
  /// In en, this message translates to:
  /// **'Shapewear'**
  String get categoryShapewear;

  /// No description provided for @categorySocks.
  ///
  /// In en, this message translates to:
  /// **'Socks'**
  String get categorySocks;

  /// No description provided for @categoryTights.
  ///
  /// In en, this message translates to:
  /// **'Tights'**
  String get categoryTights;

  /// No description provided for @categoryStockings.
  ///
  /// In en, this message translates to:
  /// **'Stockings'**
  String get categoryStockings;

  /// No description provided for @categoryOtherUnderwear.
  ///
  /// In en, this message translates to:
  /// **'Other Underwear'**
  String get categoryOtherUnderwear;

  /// No description provided for @categorySneakers.
  ///
  /// In en, this message translates to:
  /// **'Sneakers'**
  String get categorySneakers;

  /// No description provided for @categoryCasualShoes.
  ///
  /// In en, this message translates to:
  /// **'Casual Shoes'**
  String get categoryCasualShoes;

  /// No description provided for @categoryCanvasShoes.
  ///
  /// In en, this message translates to:
  /// **'Canvas Shoes'**
  String get categoryCanvasShoes;

  /// No description provided for @categoryDressShoes.
  ///
  /// In en, this message translates to:
  /// **'Dress Shoes'**
  String get categoryDressShoes;

  /// No description provided for @categoryLoafers.
  ///
  /// In en, this message translates to:
  /// **'Loafers'**
  String get categoryLoafers;

  /// No description provided for @categoryHeels.
  ///
  /// In en, this message translates to:
  /// **'Heels'**
  String get categoryHeels;

  /// No description provided for @categoryFlats.
  ///
  /// In en, this message translates to:
  /// **'Flats'**
  String get categoryFlats;

  /// No description provided for @categorySandals.
  ///
  /// In en, this message translates to:
  /// **'Sandals'**
  String get categorySandals;

  /// No description provided for @categorySlippers.
  ///
  /// In en, this message translates to:
  /// **'Slippers'**
  String get categorySlippers;

  /// No description provided for @categoryAnkleBoots.
  ///
  /// In en, this message translates to:
  /// **'Ankle Boots'**
  String get categoryAnkleBoots;

  /// No description provided for @categoryTallBoots.
  ///
  /// In en, this message translates to:
  /// **'Tall Boots'**
  String get categoryTallBoots;

  /// No description provided for @categoryRainBoots.
  ///
  /// In en, this message translates to:
  /// **'Rain Boots'**
  String get categoryRainBoots;

  /// No description provided for @categoryHikingShoes.
  ///
  /// In en, this message translates to:
  /// **'Hiking Shoes'**
  String get categoryHikingShoes;

  /// No description provided for @categoryOtherFootwear.
  ///
  /// In en, this message translates to:
  /// **'Other Footwear'**
  String get categoryOtherFootwear;

  /// No description provided for @categoryHeadwear.
  ///
  /// In en, this message translates to:
  /// **'Headwear'**
  String get categoryHeadwear;

  /// No description provided for @categoryScarf.
  ///
  /// In en, this message translates to:
  /// **'Scarf'**
  String get categoryScarf;

  /// No description provided for @categoryShawl.
  ///
  /// In en, this message translates to:
  /// **'Shawl'**
  String get categoryShawl;

  /// No description provided for @categoryGloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get categoryGloves;

  /// No description provided for @categoryBelt.
  ///
  /// In en, this message translates to:
  /// **'Belt'**
  String get categoryBelt;

  /// No description provided for @categoryTie.
  ///
  /// In en, this message translates to:
  /// **'Tie'**
  String get categoryTie;

  /// No description provided for @categoryBowTie.
  ///
  /// In en, this message translates to:
  /// **'Bow Tie'**
  String get categoryBowTie;

  /// No description provided for @categorySleeve.
  ///
  /// In en, this message translates to:
  /// **'Sleeve / Arm Cover'**
  String get categorySleeve;

  /// No description provided for @categoryOtherAccessories.
  ///
  /// In en, this message translates to:
  /// **'Other Accessories'**
  String get categoryOtherAccessories;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
