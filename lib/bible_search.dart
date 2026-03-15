import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bible_data.dart';
import 'bible_home.dart';

class BibleSearchScreen extends StatefulWidget {
  final List<BibleBook> allBooks;
  final String Function(String) getTeluguName;

  const BibleSearchScreen({
    super.key,
    required this.allBooks,
    required this.getTeluguName,
  });

  @override
  State<BibleSearchScreen> createState() => _BibleSearchScreenState();
}

class _BibleSearchScreenState extends State<BibleSearchScreen> {
  String searchQuery = "";
  List<Map<String, dynamic>> searchResults = [];

  void _performSearch(String query) {
    setState(() {
      searchQuery = query;
      searchResults.clear();

      if (query.trim().isEmpty) return;

      for (var book in widget.allBooks) {
        for (var chapter in book.chapters) {
          for (var verse in chapter.verses) {
            // వెతికిన పదం ఉందో లేదో చెక్ చేస్తుంది (case-insensitive)
            if (verse.text.toLowerCase().contains(query.toLowerCase())) {
              searchResults.add({
                'book': book,
                'chapter': chapter,
                'verse': verse,
              });
            }
          }
        }
      }
    });
  }

  // సెర్చ్ చేసిన పదాన్ని హైలైట్ చేసే లాజిక్
  List<TextSpan> _getHighlightedText(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];

    final String lowerText = text.toLowerCase();
    final String lowerQuery = query.toLowerCase();

    List<TextSpan> spans = [];
    int start = 0;
    int indexOfMatch;

    while ((indexOfMatch = lowerText.indexOf(lowerQuery, start)) != -1) {
      if (indexOfMatch > start) {
        spans.add(TextSpan(text: text.substring(start, indexOfMatch)));
      }
      // హైలైట్ అయ్యే పదం డిజైన్
      spans.add(
        TextSpan(
          text: text.substring(indexOfMatch, indexOfMatch + query.length),
          style: GoogleFonts.balooTammudu2(
            backgroundColor: const Color(0xFFE5A853).withOpacity(0.3),
            color: const Color(0xFFE5A853),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = indexOfMatch + query.length;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: TextField(
          autofocus: true,
          style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18),
          cursorColor: const Color(0xFFE5A853),
          decoration: InputDecoration(
            hintText: "బైబిల్ లో వెతకండి...",
            hintStyle: GoogleFonts.balooTammudu2(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: searchResults.isEmpty && searchQuery.isNotEmpty
          ? Center(
              child: Text(
                "ఫలితాలు లేవు", 
                style: GoogleFonts.balooTammudu2(color: Colors.white, fontSize: 18)
              )
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final result = searchResults[index];
                final BibleBook book = result['book'];
                final Chapter chapter = result['chapter'];
                final Verse verse = result['verse'];

                return InkWell(
                  onTap: () {
                    // రిజల్ట్ పై క్లిక్ చేస్తే రీడింగ్ స్క్రీన్ కి వెళ్తుంది
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BibleReadingScreen(
                          book: book,
                          chapter: chapter,
                          initialVerse: verse,
                          teluguBookName: widget.getTeluguName(book.bname),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2A2A2A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${widget.getTeluguName(book.bname)} ${chapter.cnumber}:${verse.vnumber}",
                          style: GoogleFonts.balooTammudu2(
                            color: const Color(0xFFE5A853),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.balooTammudu2(
                              color: const Color(0xFFE0E0E0), 
                              fontSize: 18, 
                              height: 1.5
                            ),
                            children: _getHighlightedText(verse.text, searchQuery),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
