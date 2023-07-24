import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'song_model.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Stream Demo',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Song> _songs = <Song>[];
  final AudioPlayer _audioPlayer = AudioPlayer();
  Song? _currentSong;
  Duration _songDuration = const Duration();
  Duration _currentPosition = const Duration();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _songDuration = duration;
      });
    });

    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        _currentPosition = duration;
      });
    });
  }

  Future<void> _loadSongs() async {
    final String response = await rootBundle.loadString('assets/music_data.json');
    final List songsJson = json.decode(response);
    setState(() {
      _songs = songsJson.map((song) => Song.fromJson(song)).toList();
    });
  }

  Future<void> _playSong(Song song) async {
    _showLoadingSnackbar();
    await _audioPlayer.play(UrlSource(song.url));
    setState(() {
      _currentSong = song;
    });
    _dismissSnackbar();
  }

  void _showLoadingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 12),
            Text('Loading...', style: TextStyle(fontSize: 15),),
          ],
        ),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _dismissSnackbar() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  String _formatDuration(Duration duration) {
    String minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Music Stream Demo'),
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          return ListTile(
            leading: Image.network(song.coverUrl),
            title: Text(song.title),
            subtitle: Text(song.singer),
            onTap: () => _playSong(song),
          );
        },
      ),
      bottomSheet: _currentSong == null
          ? null
          : Container(
        color: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: <Widget>[
                  Image.network(_currentSong!.coverUrl, height: 50, width: 50),
                  const SizedBox(width: 8),
                  Text(_currentSong!.title),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      _audioPlayer.stop();
                      setState(() {
                        _currentSong = null;
                      });
                    },
                  ),
                ],
              ),
              Slider(
                activeColor: Colors.grey.shade900,
                inactiveColor: Colors.grey.shade300,
                value: _currentPosition.inSeconds.toDouble(),
                min: 0.0,
                max: _songDuration.inSeconds.toDouble(),
                onChanged: (value) {
                  Duration newPosition = Duration(seconds: value.toInt());
                  _audioPlayer.seek(newPosition);
                },
              ),
              Text(
                "${_formatDuration(_currentPosition)} / ${_formatDuration(_songDuration)}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
