# PRODUCT REQUIREMENTS DOCUMENT (PRD)
## Pentasera App — Event Ticketing Platform

**Version:** 1.0.0  
**Last Updated:** April 2026  
**Status:** In Development  
**Platform:** Cross-platform (iOS, Android, Web)  

---

## 1. EXECUTIVE SUMMARY

Pentasera adalah aplikasi mobile event ticketing yang memungkinkan pengguna untuk **menemukan, membeli, dan mengelola tiket event** secara digital. Platform ini dirancang dengan arsitektur multi-role untuk melayani tiga persona utama: **Pembeli (Buyer)**, **Pembuat Event (Creator)**, dan **Administrator**.

Aplikasi mengintegrasikan multiple payment gateways, QR code validation, dan real-time inventory management untuk memberikan pengalaman seamless dalam ekosistem event ticketing digital.

---

## 2. PRODUCT VISION & OBJECTIVES

### Vision Statement
Menjadi platform ticketing event terdepan yang menghubungkan event creators dengan ticket buyers melalui pengalaman digital yang intuitif, aman, dan efisien.

### Business Objectives
- **Monetization**: Komisi dari setiap transaksi ticket (estimated 5-10%)
- **Market Penetration**: Capai 50,000+ pengguna aktif dalam 12 bulan
- **Ecosystem Growth**: Support 5,000+ event creators dalam Year 1
- **Customer Retention**: Target 60% monthly active users dari registered users

### Product Objectives
- Provide frictionless ticket purchase experience
- Enable event creators to manage events efficiently
- Maintain data integrity dan security compliance
- Support real-time inventory management
- Reduce manual ticketing overhead untuk event organizers

---

## 3. TARGET USERS & PERSONAS

### 3.1 Persona 1: Ticket Buyer (Pembeli Tiket)
**Name:** Aldi (26 yo)  
**Background:** Young professional, tech-savvy, actively attends events  
**Goals:**
- Quick & easy ticket discovery
- Secure payment options
- Digital ticket access & transfer
- Track order history

**Pain Points:**
- Multiple platforms untuk different events
- Payment security concerns
- Lost/damaged physical tickets
- Complicated refund processes

**User Segment:** Primary target, 60% of user base

---

### 3.2 Persona 2: Event Creator (Pembuat Event)
**Name:** Siti (32 yo)  
**Background:** Event organizer, owns event management company  
**Goals:**
- Easy event setup & management
- Real-time sales analytics
- Ticket inventory control
- Attendee management
- Revenue tracking & reporting

**Pain Points:**
- Complex ticketing systems
- Manual attendee tracking
- Payment processing complexity
- Limited insights on ticket sales

**User Segment:** Secondary target, 35% of user base

---

### 3.3 Persona 3: Administrator (Admin)
**Name:** Budi (40 yo)  
**Background:** System administrator, manages platform operations  
**Goals:**
- Monitor platform health
- User access management
- Content moderation
- System reporting & analytics

**Pain Points:**
- Need comprehensive visibility
- Complex user management
- Compliance & audit requirements

**User Segment:** Internal, 5% of user base

---

## 4. CORE FEATURES

### 4.1 AUTHENTICATION & AUTHORIZATION
**Requirement ID:** AUTH-001 to AUTH-005

| Feature | Description | Priority | Role |
|---------|-------------|----------|------|
| User Registration | Email/password signup dengan validation | P1 | All |
| User Login | Secure login dengan JWT token management | P1 | All |
| Role-Based Access Control (RBAC) | Route protection berdasarkan user role | P1 | All |
| Session Management | Token refresh & expiration handling | P1 | All |
| Profile Management | Update nama, email, kontak informasi | P2 | All |

**Acceptance Criteria:**
- ✓ Password harus minimal 8 karakter, kombinasi alphanumeric + special char
- ✓ Token expiry: 24 jam untuk access token, 30 hari untuk refresh token
- ✓ Login attempt limit: max 5 failed attempts, lock 15 menit
- ✓ All endpoints protected dengan authentication header

