import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chat/screens/status_screen.dart';
import 'package:chat/screens/call_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> chats = [];
  bool isLoading = true;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    print("📲 Token received: ${widget.token}");
    fetchChats();
  }

  Future<void> fetchChats() async {
    final url = Uri.parse("https://wavlo.azurewebsites.net/api/chat/chats");

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print("✅ Chats loaded: ${jsonData.length} chats");

        setState(() {
          chats = jsonData;
          isLoading = false;
        });
      } else {
        print("❌ Failed to load chats: ${response.body}");
        setState(() => isLoading = false);
        showError("Failed to load chats");
      }
    } catch (e) {
      print("💥 Exception while fetching chats: $e");
      setState(() => isLoading = false);
      showError("Something went wrong. Try again later.");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void toggleFab() {
    setState(() {
      _fabExpanded = !_fabExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    chats.isEmpty ? buildEmptyChatList() : buildChatList(),
                    const StatusScreen(),
                    const CallScreen(),
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
      title: const Text(
        "WAVLO",
        style: TextStyle(
          fontSize: 22,
          color: Color(0xffF37C50),
          fontWeight: FontWeight.bold,
          fontFamily: "ADLaMDisplay",
        ),
      ),
      actions: [
        const Icon(Icons.search, color: Color(0xffF37C50)),
        const SizedBox(width: 10),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Color(0xffF37C50)),
          onSelected: (value) {
            if (value == 'logout') {
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(68),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TabBar(
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicator: BoxDecoration(
              color: Color(0xffF37C50),
              borderRadius: BorderRadius.circular(30),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: const [
              Tab(
                child: Center(
                  child: Text(
                    "All Chats",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Tab(
                child: Center(
                  child: Text(
                    "Status",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Tab(
                child: Center(
                  child: Text(
                    "Call",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyChatList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.message_outlined, size: 80, color: Color(0xffF37C50)),
          SizedBox(height: 20),
          Text(
            "Start a New Chat",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffF37C50),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "You can start a conversation with anyone here.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
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
              'https://randomuser.me/api/portraits/men/${index + 1}.jpg',
            ),
          ),
          title: Text(
            chat['name'] ?? "Chat Name",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B222C),
            ),
          ),
          subtitle: Text(
            chat['company'] ?? "Company Name",
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: buildTrailing(chat),
          onTap: () {
            // Navigate to chat details
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

  Widget buildFloatingActionButton() {
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
          backgroundColor: const Color(0xffF37C50),
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
      backgroundColor: const Color(0xffF37C50),
      onPressed: () {
        // Add specific actions here later
      },
      child: Icon(icon, color: Colors.white),
    );
  }
}
