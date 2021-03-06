import 'dart:async';
import 'package:dispatcher/models/models.dart';
import 'package:dispatcher/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(
    this.locale,
  );

  static AppLocalizations of(
    BuildContext context,
  ) =>
      Localizations.of<AppLocalizations>(
        context,
        AppLocalizations,
      );

  static String get appTitle => 'Dispatcher';

  String get loading => addMessage('Loading...');
  String get loadingUser => addMessage('Loading User');
  String get login => addMessage('Login');
  String get logout => addMessage('Logout');
  String get password => addMessage('Password');
  String get passwordPlease => addMessage('Please enter your password');
  String get create => addMessage('Create Account');
  String get creating => addMessage('Creating your account. Please wait...');
  String get dashboard => addMessage('Dashboard');
  String get contacts => addMessage('Contacts');
  String get contactsNone => addMessage('No contacts found');
  String get contactsLoading =>
      addMessage('Loading your contacts. Please wait...');

  String get connections => addMessage('Connections');
  String get connectionsNone => addMessage('No connections found');
  String get connectionsLoading =>
      addMessage('Loading your connections. Please wait...');

  String get saySomething => addMessage('Say Something...');
  String get settings => addMessage('Settings');
  String get menu => addMessage('Menu');
  String get photo => addMessage('Photo');
  String get takePhoto => addMessage('Take Photo');
  String get uploadingPhoto =>
      addMessage('Uploading your photo. Please wait...');

  String get selectPhoto => addMessage('Select Photo');
  String get search => addMessage('Search');
  String get yes => addMessage('Yes');
  String get no => addMessage('No');
  String get tryAgain => addMessage('Try Again');
  String get all => addMessage('All');
  String get sendInvite => addMessage('Send Invite');
  String get sendMessage => addMessage('Send Message');
  String get yourInviteCode => addMessage('Your invite code');
  String get enterInviteCode => addMessage('Enter the invite code');
  String get lookup => addMessage('Lookup');
  String get connect => addMessage('Connect');
  String get connectSuccess => addMessage('Connection Success!');
  String get cancel => addMessage('Cancel');
  String get personalDetails => addMessage('Personal Details');
  String get name => addMessage('Name');
  String get namePlease => addMessage('Please enter your name');
  String get email => addMessage('Email');
  String get emailPlease => addMessage('Please enter your email');
  String get emailValidPlease => addMessage('Please enter a valid email');
  String get phoneNumber => addMessage('Phone Number');
  String get phoneNumberPlease => addMessage('Please enter your phone number');
  String get avatar => addMessage('Avatar');
  String get avatarHowsItLike => addMessage('How\'s it look?');
  String get avatarReTake => addMessage('Re-Take');
  String get avatarLikeIt => addMessage('I like it');
  String get avatarDelete => addMessage('Delete Avatar');
  String get avatarDeleteConfirm => addMessage(
      'Are you sure you want to delete this avatar? This cannot be undone.');

  String get avatarDeleteError => addMessage(
      'There was an issue deleting your avatar. Please contact support.');

  String get save => addMessage('Save');
  String get saved => addMessage('Saved');
  String get ok => addMessage('OK');
  String get security => addMessage('Security');
  String get enterPin => addMessage('Please enter your new PIN');
  String get changePin => addMessage('Change PIN');
  String get updateEmail => addMessage('Update Email');
  String get updatePhoneNumber => addMessage('Update Phone Number');
  String get resendCode => addMessage('Resend Code');
  String get setPINCode => addMessage('Set PIN Code');
  String get verifyPINCode => addMessage('Verify PIN Code');
  String get invalidPINCode =>
      addMessage('Invalid PIN code. Please try again.');

  String get sendCode => addMessage('Send Code');
  String get verifyCode => addMessage('Verify Code');
  String get validVerificationCode =>
      addMessage('Your verification code was successfully verified!');

  String get invalidVerificationCode =>
      addMessage('Invalid verification code. Please try again.');

  String get resentVerificationCode =>
      addMessage('The verification code was re-sent.');

  String get application => addMessage('Application');
  String get permissions => addMessage('Permissions');
  String get privacyPolicy => addMessage('Privacy Policy');
  String get account => addMessage('Account');

  String get alreadyHaveAccount => addMessage('I already have an account');
  String get dontHaveAccount => addMessage('I don\'t have an account');
  String get cantCreateAccount => addMessage(
      'There was an issue creating your account. Please contact support.');

  String get cantAuthAccount => addMessage(
      'Account not found. Please try again or contact support if this problem persists.');

  String get authorizing => addMessage('Authorizing...');

  String inviteCodeText(
    String appName,
    String inviteCode,
  ) =>
      addMessage(
        'Try out $appName today! Use my invite code $inviteCode to connect ' +
            'with me. $appName is available in the app store!',
        name: 'inviteCodeText',
        args: [
          appName,
          inviteCode,
        ],
      );

  String get getInviteCodeText => addMessage(
        'Get the code from the person\nwho you\'re trying to connect with',
        name: 'getInviteCodeText',
      );

  String get wouldYouConnect =>
      addMessage('Would you like to connect with this person?',
          name: 'wouldYouConnect');

  String get bummer => addMessage(
        'Bummer!',
        name: 'bummer',
      );

  String get bummerText => addMessage(
        'We didn\'t find anything',
        name: 'bummerText',
      );

  String get error => addMessage(
        'There was an error. Please try again.',
        name: 'error',
      );

  String enterPhoneNumber(
    int length,
  ) =>
      addMessage(
        'Please update your phone number first. We need to make sure it\'s ' +
            'really you by sending you a $length-digit code.',
        name: 'enterPhoneNumber',
        args: [
          length,
        ],
      );

  String get enterPhoneNumberDisclaimer => addMessage(
        'I agree to receieving this one-time test message. Message and data ' +
            'rates may apply.',
        name: 'enterPhoneNumberDisclaimer',
      );

  String sendPinVerificationCodeText(
    int length,
    int minutes,
  ) =>
      addMessage(
        'We need to make sure it\'s really you. A temporary $length-digit ' +
            'code will be sent to your phone number below. The code will expire ' +
            '$minutes minutes after being sent.',
        name: 'sendCodeText',
        args: [
          length,
          minutes,
        ],
      );

  String pinVerificationCodeSMSText(
    String appName,
    String verificationCode,
  ) =>
      addMessage(
        '$appName won\'t call you for this code. The temporary code you ' +
            'requested is $verificationCode. Please use this code to ' +
            'complete your request.',
        name: 'codeVerificationText',
        args: [
          appName,
          verificationCode,
        ],
      );

  String verifyPinVerificationCodeText(
    int length,
  ) =>
      addMessage(
        'For your security, please verify this is you by sending the ' +
            'temporary $length-digit code we sent to your phone number.',
        name: 'codeVerificationText',
        args: [
          length,
        ],
      );

  String get pinCodeUpdateConfirmationText => addMessage(
        'Your PIN was updated successfully!',
        name: 'pinCodeUpdateConfirmationText',
      );

  String get settingsUpdated =>
      addMessage('Your settings were updated successfully!');

  String get avatarUpdated =>
      addMessage('Your avatar was updated successfully!');

  String get avatarFailed =>
      addMessage('There was an issue updating your avatar. Please try again.');

  String get avatarDeleted =>
      addMessage('Your avatar was deleted successfully!');

  String get connectionNotFoundText => addMessage(
        'Connection not found',
        name: 'connectionNotFoundText',
      );

  String get connectionFoundText => addMessage(
        'Connection found!',
        name: 'connectionFoundText',
      );

  String connectSuccessText(
    User user,
  ) =>
      addMessage(
        'You successfully connected with ${user.name}!',
        name: 'connectSuccessText',
        args: [
          user,
        ],
      );

  String alreadyConnectedText(
    User user,
  ) =>
      addMessage(
        'You\'re already connected with ${user.name}!',
        name: 'alreadyConnectedText',
        args: [
          user,
        ],
      );

  String get cantConnectText => addMessage(
        'Sorry but we can\'t connect you with this account.',
        name: 'cantConnectText',
      );

  String passwordLength(
    int minLength,
  ) =>
      addMessage(
        'Password must be at least $minLength characters long',
        args: [
          minLength,
        ],
      );

  String cameraError(
    String error,
  ) =>
      addMessage(
        'Camera error $error',
        args: [
          error,
        ],
      );

  addMessage(
    String message, {
    String name,
    List<Object> args,
  }) =>
      Intl.message(
        message,
        name: (name == null) ? toCamelCase(message) : name,
        args: args,
        locale: locale.toString(),
      );
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  Future<AppLocalizations> load(
    Locale locale,
  ) =>
      Future(() => AppLocalizations(locale));

  @override
  bool shouldReload(
    AppLocalizationsDelegate old,
  ) =>
      false;

  @override
  bool isSupported(
    Locale locale,
  ) =>
      locale.languageCode.toLowerCase().contains('en'); // TODO!
}
