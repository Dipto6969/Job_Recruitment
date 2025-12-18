# 💼 Job Recruitment Platform

A modern Flutter-based mobile application for job recruitment, connecting job seekers with employers seamlessly.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-blue?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green?logo=supabase)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## 📱 Overview

The **Job Recruitment Platform** is a comprehensive mobile solution that streamlines the job search and hiring process. It features two distinct user roles with specialized dashboards, real-time updates, and an intuitive user interface.

### Key Highlights
- 🔐 Secure authentication with Supabase
- 💼 Dual role system (Job Seekers & Employers)
- 🎯 Advanced job search and filtering
- 📊 Real-time application tracking
- 📱 Responsive UI with Material Design 3
- ⚡ Seamless database integration

---

## ✨ Features

### 👤 For Job Seekers

| Feature | Description |
|---------|-------------|
| 🔑 **Authentication** | Secure signup/login with email verification |
| 👨‍💼 **Profile Management** | Build professional profiles with skills and experience |
| 🔍 **Job Search** | Browse and filter jobs by location, type, salary |
| 📝 **Apply to Jobs** | Submit applications with resume and cover letter |
| 📋 **Track Applications** | Monitor application status in real-time |
| ✅ **Success Notifications** | Instant congratulations when accepted |
| 📱 **User-Friendly UI** | Clean, intuitive interface for easy navigation |

### 🏢 For Employers

| Feature | Description |
|---------|-------------|
| 🏪 **Company Profile** | Create and manage company information |
| 📢 **Post Jobs** | Create and publish job listings |
| 👥 **View Applicants** | See all applicants for each job posting |
| ✅ **Accept/Reject** | Manage applications with one-click decisions |
| 📊 **Job Management** | Edit, delete, and track posted jobs |
| 📈 **Recruitment Dashboard** | Overview of all job postings and applications |
| 🎯 **Applicant Details** | Review applicant profiles and resume |

---

## 📸 App Screenshots

### 🔐 Authentication & Onboarding

<div align="center">
  <img src="screenshots/1_login_screen.png" width="280" alt="Login Screen" />
  <img src="screenshots/2_signup_screen.png" width="280" alt="Signup Screen" />
  <img src="screenshots/3_role_selection.png" width="280" alt="Role Selection" />
</div>

**Login & Registration**
- Secure email-based authentication
- Role selection (Job Seeker / Employer)
- Password validation and error handling

---

### 👨‍💼 Job Seeker Dashboard

<div align="center">
  <img src="screenshots/4_job_listing.png" width="280" alt="Job Listing" />
  <img src="screenshots/5_job_detail.png" width="280" alt="Job Detail" />
  <img src="screenshots/6_apply_job.png" width="280" alt="Apply to Job" />
</div>

**Finding & Applying to Jobs**
- Browse all available job listings
- View detailed job information
- Filter by location, job type, and salary
- Apply with one click

---

### 📋 Job Seeker - Applications & Profile

<div align="center">
  <img src="screenshots/7_my_applications.png" width="280" alt="My Applications" />
  <img src="screenshots/8_application_status.png" width="280" alt="Application Status" />
  <img src="screenshots/9_profile_setup.png" width="280" alt="Profile Setup" />
</div>

**Application Tracking & Profile Management**
- View all submitted applications
- Track status (Pending, Accepted, Rejected)
- Manage personal profile and skills
- Update professional information

---

### 🏢 Employer Dashboard

<div align="center">
  <img src="screenshots/10_employer_dashboard.png" width="280" alt="Employer Dashboard" />
  <img src="screenshots/11_view_applicants.png" width="280" alt="View Applicants" />
  <img src="screenshots/12_post_job.png" width="280" alt="Post Job" />
</div>

**Recruitment Management**
- Create company profile
- Post and manage job listings
- Review all applicants
- Accept or reject applications
- Track recruitment metrics

---

## 🏗️ Project Structure

```
lib/
├── models/                          # Data Models
│   ├── application.dart            # Application model
│   ├── company.dart                # Company model
│   ├── job.dart                    # Job model
│   └── profile.dart                # User profile model
│
├── services/                        # Business Logic & API
│   ├── application_service.dart    # Application CRUD operations
│   ├── auth_service.dart           # Authentication logic
│   ├── company_service.dart        # Company operations
│   └── job_service.dart            # Job operations
│
├── job_seeker/                      # Job Seeker Screens
│   ├── edit_profile_screen.dart
│   ├── job_detail_screen.dart
│   ├── job_listing_screen.dart
│   ├── job_seeker_home.dart
│   ├── my_applications_screen.dart
│   └── profile_screen.dart
│
├── employer/                        # Employer Screens
│   ├── create_company_screen.dart
│   ├── edit_employer_profile_screen.dart
│   ├── employer_dashboard.dart
│   ├── employer_home.dart
│   ├── post_job_screen.dart
│   └── view_applicants_screen.dart
│
├── widgets/                         # Reusable Components
│   └── app_widgets.dart
│
├── main.dart                        # App Entry Point
└── pubspec.yaml                     # Dependencies

```

