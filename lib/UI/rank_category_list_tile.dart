import "package:flutter/material.dart";
import "package:readme_tier_list_generator/data/model.dart";
import "package:readme_tier_list_generator/data/style.dart";

class RankCategoryListTile extends StatelessWidget {
  final List<RankableItem> rankable;
  final Tier rank;
  final Style style;

  const RankCategoryListTile({
    required this.rank,
    required this.rankable,
    required this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: style.tierBackgroundColor,
      elevation: 0,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Card(
              color: rank.color,
              child: Center(
                child: Text(
                  rank.name,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: rankable.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 100,
                    child: Center(child: rankable[index].toWidget()),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
