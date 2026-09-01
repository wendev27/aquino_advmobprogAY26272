# Advanced Mobile Programming — Lab Activities Walkthrough

This project is the actual code in the current `lab-act4` branch. The repo also contains earlier branches for the lab progression, but the current implementation includes Lab 2, Lab 3, and Lab 4 features together.

## How to use this guide

Open the files mentioned below in VS Code and read them in order. Do not rely only on the explanations here; the code is the real source of truth.

Use this order:

1. `lib/main.dart`
2. `lib/constants.dart`
3. `lib/models/`
4. `lib/services/`
5. `lib/screens/`
6. `lib/providers/`
7. `lib/widgets/`

---

# Lab Activity 2

## What changed?

This is the base product app. It adds the model/service/screen pattern and introduces a product list with API data, a search input, and detail navigation.

## Where is it?

| Concept | File | Class/Function | What it does |
|---|---|---|---|
| API config | `lib/constants.dart` | `baseUrl`, `productsUrl`, `searchUrl` | Centralizes the DummyJSON endpoints |
| Product model | `lib/models/product.dart` | `Product`, `Product.fromJson()` | Converts API JSON into a Dart object |
| Product service | `lib/services/product_service.dart` | `fetchProducts()`, `searchProducts()`, `fetchProductById()` | Calls the API and returns `Product` objects |
| Product list | `lib/screens/home_screen.dart` | `HomeScreen`, `_loadProducts()` | Loads products and handles search |
| Details screen | `lib/screens/product_details_screen.dart` | `ProductDetailsScreen` | Shows one selected product |
| Reusable item | `lib/widgets/product_card.dart` | `ProductCard` | Displays a product card in the list |
| Theme provider | `lib/providers/theme_provider.dart` | `ThemeProvider` | Stores dark/light state |
| Settings screen | `lib/screens/settings_screen.dart` | `SettingsScreen` | Lets the user toggle the theme |

## How the data flows

API
↓
`ProductService`
↓
`Product.fromJson()`
↓
`HomeScreen`
↓
`ProductCard`
↓
`ProductDetailsScreen`

The actual flow in this project is:

1. `HomeScreen` calls `_loadProducts()` in `initState()`.
2. `_loadProducts()` checks whether a search query exists.
3. `ProductService.fetchProducts()` or `ProductService.searchProducts()` makes the HTTP request.
4. The JSON response is decoded and converted with `Product.fromJson()`.
5. The list is stored in `_products`.
6. `ListView.builder` renders the UI.
7. Tapping a card pushes `ProductDetailsScreen(product: product)`.

## Important code to study

- `Product.fromJson()` in `lib/models/product.dart`
- `ProductService.fetchProducts()` in `lib/services/product_service.dart`
- `ProductService.searchProducts()` in `lib/services/product_service.dart`
- `ProductService.fetchProductById()` in `lib/services/product_service.dart`
- `_loadProducts()` in `lib/screens/home_screen.dart`
- `_onSearch()` in `lib/screens/home_screen.dart`
- `ProductCard` in `lib/widgets/product_card.dart`
- `ProductDetailsScreen` in `lib/screens/product_details_screen.dart`

## Explain it simply

The product model is the shape of a product. The service handles the HTTP request. The screen decides when to call the service and how to display the result. This is the same pattern used in many Flutter apps: model, service, screen.

The project does not have a separate `ProductScreen` file. The list is implemented in `HomeScreen`.

## What I should be able to explain

- Why is the API logic in `ProductService` instead of directly in the screen?
- Where does the JSON become a `Product` object?
- How does the search query trigger a new API request?
- How does the detail view receive the selected product?
- Why is `ThemeProvider` useful even though it is not part of the product list itself?

---

# Lab Activity 3

## What changed?

This is the cart layer. It adds a cart model, cart service, and a cart screen that uses the currently selected user context.

## Where is it?

