import 'package:flutter/material.dart';

import "item_detail.dart";
import 'order_history.dart';

class RedeemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Redeem Page'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Text(
          'Redeeming your item... 🎉',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
        ),
      ),
    );
  }
}

class MiniStorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //shows an alert dialog telling user they are viewing a prototype of the mini-store

    return Scaffold(
      appBar: AppBar(
        title: Text("Mini-Store 🛍️"),
        centerTitle: true,
        backgroundColor: Colors.pinkAccent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 1.0),
            child: Center(
              child: Row(
                children: [
                  Text(
                    '1000',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.monetization_on, color: Colors.yellowAccent),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (String value) {
              if (value == 'Order History') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderHistoryPage(),
                  ),
                );
              } else if (value == 'My Store') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyStorePage(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Available Coins: 1000', 'Order History', 'My Store'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  enabled: choice != 'Available Coins: 1000',
                  child: Text(choice),
                );
              }).toList();
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: Image.asset("assets/images/avatar1.png").image,
            ),
          ),
          //show available coins
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Welcome to My Mini-Store! 💖",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            //show available coins
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 5),
                Text(
                  'You have : 1000',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.monetization_on, color: Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            //huh, what to show here? 🤔 yeah, list of items just use this interesting builder that I found online
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 6,
              itemBuilder: (context, index) {
                return StoreItemList(
                  itemName: "Item ${index + 1}",
                  itemPrice: "${(index + 1) * 50} Coins",
                  itemImage: 'https://via.placeholder.com/150',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class StoreItemList extends StatelessWidget {
  final String itemName;
  final String itemPrice;
  final String itemImage;

  StoreItemList({
    required this.itemName,
    required this.itemPrice,
    required this.itemImage,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //go to item detail page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailPage(
              itemName: itemName,
              itemPrice: itemPrice,
              itemImage: itemImage,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                itemImage,
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    itemName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    itemPrice,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    //redeem
                    return AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text(
                          'Are you sure you want to redeem $itemName for $itemPrice?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RedeemPage(),
                              ),
                            );
                          },
                          child: Text('Sure'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(Icons.redeem, color: Colors.pinkAccent),
              tooltip: "Redeem",
            ),
          ],
        ),
      ),
    );
  }
}

class MyStorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Store'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Text(
          'Manage store items here.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }
}
