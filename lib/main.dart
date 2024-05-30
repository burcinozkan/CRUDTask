import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'apiService.dart';
import 'apiDialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crud Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String connectionStatus = "No Connection!";
  String? apiKey;
  ApiService? apiService;
  List<dynamic> fetchedData = [];
  List<dynamic> filteredData = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  void _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiKey = prefs.getString('apiKey');
      if (apiKey != null) {
        apiService = ApiService(apiKey!);
        _validateApiKey(apiKey!);
      }
    });
  }

  void _saveApiKey(String key) async {
    print('API key saving: $key'); // Debug message
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiKey', key);
    setState(() {
      apiKey = key;
      apiService = ApiService(key);
    });
    _validateApiKey(key);
  }

  void _validateApiKey(String key) async {
    try {
      final response = await apiService!.validateApiKey();
      if (response.statusCode == 200) {
        setState(() {
          connectionStatus = 'Connected!';
        });
        _showToast("Connected");
        fetchData();
      } else {
        setState(() {
          connectionStatus = 'No Connection!';
        });
      }
    } catch (e) {
      setState(() {
        connectionStatus = 'No Connection!';
      });
    }
  }

  void fetchData() async {
    if (apiService != null) {
      try {
        final response = await apiService!.fetchData();
        if (response.statusCode == 200) {
          setState(() {
            fetchedData = response.data ?? [];
            filteredData = fetchedData;
            if (fetchedData.isEmpty) {
              connectionStatus = 'No data';
            } else {
              connectionStatus = 'Connected!';
            }
          });
        } else {
          setState(() {
            connectionStatus = 'No Connection!';
          });
        }
      } catch (e) {
        setState(() {
          connectionStatus = 'No Connection!';
        });
      }
    }
  }

  void addUser(String name, String image, String birthday) async {
    if (apiService != null) {
      try {
        final response = await apiService!.addUser(name, image, birthday);
        if (response.statusCode == 201) {
          fetchData();
          _showToast("User added successfully!");
        }
      } catch (e) {
        _showToast("Failed to add user!");
      }
    }
  }

  void updateUser(String id, String name, String image, String birthday) async {
    if (apiService != null) {
      try {
        final response = await apiService!.updateUser(id, name, image, birthday);
        if (response.statusCode == 200) {
          fetchData();
          _showToast("User updated successfully!");
        }
      } catch (e) {
        _showToast("Failed to update user!");
      }
    }
  }

  void deleteUser(String id) async {
    if (apiService != null) {
      try {
        final response = await apiService!.deleteUser(id);
        if (response.statusCode == 200) {
          fetchData();
          _showToast("User deleted successfully!");
        }
      } catch (e) {
        _showToast("Failed to delete user!");
      }
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showApiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ApiDialog(
          onSubmit: (apiKey) {
            _saveApiKey(apiKey);
          },
        );
      },
    );
  }


  void _showAddUserDialog(BuildContext context, {String? id, String? name, String? image, String? birthday}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(
          name: name,
          image: image,
          birthday: birthday,
          onSubmit: (newName, newImage, newBirthday) {
            if (id == null) {
              addUser(newName, newImage, newBirthday);
            } else {
              updateUser(id, newName, newImage, newBirthday);
            }
          },
        );
      },
    );
  }

  String calculateAge(String birthday) {
    DateTime? birthDate = _parseDate(birthday);

    if (birthDate == null) {
      return "Invalid date format";
    }

    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  DateTime? _parseDate(String date) {
    try {
      List<String> parts = date.split('-');
      if (parts.length != 3) {
        return null;
      }

      String year = parts[0];
      String month = parts[1].padLeft(2, '0');
      String day = parts[2].padLeft(2, '0');

      String formattedDate = '$year-$month-$day';
      return DateTime.parse(formattedDate);
    } catch (e) {
      return null;
    }
  }

  String _getZodiacSign(String birthday) {
    DateTime? birthDate = _parseDate(birthday);

    if (birthDate == null) {
      return "Invalid date format";
    }

    int day = birthDate.day;
    int month = birthDate.month;
    String zodiac = '';

    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      zodiac = "Aquarius";
    } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      zodiac = "Pisces";
    } else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      zodiac = "Aries";
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      zodiac = "Taurus";
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      zodiac = "Gemini";
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      zodiac = "Cancer";
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      zodiac = "Leo";
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      zodiac = "Virgo";
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      zodiac = "Libra";
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      zodiac = "Scorpio";
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      zodiac = "Sagittarius";
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      zodiac = "Capricorn";
    }

    return zodiac;
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredData = fetchedData;
      } else {
        filteredData = fetchedData
            .where((user) => (user['name'] ?? '')
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crud API Example'),
        bottom: connectionStatus == 'Connected!'
            ? PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterData('');
                  },
                ),
              ),
              onChanged: (query) {
                _filterData(query);
              },
            ),
          ),
        )
            : null,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(connectionStatus),
            if (connectionStatus == 'Connected!') ...[
              if (filteredData.isEmpty)
                const Text('No data')
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final user = filteredData[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user['image'] ?? ''),
                          onBackgroundImageError: (_, __) => const Icon(Icons.error),
                        ),
                        title: Text(user['name'] ?? 'Unknown'),
                        subtitle: Text(
                            'Age: ${user['birthday'] != null ? calculateAge(user['birthday']) : 'Unknown'}, Zodiac: ${user['birthday'] != null ? _getZodiacSign(user['birthday']) : 'Unknown'}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showAddUserDialog(context, id: user['_id'], name: user['name'], image: user['image'], birthday: user['birthday']);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                deleteUser(user['_id']);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _showApiDialog(context);
            },
            child: const Icon(Icons.link),
            backgroundColor: connectionStatus=='Connected!' ? Colors.pink : Colors.white
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: connectionStatus == 'Connected!' ? () => _showAddUserDialog(context) : null,
            child: const Icon(Icons.add),
            backgroundColor: connectionStatus == 'Connected!' ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  final Function(String, String, String) onSubmit;
  final String? name;
  final String? image;
  final String? birthday;

  AddUserDialog({required this.onSubmit, this.name, this.image, this.birthday});

  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  String? selectedBirthday;

  @override
  void initState() {
    super.initState();
    if (widget.name != null) nameController.text = widget.name!;
    if (widget.image != null) imageController.text = widget.image!;
    if (widget.birthday != null) {
      birthdayController.text = widget.birthday!;
      selectedBirthday = widget.birthday;
    }
  }

  void _selectBirthday(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      minTime: DateTime(1900, 1, 1),
      maxTime: DateTime.now(),
      onConfirm: (date) {
        setState(() {
          selectedBirthday = '${date.year}-${date.month}-${date.day}';
          birthdayController.text = selectedBirthday!;
        });
      },
      currentTime: DateTime.now(),
      locale: LocaleType.en,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.name == null ? 'Create User' : 'Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: 'Enter Name'),
          ),
          TextField(
            controller: imageController,
            decoration: const InputDecoration(hintText: 'Image URL'),
          ),
          TextField(
            controller: birthdayController,
            decoration: InputDecoration(
              hintText: 'Select Birthday',
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _selectBirthday(context),
              ),
            ),
            readOnly: true,
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSubmit(
              nameController.text,
              imageController.text,
              birthdayController.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
