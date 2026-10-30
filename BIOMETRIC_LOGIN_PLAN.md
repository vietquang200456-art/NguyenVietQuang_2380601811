# Ke hoach them dang nhap bang Face ID / van tay

## Pham vi

Muc tieu la sau khi nguoi dung dang nhap thanh cong bang OTP, ung dung cho phep **bat/tat luu phuong thuc sinh trac hoc**. O nhung lan sau, man hinh dang nhap se cho phep chon:

- Dang nhap binh thuong bang email, mat khau va OTP.
- Xac thuc bang sinh trac hoc (van tay/Face ID tuy thiet bi ho tro).

Sinh trac hoc chi dung de mo khoa thong tin dang nhap da luu tren thiet bi; app khong doc hay luu du lieu van tay/khuon mat.

## Cac file can sua

### 1. `client/pubspec.yaml`

Them package `local_auth` de goi biometric prompt cua Android/iOS.

Du kien:

```yaml
dependencies:
  local_auth: <phien-ban-tuong-thich>
```

Sau do chay `flutter pub get` de tao/cap nhat lockfile. `client/pubspec.lock` la file sinh tu dong, khong nen sua tay.

### 2. `client/lib/services/biometric_auth_service.dart` (file moi)

Tao service rieng de:

- Kiem tra thiet bi co ho tro sinh trac hoc hay khong.
- Kiem tra thiet bi da dang ky van tay/Face ID chua.
- Hien thi yeu cau xac thuc.
- Luu/lay/xoa thong tin phien dang nhap da duoc ma hoa trong `flutter_secure_storage`.

Luu y: `local_auth` chi xac thuc nguoi dung. De dang nhap lan sau ma khong can OTP, can co noi luu token an toan. Do do co hai lua chon:

1. Them `flutter_secure_storage` de luu JWT va thong tin tai khoan an toan (khuyen nghi).
2. Chi dung biometric lam buoc xac nhan UI, sau do van yeu cau OTP (khong phai dang nhap nhanh day du).

Ke hoach nay de xuat lua chon 1.

### 3. `client/lib/screens/auth_page.dart`

Sua man hinh dang nhap de:

- Sau khi login thanh cong voi OTP, hien dialog hoac bottom sheet hoi nguoi dung co muon bat Face ID/van tay hay khong.
- Neu dong y va thiet bi ho tro, luu token/thong tin tai khoan vao secure storage sau khi xac thuc thanh cong.
- O lan mo app tiep theo, hien nut `Dang nhap bang Face ID / van tay` neu co thong tin da luu.
- Khi nguoi dung chon nut nay, goi biometric prompt; neu thanh cong thi doc token da luu va vao `UserHomePage`.
- Xu ly cac truong hop huy xac thuc, thiet bi khong ho tro, chua dang ky sinh trac hoc, token het han.
- Cho phep nguoi dung dang xuat va xoa thong tin dang nhap sinh trac hoc neu can.

Phan login bang email/mat khau/OTP hien tai van duoc giu nguyen lam duong lui.

### 4. `client/android/app/src/main/AndroidManifest.xml`

Them quyen:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

Tren Android hien dai, `USE_BIOMETRIC` la quyen phu hop cho van tay va nhan dien khuon mat. Khong them quyen camera cho Face ID vi biometric prompt do he dieu hanh quan ly.

### 5. `client/ios/Runner/Info.plist` (chi neu build iOS)

Them `NSFaceIDUsageDescription` voi noi dung giai thich ro vi sao app dung Face ID. Hien tai project co thu muc macOS nhung khong thay iOS; file nay chi can tao/sua khi project duoc build cho iPhone.

### 6. `client/lib/main.dart` (co the can sua)

Chi sua neu can khoi tao/phuc hoi session biometric truoc khi hien `AuthPage`. Neu xu ly phuc hoi ngay trong `AuthPage`, file nay khong can sua.

Ke hoach uu tien **khong sua `main.dart`** de giam pham vi thay doi.

### 7. `client/lib/models/auth_response.dart` (khong bat buoc)

Khong can sua neu token va thong tin user hien tai da du de vao `UserHomePage`. Chi sua neu backend tra ve them truong can thiet cho session.

### 8. Backend `Server/*` (khong can sua trong phuong an nay)

Khong can them endpoint moi vi biometric se chi bao ve token da luu tren thiet bi. Backend van nhan JWT nhu hien tai.

## Luong su dung du kien

### Lan dang nhap dau tien

1. Nguoi dung nhap email, mat khau, OTP.
2. API login tra ve JWT va thong tin user.
3. App hoi: `Ban co muon bat dang nhap bang Face ID/van tay khong?`
4. Neu dong y, app kiem tra va yeu cau xac thuc sinh trac hoc.
5. Xac thuc thanh cong thi luu JWT trong secure storage.
6. Chuyen vao man hinh sau dang nhap.

### Lan sau

1. App phat hien thong tin biometric da luu.
2. Hien nut dang nhap bang Face ID/van tay.
3. Nguoi dung chon nut.
4. He dieu hanh hien prompt Face ID/van tay.
5. Thanh cong thi doc JWT va vao app.
6. That bai/huy thi quay lai dang nhap OTP.

## Bao mat va gioi han

- Tuyet doi khong luu van tay/khuon mat trong app.
- Khong luu mat khau plaintext.
- JWT can luu bang secure storage, khong dung `SharedPreferences`.
- Can xu ly JWT het han: xoa session biometric va yeu cau dang nhap OTP lai.
- Neu nguoi dung them/xoa van tay tren may, co the can yeu cau dang ky lai biometric tuy vao co che cua he dieu hanh.
- Face ID/van tay phu thuoc vao phan cung va cau hinh bao mat cua thiet bi; khong the ep thiet bi co ca hai tuy chon.

## Thu tu thuc hien sau khi duoc phep

1. Them dependency `local_auth` va `flutter_secure_storage`.
2. Them Android permission.
3. Tao `biometric_auth_service.dart`.
4. Tich hop vao `auth_page.dart`.
5. Chay `flutter pub get`, `flutter analyze`, va test tren Android that.
6. Chi sua `Info.plist` neu can build iOS.
