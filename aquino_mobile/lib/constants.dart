import 'package:flutter_dotenv/flutter_dotenv.dart';

// Purpose: Central location for all constant values used throughout the application
// Responsibilities: Store API URLs and other constants loaded from environment variables
// Why this class exists: To avoid hardcoding values in multiple places and make maintenance easier

/// Base URL for the DummyJSON API (loaded from .env)
String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://dummyjson.com';

/// Endpoint for fetching all products
const String productsEndpoint = '/products';

/// Endpoint for searching products
const String searchEndpoint = '/products/search';

/// Full URL for products API
String get productsUrl => '$baseUrl$productsEndpoint';

/// Full URL for search API
String get searchUrl => '$baseUrl$searchEndpoint';

/// DummyJSON has no real auth, so we hardcode a demo user id to scope the cart to "one user"
const int currentUserId = 1;
