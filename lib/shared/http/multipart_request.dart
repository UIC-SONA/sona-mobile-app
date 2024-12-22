import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:sona/shared/http/exceptions.dart';
import 'package:sona/shared/http/extensions.dart';
import 'package:sona/shared/http/types.dart';

final Logger _log = Logger(level: Level.debug);

typedef ProgressCallback = void Function(int bytes, int totalBytes);
typedef MultipartRequestFactory = Future<void> Function(MultipartRequestAccessor request);

class RequesPart {
  final String field;
  final List<int> value;
  final String? filename;
  final String contentType;

  RequesPart(this.field, this.value, this.filename, {this.contentType = 'application/octet-stream'});

  RequesPart.applicationJson(this.field, this.value, this.filename) : contentType = 'application/json';

  RequesPart.textPlain(this.field, this.value, this.filename) : contentType = 'text/plain';
}

Future<StreamedResponse> multipartRequest(
  Uri url, {
  HttpMethod method = HttpMethod.get,
  MultipartRequestFactory? factory,
  ProgressCallback? onProgress,
  Map<String, String>? headers,
  Client? client,
}) async {
  final _MultipartRequest request = _MultipartRequest(url, method: method, onProgress: onProgress);
  if (headers != null) request.headers.addAll(headers);
  if (factory != null) await factory(request);

  final response = await (client == null ? request.send() : request.sendWithClient(client));
  if (response.error) {
    throw HttpException(response.status.message, response: await Response.fromStream(response));
  }

  return response;
}

abstract class MultipartRequestAccessor {
  Map<String, String> get fields;

  List<MultipartFile> get files;

  List<RequesPart> get parts;

  Map<String, List<int>> get bytes;
}

class _MultipartRequest extends BaseRequest implements MultipartRequestAccessor {
  static const int _boundaryLength = 70;

  static final Random _random = Random();

  final Map<String, String> _fields = <String, String>{};
  final List<MultipartFile> _files = <MultipartFile>[];
  final List<RequesPart> _parts = <RequesPart>[];
  final ProgressCallback? onProgress;

  @override
  Map<String, String> get fields => _fields;

  @override
  List<MultipartFile> get files => _files;

  @override
  List<RequesPart> get parts => _parts;

  @override
  Map<String, List<int>> get bytes => {};

  _MultipartRequest(Uri url, {required HttpMethod method, this.onProgress}) : super(method.value, url);

  @override
  int get contentLength {
    var length = 0;
    var endLineLength = '\r\n'.length;
    var separatorBoundaryLength = '--'.length + _boundaryLength + endLineLength;
    var closeBoundaryLength = '--'.length + _boundaryLength + '--'.length + endLineLength;

    for (var field in _fields.entries) {
      length += separatorBoundaryLength + utf8.encode(_headerForField(field.key, field.value)).length + utf8.encode(field.value).length + endLineLength;
    }
    for (var file in _files) {
      length += separatorBoundaryLength + utf8.encode(_headerForFile(file)).length + file.length + endLineLength;
    }
    for (var part in _parts) {
      length += separatorBoundaryLength + utf8.encode(_headerForPart(part)).length + part.value.length + endLineLength;
    }

    return length + closeBoundaryLength;
  }

  @override
  set contentLength(int? value) {
    throw UnsupportedError('Cannot set the contentLength property of multipart requests.');
  }

  @override
  ByteStream finalize() {
    super.finalize();

    final String boundary = _boundaryString();
    headers['content-type'] = 'multipart/form-data; boundary=$boundary';

    final Stream<List<int>> stream = _finalize(boundary);

    final int total = contentLength;
    int bytes = 0;

    final transformer = StreamTransformer.fromHandlers(
      handleData: (List<int> data, EventSink<List<int>> sink) {
        bytes += data.length;
        onProgress?.call(bytes, total);
        _log.d("Upload progress [${url.path}]: (${(bytes / total * 100).toStringAsFixed(2)}%)");
        sink.add(data);
      },
      handleDone: (sink) => sink.close(),
      handleError: (error, stackTrace, sink) => sink.addError(error, stackTrace),
    );

    return ByteStream(stream.transform(transformer));
  }

  Stream<List<int>> _finalize(String boundary) async* {
    const line = [13, 10]; // \r\n
    final separator = utf8.encode('--$boundary\r\n');
    final Uint8List close = utf8.encode('--$boundary--\r\n');

    Stream<List<int>> getStream<T>(Iterable<T> list, Stream<List<int>> Function(T) stream) async* {
      for (T item in list) {
        yield separator;
        yield* stream(item);
        yield line;
      }
    }

    yield* getStream(_fields.entries, (field) async* {
      final header = utf8.encode(_headerForField(field.key, field.value));
      yield header;
      final value = utf8.encode(field.value);
      yield value;
    });

    yield* getStream(_files, (file) async* {
      yield utf8.encode(_headerForFile(file));
      yield* file.finalize();
    });

    yield* getStream(_parts, (part) async* {
      yield utf8.encode(_headerForPart(part));
      yield* ByteStream.fromBytes(part.value);
    });

    yield close;
  }

  Future<StreamedResponse> sendWithClient(Client client) async {
    final StreamedResponse response = await client.send(this);
    final Stream<List<int>> stream = onDone(response.stream, () {});

    return _streamedResponse(stream, response);
  }

  String _headerForField(String name, String value) {
    return _headerFor(name, headers: isPlainAscii(value) ? null : {'content-type': 'text/plain; charset=utf-8', 'content-transfer-encoding': 'binary'});
  }

  String _headerForFile(MultipartFile file) {
    return _headerFor(file.field, contentType: file.contentType.toString(), filename: file.filename);
  }

  String _headerForPart(RequesPart part) {
    return _headerFor(part.field, contentType: part.contentType, filename: part.filename);
  }

  String _headerFor(String field, {String? contentType, String? filename, Map<String, String>? headers}) {
    var header = 'content-disposition: form-data; name="${_browserEncode(field)}"${filename != null ? '; filename="${_browserEncode(filename)}"' : ''}';
    if (contentType != null) header = '$header\r\ncontent-type: $contentType';
    headers?.forEach((key, value) => header = '$header\r\n$key: $value');
    return '$header\r\n\r\n';
  }

  String _browserEncode(String value) => value.replaceAll(_newlineRegExp, '%0D%0A').replaceAll('"', '%22');

  String _boundaryString() {
    var prefix = 'dart-http-boundary-';
    var list = List<int>.generate(_boundaryLength - prefix.length, (index) => boundaryCharacters[_random.nextInt(boundaryCharacters.length)], growable: false);
    return '$prefix${String.fromCharCodes(list)}';
  }

  StreamedResponse _streamedResponse(Stream<List<int>> stream, BaseResponse response) {
    return StreamedResponse(
      ByteStream(stream),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }
}

final _newlineRegExp = RegExp(r'\r\n|\r|\n');
final _asciiOnly = RegExp(r'^[\x00-\x7F]+$');

bool isPlainAscii(String string) => _asciiOnly.hasMatch(string);

Stream<T> onDone<T>(Stream<T> stream, void Function() onDone) {
  return stream.transform(
    StreamTransformer.fromHandlers(
      handleDone: (sink) {
        sink.close();
        onDone();
      },
    ),
  );
}

const List<int> boundaryCharacters = <int>[43, 95, 45, 46, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122];
