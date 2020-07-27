import 'package:MusicLyrics/constants.dart';
import 'package:MusicLyrics/models/music_lyrics.dart';
import 'package:MusicLyrics/networking/api_provider.dart';
import 'dart:async';

class MusicLyricsRepository {
  final int trackId;
  MusicLyricsRepository({this.trackId});
  ApiProvider _provider = ApiProvider();
  Future<MusicLyrics> fetchMusicDetailsData() async {
    final response = await _provider
        .get("track.lyrics.get?track_id=$trackId&apikey=$apikey");
    return MusicLyrics.fromJson(response);
  }
}
