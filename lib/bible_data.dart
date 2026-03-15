import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

class Verse {
  final String vnumber;
  final String text;
  Verse({required this.vnumber, required this.text});
}

class Chapter {
  final String cnumber;
  final List<Verse> verses;
  Chapter({required this.cnumber, required this.verses});
}

class BibleBook {
  final String bnumber;
  final String bname;
  final List<Chapter> chapters;
  BibleBook({required this.bnumber, required this.bname, required this.chapters});
}

// XML ఫైల్ ని చదివే ఫంక్షన్
Future<List<BibleBook>> loadBibleData() async {
  try {
    final xmlString = await rootBundle.loadString('assets/bible.xml');
    final document = XmlDocument.parse(xmlString);
    final books = <BibleBook>[];

    for (final bookElement in document.findAllElements('BIBLEBOOK')) {
      final bnumber = bookElement.getAttribute('bnumber') ?? '';
      final bname = bookElement.getAttribute('bname') ?? '';
      final chapters = <Chapter>[];

      for (final chapterElement in bookElement.findAllElements('CHAPTER')) {
        final cnumber = chapterElement.getAttribute('cnumber') ?? '';
        final verses = <Verse>[];

        for (final verseElement in chapterElement.findAllElements('VERS')) {
          final vnumber = verseElement.getAttribute('vnumber') ?? '';
          final text = verseElement.innerText.trim();
          verses.add(Verse(vnumber: vnumber, text: text));
        }
        chapters.add(Chapter(cnumber: cnumber, verses: verses));
      }
      books.add(BibleBook(bnumber: bnumber, bname: bname, chapters: chapters));
    }
    return books;
  } catch (e) {
    print("Error loading XML: $e");
    return [];
  }
}
