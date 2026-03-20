import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../config/app_config.dart';
import '../services/global_cart_service.dart';

class GlobalHeader extends StatelessWidget {
  final String? title;
  final bool showCart;
  final VoidCallback? onBack;

  const GlobalHeader({
    Key? key,
    this.title,
    this.showCart = true,
    this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = Get.find<ClientConfig>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/Vector.svg',
              fit: BoxFit.fill,
              width: double.infinity,
              colorFilter: ColorFilter.mode(
                Color(0xFF00ADD9),
                BlendMode.srcIn,
              ),
            ),
          ),
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack ?? () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: title != null
                          ? Text(
                              title!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Text(config.app_title, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),),
                    ),
                  ),
                  if (showCart)
                    Stack(
                      children: [
                        IconButton(
                          onPressed: () => Get.toNamed('/cart'),
                          icon: Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        Obx(() {
                          final cartService = Get.find<GlobalCartService>();
                          final totalItems = cartService.itemsCount;
                          if (totalItems > 0) {
                            return Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  '$totalItems',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        }),
                      ],
                    )
                  else
                    SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}