# API DOCUMENTATION: Request & Response Examples

## Overview
Dokumentasi lengkap semua API calls untuk fitur Event Creation dengan Image Upload.

---

## 1. POST /api/events - CREATE EVENT

### Purpose
Membuat event baru di sistem

### Authentication
✅ **Required** - Bearer Token

### Request

#### cURL Example
```bash
curl -X POST http://localhost:8000/api/events \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "nama_event": "Konser Jazz 2026",
    "lokasi": "Gedung Teater Jakarta",
    "event_datetime": "2026-06-15 19:00:00",
    "event_status": "published",
    "organizer_id": 5,
    "deskripsi": "Konser jazz internasional dengan musisi terkenal"
  }'
```

#### Dart/Flutter Code
```dart
final response = await http.post(
  Uri.parse('http://10.0.2.2:8000/api/events'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
  body: jsonEncode({
    'nama_event': 'Konser Jazz 2026',
    'lokasi': 'Gedung Teater Jakarta',
    'event_datetime': '2026-06-15 19:00:00',
    'event_status': 'published',
    'organizer_id': 5,
    'deskripsi': 'Konser jazz internasional dengan musisi terkenal',
  }),
);
```

### Request Body

```json
{
  "nama_event": "Konser Jazz 2026",
  "lokasi": "Gedung Teater Jakarta",
  "event_datetime": "2026-06-15 19:00:00",
  "event_status": "published",
  "organizer_id": 5,
  "deskripsi": "Konser jazz internasional dengan musisi terkenal"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `nama_event` | String | ✅ | Event name (1-255 chars) |
| `lokasi` | String | ✅ | Event location |
| `event_datetime` | String (Y-m-d H:i:s) | ✅ | Start date & time |
| `event_status` | String enum | ✅ | `draft` \| `published` |
| `organizer_id` | Integer | ✅ | Creator's organizer ID |
| `deskripsi` | String | ❌ | Event description (optional) |

### Response Success (201 Created)

```json
{
  "success": true,
  "data": {
    "id": 42,
    "nama_event": "Konser Jazz 2026",
    "lokasi": "Gedung Teater Jakarta",
    "event_datetime": "2026-06-15 19:00:00",
    "event_status": "published",
    "organizer_id": 5,
    "deskripsi": "Konser jazz internasional dengan musisi terkenal",
    "created_at": "2026-06-05T10:30:00Z",
    "updated_at": "2026-06-05T10:30:00Z"
  }
}
```

### Response Error (422 Validation Error)

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": {
    "nama_event": ["Nama event sudah terdaftar"],
    "organizer_id": ["Organizer tidak ditemukan"]
  }
}
```

### Response Error (401 Unauthorized)

```json
{
  "message": "Unauthenticated"
}
```

### Handling in Code

```dart
if (response.statusCode == 201 || response.statusCode == 200) {
  final data = jsonDecode(response.body);
  final eventId = data['data']['id'];  // Extract ID: 42
  print('Event created: $eventId');
  // Proceed to image upload
} else if (response.statusCode == 422) {
  final data = jsonDecode(response.body);
  final errors = data['errors'];
  print('Validation error: $errors');
  // Show error to user
} else {
  print('Unknown error: ${response.statusCode}');
}
```

---

## 2. POST /api/events/{id}/image - UPLOAD IMAGE

### Purpose
Upload gambar untuk event yang sudah dibuat

### Authentication
✅ **Required** - Bearer Token

### Request

#### cURL Example
```bash
curl -X POST http://localhost:8000/api/events/42/image \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -F "image=@/path/to/image.jpg"
```

#### Dart/Flutter Code
```dart
final request = http.MultipartRequest(
  'POST',
  Uri.parse('http://10.0.2.2:8000/api/events/42/image'),
);

request.headers.addAll({
  'Authorization': 'Bearer $token',
});

request.files.add(
  await http.MultipartFile.fromPath('image', '/storage/emulated/0/image.jpg'),
);

final response = await request.send();
final responseBody = await response.stream.bytesToString();
final data = jsonDecode(responseBody);
```

### Request Body (Multipart Form Data)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File | ✅ | Image file (JPG/PNG, max 5MB) |

**File Specifications:**
- Format: `jpg`, `png`
- Max size: 5MB (di backend) / 1024x1024 (di Flutter sebelum upload)
- Quality: 85%
- MIME type: `image/jpeg` atau `image/png`

### Response Success (200/201)

```json
{
  "success": true,
  "data": {
    "event_id": 42,
    "image_url": "https://api.pentasera.com/storage/events/42-1717576200.jpg",
    "uploaded_at": "2026-06-05T10:30:15Z"
  }
}
```

### Response Error (413 Payload Too Large)

```json
{
  "success": false,
  "message": "File terlalu besar (max 5MB)"
}
```

