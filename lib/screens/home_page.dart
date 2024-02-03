import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:video_player/video_player.dart';
import 'package:wscube_video_player/models/videos_data.dart';
import 'package:wscube_video_player/screens/video_detail_page.dart';

import '../models/video_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CategoryModel? allVideo;

  String uri =
      "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4";

  Future<void>? initialized;
  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    // For Video Player
    videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(uri));
    initialized = videoPlayerController!.initialize();
    videoPlayerController!.addListener(() {
      setState(() {});
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
      body: FutureBuilder(
        future: initialized,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            return ListView.builder(
              itemCount: mediaJSON.length,
              itemBuilder: (_, index) {
                var video = mediaJSON[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (ctx) => VideoDetailPage(
                                  url: video["sources"],
                                  title: video["title"],
                                  subtitle: video["subtitle"],
                                  description: video["description"],
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 100,
                          child: Image.network(
                            "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/${video["thumb"]}",
                            height: 100,
                            width: 200,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(video["subtitle"]),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }

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
