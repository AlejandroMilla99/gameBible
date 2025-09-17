// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get chooseTruthOrDare => 'Choose Truth or Dare to start';

  @override
  String get truth => 'Truth';

  @override
  String get dare => 'Dare';

  @override
  String get howToPlayTruthOrDare => 'How to play Truth or Dare';

  @override
  String get instruction1 => 'Choose \'Truth\' or \'Dare\' by tapping one of the two buttons below.';

  @override
  String get instruction2 => 'If you choose \'Truth\', answer honestly the question shown on screen.';

  @override
  String get instruction3 => 'If you choose \'Dare\', perform the action given.';

  @override
  String get instruction4 => 'Players take turns alternating questions and dares.';

  @override
  String get instruction5 => 'The goal is to have fun, discover new things and accept challenges.';

  @override
  String get example => 'Example: If you choose \'Truth\', you may answer \'What was your most embarrassing moment?\'. If you choose \'Dare\', you may get \'Imitate someone in the group for 1 minute\'.';

  @override
  String get chooseCategory => 'Choose a category to start: Normal, +18 or Sentimental';

  @override
  String get normal => 'Normal';

  @override
  String get plus18 => '+18';

  @override
  String get sentimental => 'Sentimental';

  @override
  String get howToPlayNeverHaveIEver => 'How to play Never Have I Ever';

  @override
  String get nhieInstruction1 => 'Choose a question category by tapping one of the three buttons: \'Normal\', \'+18\', or \'Sentimental\'.';

  @override
  String get nhieInstruction2 => 'A phrase starting with \'Never have I ever...\' will appear on the screen.';

  @override
  String get nhieInstruction3 => 'All players must think if they have ever done what the phrase says.';

  @override
  String get nhieInstruction4 => 'If a player HAS done it, they must admit it (for example, by raising their hand, taking a sip of a drink, or however the group decides).';

  @override
  String get nhieInstruction5 => 'The game continues as long as players want, switching between categories if desired.';

  @override
  String get nhieInstruction6 => 'WARNING: The +18 category contains very explicit questions that may not be suitable for everyone.';

  @override
  String get nhieInstruction7 => 'WARNING: The Sentimental category is aimed at deep introspection and may contain very tough questions not suitable for everyone.';

  @override
  String get nhieExample => 'Example: If the phrase \'Never have I ever missed a flight\' appears and a player has missed one, they must admit it.';

  @override
  String get pressToStart => 'Press the button to start';

  @override
  String get forbiddenWords => 'Forbidden words:';

  @override
  String get start => 'Start';

  @override
  String get discard => 'Discard';

  @override
  String get correct => 'Correct';

  @override
  String get howToPlayTabu => 'How to play Taboo';

  @override
  String get tabuInstruction1 => 'Press the \'Start\' button to get a word.';

  @override
  String get tabuInstruction2 => 'A main word will be shown on screen along with a list of forbidden words.';

  @override
  String get tabuInstruction3 => 'The player must describe the main word without mentioning any of the forbidden ones.';

  @override
  String get tabuInstruction4 => 'The rest of the group must try to guess what the word is.';

  @override
  String get tabuInstruction5 => 'If the player says a forbidden word, they lose their turn.';

  @override
  String get tabuExample => 'Example: If the word \'Dog\' appears and the forbidden ones are \'Animal\', \'Bark\', \'Pet\', and \'Cat\', you should describe it by saying something like \'a living being that usually accompanies people at home\'.';

  @override
  String get incorrect => 'Incorrect!';

  @override
  String get guessEmoji => 'Guess the emojis';

  @override
  String get writeAnswer => 'Write your answer';

  @override
  String get send => 'Send';

  @override
  String get next => 'Next';

  @override
  String get howToPlayEmoji => 'How to play EmojiChallenge';

  @override
  String get emojiInstruction1 => 'On the screen you will see a combination of emojis that represent a concept, a movie, a book, or someone known.';

  @override
  String get emojiInstruction2 => 'Your goal is to guess what that combination means and write the answer in the text box.';

  @override
  String get emojiInstruction3 => 'Press \'Send\' to check if your answer is correct.';

  @override
  String get emojiInstruction4 => 'If you guess correctly, you will earn a point in your score. If you fail, a message will indicate the answer is incorrect.';

  @override
  String get emojiInstruction5 => 'You can move to the next challenge by pressing the \'Next\' button.';

  @override
  String get emojiInstruction6 => 'If you get stuck, you can get inspired by the suggestion system that appears when you type.';

  @override
  String get emojiInstruction7 => 'You can also challenge yourself with the timer to measure how long it takes to solve each challenge.';

  @override
  String get emojiInstruction8 => 'Your number of accumulated correct answers appears at the top, and you can reset it anytime.';

  @override
  String get emojiExample => 'Example: If you see the emojis \'🦁👑\', the correct answer would be \'The Lion King\'.';

  @override
  String get resetGame => 'Reset Game';

  @override
  String get howToPlayWorday => 'How to play Worday';

  @override
  String get wordayInstruction1 => 'You have 6 attempts to guess the hidden 5-letter word.';

  @override
  String get wordayInstruction2 => 'When you type a valid word, letters are marked with different colors:\n🟩 Green: correct letter in correct position.\n🟧 Orange: correct letter in wrong position.\n⬛ Gray: letter not in word.';

  @override
  String get wordayInstruction3 => 'Use the colors to refine your guesses.';

  @override
  String get wordayInstruction4 => 'The game ends when you guess the word or run out of attempts.';

  @override
  String get wordayExample => 'Example: If the target word is \'CARGO\' and you type \'MANSO\', the letters \'A\' and \'O\' will be green and the rest gray.';

  @override
  String get invalidWord => 'Invalid word, try again';

  @override
  String get winTitle => '🎉 You guessed it! 🎉';

  @override
  String get loseTitle => '😢 Game Over 😢';

  @override
  String winDescription(Object attempts, Object word) {
    return 'Congratulations! The word was $word. You guessed it in $attempts attempts.';
  }

  @override
  String loseDescription(Object word) {
    return 'You didn\'t guess the word. The correct word was $word.';
  }

  @override
  String get playAgain => 'Play Again';

  @override
  String get nextQuestion => 'Next question';

  @override
  String get fastQuizHowToPlay => 'How to play FastQuiz';

  @override
  String get fastQuizInstruction1 => 'A question with multiple options will appear on screen.';

  @override
  String get fastQuizInstruction2 => 'Read the question carefully and select one of the available options.';

  @override
  String get fastQuizInstruction3 => 'If correct, the option will be highlighted in green and you earn a point.';

  @override
  String get fastQuizInstruction4 => 'If wrong, your answer will be marked in red and you won\'t earn points.';

  @override
  String get fastQuizInstruction5 => 'After answering, press \'Next question\' to continue.';

  @override
  String get fastQuizInstruction6 => 'You can check your total correct answers at the top of the screen and reset anytime.';

  @override
  String get fastQuizInstruction7 => 'You can also use the built-in stopwatch to challenge yourself in a limited time.';

  @override
  String get fastQuizExample => 'Example: If the question \'What is the capital of France?\' appears and you select \'Paris\', your answer is correct and you earn a point.';

  @override
  String get play => 'Play';

  @override
  String get back => 'Back';

  @override
  String get truthOrDareTitle => 'Truth or Dare';

  @override
  String get truthOrDareDesc => 'Choose between telling a truth or completing a risky challenge.';

  @override
  String get neverHaveIEverTitle => 'Never Have I Ever';

  @override
  String get neverHaveIEverDesc => 'Reveal secrets with your friends.';

  @override
  String get fastQuizTitle => 'Fast Quiz';

  @override
  String get fastQuizDesc => 'General knowledge quiz.';

  @override
  String get emojiChallengeTitle => 'Emoji Challenge';

  @override
  String get emojiChallengeDesc => 'Guess movies, books, or concepts based only on emojis.';

  @override
  String get geoExpertTitle => 'Geo Expert';

  @override
  String get geoExpertDesc => 'Rank countries based on different indexes.';

  @override
  String get wordayTitle => 'Worday';

  @override
  String get wordayDesc => 'Guess the daily word by testing other words and considering the letter positions.';

  @override
  String get tabuWordTitle => 'Taboo Word';

  @override
  String get tabuWordDesc => 'Describe the word to your friends without using a forbidden word list.';

  @override
  String get correctAnswers => 'Correct';

  @override
  String get reset => 'Reset';

  @override
  String get startWatch => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String get resume => 'Resume';

  @override
  String get resetTimer => 'Reset';

  @override
  String get friendsGames => 'Friends Games';

  @override
  String get favorites => 'Favorites';

  @override
  String get profile => 'Profile';

  @override
  String get searchGames => 'Search games';

  @override
  String get favoritesCleared => 'Favorites cleared';

  @override
  String get openSettings => 'Open settings';

  @override
  String get home => 'Home';

  @override
  String get appTitle => 'Games with Friends';

  @override
  String get appSubtitle => 'Have fun in group! 🎉';

  @override
  String get settings => 'Settings';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About the App';

  @override
  String get language => 'Language';

  @override
  String get spanish => 'Spanish';

  @override
  String get english => 'English';

  @override
  String get sound => 'Sound';

  @override
  String get notifications => 'Notifications';

  @override
  String get save => 'Save';
}
