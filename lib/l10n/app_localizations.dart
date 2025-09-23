import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @chooseTruthOrDare.
  ///
  /// In en, this message translates to:
  /// **'Choose Truth or Dare to start'**
  String get chooseTruthOrDare;

  /// No description provided for @truth.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get truth;

  /// No description provided for @dare.
  ///
  /// In en, this message translates to:
  /// **'Dare'**
  String get dare;

  /// No description provided for @howToPlayTruthOrDare.
  ///
  /// In en, this message translates to:
  /// **'How to play Truth or Dare'**
  String get howToPlayTruthOrDare;

  /// No description provided for @instruction1.
  ///
  /// In en, this message translates to:
  /// **'Choose \'Truth\' or \'Dare\' by tapping one of the two buttons below.'**
  String get instruction1;

  /// No description provided for @instruction2.
  ///
  /// In en, this message translates to:
  /// **'If you choose \'Truth\', answer honestly the question shown on screen.'**
  String get instruction2;

  /// No description provided for @instruction3.
  ///
  /// In en, this message translates to:
  /// **'If you choose \'Dare\', perform the action given.'**
  String get instruction3;

  /// No description provided for @instruction4.
  ///
  /// In en, this message translates to:
  /// **'Players take turns alternating questions and dares.'**
  String get instruction4;

  /// No description provided for @instruction5.
  ///
  /// In en, this message translates to:
  /// **'The goal is to have fun, discover new things and accept challenges.'**
  String get instruction5;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'Example: If you choose \'Truth\', you may answer \'What was your most embarrassing moment?\'. If you choose \'Dare\', you may get \'Imitate someone in the group for 1 minute\'.'**
  String get example;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category to start: Normal, +18 or Sentimental'**
  String get chooseCategory;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @plus18.
  ///
  /// In en, this message translates to:
  /// **'+18'**
  String get plus18;

  /// No description provided for @sentimental.
  ///
  /// In en, this message translates to:
  /// **'Sentimental'**
  String get sentimental;

  /// No description provided for @howToPlayNeverHaveIEver.
  ///
  /// In en, this message translates to:
  /// **'How to play Never Have I Ever'**
  String get howToPlayNeverHaveIEver;

  /// No description provided for @nhieInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Choose a question category by tapping one of the three buttons: \'Normal\', \'+18\', or \'Sentimental\'.'**
  String get nhieInstruction1;

  /// No description provided for @nhieInstruction2.
  ///
  /// In en, this message translates to:
  /// **'A phrase starting with \'Never have I ever...\' will appear on the screen.'**
  String get nhieInstruction2;

  /// No description provided for @nhieInstruction3.
  ///
  /// In en, this message translates to:
  /// **'All players must think if they have ever done what the phrase says.'**
  String get nhieInstruction3;

  /// No description provided for @nhieInstruction4.
  ///
  /// In en, this message translates to:
  /// **'If a player HAS done it, they must admit it (for example, by raising their hand, taking a sip of a drink, or however the group decides).'**
  String get nhieInstruction4;

  /// No description provided for @nhieInstruction5.
  ///
  /// In en, this message translates to:
  /// **'The game continues as long as players want, switching between categories if desired.'**
  String get nhieInstruction5;

  /// No description provided for @nhieInstruction6.
  ///
  /// In en, this message translates to:
  /// **'WARNING: The +18 category contains very explicit questions that may not be suitable for everyone.'**
  String get nhieInstruction6;

  /// No description provided for @nhieInstruction7.
  ///
  /// In en, this message translates to:
  /// **'WARNING: The Sentimental category is aimed at deep introspection and may contain very tough questions not suitable for everyone.'**
  String get nhieInstruction7;

  /// No description provided for @nhieExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If the phrase \'Never have I ever missed a flight\' appears and a player has missed one, they must admit it.'**
  String get nhieExample;

  /// No description provided for @pressToStart.
  ///
  /// In en, this message translates to:
  /// **'Press the button to start'**
  String get pressToStart;

  /// No description provided for @forbiddenWords.
  ///
  /// In en, this message translates to:
  /// **'Forbidden words:'**
  String get forbiddenWords;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// No description provided for @howToPlayTabu.
  ///
  /// In en, this message translates to:
  /// **'How to play Taboo'**
  String get howToPlayTabu;

  /// No description provided for @tabuInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Press the \'Start\' button to get a word.'**
  String get tabuInstruction1;

  /// No description provided for @tabuInstruction2.
  ///
  /// In en, this message translates to:
  /// **'A main word will be shown on screen along with a list of forbidden words.'**
  String get tabuInstruction2;

  /// No description provided for @tabuInstruction3.
  ///
  /// In en, this message translates to:
  /// **'The player must describe the main word without mentioning any of the forbidden ones.'**
  String get tabuInstruction3;

  /// No description provided for @tabuInstruction4.
  ///
  /// In en, this message translates to:
  /// **'The rest of the group must try to guess what the word is.'**
  String get tabuInstruction4;

  /// No description provided for @tabuInstruction5.
  ///
  /// In en, this message translates to:
  /// **'If the player says a forbidden word, they lose their turn.'**
  String get tabuInstruction5;

  /// No description provided for @tabuExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If the word \'Dog\' appears and the forbidden ones are \'Animal\', \'Bark\', \'Pet\', and \'Cat\', you should describe it by saying something like \'a living being that usually accompanies people at home\'.'**
  String get tabuExample;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  /// No description provided for @guessEmoji.
  ///
  /// In en, this message translates to:
  /// **'Guess the emojis'**
  String get guessEmoji;

  /// No description provided for @writeAnswer.
  ///
  /// In en, this message translates to:
  /// **'Write your answer'**
  String get writeAnswer;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @howToPlayEmoji.
  ///
  /// In en, this message translates to:
  /// **'How to play EmojiChallenge'**
  String get howToPlayEmoji;

  /// No description provided for @emojiInstruction1.
  ///
  /// In en, this message translates to:
  /// **'On the screen you will see a combination of emojis that represent a concept, a movie, a book, or someone known.'**
  String get emojiInstruction1;

  /// No description provided for @emojiInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Your goal is to guess what that combination means and write the answer in the text box.'**
  String get emojiInstruction2;

  /// No description provided for @emojiInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Press \'Send\' to check if your answer is correct.'**
  String get emojiInstruction3;

  /// No description provided for @emojiInstruction4.
  ///
  /// In en, this message translates to:
  /// **'If you guess correctly, you will earn a point in your score. If you fail, a message will indicate the answer is incorrect.'**
  String get emojiInstruction4;

  /// No description provided for @emojiInstruction5.
  ///
  /// In en, this message translates to:
  /// **'You can move to the next challenge by pressing the \'Next\' button.'**
  String get emojiInstruction5;

  /// No description provided for @emojiInstruction6.
  ///
  /// In en, this message translates to:
  /// **'If you get stuck, you can get inspired by the suggestion system that appears when you type.'**
  String get emojiInstruction6;

  /// No description provided for @emojiInstruction7.
  ///
  /// In en, this message translates to:
  /// **'You can also challenge yourself with the timer to measure how long it takes to solve each challenge.'**
  String get emojiInstruction7;

  /// No description provided for @emojiInstruction8.
  ///
  /// In en, this message translates to:
  /// **'Your number of accumulated correct answers appears at the top, and you can reset it anytime.'**
  String get emojiInstruction8;

  /// No description provided for @emojiExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If you see the emojis \'🦁👑\', the correct answer would be \'The Lion King\'.'**
  String get emojiExample;

  /// No description provided for @resetGame.
  ///
  /// In en, this message translates to:
  /// **'Reset Game'**
  String get resetGame;

  /// No description provided for @howToPlayWorday.
  ///
  /// In en, this message translates to:
  /// **'How to play Worday'**
  String get howToPlayWorday;

  /// No description provided for @wordayInstruction1.
  ///
  /// In en, this message translates to:
  /// **'You have 6 attempts to guess the hidden 5-letter word.'**
  String get wordayInstruction1;

  /// No description provided for @wordayInstruction2.
  ///
  /// In en, this message translates to:
  /// **'When you type a valid word, letters are marked with different colors:\n🟩 Green: correct letter in correct position.\n🟧 Orange: correct letter in wrong position.\n⬛ Gray: letter not in word.'**
  String get wordayInstruction2;

  /// No description provided for @wordayInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Use the colors to refine your guesses.'**
  String get wordayInstruction3;

  /// No description provided for @wordayInstruction4.
  ///
  /// In en, this message translates to:
  /// **'The game ends when you guess the word or run out of attempts.'**
  String get wordayInstruction4;

  /// No description provided for @wordayExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If the target word is \'CARGO\' and you type \'MANSO\', the letters \'A\' and \'O\' will be green and the rest gray.'**
  String get wordayExample;

  /// No description provided for @invalidWord.
  ///
  /// In en, this message translates to:
  /// **'Invalid word, try again'**
  String get invalidWord;

  /// No description provided for @winTitle.
  ///
  /// In en, this message translates to:
  /// **'🎉 You guessed it! 🎉'**
  String get winTitle;

  /// No description provided for @loseTitle.
  ///
  /// In en, this message translates to:
  /// **'😢 Game Over 😢'**
  String get loseTitle;

  /// No description provided for @winDescription.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! The word was {word}. You guessed it in {attempts} attempts.'**
  String winDescription(Object attempts, Object word);

  /// No description provided for @loseDescription.
  ///
  /// In en, this message translates to:
  /// **'You didn\'t guess the word. The correct word was {word}.'**
  String loseDescription(Object word);

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// No description provided for @nextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question'**
  String get nextQuestion;

  /// No description provided for @fastQuizHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play FastQuiz'**
  String get fastQuizHowToPlay;

  /// No description provided for @fastQuizInstruction1.
  ///
  /// In en, this message translates to:
  /// **'A question with multiple options will appear on screen.'**
  String get fastQuizInstruction1;

  /// No description provided for @fastQuizInstruction2.
  ///
  /// In en, this message translates to:
  /// **'Read the question carefully and select one of the available options.'**
  String get fastQuizInstruction2;

  /// No description provided for @fastQuizInstruction3.
  ///
  /// In en, this message translates to:
  /// **'If correct, the option will be highlighted in green and you earn a point.'**
  String get fastQuizInstruction3;

  /// No description provided for @fastQuizInstruction4.
  ///
  /// In en, this message translates to:
  /// **'If wrong, your answer will be marked in red and you won\'t earn points.'**
  String get fastQuizInstruction4;

  /// No description provided for @fastQuizInstruction5.
  ///
  /// In en, this message translates to:
  /// **'After answering, press \'Next question\' to continue.'**
  String get fastQuizInstruction5;

  /// No description provided for @fastQuizInstruction6.
  ///
  /// In en, this message translates to:
  /// **'You can check your total correct answers at the top of the screen and reset anytime.'**
  String get fastQuizInstruction6;

  /// No description provided for @fastQuizInstruction7.
  ///
  /// In en, this message translates to:
  /// **'You can also use the built-in stopwatch to challenge yourself in a limited time.'**
  String get fastQuizInstruction7;

  /// No description provided for @fastQuizExample.
  ///
  /// In en, this message translates to:
  /// **'Example: If the question \'What is the capital of France?\' appears and you select \'Paris\', your answer is correct and you earn a point.'**
  String get fastQuizExample;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @dailyChallenge.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge'**
  String get dailyChallenge;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @truthOrDareTitle.
  ///
  /// In en, this message translates to:
  /// **'Truth or Dare'**
  String get truthOrDareTitle;

  /// No description provided for @truthOrDareDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose between telling a truth or completing a risky challenge.'**
  String get truthOrDareDesc;

  /// No description provided for @neverHaveIEverTitle.
  ///
  /// In en, this message translates to:
  /// **'Never Have I Ever'**
  String get neverHaveIEverTitle;

  /// No description provided for @neverHaveIEverDesc.
  ///
  /// In en, this message translates to:
  /// **'Reveal secrets with your friends.'**
  String get neverHaveIEverDesc;

  /// No description provided for @fastQuizTitle.
  ///
  /// In en, this message translates to:
  /// **'Fast Quiz'**
  String get fastQuizTitle;

  /// No description provided for @fastQuizDesc.
  ///
  /// In en, this message translates to:
  /// **'General knowledge quiz.'**
  String get fastQuizDesc;

  /// No description provided for @emojiChallengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Emoji Challenge'**
  String get emojiChallengeTitle;

  /// No description provided for @emojiChallengeDesc.
  ///
  /// In en, this message translates to:
  /// **'Guess movies, books, or concepts based only on emojis.'**
  String get emojiChallengeDesc;

  /// No description provided for @geoExpertTitle.
  ///
  /// In en, this message translates to:
  /// **'Geo Expert'**
  String get geoExpertTitle;

  /// No description provided for @geoExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Rank countries based on different indexes.'**
  String get geoExpertDesc;

  /// No description provided for @wordayTitle.
  ///
  /// In en, this message translates to:
  /// **'Worday'**
  String get wordayTitle;

  /// No description provided for @wordayDesc.
  ///
  /// In en, this message translates to:
  /// **'Guess the daily word by testing other words and considering the letter positions.'**
  String get wordayDesc;

  /// No description provided for @tabuWordTitle.
  ///
  /// In en, this message translates to:
  /// **'Taboo Word'**
  String get tabuWordTitle;

  /// No description provided for @tabuWordDesc.
  ///
  /// In en, this message translates to:
  /// **'Describe the word to your friends without using a forbidden word list.'**
  String get tabuWordDesc;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correctAnswers;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @startWatch.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startWatch;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @resetTimer.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetTimer;

  /// No description provided for @friendsGames.
  ///
  /// In en, this message translates to:
  /// **'Friends Games'**
  String get friendsGames;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @searchGames.
  ///
  /// In en, this message translates to:
  /// **'Search games'**
  String get searchGames;

  /// No description provided for @favoritesCleared.
  ///
  /// In en, this message translates to:
  /// **'Favorites cleared'**
  String get favoritesCleared;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Games with Friends'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Have fun in group! 🎉'**
  String get appSubtitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutApp;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reverseVoice.
  ///
  /// In en, this message translates to:
  /// **'Reverse Voice'**
  String get reverseVoice;

  /// No description provided for @reverseVoiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Imitate a phrase you record in reverse and observe the result.'**
  String get reverseVoiceDesc;

  /// No description provided for @reverseVoiceHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play Reverse Voice'**
  String get reverseVoiceHowToPlay;

  /// No description provided for @reverseVoiceInstruction1.
  ///
  /// In en, this message translates to:
  /// **'Press the green microphone section to record your voice (max 10 seconds).'**
  String get reverseVoiceInstruction1;

  /// No description provided for @reverseVoiceInstruction2.
  ///
  /// In en, this message translates to:
  /// **'When you stop recording, the blue section will unlock.'**
  String get reverseVoiceInstruction2;

  /// No description provided for @reverseVoiceInstruction3.
  ///
  /// In en, this message translates to:
  /// **'Press the blue speaker button to hear your recording in reverse.'**
  String get reverseVoiceInstruction3;

  /// No description provided for @reverseVoiceInstruction4.
  ///
  /// In en, this message translates to:
  /// **'Now, try to imitate what you heard in reverse by recording again!'**
  String get reverseVoiceInstruction4;

  /// No description provided for @reverseVoiceExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Record \'Hello World\' → hear \'dlroW olleH\' → try to record that and hear your original phrase.'**
  String get reverseVoiceExample;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Touch for recording'**
  String get record;

  /// No description provided for @reproduce.
  ///
  /// In en, this message translates to:
  /// **'Touch for listening'**
  String get reproduce;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @geoExpertTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total score: {totalScore}'**
  String geoExpertTotalScore(Object totalScore);

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @geoExpertShowName.
  ///
  /// In en, this message translates to:
  /// **'Show name'**
  String get geoExpertShowName;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get gameOver;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @geoExpertAbandonTryDaily.
  ///
  /// In en, this message translates to:
  /// **'You have abandoned the attempt. Penalty score:'**
  String get geoExpertAbandonTryDaily;

  /// No description provided for @geoExpertFinalScoreDaily.
  ///
  /// In en, this message translates to:
  /// **'Your total score was:'**
  String get geoExpertFinalScoreDaily;

  /// No description provided for @geoExpertFinalScoreNormal.
  ///
  /// In en, this message translates to:
  /// **'Your total score is:'**
  String get geoExpertFinalScoreNormal;

  /// No description provided for @geoExpertShareText.
  ///
  /// In en, this message translates to:
  /// **'🌍 Day #1 at GeoExpert\n🏆 Total Score: {displayScore}\n🎯 Show off your geographic knowledge!\n📲 Play now: https://link_to_the_app'**
  String geoExpertShareText(Object displayScore);

  /// No description provided for @geoExpertRecommendation.
  ///
  /// In en, this message translates to:
  /// **'⚡You had a better choice: {category} (Rank: {rank})'**
  String geoExpertRecommendation(Object category, Object rank);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
