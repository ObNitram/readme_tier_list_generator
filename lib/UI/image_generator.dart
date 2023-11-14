import "package:flutter/material.dart";
import "package:readme_tier_list_generator/data/model.dart";
import "package:readme_tier_list_generator/UI/rank_category_list_tile.dart";

class TierListWidget extends StatelessWidget {
  final TierList tierList;

  const TierListWidget({required this.tierList, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: tierList.style.radius,
      ),
      color: tierList.style.backgroundColor,
      child: ClipRRect(
          borderRadius: tierList.style.radius,
          child: Column(
            children: [
              Container(
                color: tierList.style.titleBackgroundColor,
                height: 80,
                child: Center(
                    child: Text(tierList.title,
                        style: TextStyle(
                            fontSize: 30,
                            color: tierList.style.titleTextColor))),
              ),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              for (Tier rank in tierList.tierList.keys)
                Expanded(
                  child: RankCategoryListTile(
                    rankable: tierList.tierList[rank]!,
                    rank: rank,
                    style: tierList.style,
                  ),
                ),
            ],
          )),
    );
  }
}
