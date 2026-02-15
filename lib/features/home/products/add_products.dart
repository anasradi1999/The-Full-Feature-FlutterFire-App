import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? productData;

  const AddProductPage({super.key, this.productData});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedCategoryId;
  bool isLoading = false;

  File? selectedImage;
  final ImagePicker picker = ImagePicker();

  final List<Map<String, dynamic>> categories = [
    {'id': 'phones', 'name': 'هواتف'},
    {'id': 'laptops', 'name': 'لابتوبات'},
    {'id': 'fashion', 'name': 'ملابس'},
    {'id': 'shoes', 'name': 'أحذية'},
    {'id': 'electronics', 'name': 'إلكترونيات'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.productData != null) {
      nameController.text = widget.productData!['name'];
      priceController.text = widget.productData!['price'].toString();
      selectedCategoryId = widget.productData!['categoryId'];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String> uploadImage(String productId) async {
    final extension = path.extension(selectedImage!.path);
    final fileName = '$productId${DateTime.now().millisecondsSinceEpoch}$extension';
    final ref = FirebaseStorage.instance.ref().child('images').child(fileName);

    await ref.putFile(selectedImage!);
    return await ref.getDownloadURL();
  }

  Future<void> saveProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    setState(() => isLoading = true);
    final selectedCategory = categories.firstWhere((c) => c['id'] == selectedCategoryId);

    try {
      if (widget.productData != null) {
        // تعديل المنتج
        String imageUrl = widget.productData!['imageUrl'] ?? "none";

        if (selectedImage != null) {
          if (imageUrl != "none") {
            await FirebaseStorage.instance.refFromURL(imageUrl).delete();
          }
          imageUrl = await uploadImage(widget.productData!['id']);
        }

        await FirebaseFirestore.instance.collection('products').doc(widget.productData!['id']).update({
          'name': nameController.text.trim(),
          'price': double.parse(priceController.text),
          'categoryId': selectedCategory['id'],
          'categoryName': selectedCategory['name'],
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تعديل المنتج ✅')),
        );
      } else {
        // إضافة المنتج
        final docRef = FirebaseFirestore.instance.collection('products').doc();
        String imageUrl = "none";

        if (selectedImage != null) {
          imageUrl = await uploadImage(docRef.id);
        }

        await docRef.set({
          'id': docRef.id,
          'name': nameController.text.trim(),
          'price': double.parse(priceController.text),
          'categoryId': selectedCategory['id'],
          'categoryName': selectedCategory['name'],
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
        });

        // 🔔 إضافة إشعار تلقائي عند إضافة المنتج
        await FirebaseFirestore.instance.collection('notifications').add({
          'title': 'تمت إضافة منتج جديد',
          'body': '${nameController.text.trim()}',
          'isRead': false,
          'createdAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت إضافة المنتج ✅')),
        );
      }

      Navigator.pop(context, true); // نرجع true لإعلام الهوم أن المنتج أضيف
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.productData != null;

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(isEditing ? 'تعديل المنتج' : 'إضافة منتج',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // الصورة
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('الكاميرا'),
                          onTap: () {
                            pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo),
                          title: const Text('المعرض'),
                          onTap: () {
                            pickImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(selectedImage!, fit: BoxFit.cover),
                )
                    : const Center(
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'اسم المنتج',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'السعر',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedCategoryId,
              items: categories
                  .map((category) => DropdownMenuItem<String>(
                value: category['id'],
                child: Text(category['name']),
              ))
                  .toList(),
              onChanged: (value) => setState(() => selectedCategoryId = value),
              decoration: InputDecoration(
                labelText: 'التصنيف',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: isLoading ? null : saveProduct,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEditing ? 'تعديل المنتج' : 'إضافة المنتج',
                    style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}