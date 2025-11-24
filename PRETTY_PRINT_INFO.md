# Pretty Print Log Təkmilləşdirmələri

## Nə dəyişdi?

`lib/service/debug_logging.dart` faylında **pretty print** funksionallığı əlavə edildi.

## Əsas Dəyişikliklər

### 1. JSON Formatlama
Artıq bütün JSON məlumatları oxunaqlı formatda çap olunur:
- 2 boşluqla indent edilir
- Strukturlaşdırılmış və təmiz görünür

### 2. Yeni Log Formatı

#### REQUEST Logları:
```
🐙 REQUEST [POST] => URL: https://api.example.com/users
⏰ TIME: 2024-11-24 15:30:45.123
📋 HEADERS:
{
  "Content-Type": "application/json",
  "Authorization": "Bearer token123"
}
📦 BODY:
{
  "name": "John Doe",
  "email": "john@example.com"
}
────────────────────────────────────────────────────────────────────────────────
```

#### RESPONSE Logları:
```
🦑 RESPONSE [200] => POST https://api.example.com/users
⏰ TIME: 2024-11-24 15:30:45.456
⏱️  ELAPSED TIME: 333 ms
📋 HEADERS:
{
  "content-type": ["application/json"],
  "server": ["nginx"]
}
📦 DATA:
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-11-24T15:30:45Z"
}
────────────────────────────────────────────────────────────────────────────────
```

#### ERROR Logları:
```
🦀 ERROR [404] => GET /api/users/999
⏰ TIME: 2024-11-24 15:30:46.789
⏱️  ELAPSED TIME: 123 ms
❌ ERROR TYPE: DioExceptionType.badResponse
💬 MESSAGE: Http status error [404]
📦 ERROR DATA:
{
  "error": "User not found",
  "code": "USER_NOT_FOUND"
}
────────────────────────────────────────────────────────────────────────────────
```

## Üstünlüklər

✅ **Daha oxunaqlı**: JSON məlumatları artıq formatlı şəkildə göstərilir
✅ **Aydın struktur**: Hər məlumat növü öz emoji və başlığı ilə ayrılır
✅ **Vizual ayırıcılar**: Hər log 80 tire ilə ayrılır
✅ **Ətraflı məlumat**: Headers, body və error detalları ayrıca göstərilir
✅ **Performance info**: Hər sorğunun icra müddəti millisaniyə ilə göstərilir

## Texniki Detallar

`_prettyPrint()` metodu əlavə edildi:
- `dart:convert` paketindən `JsonEncoder.withIndent()` istifadə edir
- JSON olmayan məlumatları da düzgün handle edir
- `null` dəyərlər üçün xüsusi davranış
- Exception handling daxildir

## İstifadə

Kod artıq avtomatik olaraq bütün Dio request/response/error-ları pretty print formatında log edəcək. Heç bir əlavə konfiqurasiya tələb olunmur.

