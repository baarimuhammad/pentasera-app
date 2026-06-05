# PRD: Event Creation dengan Image Upload
**Pentasera App - Creator Feature**

---

## 1. RINGKASAN FITUR

Fitur ini memungkinkan **kreator event** untuk:
- ✅ Membuat event dengan informasi lengkap (nama, deskripsi, lokasi, tanggal, kategori)
- ✅ Upload gambar/foto event
- ✅ Melihat preview gambar sebelum upload
- ✅ Membuat tiket dengan harga dan kapasitas
- ✅ Publikasi event atau simpan sebagai draft
- ✅ Melihat gambar event di halaman daftar event ("Event Saya")

---

## 2. ARSITEKTUR KOMPONEN

### 2.1 Frontend Structure (Flutter)

```
lib/
├── features/
│   └── creator/
│       ├── buat_event/
│       │   └── buat_event_page.dart          ← HALAMAN UTAMA
│       └── event_saya/
│           └── event_saya_page.dart          ← TAMPIL DAFTAR EVENT
├── services/
│   └── event_service.dart                    ← API INTEGRATION
└── core/
    └── app_router.dart                       ← ROUTING
```

### 2.2 Backend Endpoints (API)

| Endpoint | Method | Deskripsi | Auth |
|----------|--------|-----------|------|
| `/api/events` | POST | Buat event baru | ✅ |
| `/api/events/{id}/image` | POST | Upload gambar event | ✅ |
| `/api/tickets` | POST | Buat tiket event | ✅ |
| `/api/my-events` | GET | Ambil event milik creator | ✅ |
| `/api/events/{id}` | GET | Detail event (dengan gambar) | ❌ |

---

## 3. ALUR DATA (DATA FLOW)

### 3.1 Diagram Alur Pembuatan Event

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER INTERACTION                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. STEP 1: INFORMASI EVENT                                     │
│     ├─ Input: Nama Event, Kategori, Deskripsi                  │
│     ├─ Input: Tanggal Mulai, Tanggal Selesai                   │
│     ├─ Input: Lokasi, Kapasitas                                │
│     └─ UPLOAD GAMBAR ← [ImagePicker]                           │
│                                                                  │
│  2. STEP 2: PUBLIKASI                                           │
│     ├─ Input: Nama Tiket, Harga, Stok                          │
│     ├─ Pilih: Status (Draft/Publikasi)                         │
│     └─ SUBMIT: Klik "Publikasikan" atau "Simpan Draft"         │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────────────┐
                    │ VALIDATION    │
                    ├───────────────┤
                    │ • Nama Event  │
                    │ • Status      │
                    └───────────────┘
                            ↓
        ┌───────────────────┴────────────────────┐
        │                                         │
┌───────▼────────────┐               ┌──────────▼──────────┐
│   CREATE EVENT     │               │  UPLOAD IMAGE      │
│   (Step 1)         │               │   (Step 2)         │
├──────────────────┤               ├────────────────────┤
│ POST /api/events  │               │ POST /api/events/  │
│                  │               │ {id}/image         │
│ Body:            │               │                    │
│ {                │               │ Body (multipart):  │
│  nama_event,     │               │ {                  │
│  lokasi,         │               │  image: File       │
│  event_datetime, │               │ }                  │
│  event_status,   │               │                    │
│  organizer_id,   │               │ Returns:           │
│  deskripsi       │               │ {                  │
│ }                │               │  success,          │
│                  │               │  data: { url }     │
│ Returns:         │               │ }                  │
│ {                │               │                    │
│  success,        │               │ ⚠️ Non-blocking:  │
│  data: {         │               │ Jika gagal, event  │
│   id,            │               │ tetap tersimpan    │
│   nama_event,    │               │                    │
│   ...            │               │                    │
│  }               │               │                    │
│ }                │               │                    │
└────────┬─────────┘               └────────┬───────────┘
         │                                  │
         └──────────────┬───────────────────┘
                        │
              ┌─────────▼──────────┐
              │  CREATE TICKET     │
              │  (Jika diisi)      │
              ├────────────────────┤
              │ POST /api/tickets  │
              │                    │
              │ Body:              │
              │ {                  │
              │  event_id,         │
              │  kategori,         │
              │  harga,            │
              │  kuota,            │
              │  sisa_kuota        │
              │ }                  │
              │                    │
              │ Returns:           │
              │ {                  │
              │  success,          │
              │  data: { id, ... } │
              │ }                  │
              └─────────┬──────────┘
                        │
              ┌─────────▼──────────┐
              │ SUCCESS RESPONSE   │
              │ & REDIRECT         │
              └────────────────────┘
