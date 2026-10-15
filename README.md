# aquino_advmobprogAY26-27

This repository contains the Flutter project for Advanced Mobile Programming.

The current project folder is `aquino_mobile`, and it follows the lab progression across branches:

- `lab-act2`: product model, API service, list screen, theme provider
- `lab-act3`: cart model, cart service, cart screen, add-to-cart flow
- `lab-act4`: DummyJSON user authentication, persistence, splash flow, profile/logout
- `lab-act5`: DummyJSON and Firebase Authentication, signup, account management
- `lab-act6`: Firestore-backed Firebase profiles and real-time private chat

The active branch is `lab-act6`, which includes Lab 2, 3, 4, 5, and 6 features together.

For the full study guide, see [aquino_mobile/README.md](aquino_mobile/README.md) and [aquino_mobile/docs/LAB_ACTIVITIES_WALKTHROUGH.md](aquino_mobile/docs/LAB_ACTIVITIES_WALKTHROUGH.md).

## Lab Activity 2 — Discussion

In this activity, the application was organized into separate models, services, and screens, with each layer handling a specific responsibility. The Product model defines the structure of product data and converts the API's JSON response into Dart objects. ProductService is responsible for communicating with the API and returning the retrieved products. ProductScreen then uses FutureBuilder to handle the different states of the request, such as loading, errors, and successfully displaying the products in a grid.

This structure made it possible to add features such as product searching and a product details screen without having to modify the model or service. The project also introduced a cleaner folder organization using models, services, screens, and widgets. Another important addition was ThemeProvider with the Provider package, which centralizes the application's theme state and allows listening widgets to automatically update when the theme changes.

## Lab Activity 3 — Discussion

This activity extended the same layered approach used in the product feature by adding cart functionality. The Cart and CartProduct models represent the structure of the cart data returned by the API, while CartService is responsible for handling the HTTP requests. The getCartByUserId() method retrieves the cart associated with a specific user through the user ID, while addToCart() sends a new item to the API.

CartScreen then connects these services to the interface using FutureBuilder. Instead of displaying products in a GridView like the previous activity, the cart uses a ListView to present the user's items. Keeping the data models, API requests, and UI separated makes the cart functionality easier to understand and maintain.

## Lab Activity 4 — Discussion

In this activity, the application was expanded to handle user information using the same separation of responsibilities established in the previous activities. The user model defines how user data is represented, while UserService manages communication with the API. The sign-in and profile screens then use the retrieved information to display the user's details.

Separating the user model, service, and screens keeps the application more organized because each component has a specific responsibility. The stored user ID also becomes useful beyond displaying profile information. It can be passed to the cart service to retrieve the cart belonging to the currently logged-in user, ensuring that the application displays the correct user's data.

## Lab Activity 5: Discussion

### 1. How does the workflow work for DummyJSON and Firebase implementations, from sign-in to sign-up?

The sign-in screen lets the user choose DummyJSON or Firebase. DummyJSON sign-in sends the username and password to `https://dummyjson.com/auth/login`. A successful response is normalized into the app's `User` model and its token/profile fields are saved in `SharedPreferences`. DummyJSON is only used for sign-in in this project because its demo API does not provide persistent account creation.

Firebase sign-in uses `FirebaseAuth.signInWithEmailAndPassword()` with an email address and password. Firebase sign-up uses `createUserWithEmailAndPassword()`, updates the Firebase display name, and saves the additional first name, last name, age, contact number, and username locally. The app initializes Firebase with the generated Android/Web options before `runApp()`. The selected `LoginType` is persisted so the splash screen and profile screen know which authentication flow is active.

### 2. What is the main idea behind implementing `UserService`?

`UserService` provides one reusable place for authentication and account operations instead of duplicating them in screens. It contains provider-aware sign-in, account creation, sign-out, username updates, password changes through reauthentication, account deletion, session checks, and `getUserData()`. The screens therefore focus on form validation, loading states, errors, and navigation while the service owns API calls, Firebase SDK calls, and session persistence.

### 3. What are the benefits of Firebase implementation in the current Flutter application?

Firebase Authentication gives the app SDK-based email/password authentication, Firebase-managed authentication state and token handling, duplicate-email and weak-password errors, display-name updates, reauthentication before password changes, and account deletion. These operations are more appropriate for real account management than the DummyJSON demo login endpoint. Both providers can coexist because `LoginType` keeps their distinct credentials, errors, sessions, and user data behavior separate.

The current implementation stores Firebase's extra profile fields in local `SharedPreferences`; it does not claim to use Firestore or Realtime Database, and deleting a Firebase Auth account does not delete any remote profile record. Email/Password must be enabled manually in Firebase Console: open the `advmobprog-firebase-4c5b8` project, go to **Build → Authentication → Sign-in method**, select **Email/Password**, enable it, and save. The Android and Web app configuration files are already present in this repository.

## Lab Activity 6: Discussion

### 1. How is Firebase profile data persisted?

Firebase Authentication remains responsible for identity, email, password, and authentication state. The app now stores the public chat-directory fields in Firestore under `Users/{firebaseUid}`. A self-readable `Users/{firebaseUid}/private/profile` subdocument stores age and contact number; neither document stores a password or token. The existing UID-scoped `SharedPreferences` record is retained as an offline fallback so Firebase signup, login, and profile viewing do not stop working when Firestore has not been provisioned or is temporarily unavailable. On login, Firestore documents are used to restore the profile; older accounts are backfilled from their UID-scoped local record.

DummyJSON users continue to use their API token and local active session. They are not written to the Firebase `Users` collection, and the chat UI refuses to treat a DummyJSON numeric ID as a Firebase UID.

### 2. How does the chat workflow work?

The main navigation includes a **Chats** floating action button. A Firebase-authenticated user opens a real-time directory of other Firebase users from the `Users` collection and can filter it by name, username, or email. Selecting a user opens the chat detail screen. A room ID is created deterministically from the two Firebase UIDs, so both participants read the same room. Messages are stored in `chat_rooms/{roomId}/messages` with sender and receiver UIDs, text, a server timestamp, and a basic status, then displayed through a Firestore snapshot stream in chronological order.

Self-chat is rejected, messages are limited to 2,000 characters, and the receiver is identified by Firebase UID rather than by a DummyJSON ID or an email-only guess. If the current session is DummyJSON, the chat screen explains that a Firebase account is required.

### 3. What security rules and setup are required?

The deployed rules are in [`aquino_mobile/firestore.rules`](aquino_mobile/firestore.rules). They require Firebase Authentication for public directory reads, allow a user to create/update/delete only their own profile documents, and allow chat-room and message access only to the two room participants. Age and contact data are restricted to the profile owner. Message creation requires the authenticated sender UID, a different receiver UID, non-empty text, and the `sent` status. These rules were validated and deployed to the `default` Firestore database in the `advmobprog-firebase-4c5b8` project; future deployments use the `firestore.rules` mapping in `aquino_mobile/firebase.json`.

### 4. What was preserved from the previous activities?

The existing FlutterFire initialization, Firebase email/password signup and login, username update, password-change reauthentication, account-deletion reauthentication, logout behavior, DummyJSON login, product loading, cart flow, provider selection, and UI remain in place. Firestore is an additional persistence and messaging layer; it does not replace Firebase Authentication or the DummyJSON demo provider.
