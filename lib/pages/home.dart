import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutrilens/constants/size_conf.dart';
import 'package:permission_handler/permission_handler.dart';
import '../cubit/theme/theme_cubit.dart';
import '../cubit/home/home_cubit.dart'; // NutritionCubit

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;


  String _getMealSuggestion() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 11) {
      return "I will eat this for breakfast";
    } else if (hour < 16) {
      return "I will eat this for lunch";
    } else {
      return "I will eat this for dinner";
    }
  }

  Future<void> _pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        context.read<NutritionCubit>().analyzeImage(_image!);
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Camera permission denied")),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _pickImageFromGallery() async {
    final status = await Permission.photos.request();
    final storageStatus = await Permission.storage.request();

    if (status.isGranted || storageStatus.isGranted) {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        context.read<NutritionCubit>().analyzeImage(_image!);
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery permission denied")),
      );
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrilens"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Tap to Scan Section
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: EdgeInsets.all(AppSizes.paddingMedium),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: AppSizes.iconXLarge,
                      color: theme.colorScheme.onPrimary,
                    ),
                    SizedBox(width: AppSizes.spacingMedium),
                    Text(
                      "Take a picture of your food",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSizes.spacingSmall),

            // 🔹 Show captured/selected image
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                child: Image.file(
                  _image!,
                  height: AppSizes.imageHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            SizedBox(height: AppSizes.spacingMedium),

            // 🔹 Nutrition Results
            BlocBuilder<NutritionCubit, NutritionState>(
              builder: (context, state) {
                if (state is NutritionLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NutritionLoaded) {
                  final data = state.nutritionData;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.paddingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nutrition Info",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              )),
                          SizedBox(height: AppSizes.spacingSmall),
                          Text("Food: ${data['nameOfFood']}"),
                          Text("Calories: ${data['calories']}"),
                          Text("Protein: ${data['protein']}"),
                          Text("Fat: ${data['fat']}"),
                          Text("Carbs: ${data['carbs']}"),
                          SizedBox(height: AppSizes.spacingSmall),

                          Text(
                            "Good for Health: ${data['goodForHealth'] == true ? 'Yes' : 'No'}",
                            style: TextStyle(
                              color: data['goodForHealth'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          Text(
                            "Good for Weight Loss: ${data['goodForWeightLoss'] == true ? 'Yes' : 'No'}",
                            style: TextStyle(
                              color: data['goodForWeightLoss'] == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),

                          SizedBox(height: AppSizes.spacingSmall),
                          Text("Health Benefits:"),
                          Text(data['healthBenefits'] ?? "N/A"),

                          SizedBox(height: AppSizes.spacingSmall),

                  
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                     context.read<NutritionCubit>().saveDeit();
                                      _image = null;
                                    });
                                  },
                                   style: ElevatedButton.styleFrom(
                                    backgroundColor:    data['goodForHealth'] == false
                                        ?Colors.red: Colors.blue,
                                  ),
                                  child: Text(
                                    data['goodForHealth'] == true
                                        ? _getMealSuggestion()
                                        : "I will eat this anyway", 
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSizes.spacingSmall),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      context.read<NutritionCubit>().reset();
                                      _image = null;

                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "It is not recommended to eat",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is NutritionError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: AppSizes.paddingMedium),
                      Text(
                        state.error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),

     

        

            SizedBox(height: AppSizes.spacingSmall),

    
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: AppSizes.spacingMedium,
              crossAxisSpacing: AppSizes.spacingMedium,
              children: [
                _buildServiceCard(Icons.restaurant_menu, "Diet Plans", theme),
                _buildServiceCard(Icons.monitor_heart, "Nutrition Tracking", theme),
                _buildServiceCard(Icons.history, "Meal History", theme),
                _buildServiceCard(Icons.show_chart, "Progress", theme),
                _buildServiceCard(Icons.qr_code_scanner, "Barcode Scanner", theme),
                _buildServiceCard(Icons.more_horiz, "More", theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Service Card Widget
  Widget _buildServiceCard(IconData icon, String title, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppSizes.blurSmall,
            offset: Offset(AppSizes.spacingSmall, AppSizes.spacingSmall),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        onTap: () {
          // TODO: Handle service action
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppSizes.iconLarge,
              color: theme.colorScheme.primary,
            ),
            SizedBox(height: AppSizes.spacingSmall),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
