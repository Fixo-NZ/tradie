import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradie/features/notification/models/notification_model.dart';
import 'package:tradie/features/notification/repositories/notification_repository.dart';

class _MockAdapter implements HttpClientAdapter {
  final dynamic responseData;
  _MockAdapter(this.responseData);

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future? cancelFuture,
  ) async {
    final body = json.encode(responseData);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void main() {
  test('fetchNotifications parses backend response with Map data', () async {
    final backendResponse = {
      'success': true,
      'data': [
        {
          'id': 'abbabfa7-f896-4722-be33-82d037580e50',
          'type': 'JobBookedNotification',
          'data': {
            'type': 'job_booked',
            'title': 'New Job Request',
            'message': 'A homeowner has booked you.',
            'booking_id': 17,
            'service_id': 1,
            'booking_start': '2025-12-21T10:00:00.000',
            'booking_end': '2025-12-21T12:00:00.000',
          },
          'read_at': null,
          'created_at': '2025-12-15T11:27:19.000000Z',
        },
      ],
    };

    final dio = Dio();
    dio.httpClientAdapter = _MockAdapter(backendResponse);
    final repo = NotificationRepository(dio: dio);

    final list = await repo.fetchNotifications();

    expect(list, isNotEmpty);
    final n = list.first;
    expect(n.title, 'New Job Request');
    expect(n.message, 'A homeowner has booked you.');
  });

  test('fetchNotifications parses backend response with String data', () async {
    final inner = json.encode({
      'type': 'job_booked',
      'title': 'New Job Request',
      'message': 'A homeowner has booked you.',
    });

    final backendResponse = {
      'success': true,
      'data': [
        {
          'id': 'abbabfa7-f896-4722-be33-82d037580e50',
          'type': 'JobBookedNotification',
          'data': inner,
          'read_at': null,
          'created_at': '2025-12-15T11:27:19.000000Z',
        },
      ],
    };

    final dio = Dio();
    dio.httpClientAdapter = _MockAdapter(backendResponse);
    final repo = NotificationRepository(dio: dio);

    final list = await repo.fetchNotifications();

    expect(list, isNotEmpty);
    final n = list.first;
    expect(n.title, 'New Job Request');
    expect(n.message, 'A homeowner has booked you.');
  });
}
