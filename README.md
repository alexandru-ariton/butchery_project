# 🥩 Butchery Management System

A **butchery management system** developed as part of an academic project at the **Bucharest University of Economic Studies**. This system includes two distinct applications:

- **Customer Application** 🛒 - Allows customers to browse products, place orders, and manage their profiles.
- **Admin Application** 🛠 - Enables butchers to manage inventory, orders, and supplier relationships efficiently.

---

## 📌 Project Overview

- **Institution**: Bucharest University of Economic Studies  
- **Faculty**: Cybernetics, Statistics, and Economic Informatics  
- **Authors**: Alexandru Ariton, Cristian-Eugen Ciurea  
- **Year**: 2024  
- **Technologies Used**: Flutter, Dart, Google Cloud Console, Firebase  

---

## 🚀 Features

### ✅ **Customer App Features**
- 🔍 **Product Catalog** – Browse products with images, descriptions, and prices.
- 📦 **Order Placement** – Select items, choose delivery/pickup, and complete orders.
- 📍 **Address Selection** – Save multiple addresses, integrate with Google Maps.
- 💳 **Payment Management** – Store and manage payment methods.
- 🔔 **Notifications** – Receive alerts on order status updates.

### ✅ **Admin App Features**
- 📦 **Inventory Management** – Add, update, and remove products with expiration alerts.
- 📊 **Order Processing** – Track and process customer orders efficiently.
- 📢 **Supplier Management** – Maintain supplier relationships and restock products.
- 📈 **Reporting** – View sales data, product performance, and analytics.

---

## 🏗️ System Architecture

The system consists of the following components:

- **Frontend**: Flutter-based mobile applications.
- **Backend & Database**: Firebase Firestore for real-time data synchronization.
- **Cloud Services**: Google Cloud Console for authentication, storage, and notifications.

### 🛠 **Technologies Used**

| Technology | Purpose |
|------------|---------|
| **Flutter** | Cross-platform UI framework for mobile development |
| **Dart** | Programming language for backend logic |
| **Firebase Firestore** | NoSQL database for real-time data |
| **Firebase Authentication** | Secure user login & authentication |
| **Google Cloud Console** | Cloud resource management |
| **Google Maps API** | Address selection & location tracking |

---

## 📥 Installation & Setup

### 🔹 **Prerequisites**
Ensure you have the following installed:
- **Flutter SDK**
- **Dart SDK**
- **Firebase CLI**

### 🔹 **Installation Steps**
1️⃣ Clone the repository:
```sh
git clone https://github.com/your-repo/butchery-management.git
```
2️⃣ Navigate to the project directory:
```sh
cd butchery-management
```
3️⃣ Install dependencies:
```sh
flutter pub get
```
4️⃣ Set up Firebase:
   - Create a Firebase project.
   - Enable **Firestore**, **Authentication**, and **Storage**.
   - Download and configure `google-services.json` (Android) / `GoogleService-Info.plist` (iOS).

5️⃣ Run the app:
```sh
flutter run
```

---

## 📊 Data Flow & Diagrams

### **📌 Database Schema**
The database is structured as follows:

- **Users**: Stores customer profiles, addresses, and orders.
- **Products**: Contains inventory details such as names, prices, stock, and expiry dates.
- **Orders**: Tracks customer purchases, payment status, and order fulfillment.
- **Suppliers**: Manages supplier information and product restocking.

### **📍 Order Processing Flowchart**
1. Customer selects products.
2. Customer chooses delivery or pickup.
3. Customer completes payment.
4. System processes the order and notifies the admin.
5. Admin verifies and ships the order.
6. Customer receives a notification upon completion.

---

## 🎯 Future Enhancements

🔮 **Next Steps:**
- Integrate **AI-based recommendations** for customers.
- Implement **Loyalty & Rewards System**.
- Add **Multilingual Support**.
- Develop a **Web Dashboard for Admins**.

---

👥 Contributors:  
- **Alexandru Ariton**   

---


