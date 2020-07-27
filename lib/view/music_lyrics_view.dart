import 'package:MusicLyrics/blocs/music_details_bloc.dart';
import 'package:MusicLyrics/blocs/music_lyrics_bloc.dart';
import 'package:MusicLyrics/models/music_details.dart';
import 'package:MusicLyrics/models/music_lyrics.dart';
import 'package:MusicLyrics/networking/response.dart';
import 'package:MusicLyrics/view/music_list_view.dart';
import 'package:flutter/material.dart';

class GetMusicLyrics extends StatefulWidget {
  final int trackId;
  GetMusicLyrics({this.trackId});
  @override
  _GetMusicLyricsState createState() => _GetMusicLyricsState();
}

class _GetMusicLyricsState extends State<GetMusicLyrics> {
  MusicDetailsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = MusicDetailsBloc(trackId: widget.trackId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
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
      ),
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchMusicDetails(),
        child: StreamBuilder<Response<MusicDetails>>(
          stream: _bloc.musicDetailsStream,
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
                    trackId: widget.trackId,
                  );
                  break;
                case Status.ERROR:
                  break;
              }
            }
            return Container();
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
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
              stream: _bloc.musicLyricsStream,
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
                return Container();
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
