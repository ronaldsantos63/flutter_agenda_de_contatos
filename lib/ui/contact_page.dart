import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_agenda_de_contatos/models/contact.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final imgDefault = "assets/images/user.png";

  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _phoneController = new TextEditingController();

  final nameFocus = new FocusNode();
  final emailFocus = new FocusNode();
  final phoneFocus = new FocusNode();

  Contact _editedContact;
  bool _userEdited = false;
  Future<File> _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = new Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _emailController.text = _editedContact.email;
      _phoneController.text = _editedContact.phone;
    }
    _imageFile = Future.value(File(_editedContact.image ?? ''));
  }

  Widget _previewImage() {
    return FutureBuilder<File>(
        future: _imageFile,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(imgDefault),
                backgroundColor: Colors.transparent,
              );
              break;
            case ConnectionState.waiting:
              return CircularProgressIndicator();
              break;
            case ConnectionState.active:
//              return Text("Ativo");
              break;
            case ConnectionState.done:
              if (snapshot.data != null && snapshot.data.path != '') {
                _editedContact.image = snapshot.data.path;
                return CircleAvatar(
                  radius: 80,
                  backgroundImage: FileImage(snapshot.data),
                  backgroundColor: Colors.transparent,
                );
              }

              return CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage(imgDefault),
                backgroundColor: Colors.transparent,
              );
              break;
          }
        });
  }

  void _onImageButtonPressed(ImageSource source) {
    _userEdited = true;
    setState(() {
      _imageFile = ImagePicker.pickImage(source: source);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(_editedContact.name ?? 'Novo Contato'),
        ),
        backgroundColor: Colors.grey.shade300,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: _previewImage(),
                onTap: () {
                  _showOptions(context);
                },
              ),
              TextField(
                autofocus: true,
                controller: _nameController,
                focusNode: nameFocus,
                cursorWidth: 3,
                cursorColor: Colors.green.shade900,
                style: TextStyle(fontSize: 20, color: Colors.green.shade700),
                maxLength: 100,
                autocorrect: true,
                textInputAction: TextInputAction.next,
                enableInteractiveSelection: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                    ),
                    labelText: "Nome *",
                    hintText: "Nome completo"),
                onSubmitted: (text) {
                  FocusScope.of(context).requestFocus(emailFocus);
                },
                onChanged: (name) {
                  _userEdited = true;
                  setState(() {
                    _editedContact.name = name;
                  });
                },
              ),
              TextField(
                controller: _emailController,
                focusNode: emailFocus,
                cursorWidth: 3,
                cursorColor: Colors.green.shade900,
                style: TextStyle(fontSize: 20, color: Colors.green.shade900),
                maxLength: 100,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email *",
                    hintText: "fulano@gmail.com"),
                onSubmitted: (text) {
                  FocusScope.of(context).requestFocus(phoneFocus);
                },
                onChanged: (email) {
                  _userEdited = true;
                  _editedContact.email = email;
                },
              ),
              TextField(
                controller: _phoneController,
                focusNode: phoneFocus,
                cursorWidth: 3,
                cursorColor: Colors.green.shade900,
                style: TextStyle(fontSize: 20, color: Colors.green.shade900),
                maxLength: 15,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                enableInteractiveSelection: true,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone),
                    labelText: "Telefone",
                    prefixText: "+55 ",
                    hintText: "XX999999999"),
                inputFormatters: <TextInputFormatter>[
                  WhitelistingTextInputFormatter.digitsOnly
                ],
                onSubmitted: (text) {
                  phoneFocus.unfocus();
                },
                onChanged: (phone) {
                  _userEdited = true;
                  _editedContact.phone = phone;
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact.name != null && _editedContact.name.isNotEmpty) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(nameFocus);
            }
          },
          child: Icon(
            Icons.save,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar alterações?"),
              content: Text("Se sair as alterações serão perdidas!"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  _showOptions(BuildContext context) {
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
                          "Galeria",
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _onImageButtonPressed(ImageSource.gallery);
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: FlatButton(
                        child: Text(
                          "Camera",
                          style: TextStyle(color: Colors.green, fontSize: 20),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _onImageButtonPressed(ImageSource.camera);
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
}