```

---

## 4. PENJELASAN API PER LANGKAH

### Step 1: POST /api/events - CREATE EVENT

**📍 Location:** `EventService.createEvent()` di `event_service.dart`

**Kapan dipanggil:**
- Saat user klik "Lanjut" (Step 1 → Step 2) 
- Saat user klik "Simpan Draft" atau "Publikasikan" di Step 2

**Request:**
```dart
// Dari: BuatEventPage._handleSubmit()
final eventResult = await EventService.createEvent(
  namaEvent: _namaController.text.trim(),      // "Konser Jazz 2026"
  lokasi: _lokasiController.text.trim(),       // "Gedung Teater Jakarta"
  eventDatetime: eventDatetime,                // "2026-06-15 19:00:00"
  deskripsi: _deskripsiController.text.trim(), // Optional
  status: status,                              // "draft" atau "published"
);
```

**HTTP Request:**
```
POST http://10.0.2.2:8000/api/events
Content-Type: application/json
Authorization: Bearer {token}

{
  "nama_event": "Konser Jazz 2026",
  "lokasi": "Gedung Teater Jakarta",
  "event_datetime": "2026-06-15 19:00:00",
  "event_status": "published",
  "organizer_id": 5,
  "deskripsi": "Konser jazz internasional..."
}
```

**Response Success (201/200):**
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
    "created_at": "2026-06-05T10:30:00Z",
    "updated_at": "2026-06-05T10:30:00Z"
  }
}
```

**Response Error:**
```json
{
  "success": false,
  "message": "Validasi gagal: Nama event sudah terdaftar"
}
```

**Error Handling:**
```dart
if (!eventResult['success']) {
  // Tampilkan snackbar error
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Error: ${eventResult['message']}'),
      backgroundColor: Colors.red,
    ),
  );
  return; // Stop process
}
```

---

### Step 2: POST /api/events/{id}/image - UPLOAD GAMBAR

**📍 Location:** `EventService.uploadEventImage()` di `event_service.dart`

**Kapan dipanggil:**
- **SETELAH** event berhasil dibuat (Step 1 berhasil)
- Hanya jika user memilih gambar (`_selectedImage != null`)
- Non-blocking: jika gagal, event tetap tersimpan

**Request:**
```dart
// Dari: BuatEventPage._handleSubmit()
final imageResult = await EventService.uploadEventImage(
  eventId: parsedEventId,              // ID dari event yang baru dibuat
  imagePath: _selectedImage!.path,     // Path file gambar
);
```

**HTTP Request (Multipart):**
```
POST http://10.0.2.2:8000/api/events/42/image
Authorization: Bearer {token}
Content-Type: multipart/form-data

FormData:
  image: <binary file data>
```

**Response Success (200/201):**
```json
{
  "success": true,
  "data": {
    "event_id": 42,
    "image_url": "https://api.pentasera.com/storage/events/42-image.jpg",
    "uploaded_at": "2026-06-05T10:30:15Z"
  }
}
```

**Response Error:**
```json
{
  "success": false,
  "message": "File terlalu besar (max 5MB)"
}
```

**Error Handling (Non-Blocking):**
```dart
if (!imageResult['success']) {
  debugPrint('[BuatEvent] WARNING: Image upload failed');
  // TIDAK return - proses tetap berlanjut
  // Event sudah tersimpan, gambar bisa diupload nanti
}
```

**Spesifikasi File:**
- Format: JPG, PNG
- Max size: Dikompres menjadi 1024x1024 di Flutter sebelum upload
- Quality: 85% (untuk menghemat bandwidth)
- Optimasi: `image_picker` package

---

### Step 3: POST /api/tickets - CREATE TIKET

**📍 Location:** `EventService.createTicket()` di `event_service.dart`

**Kapan dipanggil:**
- **SETELAH** event berhasil dibuat
- Hanya jika user mengisi "Nama Tiket" di Step 2
- Bersifat optional (event bisa tanpa tiket)

