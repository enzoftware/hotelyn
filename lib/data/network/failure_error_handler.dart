class Failure {
  Failure(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => 'Error $statusCode. $message.';
}