---

### 4.2 PUBLIC PAGES (Halaman Publik)
**Requirement ID:** PUBLIC-001 to PUBLIC-005

#### 4.2.1 Home/Event Discovery
**Features:**
- Browse all published events
- Search by event name, category, date range
- Filter by event type, location, price range
- Infinite scroll pagination (20 events per load)
- Event card display: thumbnail, title, date, location, price range

**Search Specifications:**
- Real-time search dengan debounce (500ms)
- Fuzzy matching untuk typo tolerance
- Support kategori: Konser, Seminar, Workshop, Festival, Sports, dst.
- Event status: **draft** → **published** → **ended** / **cancelled**

**Performance Target:** <2 sec page load time

---

#### 4.2.2 Event Detail Page
**Features:**
- Complete event information:
  - Event name, description, datetime
  - Event images/gallery
  - Organizer info
  - Location & map integration
  - Available ticket categories
- Ticket availability status real-time
- Similar events recommendation
- Share event functionality

**Technical Requirement:**
- Optimistic UI updates untuk ticket quantity
- Image lazy loading dengan caching

---

### 4.3 BUYER FEATURES (Pembeli Tiket)
**Requirement ID:** BUYER-001 to BUYER-020

#### 4.3.1 Ticket Purchase Flow
**Step 1: Add to Cart**
- Select ticket category
- Specify quantity (1-100 per kategori)
- Real-time inventory check
- Add multiple ticket types dalam satu cart

**Step 2: Checkout**
- Review order summary
  - Subtotal (quantity × ticket price)
  - Service fee: Rp 15,000
  - Discount dari voucher (if applied)
  - **Total = Subtotal + Service Fee - Discount**

- Buyer information:
  - Nama pemesan
  - Email pemesan
  - Phone number (optional)

- Ticket holder information:
  - Option: Gunakan data pemesan (default)
  - Option: Input data pemilik tiket berbeda

**Step 3: Payment Method Selection**
Enum nilai: `ewallet`, `virtual_account`, `qris`, `bank_transfer`

| Method | Providers | Settlement Time |
|--------|-----------|-----------------|
| e-wallet | GoPay, OVO, Dana, ShopeePay | Real-time |
| virtual_account | BCA, Mandiri, BNI, BRI | < 1 hour |
| QRIS | Semua bank via unified QR | Real-time |
| Bank Transfer | Manual transfer ke rekening | 1-2 jam |

**Step 4: Payment Processing**
- Trigger payment gateway integration
- Await payment confirmation
- Auto-retry for failed transactions (max 3x)
- Transaction timeout: 15 menit

---

#### 4.3.2 E-Ticket Management
**Features:**
- Digital ticket dengan QR code
  - QR code format: `detail_order_id-ticket_code`
  - Regenerate capability untuk lost tickets
- Ticket status tracking:
  - **pending** → **verified** → **used** → **expired**
- Ticket transfer/sharing (phase 2)
- Ticket download as PDF (phase 2)
- Event reminder notifications (phase 2)

**Technical Spec:**
- QR code encode: `detail_order_id` untuk validation
- Storage: Encrypted dalam e_tickets table
- Expiry: 24 jam sebelum event end time

---

#### 4.3.3 My Tickets Page (Tiket Saya)
**Features:**
- List semua tiket pembeli (grouped by status)
- Tabs: Upcoming, History, Expired
- For each ticket:
  - Event name, date, location
  - Seat/category info
  - QR code display
  - Ticket holder name
  - Quick actions: View, Share, Download

**Sorting & Filtering:**
- Sort by: Date (nearest first), Recently bought
- Filter by: Event type, Status

---

