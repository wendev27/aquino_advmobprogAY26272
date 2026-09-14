# aquino_advmobprogAY26272

## Lab Activity 2 — Discussion

In this activity, the application was organized into separate models, services, and screens, with each layer handling a specific responsibility. The Product model defines the structure of product data and converts the API's JSON response into Dart objects. ProductService is responsible for communicating with the API and returning the retrieved products. ProductScreen then uses FutureBuilder to handle the different states of the request, such as loading, errors, and successfully displaying the products in a grid.

This structure made it possible to add features such as product searching and a product details screen without having to modify the model or service. The project also introduced a cleaner folder organization using models, services, screens, and widgets. Another important addition was ThemeProvider with the Provider package, which centralizes the application's theme state and allows listening widgets to automatically update when the theme changes.

## Lab Activity 3 — Discussion

This activity extended the same layered approach used in the product feature by adding cart functionality. The Cart and CartProduct models represent the structure of the cart data returned by the API, while CartService is responsible for handling the HTTP requests. The getCartByUserId() method retrieves the cart associated with a specific user through the user ID, while addToCart() sends a new item to the API.

CartScreen then connects these services to the interface using FutureBuilder. Instead of displaying products in a GridView like the previous activity, the cart uses a ListView to present the user's items. Keeping the data models, API requests, and UI separated makes the cart functionality easier to understand and maintain.
