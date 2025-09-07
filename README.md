**Output:-**

<img width="3560" height="1672" alt="Output" src="https://github.com/user-attachments/assets/e5b60c53-055b-466c-9866-cca6a2342f46" />
# Event Ticket Booking App 🎟️

A full-stack, cross-platform event discovery and booking application built with Flutter and Firebase. This app provides a seamless experience for users to find and purchase event tickets, while also offering a comprehensive admin panel for event management.

## ✨ Features

### 👤 User Features

  - **Browse & Discover:** Explore a list of upcoming and categorized events.
  - **Event Categories:** Filter events by categories like Music, Food, Party, and Clothes.
  - **Search Functionality:** Easily search for specific events.
  - **Event Details:** View comprehensive details for each event, including date, time, location, and price.
  - **Secure Booking:** Book multiple tickets with secure payment processing powered by Stripe.
  - **Google Sign-In:** Quick and secure user authentication.
  - **Booking History:** Users can view a list of all their booked tickets.
  - **Profile Management:** Users can view and update their profile information.

### 🛠️ Admin Panel

  - **Secure Admin Login:** Separate login portal for administrators.
  - **Role-Based Dashboards:** Different dashboards for main admins and sub-admins.
  - **Event Management:** Admins can create, upload, view, edit, and delete events.
  - **View Bookings:** Admins can see all tickets that have been sold for various events.
  - **Admin Management:** The main admin has the ability to create and manage sub-admin accounts.

## 🚀 Tech Stack

  - **Framework:** Flutter
  - **Language:** Dart
  - **Backend & Database:** Firebase (Cloud Firestore, Firebase Authentication, Firebase Storage)
  - **Payment Gateway:** Stripe
  - **Key Packages:**
      - `google_sign_in`
      - `cached_network_image`
      - `geolocator`
      - `url_launcher`

## ⚙️ Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

  - Flutter SDK installed on your machine.
  - A Firebase project set up.
  - Stripe account for API keys.

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/shantnugabhale/Event-Ticket-Booking-App.git
    ```
2.  **Navigate to the project directory**
    ```sh
    cd Event-Ticket-Booking-App
    ```
3.  **Install dependencies**
    ```sh
    flutter pub get
    ```
4.  **Setup Firebase**
      - Follow the instructions to add FlutterFire to your app and replace the `lib/firebase_options.dart` file with your own configuration.
5.  **Add Stripe API Keys**
      - Open the file `lib/services/data.dart`.
      - Add your Stripe `publishedkey` and `secrekey`.
6.  **Run the app**
    ```sh
    flutter run
    ```
