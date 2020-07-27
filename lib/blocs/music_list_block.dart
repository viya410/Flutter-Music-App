import 'dart:async';
import 'package:MusicLyrics/networking/response.dart';
import 'package:MusicLyrics/repository/music_list_repository.dart';
import 'package:MusicLyrics/models/music_list.dart';

class MusicListBloc {
  MusicListRepository _musicListRepository;
  StreamController _musicListController;

  StreamSink<Response<MusicList>> get musicListSink =>
      _musicListController.sink;

  Stream<Response<MusicList>> get musicListStream =>
      _musicListController.stream;

  MusicListBloc() {
    _musicListController = StreamController<Response<MusicList>>.broadcast();
    _musicListRepository = MusicListRepository();
    fetchMusicList();
  }

  fetchMusicList() async {
    musicListSink.add(Response.loading('Loading list. '));
    try {
      MusicList musicList = await _musicListRepository.fetchMusicListData();
      musicListSink.add(Response.completed(musicList));
    } catch (e) {
      musicListSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _musicListController?.close();
  }
}