**Request:**
```dart
// Dari: BuatEventPage._handleSubmit()
final ticketResult = await EventService.createTicket(
  eventId: parsedEventId,                      // 42
  kategori: _namaTicketController.text.trim(), // "VIP"
  harga: harga,                                // 500000
  kuota: kuota,                                // 100
);
```

**HTTP Request:**
```
POST http://10.0.2.2:8000/api/tickets
Content-Type: application/json
Authorization: Bearer {token}

{
  "event_id": 42,
  "kategori": "VIP",
  "harga": 500000,
  "kuota": 100,
  "sisa_kuota": 100
}
```

**Response Success (201/200):**
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
    "created_at": "2026-06-05T10:30:20Z"
  }
}
```

---

### Step 4: GET /api/my-events - TAMPIL DAFTAR EVENT

**📍 Location:** `EventService.getMyEvents()` di `event_service.dart`

**Kapan dipanggil:**
- Saat halaman "Event Saya" dibuka
- Saat user menekan refresh button
- **SETELAH** event berhasil dibuat (redirect ke halaman Event Saya)

**Request:**
```dart
// Dari: EventSayaPage._loadEvents()
final result = await EventService.getMyEvents();
```

**HTTP Request:**
```
GET http://10.0.2.2:8000/api/my-events
Authorization: Bearer {token}
Accept: application/json
```

**Response Success (200):**
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
      "foto": "https://api.pentasera.com/storage/events/42-image.jpg",
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

**Bagian Gambar di UI:**
```dart
// Dari: EventSayaPage._buildEventCard()
Container(
  height: 120,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    image: imageUrl.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(imageUrl),  // ← Dari field "foto"
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: imageUrl.isEmpty
      ? Center(child: Icon(Icons.image))
      : null,
)
```

---

## 5. AUTHENTICATION & HEADERS

**📍 Location:** `AuthService.authHeaders()` di `auth_service.dart`

Semua request yang protected (⚠️ Auth: ✅) memerlukan token:

```dart
Future<Map<String, String>> authHeaders() async {
  final token = await _getToken(); // Ambil dari SharedPreferences
  return {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
```

**Diagram Authentication Flow:**
```
┌──────────────┐
│ Login Page   │
└──────┬───────┘
       │ AuthService.login()
       ↓
┌──────────────────────────┐
│ Backend: /api/login      │
│ Return: { token }        │
└──────┬───────────────────┘
       │ SharedPreferences.setString('token', token)
       ↓
┌──────────────────────────┐
│ Cache Token Locally      │
└──────┬───────────────────┘
       │
       ↓ AuthService.authHeaders()
┌──────────────────────────┐
│ API Requests (Protected) │
│ Header: Authorization    │
└──────────────────────────┘
```

---

## 6. DEMO WALKTHROUGH

### Skenario: Kreator membuat event "Konser Jazz" dengan gambar

#### **Timeline Eksekusi:**

```
⏱️ T=0s   → User buka BuatEventPage
           └─ UI: Step 1 ditampilkan

⏱️ T=5s   → User isi form Step 1:
           ├─ Nama Event: "Konser Jazz 2026"
           ├─ Kategori: "Musik"
           ├─ Deskripsi: "Konser jazz internasional"
           ├─ Tanggal Mulai: "15 Jun 2026"
           ├─ Lokasi: "Gedung Teater Jakarta"
           ├─ Kapasitas: "500"
           └─ Gambar: Tap upload → Pilih gambar dari galeri

⏱️ T=8s   → Gambar preview ditampilkan
           └─ Tombol "Lanjut" siap diklik

⏱️ T=9s   → User klik "Lanjut"
           └─ UI: Step 2 ditampilkan (Publikasi)

⏱️ T=12s  → User isi form Step 2:
           ├─ Nama Tiket: "VIP"
           ├─ Harga: "500000"
           ├─ Stok: "100"
           └─ Status: "Publikasi" ← Selected

⏱️ T=13s  → User klik "Publikasikan"
           ├─ Loading indicator ON
           └─ Backend: POST /api/events
               ├─ Payload:
               │  ├─ nama_event: "Konser Jazz 2026"
               │  ├─ lokasi: "Gedung Teater Jakarta"
               │  ├─ event_datetime: "2026-06-15 00:00:00"
               │  ├─ event_status: "published"
               │  ├─ organizer_id: 5
               │  ├─ deskripsi: "Konser jazz internasional"
               │  └─ Auth: Bearer {token}
               └─ ✅ Response:
                  └─ event_id: 42

⏱️ T=14s  → Backend: POST /api/events/42/image
           ├─ Multipart upload gambar
           ├─ File: [binary image data]
           ├─ Quality: 85%, Size: 1024x1024
           └─ ✅ Response:
              └─ image_url: "https://api.pentasera.com/storage/events/42.jpg"

⏱️ T=15s  → Backend: POST /api/tickets
           ├─ Payload:
           │  ├─ event_id: 42
           │  ├─ kategori: "VIP"
           │  ├─ harga: 500000
           │  ├─ kuota: 100
           │  └─ sisa_kuota: 100
           └─ ✅ Response:
              └─ ticket_id: 128

⏱️ T=16s  → Success Snackbar: "Event berhasil dipublikasikan!"
           ├─ Loading indicator OFF
           └─ Wait 1 second

⏱️ T=17s  → Redirect to EventSayaPage
           ├─ Backend: GET /api/my-events
           └─ ✅ Response:
              └─ Events list dengan event baru + gambar

⏱️ T=18s  → UI EventSayaPage ditampilkan
           ├─ Event "Konser Jazz 2026" muncul di tab "Aktif"
           ├─ Gambar terlihat di top card
           ├─ Status: "PUBLISHED" (green badge)
           └─ Tombol Edit & Hapus tersedia
```

---

## 7. ERROR HANDLING

### 7.1 Error Scenarios

| Kondisi | Error Message | Action |
|---------|---------------|--------|
| Nama event kosong | "Nama event tidak boleh kosong" | Stop submission |
| Network error saat POST /api/events | "Tidak dapat terhubung ke server" | Show snackbar, stop |
| Organizer ID tidak ditemukan | "Gagal mendapatkan data organizer" | Stop submission |
| Image upload failed | "Gagal upload gambar" | Continue (non-blocking) |
| Token expired | 401 Unauthorized | Redirect to login |
| Tiket gagal dibuat | "Error tiket: ..." | Show snackbar, continue |

### 7.2 Non-Blocking Upload

```dart
// Gambar upload TIDAK menghalangi alur:
if (!imageResult['success']) {
  debugPrint('[BuatEvent] WARNING: Image upload failed');
  // ✅ Proses tetap berlanjut ke redirect
  // ⚠️  User akan lihat event tanpa gambar
  // 📋 Gambar bisa diupload nanti via API terpisah
}
```

---

## 8. LOCAL STATE MANAGEMENT

### State Variables di `_BuatEventPageState`

```dart
// Image handling
File? _selectedImage;                          // Gambar yang dipilih
final ImagePicker _imagePicker = ImagePicker();

// Step 1 inputs
TextEditingController _namaControllerValue;    // Nama event
TextEditingController _deskripsiControllerValue;
TextEditingController _lokasiControllerValue;
TextEditingController _kapasitasControllerValue;
String _kategori = 'Tari';                     // Default: Tari
DateTime? _tanggalMulai;
DateTime? _tanggalSelesai;

// Step 2 inputs
TextEditingController _namaTicketControllerValue;
TextEditingController _hargaControllerValue;
TextEditingController _stokControllerValue;
String _status = 'draft';                      // Default: Draft

// UI state
int _currentStep = 0;                          // Step 1 or 2
bool _isLoading = false;                       // Loading indicator
```

---

## 9. UI COMPONENTS

### Image Picker Widget

```dart
// Lokasi: BuatEventPage - Step 1 content
GestureDetector(
  onTap: _pickImage,  // ← Panggil image picker
  child: Container(
    height: 160,
    child: _selectedImage == null
        ? Column(
            // Show placeholder dengan cloud icon
          )
        : Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),  // ← Preview
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                child: GestureDetector(
                  onTap: _clearImage,  // ← Tombol delete
                  child: Icon(Icons.close)
                )
              )
            ]
          )
  ),
)
```

### Event Card di EventSayaPage

```dart
// Image display dari API response
Container(
  height: 120,
  decoration: BoxDecoration(
    image: imageUrl.isNotEmpty
        ? DecorationImage(
            image: NetworkImage(imageUrl),  // ← URL dari API
            fit: BoxFit.cover,
          )
        : null,
  ),
  child: imageUrl.isEmpty
      ? Center(child: Icon(Icons.image))  // ← Placeholder
      : null,
)
```

---

## 10. DEPENDENCIES

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Image picking
  image_picker: ^1.1.2      # Gallery & camera selection
  
  # HTTP & API
  http: ^1.2.1              # HTTP requests
  
  # State & Auth
  flutter_riverpod: ^2.6.1  # State management (jika digunakan)
  flutter_secure_storage: ^9.2.4  # Secure token storage
  
  # UI
  google_fonts: ^8.0.2      # Font styling
  intl: ^0.19.0             # Date formatting
  cached_network_image: ^3.3.1  # Image caching
  shimmer: ^3.0.0           # Loading animation
```

