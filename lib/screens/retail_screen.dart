import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RetailScreen extends StatefulWidget {
  const RetailScreen({super.key});

  @override
  State<RetailScreen> createState() => _RetailScreenState();
}

class _RetailScreenState extends State<RetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _storeTypeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  DateTime? selectedDate;

  final List<Map<String, dynamic>> retailOptions = [
    {
      "name": "Urban Mart",
      "type": "Supermarket",
      "location": "Delhi",
      "availableFrom": DateTime.now().add(const Duration(days: 3)),
      "rent": 15000
    },
    {
      "name": "Fashion Hub",
      "type": "Clothing Store",
      "location": "Mumbai",
      "availableFrom": DateTime.now().add(const Duration(days: 5)),
      "rent": 20000
    },
    {
      "name": "Gadget Zone",
      "type": "Electronics",
      "location": "Bangalore",
      "availableFrom": DateTime.now().add(const Duration(days: 7)),
      "rent": 25000
    },
  ];

  List<Map<String, dynamic>> filteredRetail = [];

  Future<void> pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void searchRetailSpaces() {
    if (!_formKey.currentState!.validate()) return;

    final location = _locationController.text.trim().toLowerCase();
    final type = _storeTypeController.text.trim().toLowerCase();
    final budget = int.tryParse(_budgetController.text.trim()) ?? 0;

    setState(() {
      filteredRetail = retailOptions.where((option) {
        final matchLocation = option["location"].toString().toLowerCase().contains(location);
        final matchType = option["type"].toString().toLowerCase().contains(type);
        final matchBudget = option["rent"] <= budget;
        final matchDate = selectedDate == null || option["availableFrom"].isAfter(selectedDate!);
        return matchLocation && matchType && matchBudget && matchDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Retail Spaces")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "Preferred Location"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _storeTypeController,
                decoration: const InputDecoration(labelText: "Store Type"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                decoration: const InputDecoration(labelText: "Monthly Budget (₹)"),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? "Available From: ${DateFormat.yMMMd().format(selectedDate!)}"
                          : "Pick availability date",
                    ),
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: const Text("Select Date"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: searchRetailSpaces,
                child: const Text("Search"),
              ),
              const SizedBox(height: 24),
              if (filteredRetail.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Available Retail Spaces:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...filteredRetail.map((retail) => Card(
                          child: ListTile(
                            title: Text(retail['name']),
                            subtitle: Text(
                                "${retail['type']} in ${retail['location']}\nAvailable from: ${DateFormat.yMMMd().format(retail['availableFrom'])}"),
                            trailing: Text("₹${retail['rent']}"),
                          ),
                        )),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
