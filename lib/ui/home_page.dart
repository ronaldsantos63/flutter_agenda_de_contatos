import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_agenda_de_contatos/helpers/contact_helper.dart';
import 'package:flutter_agenda_de_contatos/models/contact.dart';
import 'package:flutter_agenda_de_contatos/ui/contact_page.dart';

enum OrderOptions { orderaz, orderza }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper _helper = ContactHelper();
  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda de Contatos"),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                  const PopupMenuItem(
                    child: Text("Ordenar de A-Z"),
                    value: OrderOptions.orderaz,
                  ),
                  const PopupMenuItem(
                    child: Text("Ordenar de Z-A"),
                    value: OrderOptions.orderza,
                  ),
                ],
            onSelected: _orderList,
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _buildContactCard(context, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        tooltip: "Adicionar contato",
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, int index) {
    final contact = contacts[index];
    final imgDefault = AssetImage("assets/images/user.png");
    final img = File(contact.image ?? '');

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          backgroundImage: img.existsSync() ? FileImage(img) : imgDefault,
        ),
        title: Text(
          contact.name ?? '',
          overflow: TextOverflow.ellipsis,
          textScaleFactor: 1,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              contact.email ?? '',
              overflow: TextOverflow.ellipsis,
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              contact.phone ?? '',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          _showOptions(context, contact);
        },
      ),
    );
  }

  void _showOptions(BuildContext context, Contact contact) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Ligar",
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () {
                          launch("tel:${contact.phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Editar",
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contact);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Excluir",
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () {
                          setState(() {
                            _helper.deleteContact(contact.id);
                            contacts.remove(contact);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await _helper.updateContact(recContact);
      } else {
        await _helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    _helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _orderList(OrderOptions result) {
    switch (result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {
      // Informe o flutter que a lista foi ordenada
    });
  }
}
