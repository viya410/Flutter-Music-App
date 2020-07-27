import 'package:MusicLyrics/blocs/music_details_bloc.dart';
import 'package:MusicLyrics/blocs/music_lyrics_bloc.dart';
import 'package:MusicLyrics/models/music_details.dart';
import 'package:MusicLyrics/models/music_lyrics.dart';
import 'package:MusicLyrics/networking/response.dart';
import 'package:MusicLyrics/view/music_list_view.dart';
import 'package:flutter/material.dart';
import 'package:MusicLyrics/blocs/connectivity_bloc.dart';
import 'package:connectivity/connectivity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:MusicLyrics/models/music_list.dart' as ListTrack;

class GetMusicLyrics extends StatefulWidget {
  final ListTrack.Track trackCurrent;
  GetMusicLyrics({@required this.trackCurrent});
  @override
  _GetMusicLyricsState createState() => _GetMusicLyricsState();
}

class _GetMusicLyricsState extends State<GetMusicLyrics> {
  ConnectivityBloc _netBloc;
  MusicDetailsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _netBloc = ConnectivityBloc();
    _bloc = MusicDetailsBloc(trackId: widget.trackCurrent.trackId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: LyricAppBar(
            track: widget.trackCurrent,
          )),
      body: StreamBuilder<ConnectivityResult>(
          stream: _netBloc.connectivityResultStream.asBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              switch (snapshot.data) {
                case ConnectivityResult.mobile:
                case ConnectivityResult.wifi:
                  _bloc.fetchMusicDetails();
                  print('NET2 : ');
                  return RefreshIndicator(
                    onRefresh: () => _bloc.fetchMusicDetails(),
                    child: StreamBuilder<Response<MusicDetails>>(
                      stream: _bloc.musicDetailsStream.asBroadcastStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          switch (snapshot.data.status) {
                            case Status.LOADING:
                              return Loading(
                                loadingMessage: snapshot.data.message,
                              );
                              break;
                            case Status.COMPLETED:
                              return TrackDetails(
                                musicDetails: snapshot.data.data,
                                trackId: widget.trackCurrent.trackId,
                              );
                              break;
                            case Status.ERROR:
                              return Text('Errror');
                              break;
                          }
                        }
                        return Loading(
                          loadingMessage: 'Connecting',
                        );
                      },
                    ),
                  );
                  break;
                case ConnectivityResult.none:
                  print('No Net : ');
                  return Center(
                    child: Text('No internet'),
                  );
                  break;
              }
            }
            return Text('Check Connectivity object');
          }),
    );
  }

  @override
  void dispose() {
    _netBloc.dispose();
    _bloc.dispose();
    super.dispose();
  }
}

class TrackDetails extends StatefulWidget {
  final MusicDetails musicDetails;
  final int trackId;
  TrackDetails({this.musicDetails, @required this.trackId});

  @override
  _TrackDetailsState createState() => _TrackDetailsState();
}

class _TrackDetailsState extends State<TrackDetails> {
  MusicLyricsBloc _bloc;
  @override
  void initState() {
    super.initState();
    _bloc = MusicLyricsBloc(trackId: widget.trackId);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Track track = widget.musicDetails.message.body.track;
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: <Widget>[
          InfoTile(
            heading: 'Name',
            body: track.trackName,
          ),
          InfoTile(
            heading: 'Artist',
            body: track.artistName,
          ),
          InfoTile(
            heading: 'Album Name',
            body: track.albumName,
          ),
          InfoTile(
            heading: 'Explicit',
            body: track.explicit == 1 ? 'True' : 'False',
          ),
          InfoTile(
            heading: 'Rating',
            body: track.trackRating.toString(),
          ),
          StreamBuilder<Response<MusicLyrics>>(
              stream: _bloc.musicLyricsStream.asBroadcastStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  switch (snapshot.data.status) {
                    case Status.LOADING:
                      return Loading(
                        loadingMessage: snapshot.data.message,
                      );
                      break;
                    case Status.COMPLETED:
                      return InfoTile(
                        heading: 'Lyrics',
                        body: snapshot.data.data.message.body.lyrics.lyricsBody,
                      );
                      break;
                    case Status.ERROR:
                      break;
                  }
                }
                return Loading(
                  loadingMessage: '',
                );
              })
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String heading;
  final String body;
  InfoTile({this.heading, @required this.body});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 15.0,
        ),
        Text(
          heading,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
        ),
        Text(
          body,
          style: TextStyle(fontSize: 20.0),
        ),
      ],
    );
  }
}

class LyricAppBar extends StatefulWidget {
  final ListTrack.Track track;
  LyricAppBar({@required this.track});
  @override
  _LyricAppBarState createState() => _LyricAppBarState();
}

class _LyricAppBarState extends State<LyricAppBar> {
  IconData bookmarkIcon = Icons.bookmark_border;
  bool changed = false;
  void checkBookmarkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final stringList = prefs.getStringList('bookmarkList') ?? [];
    setState(() {
      if (stringList.contains(widget.track.trackId.toString())) {
        bookmarkIcon = Icons.bookmark;
      } else {
        bookmarkIcon = Icons.bookmark_border;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkBookmarkStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.white,
      elevation: 5.0,
      centerTitle: true,
      title: Text(
        'Track Details',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            bookmarkIcon,
            color: Colors.black,
          ),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final trackIDList = prefs.getStringList('bookmarkList') ?? [];
            final trackNameList = prefs.getStringList('nameList') ?? [];
            final trackAlbumList = prefs.getStringList('albumList') ?? [];
            final trackArtistList = prefs.getStringList('artistList') ?? [];
            setState(() {
              changed = true;
              if (bookmarkIcon == Icons.bookmark_border) {
                bookmarkIcon = Icons.bookmark;
                trackIDList.add(widget.track.trackId.toString());
                trackNameList.add(widget.track.trackName);
                trackAlbumList.add(widget.track.albumName);
                trackArtistList.add(widget.track.artistName);
              } else {
                bookmarkIcon = Icons.bookmark_border;
                if (prefs.containsKey('bookmarkList') &&
                    trackIDList.contains(widget.track.trackId.toString())) {
                  int index =
                      trackIDList.indexOf(widget.track.trackId.toString());
                  trackIDList.removeAt(index);
                  trackNameList.removeAt(index);
                  trackAlbumList.removeAt(index);
                  trackArtistList.removeAt(index);
                }
              }
              prefs.setStringList('bookmarkList', trackIDList);
              prefs.setStringList('nameList', trackNameList);
              prefs.setStringList('albumList', trackAlbumList);
              prefs.setStringList('artistList', trackArtistList);
            });
            print(trackIDList.toString());
            print(trackNameList.toString());
            print(trackAlbumList.toString());
            print(trackArtistList.toString());
          },
        )
      ],
    );
  }
}