---

## 11. FILE STRUCTURE REFERENCE

```
pentasera_app/
├── lib/
│   ├── main.dart                          # Main app entry
│   ├── core/
│   │   ├── app_router.dart                # Navigation routing
│   │   ├── constants/                     # Colors, typography
│   │   ├── errors/                        # Error handling
│   │   ├── network/                       # Network config
│   │   └── storage/                       # Local storage
│   ├── features/
│   │   ├── authentication/
│   │   │   └── login/                     # Login page
│   │   └── creator/
│   │       ├── buat_event/
│   │       │   └── buat_event_page.dart   # ✨ EVENT CREATION
│   │       ├── event_saya/
│   │       │   └── event_saya_page.dart   # ✨ EVENT LIST & IMAGE DISPLAY
│   │       └── dashboard/
│   ├── services/
│   │   ├── event_service.dart             # ✨ API CALLS
│   │   ├── auth_service.dart              # Auth & token
│   │   └── user_service.dart              # User data
│   └── shared/
│       └── widgets/                       # Reusable widgets
├── pubspec.yaml                           # Dependencies
└── docs/
    └── PRD_EVENT_IMAGE_UPLOAD.md          # ← This document
```

---

## 12. TESTING CHECKLIST

### Manual Testing Steps

- [ ] **Create Event (Step 1)**
  - [ ] Isi semua field dengan data valid
  - [ ] Upload gambar dari galeri
  - [ ] Lihat preview gambar
  - [ ] Klik "Lanjut"

