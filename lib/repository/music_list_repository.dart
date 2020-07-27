import 'package:MusicLyrics/constants.dart';
import 'package:MusicLyrics/networking/api_provider.dart';
import 'dart:async';
import 'package:MusicLyrics/models/music_list.dart';

class MusicListRepository {
  ApiProvider _provider = ApiProvider();
  Future<MusicList> fetchMusicListData() async {
    final response = await _provider.get("chart.tracks.get?apikey=$apikey");
    return MusicList.fromJson(response);
  }
}
