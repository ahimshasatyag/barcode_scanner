/// Model pembungkus generik respon API backend
class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.statusCode,
    this.data,
    this.message,
    this.errors,
  });

  final bool isSuccess;
  final int statusCode;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  factory ApiResponse.success({
    required int statusCode,
    T? data,
    String? message,
  }) {
    return ApiResponse<T>(
      isSuccess: true,
      statusCode: statusCode,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.failure({
    required int statusCode,
    String? message,
    Map<String, dynamic>? errors,
    T? data,
  }) {
    return ApiResponse<T>(
      isSuccess: false,
      statusCode: statusCode,
      message: message ?? 'Request gagal dengan status $statusCode',
      errors: errors,
      data: data,
    );
  }

  @override
  String toString() => 'ApiResponse(status: $statusCode, success: $isSuccess, message: $message)';
}

