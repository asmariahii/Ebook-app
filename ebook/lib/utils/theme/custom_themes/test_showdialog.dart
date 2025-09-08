import 'package:flutter/material.dart';

class TestShowDialog extends StatelessWidget {
  const TestShowDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test ShowDialog')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show a dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'Dialog Title',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  content: Text('This is a dialog to test the theme.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                );
              },
            );
          },
          child: Text('Show Dialog'),
        ),
      ),
    );
  }
}
