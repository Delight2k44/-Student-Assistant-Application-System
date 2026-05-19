#  Student Assistant Application System

**Module:** Technical Programming III (TPG316C)  
**Programme:** Diploma in Information Technology  
**Institution:** Central University of Technology, Free State  
**Assignment Type:** Group Assignment (30% of Final Semester Mark)  
**Due Date:** 15 May 2026

---

##  Project Overview

The Student Assistant Application System is a mobile application built with **Flutter** and **Supabase** that allows students to apply for Student Assistant positions within the Information Technology Department. The system manages applications for first-year, second-year, and third-year modules in a structured and secure manner.

The application supports two user roles:
- **Students** — can submit, view, edit, and delete their applications
- **Admins** — can view all applications, approve or reject them, and manage records

---

##  Group Members

| Full Name | Student Number |
|---|---|
| Delight Tshitangano | 223022577 |
| Geraldo Leeuw | 221026798 |
| Mathabo Mohapi | 222070281|
| *(Add member name)* | *(Add student number)* |


---

##  Contributors — README Acknowledgement

> **Important:** Every group member who contributed to this project **must** add their name and student number below as proof that they have read through this README and understand the system.

| Full Name | Student Number | Date |
|---|---|---|
| Delight Tshitangano | 223022577 | 15 May 2026 |
| Geraldo Leeuw | 221026798 | 15 May 2026 |
| Mathabo Mohapi | 222070281 | 15 May 2026 |
| *(Your full name)* | *(Your student number)* | *(Date)* |
| *(Your full name)* | *(Your student number)* | *(Date)* |

---
Login Details 

Email: admin@gmail.com
password:Test!1234

For User 
Create a new user 

##  Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| Supabase | Backend (Auth, Database, Storage) |
| Provider | State management |
| MVVM | Architectural pattern |
| GitHub | Version control and collaboration |

---

##  Architecture — MVVM with Provider

This project follows the **Model-View-ViewModel (MVVM)** architecture pattern as required by the assignment.

```
lib/
├── models/
│   ├── application_model.dart      # StudentApplication data model
│   └── user_model.dart             # User model
├── viewmodels/
│   ├── admin_viewmodel.dart        # Admin logic: fetch, approve, reject
│   ├── application_viewmodel.dart  # Submit, edit, delete applications
│   ├── auth_viewmodel.dart         # Login, signup, role detection
│   └── home_viewmodel.dart         # Student's application list (real-time)
├── views/
│   ├── onboarding_view.dart        # Welcome/onboarding screen
│   ├── login_view.dart             # Authentication screen
│   ├── signup_view.dart            # Registration screen
│   ├── home_view.dart              # Student home — application overview
│   ├── application_form_view.dart  # Submit new application
│   ├── application_detail_view.dart# View, edit, delete application
│   ├── edit_application_view.dart  # Edit pending application
│   └── admin_dashboard_view.dart   # Admin — manage all applications
├── services/
│   └── supabase_service.dart       # Supabase auth and role service
└── main.dart                       # App entry point, routes, providers
```

---

##  Supabase Setup

### Tables Required

**`profiles`**
```sql
id        uuid  (references auth.users)
role      text  ('student' or 'admin')
full_name text
```

**`applications`**
```sql
id            uuid (primary key, auto-generated)
user_id       uuid (references auth.users)
year_of_study text
modules       text[] (array)
status        text ('pending', 'approved', 'rejected')
document_path text
created_at    timestamptz
updated_at    timestamptz
reviewed_by   uuid
```

### RLS Policies Required

Run these in the Supabase SQL Editor:

```sql
-- Profiles: allow authenticated users to read
CREATE POLICY "Anyone authenticated can read profiles"
ON profiles FOR SELECT TO authenticated USING (true);

-- Applications: students can insert their own
CREATE POLICY "Users can insert own apps"
ON applications FOR INSERT TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Applications: students can view their own
CREATE POLICY "Users can view own apps"
ON applications FOR SELECT TO authenticated
USING (auth.uid() = user_id);

-- Applications: students can delete their own pending apps
CREATE POLICY "Users can delete own applications"
ON applications FOR DELETE TO authenticated
USING (auth.uid() = user_id);

-- Applications: admins can view all
CREATE POLICY "Admins can see all applications"
ON applications FOR SELECT TO authenticated
USING (EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
));

-- Applications: admins can update (approve/reject)
CREATE POLICY "Admins can update applications"
ON applications FOR UPDATE TO authenticated
USING (EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
))
WITH CHECK (EXISTS (
  SELECT 1 FROM profiles
  WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
));

-- Add columns if missing
ALTER TABLE applications
ADD COLUMN IF NOT EXISTS updated_at timestamptz,
ADD COLUMN IF NOT EXISTS reviewed_by uuid;
```

### Setting an Admin Account

```sql
UPDATE profiles
SET role = 'admin'
WHERE id = '<your-user-uuid>';
```

---

##  How to Run the Project

### Prerequisites
- Flutter SDK installed ([flutter.dev](https://flutter.dev))
- A web browser (Chrome recommended)
- Git installed

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/Delight2k44/-Student-Assistant-Application-System.git

# 2. Navigate into the project
cd -Student-Assistant-Application-System

# 3. Install dependencies
flutter pub get

# 4. Run on Chrome
flutter run -d chrome
```

### Before Submitting
ean
```

---

##  Application Screens

### Student Portal
| Screen | Description |
|---|---|
| Onboarding | Welcome screen shown on first launch |
| Login | Authenticates user via Supabase, redirects based on role |
| Home | Displays all submitted applications with live status updates |
| Application Form | Submit a new Student Assistant application (max 2 modules) |
| Application Detail | View full details, edit or delete a pending application |
| Edit Application | Update year of study and modules while application is pending |

### Admin Portal
| Screen | Description |
|---|---|
| Admin Dashboard | View all applications, filter by status, approve or reject |

---

##  Key Features Implemented

-  Supabase Authentication with role-based routing
-  Students can submit one application with up to 2 modules
-  Supporting document upload to Supabase Storage
-  Students can edit their application while it is pending
-  Students can delete their application with confirmation
-  Admin can approve or reject applications
-  Real-time status updates — student sees approval/rejection instantly without refreshing
-  Admin dashboard with counters (Total, Pending, Approved, Rejected)
- Search and filter on admin dashboard
-  Row Level Security (RLS) for data isolation between users

---

##  Concepts Applied (Units 1–5)

| Unit | Concept | Where Applied |
|---|---|---|
| Unit 1 | UI Design & Widgets | All view files — Material 3 components |
| Unit 2 | State Management (MVVM + Provider) | ViewModels + MultiProvider in main.dart |
| Unit 3 | Routing & Navigation | Named routes in main.dart, Navigator.pushNamed |
| Unit 4 | Form Handling & Validation | ApplicationFormView, EditApplicationView |
| Unit 5 | Supabase Auth & CRUD | SupabaseService, all ViewModels |

---


- [ ] Zipped project folder named `GROUP_<letter>`
- [ ] GitHub repository link included
- [ ] All group members' names and student numbers in all `.dart` files
- [ ] PDF documentation (5–10 pages) submitted via Blackboard
- [ ] `flutter clean` run before zipping
- [ ] README Contributors table filled in by all members

---

##  License

This project was developed for academic purposes at the Central University of Technology, Free State. All rights reserved by the group members listed above.
