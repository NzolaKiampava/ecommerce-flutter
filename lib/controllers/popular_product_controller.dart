import 'package:flutter/material.dart';
import 'package:food_delivery/controllers/cart_controller.dart';
import 'package:food_delivery/data/repository/popular_product_repo.dart';
import 'package:food_delivery/models/products_model.dart';
import 'package:food_delivery/utils/app_constants.dart';
import 'package:food_delivery/utils/colors.dart';
import 'package:get/get.dart';

class PopularProductController extends GetxController {
  final PopularProductRepo popularProductRepo;
  PopularProductController({required this.popularProductRepo});
  List<dynamic> _popularProductList = [];
  List<dynamic> get popularProductList => _popularProductList;
  late CartController _cart;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  int _quantity = 0;
  int get quantity => _quantity;
  int _inCartItems = 0;
  int get inCartitems => _inCartItems + _quantity;

  Future<void> getPopularProductList() async {
    Response response = await popularProductRepo.getPopularProductList();
    if (response.statusCode == 200) {
      //print("got products");
      _popularProductList = [];
      _popularProductList.addAll(Product.fromJson(response.body).products);
      //print(_popularProductList);
      _isLoaded = true;
      update();
    } else {
      print("No products");
    }
  }

  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = checkQuantity(_quantity + 1);
      //print("increment " + _quantity.toString());
    } else {
      _quantity = checkQuantity(_quantity - 1);
      //print("decrement " + _quantity.toString());
    }
    update();
  }

  int checkQuantity(int quantity) {
    if ((inCartitems + quantity) < 0) {
      Get.snackbar("Item count", "You can´t reduce more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      return 0;
    } else if (inCartitems + quantity > 20) {
      Get.snackbar("Item count", "You can´t add more!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
      return 20;
    } else {
      return quantity;
    }
  }

  void initProduct(ProductModel product, CartController cart) {
    _quantity = 0;
    _inCartItems = 0;
    _cart = cart;
    var exist = false;
    exist = _cart.existInCart(product);
    // if exist
    // get from storage _inCartItems=3
    print("exist or not " + exist.toString());
    if (exist) {
      _inCartItems = _cart.getQuantity(product);
    }
    print("the quantity is " + inCartitems.toString());
  }

  void addItem(ProductModel product) {
    if (_quantity > 0) {
      _cart.addItem(product, _quantity);
      _quantity = 0;
      _inCartItems = _cart.getQuantity(product);
      _cart.items.forEach((key, value) {
        print("The id is " +
            value.id.toString() +
            " The quantity is " +
            value.quantity.toString());
      });

      update();
    } else {
      Get.snackbar(
          "Item count", "You should at least add one item in the cart!",
          backgroundColor: AppColors.mainColor, colorText: Colors.white);
    }
  }

  int get totalItems {
    return _cart.totalItems;
  }
}
