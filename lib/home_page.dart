import 'package:chat_bot/message.dart';
import 'package:chat_bot/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Message> _messages = [
    const Message(text: 'Hi', isUser: true),
    const Message(text: 'Hello, what\'s up?', isUser: false),
    const Message(text: 'Greate and you?', isUser: true),
    const Message(text: 'Excellent', isUser: false),
  ];
  late final TextEditingController textEditingController;
  late final ScrollController scrollController;
  late final FocusNode focusNode;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    scrollController = ScrollController();
    focusNode = FocusNode();
    focusNode.addListener(() async {
      if (focusNode.hasFocus) {
        await Future.delayed(const Duration(milliseconds: 500), scrollToEnd);
      }
    });
  }

  void scrollToEnd() async {
    await Future.delayed(const Duration(milliseconds: 150), () {
      scrollController.position.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeIn);
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> callGemini() async {
    try {
      if (textEditingController.text.isNotEmpty) {
        final message = textEditingController.text.trim();
        setState(() {
          _messages.add(Message(text: message, isUser: true));
          isLoading = true;
        });
        textEditingController.clear();
        scrollToEnd();

        final model = GenerativeModel(
          model: 'gemini-1.5-flash-latest',
          apiKey: dotenv.env['GOOGLE_API_KEY']!,
        );
        final prompt = message;
        final content = [Content.text(prompt)];
        final response = await model.generateContent(content);

        setState(() {
          _messages.add(Message(text: response.text ?? '', isUser: false));
          isLoading = false;
        });
        scrollToEnd();
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            Image.asset(
              'assets/gpt-robot.png',
              scale: 1.5,
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('Gemini GPT')
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) => IconButton(
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                icon: const Icon(Icons.dark_mode_rounded)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isUser
                            ? Colors.blueAccent
                            : Colors.grey[300],
                        borderRadius: message.isUser
                            ? const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              )
                            : const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _messages.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 8,
            ),
            child: TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                suffixIcon: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: isLoading
                      ? null
                      : () async {
                          await callGemini();
                        },
                  child: isLoading
                      ? Container(
                          padding: const EdgeInsets.all(12),
                          width: 10,
                          height: 10,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                ),
                hintText: 'Write your message',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