### Response Error (422 Invalid File Type)

```json
{
  "success": false,
  "message": "File harus berupa gambar (jpg, png)"
}
```

### Handling in Code

```dart
final response = await request.send();

if (response.statusCode == 200 || response.statusCode == 201) {
  final responseBody = await response.stream.bytesToString();
  final data = jsonDecode(responseBody);
  final imageUrl = data['data']['image_url'];
  print('Image uploaded: $imageUrl');
  // Success - proceed to next step
} else if (response.statusCode == 413) {
  print('File too large');
} else {
  print('Upload failed: ${response.statusCode}');
  // Non-blocking: event sudah tersimpan
}
```

---

## 3. POST /api/tickets - CREATE TICKET

### Purpose
Membuat tiket untuk event (hanya jika diisi di form)

### Authentication
✅ **Required** - Bearer Token

### Request

#### cURL Example
```bash
curl -X POST http://localhost:8000/api/tickets \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{
    "event_id": 42,
    "kategori": "VIP",
    "harga": 500000,
    "kuota": 100,
    "sisa_kuota": 100
  }'
```

#### Dart/Flutter Code
```dart
final response = await http.post(
  Uri.parse('http://10.0.2.2:8000/api/tickets'),
  headers: {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'event_id': 42,
    'kategori': 'VIP',
    'harga': 500000,
    'kuota': 100,
    'sisa_kuota': 100,
  }),
);
```

### Request Body

```json
{
  "event_id": 42,
  "kategori": "VIP",
  "harga": 500000,
  "kuota": 100,
  "sisa_kuota": 100
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `event_id` | Integer | ✅ | Event ID (from create event response) |
| `kategori` | String | ✅ | Ticket category name (e.g., "VIP", "Regular") |
| `harga` | Integer | ✅ | Price in Rupiah |
| `kuota` | Integer | ✅ | Total quota |
| `sisa_kuota` | Integer | ✅ | Remaining quota (usually = kuota) |

### Response Success (201 Created)

```json
{
  "success": true,
  "data": {
    "id": 128,
    "event_id": 42,
    "kategori": "VIP",
    "harga": 500000,
    "kuota": 100,
    "sisa_kuota": 100,
    "created_at": "2026-06-05T10:30:20Z",
    "updated_at": "2026-06-05T10:30:20Z"
  }
}
```

### Response Error (404 Event Not Found)

```json
{
  "success": false,
  "message": "Event tidak ditemukan"
}
```

---

## 4. GET /api/my-events - LIST MY EVENTS

### Purpose
Mengambil daftar event yang dibuat oleh creator (untuk ditampilkan di EventSayaPage)

### Authentication
✅ **Required** - Bearer Token

### Request

#### cURL Example
```bash
curl -X GET http://localhost:8000/api/my-events \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGc..." \
  -H "Accept: application/json"
```

#### Dart/Flutter Code
```dart
final response = await http.get(
  Uri.parse('http://10.0.2.2:8000/api/my-events'),
  headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  },
);

final data = jsonDecode(response.body);
```

### Response Success (200 OK)

```json
{
  "success": true,
  "data": [
    {
      "id": 42,
      "nama_event": "Konser Jazz 2026",
      "lokasi": "Gedung Teater Jakarta",
      "event_datetime": "2026-06-15 19:00:00",
      "event_status": "published",
      "foto": "https://api.pentasera.com/storage/events/42-1717576200.jpg",
      "created_at": "2026-06-05T10:30:00Z"
    },
    {
      "id": 41,
      "nama_event": "Pameran Wayang",
      "lokasi": "Museum Jakarta",
      "event_datetime": "2026-06-20 14:00:00",
      "event_status": "draft",
      "foto": null,
      "created_at": "2026-06-04T15:20:00Z"
    }
  ]
}
```

### Response Structure

| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Event ID |
| `nama_event` | String | Event name |
| `lokasi` | String | Event location |
| `event_datetime` | String | Event start date & time |
| `event_status` | String | `draft` \| `published` \| `ended` \| `cancelled` |
| `foto` | String/Null | Image URL (null jika tidak ada gambar) |
| `created_at` | String (ISO 8601) | Creation timestamp |

### Handling in Code

```dart
final response = await http.get(...);
final data = jsonDecode(response.body);

if (data['success'] == true) {
  List<Map<String, dynamic>> events = 
    (data['data'] as List).cast<Map<String, dynamic>>();
  
  for (var event in events) {
    print('Event: ${event['nama_event']}');
    print('Image: ${event['foto']}');  // Bisa null
  }
}
```

### Displaying Images

```dart
// Di EventSayaPage._buildEventCard()
final imageUrl = (event['foto'] ?? '').toString();

