import 'package:flutter/material.dart';

class SelectSupplierScreen extends StatefulWidget {
  const SelectSupplierScreen({super.key});

  @override
  State<SelectSupplierScreen> createState() => _SelectSupplierScreenState();
}

class _SelectSupplierScreenState extends State<SelectSupplierScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _allSuppliers = [
    'A Organic Farms Corp',
    'Acme Open Supplier',
    'Alpine Foods',
    'Alsum Farms & Produce Inc',
    'Alta Dena Certified Dairy',
    'Applegate Open Farms',
    'Aqua Star',
    'Aramark',
    'Baldor Specialty Foods',
    'Bee Sweet Citrus',
    'Bee Sweet Citrus',
    'Bee Sweet Citrus',
    'Cargill',
    'Dole',
    'Ecolab',
    'Ferrero',
    'Foster Farms',
    'Frito-Lay',
    'Goya Foods',
    'Green Giant',
    'Hormel Foods',
    'Hudsonville Ice Cream',
    'JBS USA',
    'Jennie-O',
    'Kellogg',
    'Kraft Heinz',
    'Land O’Lakes',
    'Lassonde Pappas',
    'McCormick & Company',
    'McDonald’s',
    'Nestlé',
    'Nestlé Purina PetCare',
    'O-I',
    'Olam International',
    'Owens-Illinois',
    'Perdue Farms',
    'PepsiCo',
    'Quaker Oats',
    'Rich Products',
    'Richelieu Foods',
    'Saputo',
    'Smithfield Foods',
    'Snyder’s-Lance',
    'Tyson Foods',
    'T Marzetti',
    'Unilever',
    'US Foods',
    'V & V Supremo Foods',
    'Vermont Creamery',
    'Vermont Smoke & Cure',
    'Wegmans Food Markets',
    'Wendy’s',
    'Yoplait',
    'Zentis',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Supplier'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SupplierSearchDelegate(_allSuppliers),
              );
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Row(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _allSuppliers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_allSuppliers[index]),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              width: 40,
              child: ListView.builder(
                itemCount: 26,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  String letter = String.fromCharCode(index + 65); // ASCII A-Z
                  return Container(
                    height: MediaQuery.of(context).size.height / 26,
                    child: GestureDetector(
                      onTap: () {
                        int targetIndex = _allSuppliers.indexWhere(
                            (supplier) => supplier.startsWith(letter));
                        if (targetIndex != -1) {
                          _scrollController.animateTo(
                            targetIndex *
                                56.0, // Assuming a constant height per item
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      child: Container(
                        height: 20,
                        child: Text(
                          letter,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SupplierSearchDelegate extends SearchDelegate<String> {
  final List<String> suppliers;

  SupplierSearchDelegate(this.suppliers);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = suppliers
        .where(
            (supplier) => supplier.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(results[index]),
          onTap: () {
            close(context, results[index]);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = suppliers
        .where((supplier) =>
            supplier.toLowerCase().startsWith(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(suggestions[index]),
          onTap: () {
            query = suggestions[index];
            showResults(context);
          },
        );
      },
    );
  }
}
