import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';

class VideoDetailPage extends StatefulWidget {
  final String url;
  final String title;
  final String subtitle;
  final String description;

  const VideoDetailPage({
    super.key,
    required this.url,
    required this.title,
    required this.subtitle,
    required this.description,
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  CategoryModel? allVideo;
  bool _controlsVisible = false;
  bool _isRotate = false;
  Timer? _hideControlsTimer;

  //String uri = widget.url;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? initialized;

  @override
  void initState() {
    super.initState();

    /// For Video Player
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    videoPlayerController!.play();
    /*chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        looping: true);*/
    initialized = videoPlayerController!.initialize();
    videoPlayerController!.addListener(() {
      setState(() {});
    });
    //getAllVideo();

    /// For auto hide Controls
    _hideControlsTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_controlsVisible) {
        setState(() {
          _controlsVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            "Video Player",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: IconButton(
            onPressed: () {
              videoPlayerController!.pause();
              Navigator.pop(context);
              setState(() {});
            },
            icon: const Icon(
              CupertinoIcons.back,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () {
              /// For auto hide Controls
              setState(() {
                _controlsVisible = true;
              });
              _hideControlsTimer!.cancel();
              _hideControlsTimer =
                  Timer.periodic(const Duration(seconds: 5), (timer) {
                if (_controlsVisible) {
                  setState(() {
                    _controlsVisible = false;
                  });
                }
              });
            },
            child: FutureBuilder(
              future: initialized,
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: RotatedBox(
                            quarterTurns: _isRotate ? 1 : 0,
                            child: AspectRatio(
                              aspectRatio:
                                  videoPlayerController!.value.aspectRatio,
                              child: Stack(
                                children: [
                                  VideoPlayer(videoPlayerController!),

                                  /// Play Pause Button
                                  if (_controlsVisible) // For auto hide Controls
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                CupertinoIcons.backward_end,
                                                color: Colors.white,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                if (videoPlayerController!
                                                    .value.isPlaying) {
                                                  videoPlayerController!
                                                      .pause();
                                                } else {
                                                  videoPlayerController!.play();
                                                }
                                                setState(() {});
                                              },
                                              child: Container(
                                                height: 40,
                                                width: 40,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: videoPlayerController!
                                                        .value.isPlaying
                                                    ? const Icon(Icons.pause,
                                                        size: 30)
                                                    : const Icon(
                                                        Icons.play_arrow,
                                                        size: 30),
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {},
                                              icon: const Icon(
                                                CupertinoIcons.forward_end,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                  /// Minutes
                                  if (_controlsVisible)
                                    Positioned(
                                      bottom: 30,
                                      left: 5,
                                      right: 0,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          children: [
                                            Text(
                                              formatDuration(
                                                  videoPlayerController!
                                                      .value.position),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            Text("/"),
                                            Text(
                                              formatDuration(
                                                  videoPlayerController!
                                                      .value.duration),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  /// Slider
                                  if (_controlsVisible)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Slider(
                                        min: 0,
                                        max: videoPlayerController!
                                            .value.duration.inSeconds
                                            .toDouble(),
                                        inactiveColor: Colors.black,
                                        activeColor: Colors.orange,
                                        value: videoPlayerController!
                                            .value.position.inSeconds
                                            .toDouble(),
                                        onChanged: (seekTo) {
                                          videoPlayerController!.seekTo(
                                              Duration(
                                                  seconds: seekTo.toInt()));
                                          setState(() {});
                                        },
                                      ),
                                    ),

                                  /// Rotate Button
                                  if (_controlsVisible)
                                    Positioned(
                                      bottom: 20,
                                      right: 10,
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isRotate = !_isRotate;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey,
                              ),
                              child: Center(
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.thumb_up_alt_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Icons.thumb_down_alt_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey,
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.ios_share,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const Text(
                                    "Share",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          "Description :",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          widget.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
        )

        /*Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: Chewie(controller: chewieController!),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 300,
            child: VideoProgressIndicator(videoPlayerController!,
                allowScrubbing: true),
          ),*/ /*
        ],
      ),*/

        );
  }

  String formatDuration(Duration duration) {
    String min = (duration.inMinutes % 60).toString().padLeft(2, "0");
    String sec = (duration.inSeconds % 60).toString().padLeft(2, "0");

    return "$min:$sec";
  }

  /*String getCurrentTime() {
    var min = videoPlayerController!.value.position.inSeconds.toInt() ~/ 60;
    var sec = videoPlayerController!.value.position.inSeconds.toInt() % 60;

    return "$min: $sec";
  }*/

  Future<CategoryModel> getAllVideo() async {
    var uri = Uri.parse(
        "https://gist.githubusercontent.com/jsturgis/3b19447b304616f18657/raw/a8c1f60074542d28fa8da4fe58c3788610803a65/gistfile1.txt");

    var response = await https.get(uri);

    if (response.statusCode == 200) {
      var mData = jsonDecode(response.body);

      var data = CategoryModel.fromJson(mData);
      print(data);
      return data;
    } else {
      throw Exception(
          "Failed to load data. Status Code: ${response.statusCode}");
    }
  }
}
