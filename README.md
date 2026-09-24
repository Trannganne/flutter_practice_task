# Flutter Practice Tasks

Ứng dụng tổng hợp các bài thực hành Flutter trong thời gian thực tập tại **Công ty Cổ phần Phát triển Công nghệ Newtech**. Các bài được tổ chức theo nhóm chức năng và truy cập từ một màn hình chính để thuận tiện chạy thử, demo và review code.

Mục tiêu của project là thực hành làm việc với API, quản lý trạng thái, thông báo, quyền truy cập, lưu trữ cục bộ và nội dung đa phương tiện. Đây là **project học tập và demo**, chưa phải ứng dụng production hoặc bản hoàn thiện toàn bộ yêu cầu.

- **Người thực hiện:** Trần Thị Kim Ngân.
- **Thời gian thực hiện:** 26/06/2026 – 15/09/2026.
- **Nền tảng demo chính:** Android.
- **Repository:** https://github.com/Trannganne/flutter_practice_task

## Các nhóm chức năng

“Đã triển khai” trong bảng dưới đây thể hiện chức năng có trong source, không đồng nghĩa mọi tình huống đã được kiểm thử trên thiết bị.

| Nhóm | Nội dung đã triển khai | Giới hạn / điểm cần lưu ý |
| --- | --- | --- |
| **Push Notification – Easy** | Tải danh sách posts, xem chi tiết và nhận thông báo FCM. | Cần cấu hình Firebase và nguồn gửi thông báo phù hợp. |
| **Push Notification – Medium** | Danh sách tin tức, đăng ký/hủy đăng ký thông báo theo topic. | Đăng ký topic không tự phát hiện bài mới; phía gửi phải gửi thông báo đến topic tương ứng. |
| **Push Notification – Hard** | Gộp posts và news về model chung; phân trang tối đa 10 mục/lần; banner khi đang mở module; điều hướng khi bấm thông báo; inbox lưu cục bộ; có xử lý chống trùng và retry API. | Cần kiểm tra thêm khóa chống trùng giữa hai nguồn và các tình huống lỗi mạng. Inbox offline không đồng nghĩa bài báo gốc đọc được offline. |
| **Local Notification – Easy** | Lấy gợi ý hoạt động từ API, thông báo thử và đặt lịch nhắc. | Thời gian đặt lịch thực tế cần đối chiếu lại với yêu cầu nhắc lúc 8:00. |
| **Local Notification – Medium** | Lấy vị trí và dự báo thời tiết, kiểm tra điều kiện mưa, tạo/đặt lịch nhắc mang ô. | Cần kiểm tra các trường hợp không có mưa, từ chối quyền và lỗi API. |
| **Local Notification – Hard** | Tổng hợp thông tin, lịch nhắc, lịch sử, cài đặt và tích hợp Workmanager cập nhật nền. | Chưa xác nhận đầy đủ việc thực thi nền và độ chính xác của lịch nhắc trên thiết bị. |
| **Permissions – Medium** | Tải, tìm kiếm và lọc quốc gia; xuất toàn bộ hoặc kết quả lọc ra CSV; dùng lại file có nội dung giống nhau; chia sẻ file; thông báo lỗi mạng ngắn gọn. | Bản hiện tại xuất các cột cố định. Luồng lưu file chủ yếu phục vụ Android. |
| **Permissions – Hard** | Ghi nhận hiện trường bằng ảnh, vị trí, thời tiết, thông tin quốc gia và ghi chú; lưu nháp/báo cáo; xuất CSV; xử lý kết quả xin quyền. | Cần kiểm tra từng quyền ở trạng thái từ chối và từ chối vĩnh viễn. Dữ liệu lưu cục bộ, chưa đồng bộ lên backend. |
| **Image Caching** | Danh sách ảnh từ Pexels/Picsum, collection, phân trang, chi tiết, yêu thích và lưu metadata cục bộ; có sử dụng cache ảnh. | Khả năng xem offline phụ thuộc ảnh đã tải và còn trong cache. Một số thao tác ở màn chi tiết chưa hoàn thiện. |
| **Upload** | Chọn ảnh, kiểm tra MIME/dung lượng, tính hash, lưu task, hàng đợi, tiến độ, hai provider, sao chép URL và pause/resume. | Resume gửi lại từ đầu. Retry file lỗi, hủy task chờ và khôi phục queue cần kiểm tra thêm. |
| **Video** | Danh sách, tìm kiếm có debounce, phân trang, player, điều khiển phát, lịch sử/tiến độ và thành phần tải video. | Chỉ coi phát offline là đạt khi file đã tải hoàn tất và phát được từ thiết bị. Một số nút/màn còn là placeholder. |