---

## 🔧 Tech Stack

### Frontend
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **UI**: Material Design 3
- **Navigation**: Go Router
- **Fonts**: Google Fonts

### Backend
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Real-time**: Supabase Realtime
- **Storage**: Supabase Storage (Resumes)
- **REST API**: Supabase PostgREST

### State Management
- StatefulWidget (Flutter built-in)

### Key Packages
```yaml
dependencies:
  flutter: sdk: flutter
  supabase_flutter: ^2.0.0
  go_router: ^13.0.0
  google_fonts: ^6.0.0
  http: ^1.1.0
  path_provider: ^2.1.0
```

---

## 💾 Database Schema

### Tables Overview

#### `profiles`
```sql
- id (UUID) - Primary Key
- user_id (UUID) - Auth user reference
- full_name (TEXT)
- email (TEXT)
- bio (TEXT)
- avatar_url (TEXT)
- skills (TEXT[]) - Array of skills
- experience_years (INT)
- role (TEXT) - 'job_seeker' or 'employer'
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

#### `companies`
```sql
- id (UUID) - Primary Key
- user_id (UUID) - Employer reference
- name (TEXT)
- description (TEXT)
- location (TEXT)
- website (TEXT)
- logo_url (TEXT)
- created_at (TIMESTAMP)
```

#### `jobs`
```sql
- id (UUID) - Primary Key
- company_id (UUID) - Company reference
- title (TEXT)
- description (TEXT)
- location (TEXT)
- job_type (TEXT) - 'Full-time', 'Part-time', etc.
- salary (TEXT)
- requirements (TEXT[])
- skills_required (TEXT[])
- experience_required (INT)
- posted_date (TIMESTAMP)
- deadline (TIMESTAMP)
- is_active (BOOLEAN)
- created_at (TIMESTAMP)
```

#### `applications`
```sql
- id (UUID) - Primary Key
- job_id (UUID) - Job reference
- applicant_id (UUID) - Profile reference
- status (TEXT) - 'pending', 'accepted', 'rejected'
- resume_url (TEXT)
- created_at (TIMESTAMP)
- updated_at (TIMESTAMP)
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter 3.0 or higher
- Dart 3.0 or higher
- Supabase account
- Git

### Installation

#### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/job_recruitment.git
cd job_recruitment
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Configure Supabase

