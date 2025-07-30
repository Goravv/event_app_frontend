import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});

  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedEventType;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  DateTime? selectedDate;
  final travelersController = TextEditingController();

  final List<String> eventTypes = ['Wedding', 'Corporate', 'Birthday', 'Festival'];
  final List<String> countries = ['India', 'USA', 'UK'];
  final List<String> states = ['Maharashtra', 'California', 'London'];
  final List<String> cities = ['Mumbai', 'Los Angeles', 'London'];

  final List<Map<String, String>> travelOptions = [
    {'mode': 'Flight', 'company': 'IndiGo', 'departure': '10:00 AM'},
    {'mode': 'Train', 'company': 'Rajdhani Express', 'departure': '08:30 PM'},
    {'mode': 'Bus', 'company': 'RedBus', 'departure': '06:00 AM'},
  ];

  final List<Map<String, String>> hotelOptions = [
    {'name': 'Taj Hotel', 'location': 'Mumbai', 'price': '₹6,000/night'},
    {'name': 'Marriott', 'location': 'Delhi', 'price': '₹5,000/night'},
    {'name': 'Oberoi', 'location': 'Bangalore', 'price': '₹4,500/night'},
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Travel & Stay")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Event Type"),
                value: selectedEventType,
                items: eventTypes
                    .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => selectedEventType = val),
                validator: (val) => val == null ? "Please select event type" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "Country"),
                value: selectedCountry,
                items: countries
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCountry = val),
                validator: (val) => val == null ? "Select a country" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "State"),
                value: selectedState,
                items: states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => selectedState = val),
                validator: (val) => val == null ? "Select a state" : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: "City"),
                value: selectedCity,
                items: cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => selectedCity = val),
                validator: (val) => val == null ? "Select a city" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: travelersController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "No. of Travelers"),
                validator: (val) => val!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? "Date: ${DateFormat.yMMMd().format(selectedDate!)}"
                          : "Pick travel date",
                    ),
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: const Text("Select Date"),
                  )
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    FocusScope.of(context).unfocus();
                  }
                },
                child: const Text("Search Options"),
              ),
              const SizedBox(height: 24),
              const Text("Available Travel Options:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...travelOptions.map((opt) => Card(
                    child: ListTile(
                      leading: Icon(Icons.directions_transit),
                      title: Text(opt['company']!),
                      subtitle: Text("Mode: ${opt['mode']}"),
                      trailing: Text(opt['departure']!),
                    ),
                  )),
              const SizedBox(height: 24),
              const Text("Recommended Hotels:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ...hotelOptions.map((hotel) => Card(
                    child: ListTile(
                      leading: Icon(Icons.hotel),
                      title: Text(hotel['name']!),
                      subtitle: Text(hotel['location']!),
                      trailing: Text(hotel['price']!),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
