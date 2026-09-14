# Lab Activity Notes Map

## Lab Activity 4

### Login Feedback

The login screen now shows a simple SnackBar when login fails instead of exposing the raw API exception. Invalid credentials use the message “Invalid username or password”, while unexpected errors use a general retry message. The authentication request and the rest of the login flow were left unchanged.

### Aquino implementation

- `aquino_mobile/lib/screens/signin_screen.dart`
- `aquino_mobile/lib/services/user_service.dart`

The error message is cleaned up at `SigninScreen._login()`, where the login result is presented to the user.
