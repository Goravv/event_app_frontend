import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VenueSearchScreen extends StatefulWidget {
  const VenueSearchScreen({super.key});

  @override
  State<VenueSearchScreen> createState() => _VenueSearchScreenState();
}

class _VenueSearchScreenState extends State<VenueSearchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adultsController = TextEditingController();

  String? selectedEventType;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  String? selectedCatering;
  String? selectedCuisine;
  String? selectedBudget;
  DateTime? selectedDate;

  List<dynamic> venues = [];

  final eventTypes = ['Wedding', 'Corporate', 'Birthday', 'Concert'];
  final countries = ['India', 'USA', 'UK'];
  final states = ['Delhi', 'Maharashtra', 'California'];
  final cities = ['Mumbai', 'New York', 'London'];

  final cateringPreferences = ['Veg', 'Non-Veg', 'Both'];
  final cuisineTypes = ['Indian', 'Chinese', 'Continental', 'Italian'];
  final budgetRanges = ['< ₹500 per plate', '₹500–₹1000', '₹1000–₹2000', '> ₹2000'];

  Future<void> searchVenues() async {
    if (!_formKey.currentState!.validate()) return;

    final body = {
      "eventType": selectedEventType,
      "country": selectedCountry,
      "state": selectedState,
      "city": selectedCity,
      "date": selectedDate?.toIso8601String(),
      "adults": int.tryParse(_adultsController.text.trim()) ?? 0,
      "cateringPreference": selectedCatering,
      "cuisineType": selectedCuisine,
      "budget": selectedBudget,
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.3:5000/api/venues/search"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => venues = data['venues']);
      } else {
        throw Exception("Failed to load venues");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Venues")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Event Type"),
                items: eventTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                value: selectedEventType,
                onChanged: (val) => setState(() => selectedEventType = val),
                validator: (val) => val == null ? "Please select an event type" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Country"),
                items: countries
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                value: selectedCountry,
                onChanged: (val) => setState(() => selectedCountry = val),
                validator: (val) => val == null ? "Please select a country" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("State"),
                items: states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                value: selectedState,
                onChanged: (val) => setState(() => selectedState = val),
                validator: (val) => val == null ? "Please select a state" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("City"),
                items: cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                value: selectedCity,
                onChanged: (val) => setState(() => selectedCity = val),
                validator: (val) => val == null ? "Please select a city" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _adultsController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Number of Adults"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),

              // Catering preference
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Catering Preference"),
                items: cateringPreferences
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                value: selectedCatering,
                onChanged: (val) => setState(() => selectedCatering = val),
                validator: (val) => val == null ? "Please select a preference" : null,
              ),
              const SizedBox(height: 12),

              // Cuisine type
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Cuisine Type"),
                items: cuisineTypes
                    .map((cuisine) => DropdownMenuItem(value: cuisine, child: Text(cuisine)))
                    .toList(),
                value: selectedCuisine,
                onChanged: (val) => setState(() => selectedCuisine = val),
                validator: (val) => val == null ? "Please select a cuisine" : null,
              ),
              const SizedBox(height: 12),

              // Budget
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Budget per Plate"),
                items: budgetRanges
                    .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                    .toList(),
                value: selectedBudget,
                onChanged: (val) => setState(() => selectedBudget = val),
                validator: (val) => val == null ? "Please select a budget" : null,
              ),
              const SizedBox(height: 12),

              // Date
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? "Event Date: ${selectedDate!.toLocal()}".split(' ')[0]
                          : "Pick Event Date",
                    ),
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: const Text("Select Date"),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // Search button
              ElevatedButton(
                onPressed: searchVenues,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Search"),
              ),
              const SizedBox(height: 24),

              // Venue results
              if (venues.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Matching Venues:",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...venues.map((venue) => Card(
                          child: ListTile(
                            title: Text(venue['name']),
                            subtitle: Text(
                                "${venue['city']}, ${venue['state']}, ${venue['country']}"),
                            trailing:
                                Text("Cap: ${venue['capacity'].toString()}"),
                          ),
                        )),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
