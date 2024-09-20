import 'package:flutter/material.dart';
import 'package:social_media_app/components/my_button.dart';

class MyListTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final void Function(String title) onDelete;
  final void Function(String title) onEdit;

  const MyListTile({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  TextEditingController editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(widget.title),
                  subtitle: Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              MyButton(
                text: "Delete",
                onTap: () {
                  widget.onDelete(widget.title);
                },
              ),
              SizedBox(width: 10),
              MyButton(
                text: "Edit",
                onTap: () {
                  _showEditDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    editController.text =
        widget.title; // Postavljanje početnog teksta u TextField-u

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Post'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter your edited post'),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.red, // Boja za Cancel dugme
              ),
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Boja za Save dugme
              ),
              child: Text('Save'),
              onPressed: () {
                // Pozivamo funkciju za editovanje sa novim tekstom
                widget.onEdit(editController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