| Concept | File | Class/Function | What it does |
|---|---|---|---|
| Cart model | `lib/models/cart.dart` | `Cart`, `CartProduct`, `Cart.fromJson()` | Represents the cart response and each cart item |
| Cart service | `lib/services/cart_service.dart` | `getAllCarts()`, `getCartByUserId()`, `addToCart()` | Calls the cart API |
| Cart screen | `lib/screens/cart_screen.dart` | `CartScreen`, `_lineTotal()`, `build()` | Displays cart items, quantity, and subtotal |
| Add-to-cart trigger | `lib/screens/product_details_screen.dart` | button `onPressed` | Sends product ID and quantity to the cart API |
| Screen navigation | `lib/main.dart` | `MainNavigation` | Shows the cart tab in the app shell |

## How the data flows

User
↓
`ProductDetailsScreen`
↓
`CartService.addToCart()`
↓
DummyJSON cart endpoint
↓
`Cart.fromJson()`
↓
`CartScreen`
↓
UI totals / quantity controls

The actual flow is:

1. `ProductDetailsScreen` reads the saved user data from `UserService.getUserData()`.
2. It gets a user ID, then calls `CartService().addToCart(userId, [{'id': product.id, 'quantity': 1}])`.
3. The cart API returns cart data.
4. `CartScreen` loads the cart with `CartService().getCartByUserId(widget.userId)`.
5. The screen keeps a local quantity map for the user to change item counts in the UI.
6. `_lineTotal()` calculates the discounted total for each item.
7. `subtotal` is calculated by folding the cart list.

## Important code to study

- `Cart.fromJson()` in `lib/models/cart.dart`
- `CartProduct.fromJson()` in `lib/models/cart.dart`
- `CartService.getCartByUserId()` in `lib/services/cart_service.dart`
- `CartService.addToCart()` in `lib/services/cart_service.dart`
- `CartScreen` in `lib/screens/cart_screen.dart`
- `_lineTotal()` in `lib/screens/cart_screen.dart`
- Add-to-cart button logic in `lib/screens/product_details_screen.dart`

## Explain it simply

The cart is tied to a user ID. The app does not keep one global cart for all users. It asks the API for a specific cart using the current user. The cart screen also calculates totals in the UI so the user can see the item value before confirming an order.

Important honesty note: this is a network-backed cart call using DummyJSON, not a purely local or permanently saved cart state.

## What I should be able to explain

- How does the cart know which user it belongs to?
- Why does `CartScreen` use a local quantity map?
- Where is the subtotal calculated?
- Is the cart state permanent? What is the actual behavior in this repository?
- What triggers the cart API call from the product details screen?

---

# Lab Activity 4

## What changed?

This adds login, session persistence, splash-screen auth checks, and profile/logout behavior.

## Where is it?

| Concept | File | Class/Function | What it does |
|---|---|---|---|
| User model | `lib/models/user.dart` | `User`, `User.fromJson()` | Represents the authenticated user |
| User service | `lib/services/user_service.dart` | `loginUser()`, `saveUserData()`, `getUserData()`, `isLoggedIn()`, `logout()` | Handles auth and local persistence |
| Splash check | `lib/screens/splash_screen.dart` | `SplashScreen`, `_checkAuthentication()` | Decides whether to continue or redirect |
| Sign in screen | `lib/screens/signin_screen.dart` | `SigninScreen`, `_login()` | Sends credentials and logs the user in |
| Profile screen | `lib/screens/profile_screen.dart` | `ProfileScreen`, `_logout()` | Reads saved user data and logs out |
| Navigation | `lib/main.dart` | `MyApp`, `MainNavigation` | Sets `'/splash'`, `'/signin'`, and `'/home'` routes |

## How the data flows

App starts
↓
`SplashScreen`
↓
`UserService.isLoggedIn()`
↓
if logged in → `MainNavigation` / `HomeScreen`
if not logged in → `SigninScreen`
↓
`SigninScreen._login()`
↓
`UserService.loginUser()`
↓
`UserService.saveUserData()`
↓
`ProfileScreen` reads saved user data
↓
`UserService.logout()` clears session

This is the actual behavior in the repo.

