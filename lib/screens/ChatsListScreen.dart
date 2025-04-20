import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat/screens/Status_screen.dart';
import 'package:chat/screens/call_screen.dart';

class ChatsListScreen extends StatefulWidget {
  final String token;

  const ChatsListScreen({super.key, required this.token});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  List<dynamic> chats = [];
  bool isLoading = true;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    fetchChats();
  }

  Future<void> fetchChats() async {
    final url = Uri.parse("https://wavlo.azurewebsites.net/api/chat/chats");
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        chats = jsonDecode(response.body);
        isLoading = false;
      });
    } else {
      print("❌ Failed to load chats: ${response.body}");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load chats")));
      setState(() {
        isLoading = false;
      });
    }
  }

  void toggleFab() {
    setState(() {
      _fabExpanded = !_fabExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Set length to 3 for 3 tabs
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    buildChatList(), // Display Chats tab
                    const StatusScreen(), // Display Status tab
                    const CallScreen(), // Display Call tab
                  ],
                ),
        floatingActionButton: buildFloatingActionButton(),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      title: buildTitle(),
      actions: [
        const Icon(Icons.search, color: Color(0xffF37C50)),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xffF37C50)),
          onSelected: (value) {
            if (value == 'logout') {
              // هنا بنروح لصفحة اللوجين
              Navigator.of(context).pushReplacementNamed('/welcome');
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Text('Logout'),
                ),
              ],
        ),
        const SizedBox(width: 10),
      ],

      bottom: buildTabBar(),
    );
  }

  Text buildTitle() {
    return Text(
      "Wavlo",
      style: TextStyle(
        fontSize: 22,
        color: Color(0xffF37C50),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  PreferredSize buildTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(68),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        child: TabBar(
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.black87,
          indicator: BoxDecoration(
            color: Color(0xffF37C50),
            borderRadius: BorderRadius.circular(30),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(child: Center(child: Text("All Chats"))),
            Tab(child: Center(child: Text("Status"))),
            Tab(child: Center(child: Text("Call"))),
          ],
        ),
      ),
    );
  }

  Widget buildChatList() {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(
              'https://randomuser.me/api/portraits/men/1.jpg',
            ),
          ),
          title: Text(chat['name'] ?? "Chat Name"),
          subtitle: Text(chat['company'] ?? "Company Name"),
          trailing: buildTrailing(chat),
          onTap: () {
            // Add navigation functionality here later
          },
        );
      },
    );
  }

  Widget buildTrailing(Map<String, dynamic> chat) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(chat['time'] ?? 'No time'),
        if (chat['unread'] != null && chat['unread'] > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xffF37C50),
              shape: BoxShape.circle,
            ),
            child: Text(
              chat['unread'].toString(),
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Column buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabExpanded) ...[
          buildMiniFab(Icons.person_add, 'fab1'),
          buildMiniFab(Icons.group, 'fab2'),
          buildMiniFab(Icons.add, 'fab3'),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          backgroundColor: Color(0xffF37C50),
          onPressed: toggleFab,
          shape: const CircleBorder(),
          child: Icon(
            _fabExpanded ? Icons.close : Icons.add,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  FloatingActionButton buildMiniFab(IconData icon, String heroTag) {
    return FloatingActionButton(
      heroTag: heroTag,
      mini: true,
      backgroundColor: Color(0xffF37C50),
      onPressed: () {},
      child: Icon(icon, color: Colors.white),
    );
  }
}
