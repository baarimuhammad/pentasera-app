# QUICK REFERENCE: Event Creation + Image Upload Demo

## 🎯 Objective
Demonstrasikan fitur pembuatan event dengan upload gambar di Pentasera App

---

## 📱 UI FLOW

### Screen 1: Buat Event (Step 1 - Informasi Event)
```
┌─────────────────────────────────────┐
│          Buat Event                 │  ← AppBar
├─────────────────────────────────────┤
│                                     │
│ Input Fields:                       │
│ ├─ Nama Event: [_____________]      │
│ ├─ Kategori: [Tari ▼]              │
│ ├─ Deskripsi: [___________]         │
│ │                                   │
│ ├─ Tanggal Mulai: [Pilih]           │
│ ├─ Tanggal Selesai: [Pilih]         │
│ ├─ Lokasi: [_____________]          │
│ ├─ Kapasitas: [_____________]       │
│                                     │
│ 📷 Foto Event:                      │
│ ┌──────────────────────────────┐   │
│ │  [Upload Icon]               │   │ ← Tap to pick image
│ │  Tap untuk upload foto       │   │
│ └──────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│        [Lanjut]                     │ ← Green button
└─────────────────────────────────────┘
```

### Screen 2: Publikasi Event (Step 2)
```
┌─────────────────────────────────────┐
│          Buat Event                 │
├─────────────────────────────────────┤
│                                     │
│ Preview:                            │
│ ┌──────────────────────────────┐   │
│ │ Konser Jazz 2026             │   │
│ │ Musik • Gedung Teater        │   │
│ │ 15 Jun 2026                  │   │
│ └──────────────────────────────┘   │
│                                     │
│ Informasi Tiket:                    │
│ ├─ Nama Tiket: [_____________]      │
│ ├─ Harga (Rp): [_____________]      │
│ ├─ Stok: [_____________]            │
│                                     │
│ Status Event:                       │
│ ├─ ○ Draft    ● Publikasi          │
│                                     │
├─────────────────────────────────────┤
│  [Simpan Draft]  [Publikasikan]     │
└─────────────────────────────────────┘
```

### Screen 3: Event Saya (Hasil)
```
┌─────────────────────────────────────┐
│          Event Saya              🔄  │
├──────────┬──────────┬──────────────┤
│  Draft   │  Aktif   │    Lalu      │
└──────────┴──────────┴──────────────┘
│                                     │
│ ┌──────────────────────────────┐   │
│ │                              │   │
│ │    [📷 Event Image Here]     │   │ ← Gambar muncul!
│ │                              │   │
│ ├──────────────────────────────┤   │
│ │ Konser Jazz 2026       [PUB] │   │
│ │ Musik • Gedung Teater        │   │
│ │ 15 Jun 2026                  │   │
│ │                              │   │
│ │ [Edit] [Hapus]               │   │
│ └──────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

---

## 🔄 ALUR EKSEKUSI API

### Timeline Lengkap:

```
USER INPUT (Frontend)
        ↓
[STEP 1] User isi form + upload gambar
        ↓
        Klik "Lanjut"
        ↓
[STEP 2] User isi tiket + pilih status
        ↓
        Klik "Publikasikan"
        ↓
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[API 1] ⏱️ T=0s
POST /api/events
Header: Bearer {token}
Body:
{
  "nama_event": "Konser Jazz 2026",
  "lokasi": "Gedung Teater Jakarta",
  "event_datetime": "2026-06-15 00:00:00",
  "event_status": "published",
  "organizer_id": 5,
  "deskripsi": "..."
}
Response: { success: true, data: { id: 42 } }
        ↓
[API 2] ⏱️ T=1s
POST /api/events/42/image
Header: Bearer {token}
Body: (multipart file upload)
- image: <binary data dari _selectedImage>
Response: { success: true, image_url: "..." }
        ↓
[API 3] ⏱️ T=2s
POST /api/tickets
Header: Bearer {token}
Body:
{
  "event_id": 42,
  "kategori": "VIP",
  "harga": 500000,
  "kuota": 100,
  "sisa_kuota": 100
}
Response: { success: true, data: { id: 128 } }
        ↓