- [ ] **Publish Event (Step 2)**
  - [ ] Isi tiket (optional)
  - [ ] Pilih status "Publikasi"
  - [ ] Klik "Publikasikan"

- [ ] **Verify Results**
  - [ ] Snackbar success muncul
  - [ ] Redirect ke EventSayaPage
  - [ ] Event muncul di tab "Aktif"
  - [ ] Gambar terlihat di event card
  - [ ] Status badge: "PUBLISHED"

- [ ] **Error Scenarios**
  - [ ] Kosongkan nama event → error message
  - [ ] Network disconnect → error message
  - [ ] Image too large → handle gracefully

- [ ] **Draft Mode**
  - [ ] Klik "Simpan Draft" di Step 2
  - [ ] Event muncul di tab "Draft"
  - [ ] Status badge: "DRAFT"

---

## 13. BASE URL CONFIGURATION

**EventService.baseUrl** - Dinamis per platform:

```dart
static String get baseUrl {
  if (kIsWeb) return 'http://localhost:8000/api';
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:8000/api';  // ← Android emulator
    default:
      return 'http://localhost:8000/api';  // ← iOS, Web
  }
}
```

### Mengapa 10.0.2.2 untuk Android?
- Android emulator tidak bisa akses `localhost`
- `10.0.2.2` = alias untuk host machine dari dalam emulator
- Real device perlu config IP sesuai network

---

## 14. SUMMARY

| Aspek | Detail |
|-------|--------|
| **Feature** | Event creation + image upload |
| **Screens** | BuatEventPage (2 steps), EventSayaPage |
| **API Calls** | 4 endpoints (create event, upload image, create ticket, list events) |
| **Auth** | Token-based (Bearer token) |
| **Image Handling** | Gallery picker → compress → preview → upload |
| **Error Handling** | Blocking (event) + Non-blocking (image) |
| **Database** | Backend Laravel (assumed) |
| **Packages** | image_picker, http, intl, cached_network_image |

---

**Last Updated:** June 5, 2026  
**Status:** ✅ Implementation Complete
