import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    excludePrivateDataFromBackups()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// Keeps "Your selfie stays on this device" literally true (ADR 0001 #6,
  /// ADR 0008 #6): the check-in database and managed selfies are excluded
  /// from iCloud and iTunes backups. Done natively so no package is needed.
  ///
  /// Whole directories are excluded, not individual files: the exclusion
  /// attribute is per-item, so marking only `plant_selfie.sqlite` would leave
  /// the SQLite `-wal`/`-shm` siblings (created later) backup-eligible.
  /// Every file this app writes in these directories is private local data.
  private func excludePrivateDataFromBackups() {
    let fileManager = FileManager.default
    var directories: [URL] = []

    // Documents holds plant_selfie.sqlite (drift's default location on iOS),
    // its journal siblings, and the managed-media directory.
    if let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
      directories.append(documents)
      directories.append(documents.appendingPathComponent("plant_selfie_media"))
    }
    if let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
      directories.append(support)
    }

    for directory in directories {
      do {
        if !fileManager.fileExists(atPath: directory.path) {
          try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        var url = directory
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
      } catch {
        // Never block launch over backup metadata; the privacy copy makes no
        // promise the platform cannot keep.
        NSLog("Roots: could not exclude \(directory.lastPathComponent) from backups")
      }
    }
  }
}
