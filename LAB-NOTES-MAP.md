# Lab Activity Notes Map

This is a quick guide to the lab work in the Aquino project. It lists the main implementation files, the important classes or methods to inspect, and where the related Maquilan reference can be found.

## Lab Activity 1

### What it covers

This activity is the basic Flutter app setup and entry point before the product features are added.

### Main implementation

- `aquino_mobile/lib/main.dart`

### Important files

- `aquino_mobile/pubspec.yaml`
- `aquino_mobile/lib/main.dart`

### Where to look

Start with `main()` and `MyApp` in `main.dart`. They show how the application starts and how the first screen is configured.

### Explanation

I used this activity to establish the Flutter project structure and the initial application entry point. The later activities build on this setup by adding separate screens, models, services, and providers.

### Reference

Maquilan:

- Branch: `lab_act1`
- Relevant file/section: `maquilan_mobile/lib/main.dart` and the root `README.md`

## Lab Activity 2

### What it covers

This activity adds product loading, searching, product details, and light/dark theme state using a model-service-screen structure.

### Main implementation

- `aquino_mobile/lib/models/product.dart`
- `aquino_mobile/lib/services/product_service.dart`
- `aquino_mobile/lib/screens/product_screen.dart`

### Important files

- `aquino_mobile/lib/screens/home_screen.dart`
- `aquino_mobile/lib/screens/product_details_screen.dart`
- `aquino_mobile/lib/providers/theme_provider.dart`
- `aquino_mobile/lib/widgets/custom_text.dart`

### Where to look

`Product.fromJson()` converts API data, `ProductService.getAllProducts()` requests it, and `ProductScreen` displays the loading, error, search, and grid states. `ProductDetailsScreen` handles a selected product, while `ThemeProvider` controls the theme.

### Explanation

I kept the product data, API request, and interface in separate parts of the project. This means the screen works with `Product` objects instead of raw JSON, and the search and details features can be changed without putting networking code directly in the UI.

### Reference

Maquilan:

- Branch: `lab_act2`
- Relevant file/section: root `README.md`, Lab Activity 2 discussion

## Lab Activity 3

### What it covers

This activity extends the product flow with a temporary cart that stores selected products and quantities.

### Main implementation

- `aquino_mobile/lib/providers/cart_provider.dart`
- `aquino_mobile/lib/screens/cart_screen.dart`
- `aquino_mobile/lib/screens/product_details_screen.dart`

### Important files

- `aquino_mobile/lib/main.dart`
- `aquino_mobile/lib/models/product.dart`

### Where to look

`CartProvider.addProduct()` adds a product or increases its quantity. `CartScreen` reads the provider and shows the items, remove actions, and subtotal. The Add to Cart button is in `ProductDetailsScreen`.

### Explanation

I used a `ChangeNotifier` provider so the cart can be shared by the product details page and the Cart tab. The data is only kept in memory for now, so it resets when the app restarts, but the add, quantity, remove, and subtotal behavior can be demonstrated immediately.

### Reference

Maquilan:

- Branch: `lab_act3`
- Relevant file/section: root `README.md`, Lab Activity 3 discussion

## Lab Activity 4

### What it covers

This activity adds sign-in flow and displays the signed-in user's email in My Profile.

### Main implementation

- `aquino_mobile/lib/screens/signin_screen.dart`
- `aquino_mobile/lib/screens/profile_screen.dart`
- `aquino_mobile/lib/main.dart`

### Important files

- `aquino_mobile/lib/screens/home_screen.dart`
- `aquino_mobile/lib/screens/cart_screen.dart`

### Where to look

`SigninScreen._signIn()` validates the form and passes the email through the `/home` route. `MainNavigation` receives that value and gives it to `ProfileScreen`, which displays the email for the current session.

### Explanation

The sign-in form currently provides a temporary local login flow. After the form is valid, the entered email is passed to the main navigation instead of being lost. My Profile then uses that value to show which user signed in.

### Reference

Maquilan:

- Branch: `lab_act4`
- Relevant file/section: root `README.md`, Lab Act 4 discussion, and the user/sign-in/profile implementation

## Lab Activity 5

### What it covers

No verified LAB-ACT5 implementation is currently available in the checked-out repositories.

### Main implementation

- Pending `aquino_mobile` LAB-ACT5 implementation

### Important files

- None verified yet.

### Where to look

The Aquino repository currently has no `lab-act5` branch, and the Maquilan repository has no local or remote `lab_act5` reference available in this workspace.

### Explanation

I have not described an Activity 5 feature because there is no corresponding implementation to inspect. This section can be completed once both LAB-ACT5 branches are available.

### Reference

Maquilan:

- Branch: `lab_act5` requested, but not available in the repository references inspected
