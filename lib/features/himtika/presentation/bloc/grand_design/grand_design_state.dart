abstract class GrandDesignState {}

class GrandDesignLoading extends GrandDesignState {}

class GrandDesignLoaded extends GrandDesignState {
  final List<String> pages; // asset paths
  GrandDesignLoaded(this.pages);
}

class GrandDesignError extends GrandDesignState {
  final String message;
  GrandDesignError(this.message);
}
