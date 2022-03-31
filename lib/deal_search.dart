import 'package:flutter/material.dart';

class DealSearch extends SearchDelegate {
  late List<ExpansionTile> deals;
  late String selectedResult;

  DealSearch(this.deals);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    // ignore: avoid_unnecessary_containers
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<ExpansionTile> suggestedDealStrings = [];
    late Row stinky;
    late Text stinky2;
    late Text stinky3;
    query.isEmpty
        ? {
            suggestedDealStrings = deals,
            //stinky = suggestedDealStrings.first.title as Row,
            //stinky2 = stinky.children[0] as Text,
            // ignore: avoid_print
            //{print(stinky2.data)}
          }
        : {
            suggestedDealStrings = [],
            for (int i = 0; i < deals.length; i++)
              {
                stinky = deals[i].title as Row,
                stinky2 = stinky.children[0] as Text,
                stinky3 = stinky.children[2] as Text,
                if (stinky2.data!.toLowerCase().contains(query.toLowerCase()) ||
                    stinky3.data!.toLowerCase().contains(query.toLowerCase()))
                  {suggestedDealStrings.add(deals[i])}
              }
          };

    return ListView.builder(
        itemCount: suggestedDealStrings.length,
        itemBuilder: (context, position) => suggestedDealStrings[position]);
  }
}
