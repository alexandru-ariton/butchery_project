🥩 Butcher Shop Management System

A Flutter-based butcher shop management system designed to streamline inventory management, order processing, and customer interactions. The project consists of two applications:

Customer App – Allows customers to browse products, place orders, and manage their addresses and payments.
Admin App – Enables butchers to manage products, track orders, and communicate with suppliers.

🚀 Features

🛒 Customer App

- Product Browsing – View and search products with real-time updates.
- Order Placement – Add items to the cart and place orders.
- Address Management – Select and save delivery addresses using Google Maps.
- Payment Integration – Choose between cash and card payments.
- Order Tracking – Customers receive order status updates.
- User Authentication – Secure login and signup.

🏪 Admin App

- Inventory Management – Add, edit, and remove products.
- Supplier Management – Track suppliers and update stock availability.
- Order Processing – Manage customer orders efficiently.
- Analytics Dashboard – View real-time reports and sales insights.
- Notifications – Alerts for low stock and expiring products.

🛠️ Technologies Used

- Flutter & Dart – Frontend framework for cross-platform compatibility.
- Firebase Firestore – NoSQL database for storing product and order data.
- Firebase Authentication – Secure login and authentication.
- Firebase Storage – Store and manage product images.
- Google Maps API – Interactive location selection for deliveries.
- Cloud Functions – Backend processing for notifications and order tracking.

🏗️ Installation

Prerequisites

- Flutter SDK 
- Firebase Project Setup 
- Google Maps API Key 

Steps
1.Clone the repository:
- git clone https://github.com/yourusername/butcher-shop.git
- cd butcher-shop

2.Install dependencies:
- flutter pub get

3.Configure Firebase:

- Add google-services.json (Android) and GoogleService-Info.plist (iOS) to the respective android/app and ios/Runner folders.

4.Run the app:

- flutter run

📌 Roadmap

 - Implement a delivery personnel app for tracking deliveries.
 - Integrate real-time order tracking for customers.
 - Add POS integration for in-store purchases.
 - Improve security measures (data encryption, authentication).
 - Implement customer feedback for service improvement.
