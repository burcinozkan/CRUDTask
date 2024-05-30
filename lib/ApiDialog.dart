import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiDialog extends StatelessWidget {
  final Function(String) onSubmit;

  ApiDialog({required this.onSubmit});

  final TextEditingController apiKeyController = TextEditingController();

  Future<void> _launchURL() async {
    const url = 'https://crudcrud.com';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter API Key'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(hintText: 'API Key'),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _launchURL,
            child: Text(
              'Create an API key',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
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
            onSubmit(apiKeyController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
