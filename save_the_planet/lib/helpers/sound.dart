import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer stpAudioPlayer = AudioPlayer();
final AudioCache stpAudioCache = AudioCache(fixedPlayer: stpAudioPlayer, respectSilence: true);
final AudioPlayer stpPwrAudioPlayer = AudioPlayer();
final AudioCache stpPwrAudioCache = AudioCache(fixedPlayer: stpPwrAudioPlayer, respectSilence: true);
final AudioPlayer stpExpAudioPlayer = AudioPlayer();
final AudioCache stpExpAudioCache = AudioCache(fixedPlayer: stpExpAudioPlayer, respectSilence: true);
final AudioPlayer stpSaveAudioPlayer = AudioPlayer();
final AudioCache stpSaveAudioCache = AudioCache(fixedPlayer: stpSaveAudioPlayer, respectSilence: true);
final AudioPlayer stpBgAudioPlayer = AudioPlayer();
final AudioCache stpBgAudioCache = AudioCache(fixedPlayer: stpBgAudioPlayer, respectSilence: true);