## Important code to study

- `User.fromJson()` in `lib/models/user.dart`
- `UserService.loginUser()` in `lib/services/user_service.dart`
- `UserService.saveUserData()` in `lib/services/user_service.dart`
- `UserService.getUserData()` in `lib/services/user_service.dart`
- `UserService.isLoggedIn()` in `lib/services/user_service.dart`
- `UserService.logout()` in `lib/services/user_service.dart`
- `_checkAuthentication()` in `lib/screens/splash_screen.dart`
- `_login()` in `lib/screens/signin_screen.dart`
- `_logout()` in `lib/screens/profile_screen.dart`

## Explain it simply

The login is handled by `UserService`. The service sends the credentials to the DummyJSON auth endpoint, and then it saves the returned user data in `SharedPreferences`. The splash screen checks the saved token so the app knows whether the user is already logged in. The profile screen reads that saved user data and displays it, while logout clears the session and sends the user to sign in.

## What I should be able to explain

- Where is the logged-in user saved?
- How does the splash screen decide whether to go to home or sign in?
- Why is the user data stored in `SharedPreferences`?
- How does the profile screen know which user is logged in?
- How is the cart request connected to the signed-in user?

---

# Navigation map

`SplashScreen`
↓
`SigninScreen`
↓
`MainNavigation`
↓
`HomeScreen`
↓
`ProductDetailsScreen`

`HomeScreen`
↓
`CartScreen`

`HomeScreen`
↓
`ProfileScreen`

`MainNavigation` also includes the tabs for Home, Cart, Profile, Counter, and Settings.

---

# API map

| Feature | Service | Endpoint | Method | Model | Screen |
|---|---|---|---|---|---|
| Fetch products | `ProductService.fetchProducts()` | `baseUrl + /products` | GET | `Product` | `HomeScreen` |
| Search products | `ProductService.searchProducts()` | `baseUrl + /products/search?q=` | GET | `Product` | `HomeScreen` |
| Fetch product by ID | `ProductService.fetchProductById()` | `baseUrl + /products/{id}` | GET | `Product` | `ProductDetailsScreen` |
| Login | `UserService.loginUser()` | `baseUrl + /auth/login` | POST | `User` | `SigninScreen` |
| Get cart by user | `CartService.getCartByUserId()` | `baseUrl + /carts/user/{userId}` | GET | `Cart` | `CartScreen` |
| Add to cart | `CartService.addToCart()` | `baseUrl + /carts/add` | POST | `Cart` | `ProductDetailsScreen` |

---

# Recommended study order

1. `lib/main.dart` — app setup, providers, routes
2. `lib/constants.dart` — API config and user ID constant
3. `lib/models/product.dart` — product data model and JSON parsing
4. `lib/services/product_service.dart` — product API responsibilities
5. `lib/screens/home_screen.dart` — main product screen and search behavior
6. `lib/widgets/product_card.dart` — reusable list item UI
7. `lib/screens/product_details_screen.dart` — selected product details and add-to-cart
8. `lib/models/cart.dart` — cart and cart item model
9. `lib/services/cart_service.dart` — cart API requests
10. `lib/screens/cart_screen.dart` — cart UI and totals
11. `lib/models/user.dart` — auth user model
12. `lib/services/user_service.dart` — login and persistence
13. `lib/screens/splash_screen.dart` — startup auth check
14. `lib/screens/signin_screen.dart` — login form and auth actions
15. `lib/screens/profile_screen.dart` — saved-user profile and logout
16. `lib/providers/theme_provider.dart` — app-wide theme state
17. `lib/providers/counter_provider.dart` — app-wide counter state
18. `lib/screens/settings_screen.dart` — theme switch UI
19. `lib/screens/dual_counter_screen.dart` — local vs app state demo

---

# Final notes

The important pattern in this project is very clear:

- model = data shape
- service = API and storage logic
- screen = UI and user flow
- provider = shared app-wide state
- widget = reusable UI part

If you study the code in that order, the project will make much more sense.
