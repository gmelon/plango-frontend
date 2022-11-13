import 'dart:math';

import 'package:dio/dio.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plango/record_plan_random.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchHelper {
  static Future<List<SearchResult>> searchAddress(
      String query, bool addressDepend) async {
    if (query.isEmpty) {
      throw "쿼리 입력 없음";
    }
    var dio = Dio();
    dio.options.headers = {
      "Authorization": "KakaoAK 8390f27cab89e7f2f79db321fc0d51e7"
    };
    var result = await dio.get(
        "https://dapi.kakao.com/v2/local/search/keyword.json?query=$query");

    // 리스트 초기화
    List<SearchResult> list = [];
    // 검색 결과 리스트에 추가
    for (int i = 0; i < result.data["documents"].length; i++) {
      var map = result.data["documents"][i];
      if (addressDepend) {
        // addressDepend가 true인 경우, 주소가 없으면 제외
        if (map["road_address_name"].isEmpty) {
          continue;
        }
      }
      list.add(SearchResult(map["place_name"], map["place_url"],
          map["road_address_name"], map["x"], map["y"]));
    }
    return list;
  }

  static Future<SearchResult> getRandomPlace(
      RandomParameter randomParameter) async {
    var dio = Dio();
    Random random = Random();

    dio.options.headers = {
      "Authorization": "KakaoAK 8390f27cab89e7f2f79db321fc0d51e7"
    };

    // 최초 호출이 아닌 경우, itemCount를 고려해 여러 페이지의 item을 불러올 수 있도록 함
    int randomPageNum = 1;
    if (randomParameter.itemCount != 0) {
      int pageCount = randomParameter.itemCount ~/ 15;
      randomPageNum = random.nextInt(pageCount) + 1;
    }

    var result = await dio.get(
        "https://dapi.kakao.com/v2/local/search/category?category_group_code=${randomParameter.categoryGroupCode}&x=${randomParameter.x}&y=${randomParameter.y}&radius=${randomParameter.radius * 1000}&page=$randomPageNum");

    // 다음 호출을 위해 itemCount를 저장
    randomParameter.itemCount = result.data["meta"]["pageable_count"];

    // item 랜덤 선택
    var list = result.data["documents"];
    if (list.length == 0) {
      throw "검색 결과가 없습니다!";
    }
    var randomItem = list[random.nextInt(list.length)];
    return SearchResult(randomItem["place_name"], randomItem["place_url"],
        randomItem["road_address_name"], randomItem["x"], randomItem["y"]);
  }

  static Future<SearchResult> getCurrentLocationObject() async {
    double x = 0;
    double y = 0;
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // 자표 얻기
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw "현 위치 불러오기 오류";
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw "현 위치 불러오기 오류";
      }
    }

    await location.getLocation().then((res) {
      x = res.longitude!;
      y = res.latitude!;
    });

    // 좌표 -> 주소 검색
    var dio = Dio();

    dio.options.headers = {
      "Authorization": "KakaoAK 8390f27cab89e7f2f79db321fc0d51e7"
    };
    // 먼저 호출하여 전체 페이지 불러오고, 페이지도 랜덤으로 호출 (km 실질 반영 위함)
    var result = await dio
        .get("https://dapi.kakao.com/v2/local/geo/coord2address?x=$x&y=$y");

    if (result.data["documents"].length >= 1) {
      return SearchResult(
          "placeName",
          "placeUrl",
          result.data["documents"][0]["road_address"]["address_name"],
          x.toString(),
          y.toString());
    } else {
      throw "현 위치 불러오기 오류";
      ;
    }
  }

  static Future<String> getStaticMap(String x, String y) async {
    var dio = Dio();
    dio.options.headers = {
      "X-NCP-APIGW-API-KEY-ID": "bonvpn2tlu",
      "X-NCP-APIGW-API-KEY": "mdNwz2Yzuvng3uH8wfo0JKIFc4FEnrWBb3k13lik"
    };
    var dir = await getTemporaryDirectory();
    String path = "${dir.path}/${DateTime.now()}";
    await dio.download(
        "https://naveropenapi.apigw.ntruss.com/map-static/v2/raster?w=300&h=300&markers=type:d|size:small|pos:$x%20$y&scale=2&level=14&center=$x,$y",
        path);
    return path;
  }

  static Future<String> getImageOfStore(String query) async {
    if (query.isEmpty) {
      return Future.error(Exception("쿼리 파라미터가 없습니다."));
    }
    var dio = Dio();
    dio.options.headers = {
      "X-Naver-Client-Id": "7B41JjJ4kLfemTltNrkf",
      "X-Naver-Client-Secret": "SCZVUt6Udr"
    };
    var result =
        await dio.get("https://openapi.naver.com/v1/search/image?query=$query");
    if (result.data["items"].length <= 0) {
      return "";
    }
    return result.data["items"][0]["link"];
  }

  static Future<void> openWeb(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: true, forceWebView: true);
    } else {
      throw "호출 실패";
    }
  }
}

class SearchResult {
  String placeName;
  String placeUrl;
  String roadAddressName;
  String x;
  String y;

  SearchResult(
      this.placeName, this.placeUrl, this.roadAddressName, this.x, this.y);
}
