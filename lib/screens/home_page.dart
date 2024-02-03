import 'dart:convert';

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

  String uri =
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4";
  VideoPlayerController? videoPlayerController;
  Future<void>? initialized;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(uri));
    initialized = videoPlayerController!.initialize();
    videoPlayerController!.addListener(() {
      setState(() {});
    });
    //getAllVideo();
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
      body: FutureBuilder(
        future: initialized,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AspectRatio(
                aspectRatio: videoPlayerController!.value.aspectRatio,
                child: InkWell(
                  onTap: () {
                    if (videoPlayerController!.value.isPlaying) {
                      videoPlayerController!.pause();
                    } else {
                      videoPlayerController!.play();
                    }
                    setState(() {});
                  },
                  child: Stack(
                    children: [
                      VideoPlayer(videoPlayerController!),
                      Center(
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: videoPlayerController!.value.isPlaying
                              ? const Icon(Icons.pause)
                              : const Icon(Icons.play_arrow),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Slider(
                          min: 0,
                          max: videoPlayerController!.value.duration.inSeconds
                              .toDouble(),
                          inactiveColor: Colors.black,
                          activeColor: Colors.orange,
                          value: videoPlayerController!.value.position.inSeconds
                              .toDouble(),
                          onChanged: (seekTo) {
                            videoPlayerController!
                                .seekTo(Duration(seconds: seekTo.toInt()));
                            setState(() {});
                          },
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

      /*FutureBuilder<CategoryModel>(
        future: getAllVideo(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            var video = snapshot.data!;
            Text(snapshot.data!.name!);
            */ /*return ListView.builder(
              // itemCount: snapshot.data!,
              itemBuilder: (_, index) {
                return Container();
              },
            );*/ /*
          }

          return Container();
        },
      )*/
    );
  }

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
