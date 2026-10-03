# google-maps-and-favorite-location

A Flutter application showcasing Google Maps integration, device GPS location detection, and favorite locations management.

## 📌 Features

- **Google Maps Integration**: Interactive map with zoom controls and marker rendering.
- **Current Location (GPS)**: Utilizes `geolocator` to fetch device coordinates with full permission handling and camera animation to the user's location.
- **Predefined Favorite Locations**:
  - ⭐ Khulna University
  - ⭐ Khulna Railway Station
  - ⭐ Shibbari More
  - ⭐ Shahid Hadis Park
- **Marker Details Bottom Sheet**: Tap any marker to view its ID, Name, Latitude, and Longitude.
- **📍 Favorite Locations List**: Modal list allowing quick navigation and camera animation to any favorite spot.
- **Clean Architecture & Reusable Widgets**: Separated into models, data, services, widgets, and screens.

## 🚀 Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/munyimJR/google-maps-and-favorite-location.git
   cd google-maps-and-favorite-location
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API Key**:
   In `android/app/src/main/AndroidManifest.xml`, replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` with your Google Maps API Key:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE" />
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```
