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

| Concept         | File                                      | Class/Function                                              | What it does                                |
| --------------- | ----------------------------------------- | ----------------------------------------------------------- | ------------------------------------------- |
| API config      | `lib/constants.dart`                      | `baseUrl`, `productsUrl`, `searchUrl`                       | Centralizes the DummyJSON endpoints         |
| Product model   | `lib/models/product.dart`                 | `Product`, `Product.fromJson()`                             | Converts API JSON into a Dart object        |
| Product service | `lib/services/product_service.dart`       | `fetchProducts()`, `searchProducts()`, `fetchProductById()` | Calls the API and returns `Product` objects |
| Product list    | `lib/screens/home_screen.dart`            | `HomeScreen`, `_loadProducts()`                             | Loads products and handles search           |
| Details screen  | `lib/screens/product_details_screen.dart` | `ProductDetailsScreen`                                      | Shows one selected product                  |
| Reusable item   | `lib/widgets/product_card.dart`           | `ProductCard`                                               | Displays a product card in the list         |
| Theme provider  | `lib/providers/theme_provider.dart`       | `ThemeProvider`                                             | Stores dark/light state                     |
| Settings screen | `lib/screens/settings_screen.dart`        | `SettingsScreen`                                            | Lets the user toggle the theme              |

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

## What changed from Lab 2?

Lab 2 taught the product model/service/screen flow. Lab 3 extends that same structure by adding a cart model, a cart service, and a dedicated cart screen. The app keeps the same architecture, but the new feature adds a second domain object: cart data.

## Lab 3 files

| Concept               | File                                      | Class/Function                                      | Purpose                                              |
| --------------------- | ----------------------------------------- | --------------------------------------------------- | ---------------------------------------------------- |
| Cart model            | `lib/models/cart.dart`                    | `Cart`, `CartProduct`, `Cart.fromJson()`            | Represents the cart response and each item inside it |
| Cart service          | `lib/services/cart_service.dart`          | `getAllCarts()`, `getCartByUserId()`, `addToCart()` | Handles HTTP calls for cart data                     |
| Cart screen           | `lib/screens/cart_screen.dart`            | `CartScreen`, `_CartScreenState`, `_lineTotal()`    | Displays the cart, quantity controls, and subtotal   |
| Product detail action | `lib/screens/product_details_screen.dart` | `ProductDetailsScreen`                              | Adds the selected product to the user's cart         |
| Main navigation       | `lib/main.dart`                           | `MainNavigation`                                    | Adds the cart tab to the app shell                   |
| User scoping          | `lib/constants.dart`                      | `currentUserId`                                     | Provides the demo user ID used to scope the cart     |
| Product model         | `lib/models/product.dart`                 | `Product`                                           | Supplies the product object used by the cart flow    |

## Cart data flow

`CartScreen`
↓
`CartService.getCartByUserId()`
↓
DummyJSON cart endpoint
↓
`Cart.fromJson()`
↓
`CartProduct`
↓
UI list + subtotal + quantity controls

This is the actual flow in the repo: the screen requests cart data, the service calls the API, and the response is converted into typed objects before the UI uses it.

## Add to cart flow

`ProductDetailsScreen`
↓
saved user ID / `currentUserId`
↓
`CartService.addToCart()`
↓
DummyJSON `/carts/add`
↓
`Cart.fromJson()` response
↓
user sees the cart update or a snackbar message

The key detail is that the add-to-cart action is still a network-backed demo, not a local-only in-memory cart.

## Cart → product details flow

Inside `CartScreen`, tapping an item starts a product fetch with `ProductService.fetchProductById(item.id)`, then opens `ProductDetailsScreen(product: snapshot.data!)`. This is a useful pattern because it reuses the same detail screen for both the product list and the cart list.

## Important functions to study

- `Cart.fromJson()` in `lib/models/cart.dart` — converts the API JSON into a reusable cart object.
- `CartProduct.fromJson()` in `lib/models/cart.dart` — converts each cart item into a typed model.
- `CartService.getCartByUserId()` in `lib/services/cart_service.dart` — requests the current user's cart.
- `CartService.addToCart()` in `lib/services/cart_service.dart` — sends a product payload to the cart endpoint.
- `_lineTotal()` in `lib/screens/cart_screen.dart` — calculates the displayed total using the local quantity map and the item discount.
- `_quantities` in `lib/screens/cart_screen.dart` — stores the UI quantity state for each product item.
- The Add to Cart button in `lib/screens/product_details_screen.dart` — this is the Lab 3 feature trigger.

## What Lab 3 teaches

The important architectural idea is that Lab 3 keeps the same Model → Service → Screen pattern from Lab 2, but adds a second domain model for cart data. The cart screen is not doing raw HTTP work directly. It asks `CartService` for the data, then it renders the response and handles some local UI changes like quantity controls.

This is a good example of a service layer separating API responsibility from UI logic.

## What I should be able to explain

- Why is the cart logic in a service instead of inside the screen?
- How does the app know which user cart to request?
- Why does the cart screen keep a local quantity map?
- How does the product details screen call the cart API?
- What is the difference between API cart data and local UI state?

---

# Lab Activity 4

## What changed?

This adds login, session persistence, splash-screen auth checks, and profile/logout behavior.

## Where is it?

| Concept        | File                              | Class/Function                                                               | What it does                                        |
| -------------- | --------------------------------- | ---------------------------------------------------------------------------- | --------------------------------------------------- |
| User model     | `lib/models/user.dart`            | `User`, `User.fromJson()`                                                    | Represents the authenticated user                   |
| User service   | `lib/services/user_service.dart`  | `loginUser()`, `saveUserData()`, `getUserData()`, `isLoggedIn()`, `logout()` | Handles auth and local persistence                  |
| Splash check   | `lib/screens/splash_screen.dart`  | `SplashScreen`, `_checkAuthentication()`                                     | Decides whether to continue or redirect             |
| Sign in screen | `lib/screens/signin_screen.dart`  | `SigninScreen`, `_login()`                                                   | Sends credentials and logs the user in              |
| Profile screen | `lib/screens/profile_screen.dart` | `ProfileScreen`, `_logout()`                                                 | Reads saved user data and logs out                  |
| Navigation     | `lib/main.dart`                   | `MyApp`, `MainNavigation`                                                    | Sets `'/splash'`, `'/signin'`, and `'/home'` routes |

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

| Feature             | Service                             | Endpoint                         | Method | Model     | Screen                 |
| ------------------- | ----------------------------------- | -------------------------------- | ------ | --------- | ---------------------- |
| Fetch products      | `ProductService.fetchProducts()`    | `baseUrl + /products`            | GET    | `Product` | `HomeScreen`           |
| Search products     | `ProductService.searchProducts()`   | `baseUrl + /products/search?q=`  | GET    | `Product` | `HomeScreen`           |
| Fetch product by ID | `ProductService.fetchProductById()` | `baseUrl + /products/{id}`       | GET    | `Product` | `ProductDetailsScreen` |
| Login               | `UserService.loginUser()`           | `baseUrl + /auth/login`          | POST   | `User`    | `SigninScreen`         |
| Get cart by user    | `CartService.getCartByUserId()`     | `baseUrl + /carts/user/{userId}` | GET    | `Cart`    | `CartScreen`           |
| Add to cart         | `CartService.addToCart()`           | `baseUrl + /carts/add`           | POST   | `Cart`    | `ProductDetailsScreen` |

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