[REDIRECT] ⏱️ T=3s
Navigator.push → EventSayaPage
        ↓
[API 4] ⏱️ T=3s
GET /api/my-events
Header: Bearer {token}
Response: { data: [..., event baru dengan foto] }
        ↓
✅ DISPLAY EVENT DENGAN GAMBAR DI UI
```

---

## 📍 API ENDPOINTS REFERENCE

| # | Method | Endpoint | Purpose | Auth |
|---|--------|----------|---------|------|
| 1 | POST | `/api/events` | Buat event baru | ✅ |
| 2 | POST | `/api/events/{id}/image` | Upload gambar | ✅ |
| 3 | POST | `/api/tickets` | Buat tiket | ✅ |
| 4 | GET | `/api/my-events` | Ambil event saya | ✅ |

---

## 🔑 KEY POINTS UNTUK PRESENTASI

### 1. Image Picker Integration ✨
```
User Tap Image Area
        ↓
Flutter image_picker.pickImage()
        ↓
User pilih dari galeri
        ↓
File? _selectedImage ← Simpan referensi
        ↓
Tampilkan preview di UI
```

### 2. Image Upload Strategy 🎯
```
Event Created (SUCCESS)
        ↓
        └─→ Image Upload (Non-blocking)
            ├─ Jika berhasil: image_url tersimpan
            └─ Jika gagal: Event tetap aman, bisa upload nanti
```

### 3. Image Display Pipeline 📸
```
Backend Response (GET /api/my-events)
{
  "foto": "https://api.pentasera.com/storage/events/42.jpg"
}
        ↓
Network Image Widget
        ↓
Display di Event Card
```

---

## 🛠️ TECHNICAL STACK

```
Frontend:
├─ Flutter 3.5+
├─ image_picker: ^1.1.2    ← Gallery selection
├─ http: ^1.2.1            ← API calls
└─ intl: ^0.19.0           ← Date formatting

Backend (Assumed):
├─ Laravel
├─ MySQL
├─ Storage: /storage/events/
└─ API Response: { success, data, message }

Auth:
├─ Token-based
├─ Bearer {token} in headers
└─ Stored in SharedPreferences
```

---

## ⚠️ ERROR SCENARIOS & HANDLING

### Scenario 1: Network Error on Event Creation
```
USER ACTION: Klik Publikasikan
        ↓
API CALL: POST /api/events
        ↓
❌ No internet
        ↓
RESPONSE: { success: false, message: "Tidak dapat terhubung..." }
        ↓
