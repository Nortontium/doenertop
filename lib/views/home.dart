import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doenertop/components/responsive_text.dart';
import 'package:doenertop/views/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'navigation.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String uid = "";

  void _pushNavigation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Navigation(),
      ),
    );
  }

  void _pushProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Profile(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    uid = _auth.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[40],
        elevation: 0.0,
        title: ResponsiveText(
          text: "DönerTop",
          style: const TextStyle(
            fontSize: 36,
            color: Colors.green,
            fontFamily: "DelaGothicOne",
          ),
        ),
        leading: GestureDetector(
          onTap: _pushNavigation,
          child: Container(
            margin: const EdgeInsets.all(10),
            width: 30,
            height: 30,
            child: SvgPicture.asset(
              "assets/icons/list.svg",
              width: 20,
              height: 20,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _pushProfile,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: 37,
              height: 37,
              child: SvgPicture.asset(
                "assets/icons/person.svg",
                width: 20,
                height: 20,
              ),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Favorites",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
            SizedBox(
              height: 250,
              child: Favourites(),
            ),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class Favourites extends StatefulWidget {
  const Favourites({super.key});
  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doenershops')
            .where('favorites', arrayContains: _auth.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          if (!snapshot.hasData) {
            return Container(
              margin: const EdgeInsets.all(10),
              height: 200,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.size,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
                  snapshot.data!.docs[index].data()! as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.all(10),
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Image.asset(
                      data['image'],
                      fit: BoxFit.cover,
                      width: 300,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 150,
                        width: 300,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.grey.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data['address'],
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Roboto",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
