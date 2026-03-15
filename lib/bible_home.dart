import 'package:flutter/material.dart';

class BibleHome extends StatefulWidget {
  const BibleHome({super.key});

  @override
  State<BibleHome> createState() => _BibleHomeState();
}

class _BibleHomeState extends State<BibleHome> {
  // శాంపిల్ బైబిల్ పుస్తకాలు
  final List<String> oldTestamentBooks = [
    'ఆదికాండము (Genesis)',
    'నిర్గమకాండము (Exodus)',
    'లేవీయకాండము (Leviticus)',
    'సంఖ్యాకాండము (Numbers)',
    'ద్వితీయోపదేశకాండము (Deuteronomy)'
  ];

  String _currentSelectedBook = '';

  // బటన్ క్లిక్ చేసినప్పుడు జరిగే ఫంక్షన్
  void _onBookSelected(String bookName) {
    setState(() {
      _currentSelectedBook = bookName;
    });
    
    // స్నాక్‌బార్ ద్వారా ఏ పుస్తకం ఓపెన్ చేసామో చూపించడం
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$bookName ఓపెన్ అవుతుంది...'),
        backgroundColor: Colors.grey[800],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('పరిశుద్ధ గ్రంథము'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // సెలెక్ట్ చేసిన బుక్ పేరు పైన చూపిస్తుంది
          if (_currentSelectedBook.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'ఎంచుకున్నది: $_currentSelectedBook',
                style: const TextStyle(color: Colors.amber, fontSize: 16),
              ),
            ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'పాత నిబంధన',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: oldTestamentBooks.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    title: Text(
                      oldTestamentBooks[index],
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                    onTap: () => _onBookSelected(oldTestamentBooks[index]),
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
