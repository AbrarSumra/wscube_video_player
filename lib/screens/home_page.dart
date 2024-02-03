import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:video_player/video_player.dart';

import '../models/video_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? allVideo;
  bool _controlsVisible = false;
  bool _isRotate = false;
  Timer? _hideControlsTimer;

  String uri =
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  Future<void>? initialized;

  @override
  void initState() {
    super.initState();

    /// For Video Player
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(uri));
    chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        aspectRatio: 16 / 9,
        autoInitialize: true,
        autoPlay: true,
        looping: true);
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
        ),
        body: GestureDetector(
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
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: RotatedBox(
                    quarterTurns: _isRotate ? 1 : 0,
                    child: AspectRatio(
                      aspectRatio: videoPlayerController!.value.aspectRatio,
                      child: Stack(
                        children: [
                          VideoPlayer(videoPlayerController!),
                          if (_controlsVisible) // For auto hide Controls
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          formatDuration(videoPlayerController!
                                              .value.position),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          formatDuration(videoPlayerController!
                                              .value.duration),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Slider(
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
                                          Duration(seconds: seekTo.toInt()));
                                      setState(() {});
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                            videoPlayerController!.pause();
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
                                              : const Icon(Icons.play_arrow,
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
                            ),
                          if (_controlsVisible)
                            Positioned(
                              bottom: 0,
                              right: 0,
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
                            )
                        ],
                      ),
                    ),
                  ),
                );
              }
              return Container();
            },
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
      try {
        var mData = jsonDecode(response.body);
        var categories = mData["categories"] as List;
        if (categories.isNotEmpty) {
          var data = CategoryModel.fromJson(mData["categories"][0]);
          return data;
        } else {
          throw Exception("No categories found in the JSON data");
        }
      } catch (e) {
        throw Exception("Failed to parse JSON data. Error: $e");
      }
    } else {
      throw Exception(
          "Failed to load data. Status Code: ${response.statusCode}");
    }
  }
}