## Công nghệ sử dụng

- **Flutter / Dart:** xây dựng ứng dụng.
- **Bloc / Cubit, Equatable:** quản lý trạng thái và cập nhật giao diện.
- **GoRouter:** điều hướng bên trong các module; màn hình chính mở từng bài thực hành.
- **Dio, HTTP, dio_smart_retry:** gọi API, upload và retry request.
- **Firebase Messaging:** nhận push notification.
- **flutter_local_notifications, timezone, Workmanager:** thông báo cục bộ, lịch nhắc và tác vụ nền.
- **permission_handler, geolocator, image_picker:** quyền truy cập, vị trí và ảnh.
- **SharedPreferences, SQLite:** lưu cấu hình, metadata, inbox và dữ liệu tác vụ tùy module.
- **cached_network_image:** hiển thị và cache ảnh tại các màn có sử dụng.
- **csv, path_provider, share_plus:** tạo, lưu và chia sẻ file CSV.
- **video_player:** phát video.

Các module có cách phân tách UI, Bloc/Cubit, repository và service. Mức độ phân tách chưa đồng nhất hoàn toàn; project chưa được chuẩn hóa thành một kiến trúc duy nhất cho tất cả bài tập.

## Cấu trúc chính

| Đường dẫn | Nội dung |
| --- | --- |
| `lib/main.dart` | Điểm khởi chạy và khởi tạo các thành phần dùng chung. |
| `lib/hub/` | Màn hình chọn bài thực hành. |
| `lib/push_notification/` | Các bài FCM. |
| `lib/local_notification/` | Thông báo cục bộ và lịch nhắc. |
| `lib/permissions/` | Country CSV Exporter và Field Report Toolkit. |
| `lib/image_caching/` | Gallery, collection, yêu thích và cache ảnh. |
| `lib/file_picker/` | Chọn file và upload. |
| `lib/video_player/` | Danh sách, tìm kiếm và phát video. |
| `lib/widgets/` | Các widget dùng chung. |
| `test/models/forecast_serialization_test.dart` | Kiểm thử chuyển đổi JSON và dữ liệu cache của forecast. |

## Chuẩn bị môi trường

1. Cài Flutter cùng Android SDK và công cụ phát triển Android.
2. Dùng Flutter đi kèm Dart đáp ứng ràng buộc **`^3.10.7`** trong `pubspec.yaml`. Kiểm tra phiên bản thực tế bằng `flutter --version`.
3. Chuẩn bị thiết bị Android hoặc emulator hỗ trợ Google Play Services để kiểm tra FCM. Bản demo đã được chạy trên Samsung SM A155F.
4. Chuẩn bị cấu hình Firebase và API key của các dịch vụ cần demo.

## Chạy project

### 1. Lấy source và cài dependency

```bash
git clone https://github.com/Trannganne/flutter_practice_task.git
cd flutter_practice_task
git switch main
flutter pub get
```

### 2. Cấu hình API

Tạo file `.env` tại thư mục gốc, cùng cấp với `pubspec.yaml`. Source hiện đọc các tên biến sau:

```dotenv
NEWS_API_KEY=
NEWS_API_WEATHER_KEY=
COUNTRY_API_KEY=
PEXEL_API_KEY=
PIXABAY_API_KEY=
IMGBB_API_KEY=
FREEIMAGE_API_KEY=
```

| Biến | Phần sử dụng |
| --- | --- |
| `NEWS_API_KEY` | Tin tức. |
| `NEWS_API_WEATHER_KEY` | Dữ liệu thời tiết. |
| `COUNTRY_API_KEY` | Service quốc gia trong source hiện tại; điền theo yêu cầu của endpoint đang sử dụng. |
| `PEXEL_API_KEY` | Ảnh/video Pexels. Tên biến trong source là `PEXEL`, không phải `PEXELS`. |
| `PIXABAY_API_KEY` | Tìm kiếm video Pixabay. |
| `IMGBB_API_KEY`, `FREEIMAGE_API_KEY` | Các provider upload ảnh. |

Điền giá trị hợp lệ cho dịch vụ cần sử dụng. Khóa trống không bảo đảm module tương ứng hoạt động. App đọc `.env` lúc khởi động nên cần tạo file này trước khi chạy.

Không commit thông tin bí mật vào Git. `.env` được khai báo như asset của ứng dụng nên **không phải nơi bảo vệ bí mật phía server**; không đặt khóa Firebase Admin/service account tại đây.

### 3. Cấu hình Firebase

- Sử dụng Firebase project có ứng dụng Android khớp với application ID của bản build.
- Kiểm tra `android/app/google-services.json` và `lib/firebase_options.dart` thuộc cùng Firebase project.
- Nếu dùng Firebase project riêng, tạo lại cấu hình tương ứng trước khi chạy.
- Chấp nhận quyền thông báo khi hệ điều hành yêu cầu để demo thông báo hệ thống.

Script mô phỏng backend gửi FCM được chạy riêng. Không giả định script hoặc credential của bên gửi đã có sẵn trong repository. Khi demo bằng script, cần dùng đúng Firebase project, token/topic và payload mà module tiếp nhận.

Với luồng FCM Hard hiện tại, dữ liệu điều hướng cần có `type: "fcm_hard"` và `url` hợp lệ. Cấu hình phía gửi cần phù hợp với việc hiển thị thông báo ở nền; chỉ có dữ liệu điều hướng chưa đủ bảo đảm hệ thống hiển thị notification.

### 4. Khởi chạy

```bash
flutter devices
flutter run
```

Từ màn hình chính, chọn module muốn thử. Một số chức năng cần mạng, dịch vụ vị trí hoặc quyền truy cập tương ứng.

## Gợi ý demo

1. **FCM Hard:** xem feed, tải thêm; nhận banner khi mở module; bấm thông báo khi app chạy nền và khi khởi động lại; mở inbox khi mất mạng.
2. **Local Notification:** hiển thị thông báo thử, xem dự báo và lịch nhắc. Không dùng việc bật công tắc làm bằng chứng Workmanager đã thực thi.
3. **Country CSV Exporter:** xuất toàn bộ, lọc rồi xuất kết quả, mở file và chia sẻ. Nội dung không đổi sử dụng lại file đã có; nội dung khác tạo bản xuất khác.
4. **Field Report Toolkit:** thử cấp/từ chối quyền, thêm ảnh và vị trí, lưu nháp, mở lại và chỉnh sửa.
5. **Image Caching:** tải ảnh khi online rồi mở lại khi mất mạng. Ảnh chưa tải hoặc đã bị loại khỏi cache có thể không hiển thị.
6. **Upload:** chọn ảnh, theo dõi tiến độ, mở URL kết quả; thử pause/resume và quan sát việc gửi lại từ đầu.
7. **Video:** phát, dừng, tua, mở lại và tìm kiếm qua tab Explore.

## Kiểm tra và hiện trạng

```bash
flutter test --no-pub test/models/forecast_serialization_test.dart
flutter analyze --no-pub
flutter run
```

