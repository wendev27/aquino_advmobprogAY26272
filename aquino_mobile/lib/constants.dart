// Purpose: Central location for all constant values used throughout the application
// Responsibilities: Store API URLs and other constants
// Why this class exists: To avoid hardcoding values in multiple places and make maintenance easier

/// Base URL for the DummyJSON API
const String baseUrl = 'https://dummyjson.com';

/// Endpoint for fetching all products
const String productsEndpoint = '/products';

/// Endpoint for searching products
const String searchEndpoint = '/products/search';

/// Full URL for products API
const String productsUrl = '$baseUrl$productsEndpoint';

/// Full URL for search API
const String searchUrl = '$baseUrl$searchEndpoint';