1. Create a project at [Supabase](https://supabase.com)
2. Get your project credentials (URL and API Key)
3. Update `lib/main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const MyApp());
}
```

#### 4. Run the Application

```bash
# For development
flutter run

# For release (Android)
flutter build apk --release

# For release (iOS)
flutter build ios --release
```

---

## 📊 Database Setup

### Initial Setup SQL

Run these queries in Supabase SQL Editor:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  email TEXT,
  bio TEXT,
  avatar_url TEXT,
  skills TEXT[],
  experience_years INT,
  role TEXT CHECK (role IN ('job_seeker', 'employer')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Create companies table
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  location TEXT,
  website TEXT,
  logo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create jobs table
CREATE TABLE jobs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  job_type TEXT,
  salary TEXT,
  requirements TEXT[],
  skills_required TEXT[],
  experience_required INT,
  posted_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  deadline TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create applications table
CREATE TABLE applications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  applicant_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  resume_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX idx_jobs_company_id ON jobs(company_id);
CREATE INDEX idx_jobs_posted_date ON jobs(posted_date DESC);
CREATE INDEX idx_applications_job_id ON applications(job_id);
CREATE INDEX idx_applications_applicant_id ON applications(applicant_id);
CREATE INDEX idx_profiles_user_id ON profiles(user_id);
```

---

## 🎯 How to Use

### For Job Seekers

1. **Sign Up**
   - Open app → Tap "Sign Up"
   - Enter email and password
   - Select "Job Seeker" role
   - Verify email

2. **Complete Profile**
   - Go to Profile section
   - Add bio, skills, and experience
   - Upload profile picture

3. **Search Jobs**
   - Navigate to Jobs tab
   - Browse all available positions
   - Use filters to narrow results
   - Tap on job to view details

4. **Apply to Jobs**
   - Open job details
   - Tap "Apply Now"
   - Add cover letter (optional)
   - Submit application

5. **Track Applications**
   - Go to Applications tab
   - View status of all applications
   - See acceptance notifications

### For Employers

1. **Sign Up**
   - Open app → Tap "Sign Up"
   - Enter email and password
   - Select "Employer" role

2. **Create Company**
   - Tap "Create Company Profile"
   - Enter company name, description, location
   - Add company website

3. **Post Jobs**
   - From Dashboard → Tap "Post New Job"
   - Fill job details (title, description, salary, requirements)
   - Set job type and experience level
   - Publish job

4. **Review Applicants**
   - From Dashboard → Tap "View Applicants"
   - See all applicants for the job
   - View applicant details and resume

5. **Manage Applications**
   - Accept or reject applications
   - Update application status
   - Track recruitment progress

---

## 🔐 Authentication Flow

```
┌─────────────────────────────────────┐
│        User Opens App               │
└──────────────┬──────────────────────┘
               │
        ┌──────▼──────┐
        │   Logged In? │
        └──────┬──────┘
            No │ Yes
               │ │
         ┌─────▼──────────────┐
         │  Login/SignUp      │ Go to Home
         │  Select Role       │
         └─────┬──────────────┘
               │
        ┌──────▼──────────────┐
        │  Role Selected?     │
        └──────┬──────────────┘
          No   │ Yes
              │ │
         ┌────▼─┴──────────────────┐
         │  Job Seeker Home  OR    │
         │  Employer Home          │
         └────────────────────────┘
```

---

## 📈 Current Implementation Status

### ✅ Completed Features

**Authentication & User Management**
- ✅ Email/Password signup and login
- ✅ Role-based authentication
- ✅ Session management
- ✅ Secure token handling

**Job Seeker Features**
- ✅ Profile creation and editing
- ✅ Browse all job listings
- ✅ Job search and filtering
- ✅ View job details
- ✅ Apply to jobs
- ✅ Track application status
- ✅ Application history
- ✅ Success notifications

**Employer Features**
- ✅ Company profile creation
- ✅ Post new job listings
- ✅ View all job postings
- ✅ See applicants for each job
- ✅ Accept/reject applications
- ✅ Update application status
- ✅ Manage company information

**Database & Backend**
- ✅ Supabase integration
- ✅ PostgreSQL database
- ✅ Real-time updates
- ✅ RLS (Row Level Security)
- ✅ Secure API endpoints

**UI/UX**
- ✅ Material Design 3
- ✅ Responsive layouts
- ✅ Smooth animations
- ✅ Error handling
- ✅ Loading states

---

### 🚧 Future Enhancements

- [ ] Advanced search filters (salary range, experience level)
- [ ] Video interview scheduling
- [ ] In-app messaging between job seekers and employers
- [ ] Job recommendations AI
- [ ] Payment integration (for featured listings)
- [ ] Admin dashboard
- [ ] Analytics and reporting
- [ ] Email notifications
- [ ] Push notifications
- [ ] Social media sharing
- [ ] Dark mode
- [ ] Multi-language support
- [ ] Resume builder
- [ ] Job bookmarks/favorites
- [ ] Company reviews and ratings

---

## 🐛 Known Issues

- None currently reported

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📝 Git Workflow

### First Time Setup
```bash
git clone https://github.com/YOUR_USERNAME/job_recruitment.git
cd job_recruitment
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### Making Updates
```bash
# Create new branch for feature
git checkout -b feature/your-feature

# Make changes to files

# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: Add job filtering feature"

# Push to GitHub
git push origin feature/your-feature

# Create Pull Request on GitHub
```

### Commit Message Format
```
feat: Add new feature
fix: Fix bug
docs: Documentation changes
style: Code style changes
refactor: Code refactoring
test: Add tests
chore: Build/dependency changes
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2025 Job Recruitment Team

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
```

---

## 📞 Support & Contact

- **Email**: support@jobrecruit.com
- **Issues**: [GitHub Issues](https://github.com/YOUR_USERNAME/job_recruitment/issues)
- **Discussions**: [GitHub Discussions](https://github.com/YOUR_USERNAME/job_recruitment/discussions)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Google Fonts for typography
- Material Design for UI guidelines
- All contributors and supporters

---

## 📊 Project Statistics

- **Lines of Code**: ~5,000+
- **Dart Files**: 25+
- **Database Tables**: 4
- **API Endpoints**: 15+
- **UI Screens**: 12+

---

**Made with ❤️ for the recruitment community**

Last Updated: December 18, 2025

⭐ If you find this project helpful, please give it a star!