Container(
  height: 120,
  decoration: BoxDecoration(
    image: imageUrl.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(imageUrl),  // ← Load dari URL
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: imageUrl.isEmpty
      ? Icon(Icons.image)  // ← Placeholder jika null
      : null,
)
```

---

## 5. Authentication & Authorization

### Token Management

#### Login & Get Token
```dart
// AuthService.login()
final response = await http.post(
  Uri.parse('http://10.0.2.2:8000/api/login'),
  body: {
    'email': 'creator@example.com',
    'password': 'password123',
  },
);

final data = jsonDecode(response.body);
final token = data['data']['token'];

// Save token
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
```

#### Use Token in Requests
```dart
// AuthService.authHeaders()
Future<Map<String, String>> authHeaders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token') ?? '';
  
  return {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

// Digunakan di semua protected endpoints:
final headers = await AuthService.authHeaders();
final response = await http.post(
  Uri.parse(url),
  headers: headers,
  body: body,
);
```

---

## 6. BASE URL CONFIGURATION

### Per Platform

```dart
// EventService.baseUrl
static String get baseUrl {
  if (kIsWeb) 
    return 'http://localhost:8000/api';
  
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8000/api';  // ← Emulator
    default:
      return 'http://localhost:8000/api';  // ← Real device (adjust IP)
  }
}
```

### Untuk Production
```dart
// Ganti dengan IP/domain backend
const String BACKEND_URL = 'https://api.pentasera.com/api';
```

---

## 7. COMPLETE FLOW EXAMPLE

### Full Dart Implementation

```dart
// main flow di BuatEventPage._handleSubmit()

Future<void> _handleSubmit(String status) async {
  // 1. CREATE EVENT
  final eventResult = await EventService.createEvent(
    namaEvent: _namaController.text,
    lokasi: _lokasiController.text,
    eventDatetime: DateFormat('yyyy-MM-dd HH:mm:ss')
        .format(_tanggalMulai!),
    deskripsi: _deskripsiController.text,
    status: status,
  );

  if (!eventResult['success']) {
    _showError(eventResult['message']);
    return;
  }

  final eventId = eventResult['data']['id'];
  print('✅ Event created: $eventId');

  // 2. UPLOAD IMAGE (if selected)
  if (_selectedImage != null) {
    final imageResult = await EventService.uploadEventImage(
      eventId: eventId,
      imagePath: _selectedImage!.path,
    );

    if (imageResult['success']) {
      print('✅ Image uploaded');
    } else {
      print('⚠️ Image upload failed (non-blocking)');
      // Continue anyway
    }
  }

  // 3. CREATE TICKET (if filled)
  if (_namaTicketController.text.isNotEmpty) {
    final ticketResult = await EventService.createTicket(
      eventId: eventId,
      kategori: _namaTicketController.text,
      harga: int.parse(_hargaController.text),
      kuota: int.parse(_stokController.text),
    );

    if (!ticketResult['success']) {
      _showError('Tiket error: ${ticketResult['message']}');
      return;
    }

    print('✅ Ticket created');
  }

  // 4. SUCCESS & REDIRECT
  _showSuccess('Event berhasil dibuat!');
  await Future.delayed(Duration(seconds: 1));
  
  Navigator.pushReplacementNamed(context, '/event-saya');
  
  // 5. LOAD EVENT LIST (with images)
  // EventSayaPage will call GET /api/my-events
  // and display images from 'foto' field
}
```

---

## 8. ERROR CODES & MEANINGS

| HTTP Code | Meaning | Handling |
|-----------|---------|----------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Token missing/invalid/expired |
| 403 | Forbidden | User not authorized for this action |
| 404 | Not Found | Resource not found |
| 413 | Payload Too Large | File too large (image upload) |
| 422 | Unprocessable Entity | Validation error (required fields) |
| 500 | Server Error | Backend error |

---

## 9. POSTMAN COLLECTION QUICK SETUP

### Import to Postman

1. **Environment Variables:**
   - `base_url`: `http://localhost:8000/api`
   - `token`: (get from login response)
   - `event_id`: (get from create event response)

2. **Create Event Request:**
   - Method: `POST`
   - URL: `{{base_url}}/events`
   - Header: `Authorization: Bearer {{token}}`
   - Body (JSON):
     ```json
     {
       "nama_event": "Test Event",
       "lokasi": "Test Location",
       "event_datetime": "2026-06-15 19:00:00",
       "event_status": "published",
       "organizer_id": 1
     }
     ```

3. **Upload Image Request:**
   - Method: `POST`
   - URL: `{{base_url}}/events/{{event_id}}/image`
   - Header: `Authorization: Bearer {{token}}`
   - Body: `form-data` → `image` (file)

---

**Last Updated:** June 5, 2026  
**API Version:** v1.0
