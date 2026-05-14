import 'package:photo_manager/photo_manager.dart';

import '../models/screenshot_model.dart';
import '../models/category_model.dart';

class PhotoService {
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth;
  }

  Future<bool> get hasPermission async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth;
  }

  /// Load all screenshots from the device gallery, newest first.
  Future<List<AssetEntity>> loadScreenshots({int page = 0, int pageSize = 100}) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(
          sizeConstraint: SizeConstraint(minWidth: 100, minHeight: 100),
        ),
      ),
    );

    // Find the Screenshots album first, fall back to all images
    AssetPathEntity? screenshotAlbum;
    for (final album in albums) {
      if (album.name.toLowerCase().contains('screenshot')) {
        screenshotAlbum = album;
        break;
      }
    }

    final targetAlbum = screenshotAlbum ?? (albums.isNotEmpty ? albums.first : null);
    if (targetAlbum == null) return [];

    return targetAlbum.getAssetListPaged(page: page, size: pageSize);
  }

  /// Convert a gallery AssetEntity into a ScreenshotModel stub (unprocessed).
  Future<ScreenshotModel?> assetToScreenshotStub(
      AssetEntity asset, String id) async {
    final file = await asset.file;
    if (file == null) return null;

    return ScreenshotModel(
      id: id,
      localPath: file.path,
      category: ScreenshotCategory.miscellaneous,
      confidenceScore: 0.0,
      capturedAt: asset.createDateTime,
      processedAt: DateTime.now(),
      isProcessed: false,
    );
  }

  /// Load all assets and convert them to stubs for processing.
  Future<List<ScreenshotModel>> loadAllAsStubs() async {
    final assets = await loadScreenshots(pageSize: 500);
    final stubs = <ScreenshotModel>[];
    for (int i = 0; i < assets.length; i++) {
      final stub = await assetToScreenshotStub(assets[i], assets[i].id);
      if (stub != null) stubs.add(stub);
    }
    return stubs;
  }

  Future<int> getTotalScreenshotCount() async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );
    AssetPathEntity? screenshotAlbum;
    for (final album in albums) {
      if (album.name.toLowerCase().contains('screenshot')) {
        screenshotAlbum = album;
        break;
      }
    }
    if (screenshotAlbum == null) return 0;
    return screenshotAlbum.assetCountAsync;
  }
}
