abstract class GrandDesignState {}

class GrandDesignLoading extends GrandDesignState {}

class GrandDesignLoaded extends GrandDesignState {
  final String pdfPath; // Path ke PDF (asset atau URL)
  final String coverPath; // Path ke cover image (opsional, untuk preview)
  GrandDesignLoaded(this.pdfPath, this.coverPath);
}

class GrandDesignError extends GrandDesignState {
  final String message;
  GrandDesignError(this.message);
}
