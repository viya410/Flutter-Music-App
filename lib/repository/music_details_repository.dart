import 'package:MusicLyrics/constants.dart';
import 'package:MusicLyrics/models/music_details.dart';
import 'package:MusicLyrics/networking/api_provider.dart';
import 'dart:async';

class MusicDetailsRepository {
  final int trackId;
  MusicDetailsRepository({this.trackId});
  ApiProvider _provider = ApiProvider();
  Future<MusicDetails> fetchMusicDetailsData() async {
    final response =
        await _provider.get("track.get?track_id=$trackId&apikey=$apikey");
    return MusicDetails.fromJson(response);
  }
}
