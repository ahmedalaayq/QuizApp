# 📖 دليل التثبيت والتشغيل

## المتطلبات الأساسية

### 1. Flutter SDK
```bash
# التحقق من تثبيت Flutter
flutter --version

# يجب أن يكون الإصدار 3.7.0 أو أحدث
```

### 2. محرر الأكواد
- VS Code (موصى به)
- Android Studio
- IntelliJ IDEA

### 3. المحاكيات
- Android Emulator
- iOS Simulator (Mac فقط)
- أو جهاز حقيقي

## خطوات التثبيت

### الخطوة 1: استنساخ المشروع
```bash
cd /path/to/your/projects
# أو فتح المجلد الحالي
cd /Volumes/Programming/Apps/QuizApp
```

### الخطوة 2: تثبيت المكتبات
```bash
flutter pub get
```

إذا ظهرت أخطاء، جرب:
```bash
flutter clean
flutter pub get
```

### الخطوة 3: توليد ملفات Hive (اختياري)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### الخطوة 4: التحقق من الإعداد
```bash
flutter doctor
```

يجب أن ترى:
```
✓ Flutter (Channel stable, 3.x.x)
✓ Android toolchain
✓ Xcode (Mac only)
✓ VS Code / Android Studio
✓ Connected device
```

## التشغيل

### على Android
```bash
# قائمة الأجهزة المتاحة
flutter devices

# التشغيل
flutter run
```

### على iOS (Mac فقط)
```bash
# فتح مجلد iOS
cd ios

# تثبيت CocoaPods
pod install

# العودة للمجلد الرئيسي
cd ..

# التشغيل
flutter run
```

### على الويب
```bash
flutter run -d chrome
```

## حل المشاكل الشائعة

### مشكلة 1: خطأ في pub get
```bash
flutter clean
rm pubspec.lock
flutter pub get
```

### مشكلة 2: خطأ في Hive
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### مشكلة 3: خطأ في Gradle (Android)
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### مشكلة 4: خطأ في CocoaPods (iOS)
```bash
cd ios
rm Podfile.lock
rm -rf Pods
pod install
cd ..
```

## البناء للإنتاج

### Android APK
```bash
flutter build apk --release
```

الملف في: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## اختبار المميزات الجديدة

### 1. قاعدة البيانات
- أكمل اختبار
- أغلق التطبيق
- افتحه مرة أخرى
- اذهب للإحصائيات - يجب أن ترى النتيجة محفوظة

### 2. الوضع الليلي
- اذهب للإعدادات
- فعّل الوضع الليلي
- يجب أن يتغير التصميم فوراً

### 3. الإنجازات
- أكمل اختبارك الأول
- يجب أن ترى إشعار "🎉 إنجاز جديد!"
- اذهب لصفحة الإنجازات لرؤية التقدم

### 4. الرسوم البيانية
- أكمل عدة اختبارات
- اذهب للإحصائيات
- يجب أن ترى رسم بياني للتطور

## الأوامر المفيدة

```bash
# تنظيف المشروع
flutter clean

# تحديث المكتبات
flutter pub upgrade

# تحليل الكود
flutter analyze

# تشغيل الاختبارات
flutter test

# فحص الأداء
flutter run --profile

# عرض معلومات الجهاز
flutter devices

# عرض السجلات
flutter logs
```

## نصائح للتطوير

### 1. Hot Reload
- اضغط `r` في Terminal أثناء التشغيل
- أو احفظ الملف في VS Code

### 2. Hot Restart
- اضغط `R` في Terminal
- لإعادة تشغيل التطبيق بالكامل

### 3. DevTools
```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### 4. تصحيح الأخطاء
- استخدم `print()` للطباعة
- استخدم `debugPrint()` للرسائل الطويلة
- استخدم Breakpoints في VS Code

## البنية التقنية

### المكتبات الرئيسية
- **flutter**: الإطار الأساسي
- **get**: إدارة الحالة والتوجيه
- **hive**: قاعدة البيانات المحلية
- **fl_chart**: الرسوم البيانية
- **flutter_screenutil**: التصميم المتجاوب

### البنية المعمارية
```
lib/
├── main.dart                 # نقطة الدخول
├── app/                      # التطبيق الرئيسي
├── core/
│   ├── database/            # قاعدة البيانات
│   ├── theme/               # الثيمات
│   ├── features/            # الميزات
│   ├── models/              # النماذج
│   ├── services/            # الخدمات
│   ├── router/              # التوجيه
│   ├── styles/              # الأنماط
│   └── widgets/             # Widgets مشتركة
```

## الدعم

### الموارد
- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://pub.dev/packages/get)
- [Hive Documentation](https://docs.hivedb.dev)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)

### المشاكل الشائعة
- تحقق من `flutter doctor`
- نظف المشروع بـ `flutter clean`
- حدّث المكتبات بـ `flutter pub upgrade`
- راجع السجلات بـ `flutter logs`

---

**ملاحظة:** إذا واجهت أي مشكلة، تأكد من:
1. تحديث Flutter SDK
2. تثبيت جميع المكتبات
3. توليد ملفات Hive
4. تنظيف المشروع

**نتمنى لك تجربة تطوير ممتعة!** 🚀