#### 4.3.4 Order History
**Features:**
- List all purchases dengan timestamps
- Order details view:
  - Order ID, purchase date
  - Payment method & amount
  - Receipt generation
  - Re-purchase option

---

### 4.4 CREATOR FEATURES (Pembuat Event)
**Requirement ID:** CREATOR-001 to CREATOR-030

#### 4.4.1 Event Creation & Management
**Create Event Form:**
- Event name (max 100 chars)
- Description (rich text, max 5000 chars)
- Event type: Konser, Seminar, Workshop, Festival, Sports, Other
- Event datetime:
  - Start date & time
  - End date & time
  - Timezone support
- Location:
  - Venue name
  - Address (street, city, province)
  - GPS coordinates (optional)
- Cover image upload (JPEG/PNG, max 5MB)
- Gallery (max 10 images)

**Event Status Workflow:**
```
draft → published → ended
  ↓
cancelled
```

**Event Drafts:**
- Can be edited before publishing
- Auto-save every 30 seconds
- Restore from trash: 30 days

---

#### 4.4.2 Ticket Configuration
**Ticket Category Management:**
- Per-event ticket categories (max 20)
- For each category:
  - Kategori/name: e.g., "VIP", "Regular", "Early Bird"
  - Harga: Price in Rupiah (1000 - 100,000,000)
  - Kuota: Available quantity (1 - 100,000)
  - Sisa kuota: Real-time tracking
  - Description (optional)
  - Start/end sale date (optional)

**Real-time Inventory:**
- Sisa kuota updates immediately upon purchase
- Overselling prevention dengan database locks
- Automatic refund jika exceed kuota

---

#### 4.4.3 Creator Dashboard
**Metrics Display:**
- Total events created (lifetime)
- Active events (published & not ended)
- Total tickets sold (lifetime)
- Total revenue (lifetime) — from komisi & details
- Upcoming events (next 30 days)
- Recent sales (last 7 days)

**Charts:**
- Sales trend (last 30 days): daily bar chart
- Ticket category performance: pie chart
- Revenue by payment method: horizontal bar chart

---

#### 4.4.4 Event Analytics
**Per-Event Metrics:**
- Tickets sold vs available
- Revenue breakdown by ticket category
- Sales velocity (tickets/day)
- Attendee demographics (if provided)
- Payment method distribution
- Refund rate & reasons

**Export Capabilities:**
- Download as CSV: attendee list dengan names, emails, tickets
- Download as PDF: sales report
- Email receipt untuk attendees (batch)

---

### 4.5 ADMIN FEATURES
**Requirement ID:** ADMIN-001 to ADMIN-015

#### 4.5.1 User Access Management
**Features:**
- List all users dengan pagination
- Search by: name, email, phone
- View user details:
  - Registration date, last login
  - Account status: active, suspended, banned
  - Total purchases/events
- User actions:
  - Suspend: Disable login privileges
  - Ban: Permanent account freeze
  - Reset password: Force reset on next login
- Role assignment/modification

**Access Controls:**
- All users start with "buyer" role by default
- Creator role: manual assignment or request form (phase 2)
- Admin role: invitation only

---

#### 4.5.2 Content Moderation
**Features:**
- Flag/report event atau user
- Review reported content
- Approve/reject event publications
- Remove inappropriate events/content
- Send warning/notification ke users

**Report Types:**
- Suspicious user behavior
- Inappropriate event content
- Fake/fraud events
- Offensive images/description

---

#### 4.5.3 Platform Monitoring
**Metrics:**
- Total registered users
- Active users (last 7/30 days)
- Daily/weekly/monthly revenue
- Failed transactions rate
- System health: API response time, error rates
- Database integrity checks

---

## 5. DATA MODEL & DATABASE SCHEMA

### 5.1 Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nama VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  role ENUM('buyer', 'creator', 'admin') DEFAULT 'buyer',
  status ENUM('active', 'suspended', 'banned') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

