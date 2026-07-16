# image_gallery_saver_plus

[![pub package](https://img.shields.io/pub/v/image_gallery_saver_plus.svg)](https://pub.dartlang.org/packages/image_gallery_saver_plus)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://choosealicense.com/licenses/mit/)

An updated plugin enables users to download and save images and videos directly to their gallery, with enhanced performance, improved media organization features, and better compatibility across various devices.

## Usage

To use this plugin, add `image_gallery_saver_plus` as a dependency in your pubspec.yaml file. For example:

```yaml
dependencies:
  image_gallery_saver_plus: ^5.1.2
```

## iOS

Your project need create with swift.
Add the following keys to your Info.plist file, located in <project root></project>/ios/Runner/Info.plist:

```
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need permission to save photos and videos to your library for your convenience.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>We need permission to access your photo library to view and select your photos and videos.</string>
```

## Android

 You need to ask for storage permission to save an image to the gallery. You can handle the storage permission using [flutter_permission_handler](https://github.com/BaseflowIT/flutter-permission-handler).
 In Android version 10, Open the manifest file and add this line to your application tag

```
 <application android:requestLegacyExternalStorage="true" .....>
```

## API

### `ImageGallerySaverPlus.saveImage(...)`

Save raw image bytes to the gallery.

| Parameter                  | Type          | Default   | Description                                                                    |
| -------------------------- | ------------- | --------- | ------------------------------------------------------------------------------ |
| `imageBytes`             | `Uint8List` | required  | The image bytes to save.                                                       |
| `quality`                | `int`       | `80`    | JPEG compression quality (0–100).                                             |
| `name`                   | `String?`   | `null`  | Optional file name.                                                            |
| `isReturnImagePathOfIOS` | `bool`      | `false` | Return the saved file path on iOS.                                             |
| `creationDate`           | `DateTime?` | `null`  | **iOS only.** Sets the asset's creation date shown in Photos. See below. |

### `ImageGallerySaverPlus.saveFile(...)`

Save a PNG/JPG/JPEG image or a video file to the gallery.

| Parameter             | Type          | Default   | Description                                                                                                       |
| --------------------- | ------------- | --------- | ----------------------------------------------------------------------------------------------------------------- |
| `file`              | `String`    | required  | Path to the local file to save.                                                                                   |
| `name`              | `String?`   | `null`  | Optional file name.                                                                                               |
| `isReturnPathOfIOS` | `bool`      | `false` | Return the saved file path on iOS.                                                                                |
| `creationDate`      | `DateTime?` | `null`  | **iOS only.** Sets the asset's creation date shown in Photos (works for both images and videos). See below. |

## Setting the creation date (iOS)

By default the gallery stamps saved media with the current date/time. Pass a
`creationDate` to control the date that Photos displays for the asset — useful
when re-saving media that was originally captured at an earlier time (e.g.
downloaded backups, imported memories).

```dart
final result = await ImageGallerySaverPlus.saveImage(
  imageBytes,
  quality: 80,
  name: "my_photo",
  creationDate: DateTime(2020, 1, 1),
);
```

```dart
final result = await ImageGallerySaverPlus.saveFile(
  savePath,
  creationDate: DateTime.parse("2020-01-01T10:30:00"),
);
```

Notes:

- **iOS only.** On iOS, providing a `creationDate` imports the asset through
  `PHPhotoLibrary` so the date is honored. When it is `null`, the legacy save
  path is used and the asset gets the current date.
- On Android the parameter is accepted but currently ignored; the asset keeps
  the date it is saved.

## Example

Saving an image from the internet, quality and name is option

```dart
  _saveLocalImage() async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData =
        await (image.toByteData(format: ui.ImageByteFormat.png));
    if (byteData != null) {
      final result =
          await ImageGallerySaverPlus.saveImage(byteData.buffer.asUint8List());
      print(result);
    }
  }
  
  _saveNetworkImage() async {
    var response = await Dio().get(
        "https://ss0.baidu.com/94o3dSag_xI4khGko9WTAnF6hhy/image/h%3D300/sign=a62e824376d98d1069d40a31113eb807/838ba61ea8d3fd1fc9c7b6853a4e251f94ca5f46.jpg",
        options: Options(responseType: ResponseType.bytes));
    final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 60,
        name: "hello");
    print(result);
  }
```

Saving file(ig: video/gif/others) from the internet

```dart
  _saveNetworkGifFile() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.gif";
    String fileUrl =
        "https://hyjdoc.oss-cn-beijing.aliyuncs.com/hyj-doc-flutter-demo-run.gif";
    await Dio().download(fileUrl, savePath);
    final result =
        await ImageGallerySaverPlus.saveFile(savePath, isReturnPathOfIOS: true);
    print(result);
  }

  _saveNetworkVideoFile() async {
    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path + "/temp.mp4";
    String fileUrl =
        "https://s3.cn-north-1.amazonaws.com.cn/mtab.kezaihui.com/video/ForBiggerBlazes.mp4";
    await Dio().download(fileUrl, savePath, onReceiveProgress: (count, total) {
      print((count / total * 100).toStringAsFixed(0) + "%");
    });
    final result = await ImageGallerySaverPlus.saveFile(savePath);
    print(result);
  }
```

## Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/ArmanKT"><img src="https://avatars.githubusercontent.com/u/38861462?v=4" width="100px;" alt=""/><br /><sub><b>Arman Khan Tonmoy</b></sub></a></td>
    <td align="center"><a href="https://github.com/bousalem98"><img src="https://avatars.githubusercontent.com/u/61710794?v=4" width="100px;" alt=""/><br /><sub><b>Mohamed Salem</b></sub></a></td>
  </tr>
</table>
