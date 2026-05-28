## Neyesek

Neyesek is an iOS application that helps users discover nearby restaurants and cafes based on their location and preferences.

Users can filter places by category, price, rating, and distance, or receive a completely random suggestion. The application focuses on providing a simple and modern restaurant discovery experience.

The project is built with UIKit using the MVVM architecture and integrates Google Places API together with Supabase services.

## App Store

Download on the App Store:

https://apps.apple.com/tr/app/neyesek/id6769931264?l=tr

⸻

## Features

* Discover nearby restaurants and cafes
* Category-based filtering
* Filter by price, rating, and distance
* Random place suggestion system
* Interactive map experience
* Favorite places support
* Open / closed status display
* Sign in with Apple
* Google Sign-In
* Guest Login support
* Account deletion support

⸻

## Screenshots

<p align="center">
  <img src="screenshots/login.png" width="250">
  <img src="screenshots/filter.png" width="250">
  <img src="screenshots/map.png" width="250">
</p>
<p align="center">
  <img src="screenshots/suggestion.png" width="250">
  <img src="screenshots/favorites.png" width="250">
</p>

⸻

## Technologies

* Swift
* UIKit
* MVVM Architecture
* MapKit
* CoreLocation
* Google Places API
* Supabase
* Supabase Edge Functions

⸻

## Authentication

The application supports multiple authentication methods:

* Sign in with Apple
* Google Sign-In
* Anonymous Guest Login

Users can also permanently delete their accounts directly from the application settings screen.

⸻

## Backend & Security

The application uses Supabase Edge Functions as a backend layer between the iOS client and external APIs.

Sensitive API keys are not exposed directly to the client application. Request validation and request limiting are handled on the backend.

This repository does not contain real API keys or sensitive credentials.

⸻

## Architecture

The project follows the MVVM pattern and uses protocol-based service abstractions for better separation of concerns, maintainability, and testability.

Application flow:

ViewController → ViewModel → Service → API

⸻

## Main Components

Presentation Layer

* UIKit-based ViewControllers
* MVVM ViewModels
* Reusable UI components

Service Layer

* Place fetching service
* Favorite management service
* Authentication service
* Backend communication layer

## Backend

* Supabase Authentication
* Supabase Database
* Supabase Edge Functions

⸻

## Future Improvements

* Smarter recommendation algorithms
* Improved caching system
* Better place categorization
* Personalized recommendations
* Social features

⸻

## Support

For support or feedback:

farukerdemdereci@gmail.com
