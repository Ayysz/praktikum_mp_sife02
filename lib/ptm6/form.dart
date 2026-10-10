import 'package:flutter/material.dart';

class LearnForm extends StatefulWidget {
  const LearnForm({super.key});

  @override
  State<LearnForm> createState() => _LearnFormState();
}

class _LearnFormState extends State<LearnForm> {

  final _formKey = GlobalKey<FormState>();
  String? jenisKelamin;
  List<Map<String, dynamic>> hobi = [
    {
      "nama": "Membaca",
      "pilihan": false
    },
    {
      "nama": "Olahraga",
      "pilihan": false
    },
    {
      "nama": "Musik",
      "pilihan": false
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materi Form'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Container(
                    color:  Colors.green,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                    'Form Mahasiswa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama gaboleh kosong';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan Nama Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email gaboleh kosong';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    icon: Icon(Icons.email),
                    labelText: 'Email',
                    hintText: 'Masukkan Email Anda',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "Jenis Kelamin",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                RadioGroup(
                  groupValue: jenisKelamin,
                  onChanged: (value){
                    setState(() {
                      jenisKelamin = value.toString();
                    });
                  }, 
                  child: Column(
                    children: [
                      RadioListTile(
                        title: const Text('Laki-Laki'),
                        value: 'LK',
                      ),
                      RadioListTile(
                        title: const Text('Perempuan'),
                        value: 'Perempuan',
                      ),
                    ],
                  )
                ),
                SizedBox(height: 30),
                Text(
                  "Hobi",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: hobi.length,
                  itemBuilder: (context, index) {
                    final hobiItem = hobi[index];
                    return CheckboxListTile(
                      title: Text(hobiItem['nama']),
                      value: hobiItem['pilihan'],
                      onChanged: (value) {
                        setState(() {
                          hobiItem['pilihan'] = value!;
                        });
                      },
                    );
                  },
                )
              ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data berhasil disimpan'),
              ),
            );
          }
        },
        label: const Text('Submit'),
        icon: const Icon(Icons.save),
      ),
    );    
  }
}