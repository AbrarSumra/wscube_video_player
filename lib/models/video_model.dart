/*
class AllVideo {
  List<CategoryModel> videos;

  AllVideo({required this.videos});

  factory AllVideo.fromJson(Map<String, dynamic> json) {
    List<CategoryModel> allVideos = [];

    for (Map<String, dynamic> eachVideo in json["categories"]) {
      allVideos.add(CategoryModel.fromJson(eachVideo));
    }

    return AllVideo(videos: allVideos);
  }
}
*/

class CategoryModel {
  String? name;
  List<VideoModel>? video;

  CategoryModel({required this.name, required this.video});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<VideoModel> allVideo = [];

    for (Map<String, dynamic> eachVideo in json["video"]) {
      allVideo.add(VideoModel.fromJson(eachVideo));
    }

    return CategoryModel(
      name: json["name"],
      video: allVideo,
    );
  }
}

class VideoModel {
  String? description;
  List<String>? sources;
  String? subtitle;
  String? thumb;
  String? title;

  VideoModel({
    required this.description,
    required this.sources,
    required this.subtitle,
    required this.thumb,
    required this.title,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    List<String> allSources = [];

    for (String eachSource in json["sources"]) {
      allSources.add(eachSource);
    }

    return VideoModel(
      description: json["description"],
      sources: allSources,
      subtitle: json["subtitle"],
      thumb: json["thumb"],
      title: json["title"],
    );
  }
}
