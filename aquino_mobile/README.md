# aquino_mobile

This Flutter app is my Advanced Mobile Programming project. The code follows the lab progression in the repository branches:

- `lab-act2` contains the product and theme work
- `lab-act3` adds cart support
- `lab-act4` adds authentication and persistence

The current branch is `lab-act4`, so this project includes Lab Activity 2, 3, and 4 logic together.

## Lab Activity 2: Discussion

I built the product side of the app by separating the data model, API service, and screen logic. The app loads products from DummyJSON through `ProductService`, converts the JSON response into `Product` objects with `Product.fromJson()`, and displays them in `HomeScreen`.

This is the foundation of the app:

- `lib/models/product.dart` defines the `Product` model
- `lib/services/product_service.dart` handles the HTTP requests
- `lib/screens/home_screen.dart` loads and displays the product list
- `lib/screens/product_details_screen.dart` shows the selected product detail view
- `lib/widgets/product_card.dart` is the reusable product card component
- `lib/providers/theme_provider.dart` manages the app theme using Provider

The flow is simple:

API
↓
`ProductService`
↓
`Product.fromJson()`
↓
`HomeScreen`
↓
`ProductCard` / `ProductDetailsScreen`

The user can type in the text field in `HomeScreen`, call `searchProducts()`, and then the screen reloads the products that match the query. This keeps the HTTP work away from the UI code.

## Lab Activity 3: Discussion

Lab Activity 3 adds cart support by extending the same model/service/screen pattern from Lab 2. The cart model lives in `lib/models/cart.dart`, and the API calls are handled in `lib/services/cart_service.dart`.

The important pieces are:

- `Cart` and `CartProduct` represent the cart response and each item inside it
- `CartService.getCartByUserId()` requests the current user's cart
- `CartService.addToCart()` sends a product payload to the cart endpoint
- `CartScreen` displays cart items, quantity controls, and subtotal
- the add-to-cart button in `ProductDetailsScreen` calls the cart service instead of doing the HTTP work directly

The cart is connected to a user ID through saved user data and the `currentUserId` fallback in `lib/constants.dart`. The quantity changes in `CartScreen` are kept in a local map for the UI, so this is still a demo API-backed cart flow rather than a database-backed production cart system.

## Lab Activity 4: Discussion

Lab Activity 4 adds sign-in and session persistence. The user model is in `lib/models/user.dart`, and authentication logic is wrapped in `lib/services/user_service.dart`.

The app uses `SharedPreferences` to save the user session after login. `SplashScreen` reads the saved token on startup and decides whether to send the user to `HomeScreen` or `SigninScreen`.

The main auth flow is:

App starts
↓
`SplashScreen`
↓
`UserService.isLoggedIn()`
↓
if logged in → `MainNavigation` / `HomeScreen`
if not logged in → `SigninScreen`
↓
`UserService.loginUser()`
↓
`UserService.saveUserData()`
↓
`ProfileScreen` reads the saved data
↓
`ProfileScreen._logout()` clears the stored session

This keeps the responsibility split clear: models hold data, services call APIs and storage, and screens handle interface and navigation.

## Important Files to Study First

1. `lib/main.dart` — app entry point and provider wiring
2. `lib/constants.dart` — API endpoints and app constants
3. `lib/models/product.dart` — product model and JSON conversion
4. `lib/services/product_service.dart` — API logic for products
5. `lib/screens/home_screen.dart` — product list and search flow
6. `lib/models/cart.dart` — cart structure
7. `lib/services/cart_service.dart` — cart API logic
8. `lib/screens/cart_screen.dart` — cart UI and totals
9. `lib/models/user.dart` — user model
10. `lib/services/user_service.dart` — login and persistence logic
11. `lib/screens/splash_screen.dart` — auth check on startup
12. `lib/screens/signin_screen.dart` — login screen
13. `lib/screens/profile_screen.dart` — profile and logout

## Notes

This project does not have a separate `ProductScreen` class. The list screen is `HomeScreen`, and the detail screen is `ProductDetailsScreen`. The app uses actual DummyJSON endpoints from `lib/constants.dart`, not a fake local database.