### 5.2 Events Table
```sql
CREATE TABLE events (
  id UUID PRIMARY KEY,
  creator_id UUID NOT NULL,
  nama_event VARCHAR(255) NOT NULL,
  deskripsi TEXT,
  event_datetime DATETIME NOT NULL,
  event_status ENUM('draft', 'published', 'ended', 'cancelled') DEFAULT 'draft',
  lokasi_venue VARCHAR(255),
  lokasi_address TEXT,
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  image_url VARCHAR(255),
  kategori_event VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at TIMESTAMP NULL,
  FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_events_creator (creator_id),
  INDEX idx_events_status (event_status),
  INDEX idx_events_datetime (event_datetime)
);
```

### 5.3 Tickets Table
```sql
CREATE TABLE tickets (
  id UUID PRIMARY KEY,
  event_id UUID NOT NULL,
  kategori VARCHAR(100) NOT NULL,
  harga INT NOT NULL,
  kuota INT NOT NULL,
  sisa_kuota INT NOT NULL,
  deskripsi TEXT,
  start_sale_datetime DATETIME,
  end_sale_datetime DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  INDEX idx_tickets_event (event_id),
  INDEX idx_tickets_sisa_kuota (sisa_kuota)
);
```

### 5.4 Orders Table
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  total_harga INT NOT NULL,
  order_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_orders_user (user_id),
  INDEX idx_orders_status (order_status)
);
```

### 5.5 Detail Orders Table
```sql
CREATE TABLE detail_orders (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  ticket_id UUID NOT NULL,
  jumlah INT NOT NULL,
  subtotal INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (ticket_id) REFERENCES tickets(id),
  INDEX idx_detail_orders_order (order_id),
  INDEX idx_detail_orders_ticket (ticket_id)
);
```

### 5.6 E-Tickets Table
```sql
CREATE TABLE e_tickets (
  id UUID PRIMARY KEY,
  detail_order_id UUID NOT NULL,
  kode_qr VARCHAR(255) UNIQUE NOT NULL,
  ticket_status ENUM('pending', 'verified', 'used', 'expired') DEFAULT 'pending',
  nama_pemilik VARCHAR(255),
  email_pemilik VARCHAR(255),
  verified_at TIMESTAMP NULL,
  used_at TIMESTAMP NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (detail_order_id) REFERENCES detail_orders(id) ON DELETE CASCADE,
  INDEX idx_e_tickets_detail_order (detail_order_id),
  INDEX idx_e_tickets_kode_qr (kode_qr),
  INDEX idx_e_tickets_status (ticket_status)
);
```

### 5.7 Payments Table
```sql
CREATE TABLE payments (
  id UUID PRIMARY KEY,
  order_id UUID NOT NULL,
  jumlah_bayar INT NOT NULL,
  metode ENUM('qris', 'ewallet', 'virtual_account', 'bank_transfer') NOT NULL,
  payment_status ENUM('pending', 'completed', 'failed', 'expired') DEFAULT 'pending',
  reference_id VARCHAR(255),
  gateway_response TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  INDEX idx_payments_order (order_id),
  INDEX idx_payments_metode (metode),
  INDEX idx_payments_status (payment_status)
);
```

---

## 6. USER FLOWS

### 6.1 Buyer - Ticket Purchase Flow
```
1. Browse Events
   ├─ View home (published events)
   ├─ Search/filter
   └─ Select event

2. View Event Details
   ├─ View event info, images, tickets
   └─ Select ticket category & quantity

3. Add to Cart
   ├─ Confirm quantity
   ├─ Check real-time availability
   └─ Proceed to checkout

4. Checkout (4-step flow)
   ├─ Step 1: Create Order (user_id + total_harga)
   ├─ Step 2: Create Detail Order (ticket_id + jumlah + subtotal)
   ├─ Step 3: Create Payment (order_id + metode + jumlah_bayar)
   └─ Step 4: Create E-Ticket (detail_order_id → generate kode_qr)

