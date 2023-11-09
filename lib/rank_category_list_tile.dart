import "package:flutter/material.dart";
import "package:readme_tier_list_generator/model.dart";

class RankCategoryListTile extends StatelessWidget {
  final List<Rankable> rankable;
  final Rank rank;

  const RankCategoryListTile(
      {required this.rank, required this.rankable, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                    child: Center(child: Text(rankable[index].name)),
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
