import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'item_screen.dart';
import 'ocr_service.dart';
import 'package:intl/intl.dart';

class ReceiptRecognitionScreen extends StatefulWidget {
  @override
  _ReceiptRecognitionScreenState createState() => _ReceiptRecognitionScreenState();
}

class _ReceiptRecognitionScreenState extends State<ReceiptRecognitionScreen> {
  XFile? _image;
  final OCRService _ocrService = OCRService();
  List<Map<String, dynamic>> items = [];
  DateTime purchaseDate = DateTime.now();

  Future<void> _getImageAndRecognizeText(ImageSource source) async {
    final XFile? pickedImage = await _ocrService.pickImage(source);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
      String text = await _ocrService.getRecognizedText(pickedImage);
      setState(() {
        items = _parseTextToItems(text);
      });
    }
  }

  List<Map<String, dynamic>> _parseTextToItems(String text) {
    return text.split("\n").map((line) {
      return {
        'name': line,
        'quantity': 1,
        'expirationDate': null,
      };
    }).toList();
  }

  void _updateItem(int index, String key, dynamic value) {
    setState(() {
      items[index][key] = value;
    });
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _navigateToItemsScreen() async {
    final updatedItems = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsScreen(
          items: items,
          purchaseDate: purchaseDate,
          onDeleteItem: (index) {
            _deleteItem(index);
          },
          onUpdateItem: _updateItem,
          onUpdatePurchaseDate: (date) => setState(() {
            purchaseDate = date;
          }),
        ),
      ),
    );
    if (updatedItems != null) {
      setState(() {
        items = updatedItems; // 삭제 후 업데이트된 아이템 리스트 반영
      });
    }
  }

  Widget _buildQuantityField(int index) {
    return Row(
      children: [
        Text("수량: "),
        SizedBox(
          width: 40,
          child: TextFormField(
            initialValue: items[index]['quantity'].toString(),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateItem(index, 'quantity', int.tryParse(value) ?? 1),
          ),
        ),
      ],
    );
  }

  Widget _buildButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _getImageAndRecognizeText(ImageSource.camera),
              child: Text("카메라", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.blueAccent,
              ),
            ),
            SizedBox(width: 20),
            ElevatedButton(
              onPressed: () => _getImageAndRecognizeText(ImageSource.gallery),
              child: Text("갤러리", style: TextStyle(fontSize: 18, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: items.isEmpty ? null : _navigateToItemsScreen,
          child: Text("상품 목록", style: TextStyle(fontSize: 18, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            backgroundColor: items.isEmpty ? Colors.grey : Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: AppBar(
        title: Text("영수증 인식"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30, width: double.infinity),
          _buildPhotoArea(),
          _buildButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: FileImage(File(_image!.path)),
          fit: BoxFit.cover,
        ),
      ),
    )
        : Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          "이미지를 선택하세요",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}

