import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  final List messages;
  const MessagesScreen({Key? key, required this.messages}) : super(key: key);

  @override
  _MessagesScreenState createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;

    // Log the messages to the console for debugging
    print("Messages: ${widget.messages}");

    return ListView.separated(
      itemBuilder: (context, index) {
        // Log the individual message being rendered
        print("Rendering message: ${widget.messages[index]['message'].text.text[0]}");

        return Container(
          margin: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: widget.messages[index]['isUserMessage']
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(
                        widget.messages[index]['isUserMessage'] ? 0 : 16),
                    topLeft: Radius.circular(
                        widget.messages[index]['isUserMessage'] ? 16 : 0),
                  ),
                  color: widget.messages[index]['isUserMessage']
                      ? Color(0xffB3FD14)
                      : Colors.grey.shade900.withOpacity(0.8),
                ),
                constraints: BoxConstraints(maxWidth: w * 2 / 3),
                child: Text(widget.messages[index]['message'].text.text[0],style: TextStyle(
                  color: widget.messages[index]['isUserMessage']?Color(0xff242426) :Color(0xff797979),
                  fontSize: 20,
                  fontFamily: 'Gelix',
                ),),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (_, i) => Padding(padding: EdgeInsets.only(top: 10)),
      itemCount: widget.messages.length,
    );
  }
}
