import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:task_8/model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 10,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,

              child: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(
                  "https://www.electroind.com/wp-content/uploads/2019/02/person4-1.jpg",
                ),
              ),
            ),
            Text(
              "CHATS",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.camera)),
          IconButton(onPressed: () {}, icon: Icon(Icons.chat)),
        ],
      ),

      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(10),
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 218, 210, 210),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 5),
                  Text("search", style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(users[index].image),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(users[index].image),
                      ),
                    ),
                    title: Text(users[index].title),
                    subtitle: Text(users[index].subtitle),
                    trailing: Icon(Icons.more_vert),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