5. Payment Processing
   ├─ Select payment method
   ├─ Submit payment
   ├─ Payment gateway processing
   └─ Await confirmation (timeout 15 min)

6. Ticket Received
   ├─ Navigate to E-Ticket page
   ├─ Display QR code
   ├─ Show event details + ticket holder name
   └─ Option to access from "Tiket Saya" page

7. View My Tickets
   ├─ List all tickets
   ├─ Filter by status (Upcoming/History/Expired)
   └─ Open ticket → show QR + details
```

### 6.2 Creator - Event Management Flow
```
1. Create Event
   ├─ Fill event form (name, desc, datetime, location, image)
   ├─ Save as draft
   └─ Auto-save every 30 sec

2. Configure Tickets
   ├─ Add ticket categories
   ├─ Set price & quota per kategori
   └─ Define sale period (optional)

3. Publish Event
   ├─ Review event details
   ├─ Verify all required fields
   └─ Change status: draft → published

4. Monitor Sales
   ├─ View dashboard analytics
   ├─ Check real-time ticket sales
   ├─ Monitor revenue
   └─ Export reports

5. Manage Event (post-publish)
   ├─ View upcoming event
   ├─ Check attendee list
   ├─ Send announcements (phase 2)
   └─ Adjust inventory (limited)

6. Event Completion
   ├─ Event auto-transitions to "ended"
   ├─ Final analytics available
   └─ Revenue settlement (phase 2)
```

### 6.3 Admin - Platform Management Flow
```
1. Dashboard Overview
   ├─ View key metrics (users, events, revenue)
   ├─ Monitor system health
   └─ Check alerts/issues

2. User Management
   ├─ Search users
   ├─ View details
   ├─ Assign roles
   └─ Suspend/ban if needed

3. Content Moderation
   ├─ Review flagged content
   ├─ Approve/reject events
   └─ Take action on violations

4. Generate Reports
   ├─ Platform analytics
   ├─ User segmentation
   └─ Revenue reports
```

---

## 7. PAYMENT FLOW (Detailed)

### 7.1 Payment Processing Steps

**Frontend (Flutter App):**
```
1. User selects payment method
2. Validates order data
3. API Call 1: POST /orders
   → Create order with (user_id, total_harga)
   → Receive order_id
   
4. API Call 2: POST /detail-orders
   → Create detail order with (order_id, ticket_id, jumlah, subtotal)
   → Receive detail_order_id
   
5. API Call 3: POST /payments
   → Create payment with (order_id, metode, jumlah_bayar)
   → Receive payment_id & redirect_url (if applicable)
   
6. API Call 4: POST /e-tickets
   → Create e-ticket with detail_order_id
   → Receive e_ticket_id & kode_qr
   
7. Navigate to E-Ticket page
   → Display QR code (from kode_qr)
   → Show ticket details
```

### 7.2 Payment Methods Integration

| Method | Integration | Status |
|--------|-------------|--------|
| QRIS | Midtrans/Xendit API | Phase 1 ✓ |
| E-wallet | Midtrans/Xendit API | Phase 1 ✓ |
| Virtual Account | Midtrans/Xendit API | Phase 1 ✓ |
| Bank Transfer | Manual verification (Phase 2) | Planned |

### 7.3 Transaction Status Flow
```
Order Created
  ├─ order_status: pending
  ├─ payment_status: pending
  └─ e_ticket_status: pending
        ↓
Payment Initiated
  └─ Awaiting payment gateway response (15 min timeout)
        ↓
Payment Confirmed
  ├─ order_status: completed
  ├─ payment_status: completed
  └─ e_ticket_status: verified
        ↓
E-Ticket Available
  └─ User can see QR code & share ticket
