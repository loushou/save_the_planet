import 'package:savetheplanet/helpers/sound.dart';

Future<void> preloadLibraries() {
  stpExpAudioCache.load('sounds/explosion.mp3');
  stpSaveAudioCache.load('sounds/saved.mp3');
  stpAudioCache.load('sounds/fire.mp3');
  stpPwrAudioCache.load('sounds/powerup.mp3');
  stpAudioCache.load('sounds/failure.mp3');
  stpBgAudioCache.load('music/music.mp3');
  stpBgAudioCache.load('music/menu-music.mp3');

  stpAudioCache.disableLog();
  stpBgAudioCache.disableLog();
}
