import 'package:flutter/material.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';

import '../cusTxt_widget.dart';

class PromotionWithItemWidget extends StatelessWidget {
  
  final PromotionModel promotion;
  const PromotionWithItemWidget({
    super.key,
    required this.promotion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CusTxtWidget(
          txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.pinkAccent.withOpacity(0.6),
          ),
          txt: "Promotion : ",
        ),
        Column(
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.pinkAccent.withOpacity(0.6),
              ),
              txt: promotion.promotionName,
            ),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.pinkAccent,
                fontWeight: FontWeight.bold,
              ),
              txt: promotion.promotionPrice == null ? '${promotion.promotionPercentage} %' : '${promotion.promotionPrice} MMK',
            ),
          ],
        )
      ],
    );
  }
}
