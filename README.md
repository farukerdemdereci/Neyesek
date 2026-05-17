# Neyesek

Neyesek is an iOS application that suggests restaurants based on the user's location. Users can filter places by category, price, rating, and distance, or get a random suggestion.

The app uses Google Places API to fetch place data and Supabase to manage user data such as favorites.

## Features

- Discover nearby restaurants
- Category-based filtering
- Filter by price, rating, and distance
- Random place suggestion system
- Favorite places support
- Open / closed status display
- Interactive map experience
  
## Technologies

- Swift
- UIKit
- MVVM Architecture
- MapKit
- Google Places API
- Supabase
- CoreLocation

## Security

This project does not contain real API keys or sensitive credentials.
Example configuration files are provided for demonstration purposes.

## Architecture

The project follows the MVVM pattern and uses protocol-based service abstractions for better separation of concerns, maintainability, and testability.

ViewController → ViewModel → Service → API

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
