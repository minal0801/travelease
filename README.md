# TravelEase

TravelEase is a Flutter web app with a Node.js/Express API and MongoDB.

## Requirements

- Node.js (18 or newer)
- Flutter (3.22 or newer, with web support enabled)
- MongoDB running locally, or a MongoDB Atlas connection string

## Start the API

In a terminal from the project folder:

```powershell
cd backend
npm install
```

Set `MONGO_URI` and a private, long `JWT_SECRET` in `backend/.env` (copy `backend/.env.example` to start). Start MongoDB first, then run:

```powershell
npm start
```

The API listens on `http://localhost:5000`. Check `http://localhost:5000/api/health` for `{"status":"ok"}`.

To load sample data into a **disposable/empty** database, open a terminal in the project root and run `npm run seed` before starting the API. Seeding deletes existing TravelEase users, destinations, hotels, packages, bookings and reviews in the selected database. Sample logins after seeding: `admin@travelease.com` / `Admin@123`, and `aarav@example.com` / `User@123`.

## Start the website

Open a second terminal from the project folder:

```powershell
cd frontend
flutter pub get
flutter run -d chrome
```

The app uses `http://localhost:5000/api` by default. If the API runs elsewhere, pass its API base URL when launching:

```powershell
flutter run -d chrome --dart-define=API_URL=http://localhost:5000/api
```

## Build for web hosting

```powershell
cd frontend
flutter build web --dart-define=API_URL=https://your-api.example.com/api
```

Upload `frontend/build/web` to your static web host and configure the API's `CLIENT_ORIGIN` to allow that site's origin.
