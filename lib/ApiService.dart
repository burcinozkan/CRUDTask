import 'package:dio/dio.dart';

class ApiService{
  final String apiKey;
  final Dio _dio=Dio();

  ApiService(this.apiKey);

  Future<Response> validateApiKey() async {
    return await _dio.get(
      "https://crudcrud.com/api/$apiKey",
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
  }
  Future<Response> fetchData() async {
    return await _dio.get(
      "https://crudcrud.com/api/$apiKey/users",
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
  }
  Future<Response> addUser(String name, String imagePath, String birthday) async {
    return await _dio.post(
      "https://crudcrud.com/api/$apiKey/users",
      data: {'name': name, 'imagePath': imagePath, 'birthday': birthday},
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
  }

  Future<Response> deleteUser(String id) async {
    return await _dio.delete(
      "https://crudcrud.com/api/$apiKey/users/$id",
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
  }
  Future<Response> updateUser(String id, String name, String imagePath, String birthday) async {
    return await _dio.put(
      "https://crudcrud.com/api/$apiKey/users/$id",
      data: {'name': name, 'imagePath': imagePath, 'birthday': birthday},
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
  }
}



