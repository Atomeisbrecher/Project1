import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String productName;
  final String price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Небольшая тень для эффекта "поднятия"
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Скругленные углы карточки
      ),
      clipBehavior: Clip.antiAlias, // Для корректного скругления изображения
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение товара
          Expanded(
            child: Ink.image(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
              child: InkWell(
                onTap: () {
                  // Обработчик нажатия на товар
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Нажато на ${productName}')),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название товара
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                // Цена товара
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                // Кнопка "Добавить в корзину" или "Купить"
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.add_shopping_cart, color: Colors.blueAccent),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${productName} добавлен в корзину!')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}