ACTION: Show snackbar error, STOP (don't proceed)
```

### Scenario 2: Image Upload Fails (Non-Blocking)
```
EVENT: Created ✅
        ↓
IMAGE UPLOAD: POST /api/events/42/image
        ↓
❌ File too large / Network error
        ↓
RESPONSE: { success: false, message: "File terlalu besar" }
        ↓
ACTION: Log warning, CONTINUE (event still saved)
        ↓
RESULT: Event muncul tanpa gambar, bisa diupdate nanti
```

### Scenario 3: Organizer Not Found
```
EVENT CREATION: Need organizer_id
        ↓
API CALL: GET /api/organizers
        ↓
❌ User tidak terdaftar sebagai kreator
        ↓
RESPONSE: { success: false, message: "Gagal mendapatkan..." }
        ↓
ACTION: Show error, STOP
```

---

## ✅ DEMO SCRIPT

### Setup
- [ ] Buka app di Android Emulator atau Device
- [ ] Login sebagai kreator/admin
- [ ] Navigate ke "Buat Event"

### Demo Steps

**Step 1: Event Information**
```
1. Fill form:
   - Nama Event: "Konser Jazz 2026"
   - Kategori: "Musik"
   - Deskripsi: "Konser jazz internasional dengan artis terkenal"
   - Tanggal: 15 June 2026
   - Lokasi: "Gedung Teater Jakarta"
   - Kapasitas: "500"

2. Upload Gambar:
   - Tap "Tap untuk upload foto"
   - Select image dari galeri
   - Show preview (dengan X button)
   
3. Klik "Lanjut"
```

**Step 2: Publication**
```
1. Show preview di Step 2
2. Fill tiket:
   - Nama: "VIP"
   - Harga: "500000"
   - Stok: "100"
   
3. Select status: "Publikasi"

4. Klik "Publikasikan"
   → Show loading indicator
   → Success snackbar: "Event berhasil dipublikasikan!"
   → Auto redirect ke Event Saya
```

**Step 3: Verification**
```
1. Navigate ke Event Saya
2. Click tab "Aktif"
3. Verify:
   ✅ Event "Konser Jazz 2026" muncul
   ✅ Gambar terlihat di top card
   ✅ Status badge: "PUBLISHED"
   ✅ Kategori & lokasi ditampilkan
```

---

## 📊 STATE FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────┐
│                     BuatEventPage                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  State Variables:                                           │
│  ├─ File? _selectedImage              ← Image picker result │
│  ├─ String _namaEvent                 ← Text input          │
│  ├─ DateTime? _tanggalMulai           ← Date picker         │
│  ├─ int _currentStep                  ← Step 1 or 2        │
│  ├─ bool _isLoading                   ← API call status    │
│  └─ ...other fields                                        │
│                                                             │
│  Methods:                                                   │
│  ├─ _pickImage()        → Opens gallery                    │
│  ├─ _clearImage()       → Clear selection                  │
│  ├─ _handleSubmit()     → Validate & call APIs             │
│  └─ setState()          → Rebuild UI                       │
│                                                             │
│  Event Listeners:                                           │
│  ├─ onTap (image area)  → _pickImage()                     │
│  ├─ onPressed (next)    → setState(_currentStep++)         │
│  └─ onPressed (submit)  → _handleSubmit()                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
            ┌───────────────────────────────┐
            │   EventService (API Layer)    │
            ├───────────────────────────────┤
            │ static createEvent()          │
            │ static uploadEventImage()     │
            │ static createTicket()         │
            │ static getMyEvents()          │
            └───────────────────────────────┘
                            ↓
            ┌───────────────────────────────┐
            │   Backend API (Laravel)       │
            ├───────────────────────────────┤
            │ POST /api/events              │
            │ POST /api/events/{id}/image   │
            │ POST /api/tickets             │
            │ GET /api/my-events            │
            └───────────────────────────────┘
                            ↓
            ┌───────────────────────────────┐
            │   Database + Storage          │
            ├───────────────────────────────┤
            │ events table                  │
            │ tickets table                 │
            │ /storage/events/ (images)     │
            └───────────────────────────────┘
```

---

## 🎬 VISUAL DEMO CHECKLIST

- [ ] **Before demo:**
  - [ ] Backend running dan accessible
  - [ ] Device/emulator connected
  - [ ] Gallery punya test image
  - [ ] User sudah login

- [ ] **During demo:**
  - [ ] Show form filling smooth
  - [ ] Image preview muncul dengan cepat
  - [ ] Loading indicator visible saat submit
  - [ ] Success message jelas
  - [ ] Redirect smooth ke Event Saya
  - [ ] Image visible di event card
  - [ ] Status badge benar

- [ ] **After demo:**
  - [ ] Verify API logs (backend)
  - [ ] Check database (events, tickets, images)
  - [ ] Confirm image file stored correctly
  - [ ] Test image deletion flow

---

## 📞 TROUBLESHOOTING

| Issue | Solution |
|-------|----------|
| Image tidak muncul di galeri picker | Perlu permission di AndroidManifest.xml |
| Upload fails dengan 403 | Token expired, re-login |
| Event created tapi image tidak | Check backend storage permissions |
| Gambar blur di preview | Ukuran terlalu besar, check quality |
| Redirect tidak bekerja | Cek app_router.dart navigation |
| API tidak terhubung | Verifikasi baseUrl (localhost vs 10.0.2.2) |

---

**Document Version:** 1.0  
**Last Updated:** June 5, 2026  
**Prepared for:** Demo & Presentation
