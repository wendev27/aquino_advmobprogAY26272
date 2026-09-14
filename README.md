# aquino_advmobprogAY26272

## Lab Activity 2 — Discussion

In this activity, the application was organized into separate models, services, and screens, with each layer handling a specific responsibility. The Product model defines the structure of product data and converts the API's JSON response into Dart objects. ProductService is responsible for communicating with the API and returning the retrieved products. ProductScreen then uses FutureBuilder to handle the different states of the request, such as loading, errors, and successfully displaying the products in a grid.

This structure made it possible to add features such as product searching and a product details screen without having to modify the model or service. The project also introduced a cleaner folder organization using models, services, screens, and widgets. Another important addition was ThemeProvider with the Provider package, which centralizes the application's theme state and allows listening widgets to automatically update when the theme changes.
