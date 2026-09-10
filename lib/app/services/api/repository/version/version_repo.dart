class VersionRepository{
  static String versionGet = '/application-version/getLatestVersion';

  static String getVersion() {
    return "$versionGet";
  }
}