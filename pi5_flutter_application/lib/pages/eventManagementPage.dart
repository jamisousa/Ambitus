// ignore_for_file: file_names, camel_case_types

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pi5_flutter_application/pages/confirmPage.dart';
import 'package:pi5_flutter_application/pages/userEventsPage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';

class eventManagementPage extends StatefulWidget {
  const eventManagementPage({super.key});

  @override
  State<eventManagementPage> createState() => _eventManagementPageState();
}

class _eventManagementPageState extends State<eventManagementPage> {
  //Alterar valores ao criar novo evento ou atualizar existente
  bool isUpdating = false;
  var _controllerTitle;
  var _controllerDescription;
  var _controllerAddress;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  String dropdownValue = 'Reciclagem'; // valor padrão selecionado
  List<String> options = [
    'Reciclagem',
    'Reflorestamento',
    'Limpeza de ambientes',
    'Conscientização e educação',
    'Conservação de espécies'
  ];
  TextEditingController _textFieldController = TextEditingController();

  //Seletor de data
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  //Seletor de hora
  DateTime _selectedTime = DateTime.now();
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedTime),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = DateTime(
          _selectedTime.year,
          _selectedTime.month,
          _selectedTime.day,
          picked.hour,
          picked.minute,
        );
        _timeController.text = DateFormat('HH:mm').format(_selectedTime);
      });
    }
  }

  //Dropdown
  void _showPicker(BuildContext context) {
    showMaterialScrollPicker(
      context: context,
      title: 'Selecione uma opção',
      headerColor: Color.fromARGB(255, 47, 95, 67),
      headerTextColor: Color.fromARGB(255, 47, 95, 67),
      selectedItem: dropdownValue,
      items: options,
      onChanged: (value) {
        setState(() {
          dropdownValue = value;
          _textFieldController.text = value;
        });
      },
      confirmText: 'Confirmar',
      cancelText: 'Cancelar',
      // Define a posição do menu suspenso no centro da tela
      showDivider: false,
    );
  }

  //Uploader de imagem
  final picker = ImagePicker();
  File? _imageFile;

  Future<void> _getImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } else if (status.isDenied) {
      // Processo caso usuário negue a permissão
      // ignore: use_build_context_synchronously
      var dialogResult = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Permissão necessária'),
          content: const Text(
              'O aplicativo precisa da permissão de acesso à galeria para continuar.'),
          actions: [
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.pop(context, false),
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        ),
      );

      if (dialogResult == true) {
        // Usuário liberou a permissão
        var newStatus = await Permission.photos.request();
        if (newStatus.isGranted) {
          final pickedFile =
              await picker.pickImage(source: ImageSource.gallery);
          if (pickedFile != null) {
            setState(() {
              _imageFile = File(pickedFile.path);
            });
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          height: double.maxFinite,
          width: double.maxFinite,
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUpdating
                                  ? "Atualizar evento"
                                  : "Criar novo evento",
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const userEventsPage()));
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        "assets/images/cd-boyicon.jpg"))),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 0, bottom: 0.0),
                      child: Column(
                        children: [
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z ]+$')),
                              LengthLimitingTextInputFormatter(
                                  100), //Aceitar apenas letras e números, máx 100 caracteres
                            ],
                            controller: _controllerTitle,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 6, 12, 6),
                                labelText: "Título",
                                hintText: "Título do seu evento",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0))),
                            onChanged: (value) {
                              //To do
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z ]+$')),
                              LengthLimitingTextInputFormatter(
                                  250), //Aceitar apenas letras e números, máx 100 caracteres
                            ],
                            controller: _controllerDescription,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 6, 12, 6),
                                labelText: "Descrição",
                                hintText: "Uma breve descrição sobre o evento",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0))),
                            onChanged: (value) {
                              //To do
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[a-zA-Z ]+$')),
                              LengthLimitingTextInputFormatter(300),
                            ],
                            controller: _controllerAddress,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 6, 12, 6),
                                labelText: "Local do evento",
                                hintText: "Endereço onde acontecerá o evento",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0))),
                            onChanged: (value) {
                              //To do
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            onTap: () {
                              _selectDate(context);
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: _dateController,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 6, 12, 6),
                                labelText: "Data do evento",
                                hintText: "DD/MM/YYYY",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0))),
                            onChanged: (value) {
                              //To do
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            onTap: () {
                              _selectTime(context);
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            controller: _timeController,
                            decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.fromLTRB(12, 6, 12, 6),
                                labelText: "Hora",
                                hintText: "00:00",
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0))),
                            onChanged: (value) {
                              //To do
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textFieldController,
                                  decoration: InputDecoration(
                                    labelText: 'Selecione uma opção',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.arrow_drop_down),
                                  ),
                                  onTap: () {
                                    // Fecha o teclado virtual e abre o menu suspenso
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    _showPicker(context);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Card(
                            child: GestureDetector(
                              onTap: _getImage,
                              child: InkWell(
                                child: _imageFile == null
                                    ? Container(
                                        height: 150,
                                        child: const Center(
                                          child: Text('Selecione uma imagem'),
                                        ),
                                      )
                                    : Image.file(_imageFile!),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ListTile(
                            leading: Switch(
                              value: true,
                              onChanged: (bool value) {
                                //To do
                              },
                            ),
                            title: const Text('Permitir inscrições'),
                            subtitle: const Text(
                                'Ative essa opção caso ainda esteja aceitando inscrições de usuários no evento.'),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SizedBox(
                                width: 300,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const confirmPage()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xff606c38),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  child: Text(
                                    isUpdating ? "Atualizar" : "Criar",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ],
          )),
    );
  }
}