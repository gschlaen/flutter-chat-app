import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'package:chat_app/models/mensajes_response.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widgets/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  final List<ChatMessage> _messages = [];

  bool _isWriting = false;

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  @override
  void initState() {
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);
    super.initState();

    socketService.socket.on('mensaje-personal', _escuchandoMensaje);

    _cargarHistorial(chatService.targetUser.uid);
  }

  void _cargarHistorial(String userID) async {
    List<Mensaje> chat = await chatService.getChat(userID);

    final history = chat.map((m) => ChatMessage(
          text: m.mensaje,
          uid: m.de,
          animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 0))..forward(),
        ));

    setState(() {
      _messages.insertAll(0, history);
    });
  }

  void _escuchandoMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
        text: payload['mensaje'],
        uid: payload['de'],
        animationController: AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        ));
    setState(() {
      _messages.insert(0, message);
    });
    // Para hechar a andar la animacion
    message.animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final targetUser = chatService.targetUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Column(
          children: [
            CircleAvatar(
              child: Text(targetUser.name.substring(0, 2), style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.blue[100],
              maxRadius: 14,
            ),
            const SizedBox(height: 3),
            Text(targetUser.name, style: const TextStyle(color: Colors.black87, fontSize: 12))
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _messages[i],
                reverse: true,
              ),
            ),
            const Divider(height: 1),

            //TODO: Caja de texto
            Container(
              color: Colors.white,
              child: _inputChat(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputChat() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: (value) {
                  _handleSubmit(value);
                },
                onChanged: (value) {
                  setState(() {
                    if (value.trim().isNotEmpty) {
                      _isWriting = true;
                    } else {
                      _isWriting = false;
                    }
                  });
                },
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send message',
                ),
                focusNode: _focusNode,
              ),
            ),
            //Send Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Platform.isIOS
                  ? CupertinoButton(
                      child: const Text('Send'),
                      onPressed: _isWriting ? () => _handleSubmit(_textController.text.trim()) : null,
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IconTheme(
                        data: IconThemeData(color: Colors.blue[400]),
                        child: IconButton(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          icon: const Icon(Icons.send),
                          onPressed: _isWriting ? () => _handleSubmit(_textController.text.trim()) : null,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  _handleSubmit(String text) {
    if (text.isEmpty) return;
    //Para no perder el foco en IOS cada vez que se envia un mje
    _textController.clear();
    _focusNode.requestFocus();

    final newMessage = ChatMessage(
      text: text,
      uid: authService.usuario.uid,
      animationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      ),
    );
    _messages.insert(0, newMessage);
    //Indica que la animacion comience cdo se crea el mje
    newMessage.animationController.forward();
    setState(() {
      _isWriting = false;
    });

    socketService.emit('mensaje-personal', {
      'de': authService.usuario.uid,
      'para': chatService.targetUser.uid,
      'mensaje': text,
    });
  }

  @override
  void dispose() {
    // Al salir de la pantalla se borra cada uno de los animationController para no ocupar memoria
    for (ChatMessage message in _messages) {
      message.animationController.dispose();
    }

    // Cancela la escucha del socket
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
