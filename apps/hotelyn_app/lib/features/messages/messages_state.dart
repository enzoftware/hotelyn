sealed class MessagesState {}

class MessagesLoading extends MessagesState {}

class MessagesEmpty extends MessagesState {}

class MessagesLoadSuccess extends MessagesState {}

class MessagesError extends MessagesState {}