```

### 7.4 Failure Handling
- **Payment Timeout:** Auto-cleanup after 15 minutes
- **Payment Failed:** Retry mechanism (max 3 attempts)
- **Refund Request:** Manual processing by admin (phase 2)

---

## 8. TECHNICAL ARCHITECTURE

### 8.1 Tech Stack

**Frontend (Mobile):**
- **Framework:** Flutter 3.5+
- **Language:** Dart
- **State Management:** StatefulWidget (current), consider Provider/BLoC for future
- **HTTP Client:** http package (v1.2.1+)
- **Storage:** SharedPreferences (local)
- **QR Generation:** qr_flutter (v4.1.0+)
- **Image Caching:** cached_network_image (v3.3.1+)
- **UI Components:** Material Design 3
- **Fonts:** Google Fonts (Plus Jakarta Sans)
- **Internationalization:** intl package

**Backend (Referenced):**
- **Language:** Not specified (assumed Node.js/Express or Laravel/PHP)
- **Database:** MySQL/MariaDB
- **Payment Gateway:** Midtrans/Xendit integration
- **Authentication:** JWT (Bearer token)
- **API Format:** REST with JSON

**DevOps:**
- **Version Control:** Git
- **CI/CD:** Recommended GitHub Actions or GitLab CI
- **Deployment:** Native app stores (Apple App Store, Google Play Store)

### 8.2 API Endpoints (Frontend Consumption)

#### Authentication
```
POST   /auth/login          → Login user
POST   /auth/register       → Register new user
POST   /auth/refresh        → Refresh JWT token
POST   /auth/logout         → Logout (optional)
GET    /me                  → Get current user info
```

#### Events
```
GET    /events              → List published events (with pagination)
GET    /events/:id          → Get event details
GET    /events/:id/tickets  → Get ticket categories for event
```

#### Orders & Payments (Checkout Flow)
```
POST   /orders              → Create order
POST   /detail-orders       → Create detail order
POST   /payments            → Create payment & initiate gateway
POST   /e-tickets           → Create e-ticket
GET    /orders/:id          → Get order details
GET    /payments/:id        → Get payment status
```

#### Creator Features
```
POST   /events              → Create event
PUT    /events/:id          → Update event
DELETE /events/:id          → Delete event (soft delete)
POST   /events/:id/tickets  → Create ticket category
PUT    /events/:id/tickets/:ticketId → Update ticket
GET    /events/:id/analytics → Get event analytics
GET    /events/:id/attendees → List attendees
```

#### Admin Features
```
GET    /admin/users         → List all users
GET    /admin/users/:id     → Get user details
PUT    /admin/users/:id     → Update user (role/status)
GET    /admin/events        → List all events for moderation
POST   /admin/events/:id/approve  → Approve event
DELETE /admin/events/:id    → Remove event
GET    /admin/analytics     → Platform analytics
```

---

## 9. SECURITY & COMPLIANCE

### 9.1 Authentication & Authorization
- **JWT Tokens:**
  - Access Token: 24-hour expiry
  - Refresh Token: 30-day expiry
  - Token stored securely in SharedPreferences (encrypted if possible)
- **Password Requirements:**
  - Minimum 8 characters
  - Mix of uppercase, lowercase, numbers, special characters
  - Hashing: bcrypt or PBKDF2
- **HTTPS:** All API calls must use HTTPS
- **CORS:** Configure appropriate CORS headers

### 9.2 Data Protection
- **PCI Compliance:** Payment card data handled by payment gateway (no direct storage)
- **GDPR Compliance:** User data deletion requests, data export (phase 2)
- **Data Encryption:** Sensitive data encrypted at rest & in transit
- **Backup:** Daily database backups, 30-day retention

### 9.3 Rate Limiting
- Login attempts: max 5/15 minutes
- API requests: 100 requests/minute per user
- Search: 50 requests/minute

### 9.4 Account Security
- Login attempt limit with account lockout
- Session timeout: 24 hours
- Suspicious activity alerts (phase 2)
- Two-factor authentication (phase 3)

---

## 10. PERFORMANCE TARGETS

| Metric | Target | Current |
|--------|--------|---------|
| Home page load time | < 2 seconds | TBD |
| Event details load time | < 1.5 seconds | TBD |
| Checkout completion time | < 30 seconds | In progress |
| Payment processing | < 2 seconds (gateway) | TBD |
| Search response time | < 500ms | TBD |
| Image loading | < 1 second | With caching |
| API response time (avg) | < 200ms | TBD |
| Database query time (avg) | < 100ms | TBD |

---

## 11. SUCCESS METRICS & KPIs

### User Acquisition & Growth
- Monthly Active Users (MAU)
- Daily Active Users (DAU)
- User retention rate (7-day, 30-day, 90-day)
- Cost per acquisition (CPA)

### Engagement Metrics
- Average tickets per transaction
- Average transaction value
- Feature usage distribution
- Time spent in app

### Monetization Metrics
- Total transaction value (GTV)
- Commission revenue
- Average order value (AOV)
- Payment success rate (target: 98%)

### Creator Metrics
- Number of active creators
- Events per creator (average)
- Ticket sell-through rate
- Creator satisfaction score

### Operational Metrics
- API uptime (target: 99.9%)
- Payment failure rate (target: < 2%)
- User support response time
- Bug fix cycle time

---

## 12. ROADMAP & PHASES

### Phase 1: MVP (Current - Q2 2026)
**Focus:** Core ticketing functionality for buyers & creators

- ✅ User authentication & authorization
- ✅ Event browsing & discovery
- ✅ Ticket purchase flow (4-step)
- ✅ Payment integration (QRIS, E-wallet, Virtual Account)
- ✅ E-ticket generation & QR code
- ✅ Creator event management
- ✅ Creator dashboard (basic analytics)
- ✅ Admin user management
- ✅ Dark mode support

**Release Date:** Q2 2026

---

### Phase 2: Enhanced Features (Q3 2026)
**Focus:** Advanced features & UX improvements

- [ ] Ticket transfer/sharing
- [ ] Advanced analytics & reporting
- [ ] Push notifications (event reminders)
- [ ] In-app messaging (creator ↔ buyer)
- [ ] Refund management system
- [ ] Creator verification & badges
- [ ] Voucher & promo code system
- [ ] PDF ticket download
- [ ] Email receipts & confirmations
- [ ] Bank transfer payment method (manual verification)

**Estimated Duration:** 4-6 weeks

---

### Phase 3: Scale & Optimization (Q4 2026)
**Focus:** Performance, scale, & monetization

- [ ] Advanced search with Elasticsearch
- [ ] Recommendation engine
- [ ] Waitlist feature for sold-out events
- [ ] Dynamic pricing
- [ ] Creator payout system (automated)
- [ ] Event sponsorship management
- [ ] Two-factor authentication
- [ ] API rate limiting & caching
- [ ] Web portal (desktop version)
- [ ] Admin reporting suite

**Estimated Duration:** 6-8 weeks

---

### Phase 4: Ecosystem & Partnerships (Q1 2027)
**Focus:** Third-party integrations & expansion

- [ ] Google Calendar integration
- [ ] Stripe/PayPal integration
- [ ] Marketing partner integrations
- [ ] White-label solutions for enterprise
- [ ] Affiliate program
- [ ] B2B ticket management

**Estimated Duration:** Ongoing

---

## 13. RISKS & MITIGATION

### Risk 1: Payment Gateway Failures
**Impact:** High | **Probability:** Medium

**Mitigation:**
- Implement retry logic (3 attempts)
- Fallback to secondary payment provider
- 15-minute payment timeout with cleanup
- Real-time monitoring & alerts

---

### Risk 2: Inventory Overselling
**Impact:** Critical | **Probability:** Low

**Mitigation:**
- Database-level row locking during purchase
- Real-time quota validation
- Atomic transactions for order + detail_order creation
- Monitoring untuk suspicious patterns

---

### Risk 3: Security Breach / Data Leakage
**Impact:** Critical | **Probability:** Low

**Mitigation:**
- HTTPS for all communications
- JWT token validation
- Rate limiting & DDoS protection
- Regular security audits
- PCI compliance for payments
- Encryption at rest & in transit

---

### Risk 4: High Latency During Peak Times
**Impact:** High | **Probability:** Medium

**Mitigation:**
- Database query optimization & indexing
- API caching strategies
- CDN for static assets
- Load balancing
- Auto-scaling infrastructure

---

### Risk 5: Creator Churn
**Impact:** Medium | **Probability:** Medium

**Mitigation:**
- Creator onboarding program
- 24/7 support & documentation
- Community forum
- Creator incentive program
- Regular feature updates

---

## 14. ASSUMPTIONS & DEPENDENCIES

### Assumptions
- Backend API is stable & well-documented
- Payment gateway providers (Midtrans/Xendit) are reliable
- Users have access to internet (no offline mode planned for Phase 1)
- iOS 12.0+ & Android 6.0+ device support
- Users are willing to provide necessary personal information

### Dependencies
- Payment gateway provider availability
- App store approval process (iOS & Android)
- Third-party libraries stability (Flutter packages)
- Backend infrastructure reliability
- Network connectivity

---

## 15. DEFINITIONS & GLOSSARY

| Term | Definition |
|------|-----------|
| **Order** | Customer's purchase transaction (user_id + total_harga) |
| **Detail Order** | Line items within an order (ticket_id + quantity + subtotal) |
| **E-Ticket** | Digital ticket with QR code for event entry (generated from detail_order_id) |
| **Kode QR** | Unique QR code identifier for each e-ticket |
| **Kuota** | Available inventory for a ticket category |
| **Sisa Kuota** | Remaining/sold inventory for a ticket category |
| **Creator** | User role: Event organizer/publisher |
| **Buyer** | User role: Ticket purchaser |
| **Admin** | User role: Platform administrator |
| **RBAC** | Role-Based Access Control |
| **JWT** | JSON Web Token for authentication |
| **GTV** | Gross Transaction Value |
| **AOV** | Average Order Value |
| **MAU** | Monthly Active Users |
| **DAU** | Daily Active Users |

---

## 16. DOCUMENT HISTORY

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 0.1 | Apr 2026 | Product Team | Initial draft |
| 1.0 | Apr 2026 | Product Team | Ready for Phase 1 |

---

## APPENDIX A: User Story Examples

### User Story 1: Buyer - Purchase Ticket
```
As a buyer,
I want to browse events and purchase tickets easily,
So that I can attend my favorite events without hassle.

Acceptance Criteria:
- I can see a list of published events on the home page
- I can search and filter events by name, date, and type
- I can view event details with ticket availability
- I can complete checkout with 4-step process
- I receive a digital QR code e-ticket after payment
- I can view my tickets anytime from "Tiket Saya" page
```

### User Story 2: Creator - Manage Event
```
As a creator,
I want to create and manage events with ease,
So that I can focus on event organization rather than ticketing logistics.

Acceptance Criteria:
- I can create an event with all necessary details
- I can set up multiple ticket categories with pricing and quota
- I can publish events and see real-time sales
- I can view event analytics and attendee information
- I can export attendee lists and sales reports
```

### User Story 3: Admin - Moderate Content
```
As an admin,
I want to manage users and moderate event content,
So that the platform remains safe and compliant.

Acceptance Criteria:
- I can view all users and their account details
- I can assign/revoke roles and suspend accounts
- I can review flagged events and approve/reject them
- I can view platform-wide analytics and metrics
```

---

**END OF DOCUMENT**

---

*This PRD is a living document and will be updated as the product evolves. Last updated: April 2026*
