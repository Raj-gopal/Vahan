import 'package:dialog_flowtter_plus/dialog_flowtter_plus.dart';
import 'package:flutter/material.dart';
import 'package:vahan/screen/Messages.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  late DialogFlowtter dialogFlowtter;
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    // Initialize DialogFlowtter with credentials from the assets
    DialogFlowtter.fromFile().then((instance) {
      dialogFlowtter = instance;
      print("DialogFlowtter initialized successfully.");
    }).catchError((error) {
      print("Error initializing DialogFlowtter: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text ('Chat with VAHA',
          style: TextStyle(
            color: Color(0xff797979),
            fontSize: 20,
            fontFamily: 'Gelix',
            fontWeight: FontWeight.w500
          ),),),
      body: Container(
        child: Column(
          children: [
            Expanded(child: MessagesScreen(messages: messages)),
            Container(
              margin:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16)
              ),
              
              child: Row(
                children: [
                  Expanded(
                      child: TextField(
                        cursorColor: Color(0xffB3FD14),
                        style: TextStyle(
                          color: Color(0xff797979),
                          fontSize: 20,
                          fontFamily: 'Gelix',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type your message here',
                          hintStyle: TextStyle(
                            color: Color(0xff797979),
                            fontSize: 20,
                            fontFamily: 'Gelix',
                          ),
                          filled: true,
                          fillColor: Color(0xff242426),
                          border: OutlineInputBorder(

                            borderRadius: BorderRadius.circular(16.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: _controller,

                      )),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                   // margin:  EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    padding: EdgeInsets.symmetric( vertical: 8,horizontal: 8),
                    decoration: BoxDecoration(
                      color: Color(0xff242426),
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Center(
                      child: IconButton(
                          onPressed: () {
                            sendMessage(_controller.text);
                            _controller.clear();
                          },
                          icon: Icon(Icons.send,color: Color(0xffB3FD14),)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Send a message to the DialogFlowtter and receive the response
  sendMessage(String text) async {
    if (text.isEmpty) {
      print('Message is empty');
    } else {
      setState(() {
        addMessage(Message(text: DialogText(text: [text])), true);
      });

      // Send the message to DialogFlowtter for intent detection
      DetectIntentResponse response = await dialogFlowtter.detectIntent(
          queryInput: QueryInput(text: TextInput(text: text)));
      if (response.message == null) {
        print('No response from DialogFlowtter');
        return;
      }

      // Log the response
      print("Received response: ${response.message}");

      // Add the response message to the list of messages
      setState(() {
        addMessage(response.message!);
      });
    }
  }

  // Add a message to the list of messages
  addMessage(Message message, [bool isUserMessage = false]) {
    messages.add({'message': message, 'isUserMessage': isUserMessage});
  }
}
