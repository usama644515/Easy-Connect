import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AudioPlay extends StatefulWidget {
  final url, color, userimage;
  const AudioPlay({Key? key, this.url, this.color, this.userimage})
      : super(key: key);

  @override
  State<AudioPlay> createState() => _AudioPlayState();
}

class _AudioPlayState extends State<AudioPlay> {
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  final audioPlayer = AudioPlayer();
  @override
  void initState() {
    // TODO: implement initState

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        height: 65.0,
        width: MediaQuery.of(context).size.width * 0.7,
        // constraints: BoxConstraints(maxWidth: size.width - size.width * 0.30),
        decoration: widget.color == null
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 74, 110, 228),
                    Color.fromARGB(255, 118, 180, 231),
                  ],
                ),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              )
            : const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15)),
              ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10.0),
          child: Stack(
            children: [
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                      onTap: () async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          var url = widget.url;
                          await audioPlayer.play(UrlSource(url));
                        }
                      },
                      child: Icon(isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 35.0)),
                  const SizedBox(width: 5.0),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.44,
                    child: Slider(
                        min: 0,
                        max: duration.inSeconds.toDouble(),
                        value: position.inSeconds.toDouble(),
                        onChanged: (value) async {
                          final position = Duration(seconds: value.toInt());
                          await audioPlayer.seek(position);
                          await audioPlayer.resume();
                        }),
                  ),
                  CachedNetworkImage(
                    imageUrl: widget.userimage,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        // borderRadius: BorderRadius.circular(50),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ],
              ),
              Positioned(
                top: 47,
                left: 50,
                child: Text(
                  formatTime(position),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }
}
