import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- 1. MODEL ---
class Task {
  String title;
  String description;
  String priority;
  Task({required this.title, required this.description, required this.priority});
}

// --- 2. CONTROLLERS ---
class TaskController extends GetxController {
  var tasks = <Task>[].obs;
  void addTask(Task task) => tasks.add(task);
}

class ThemeController extends GetxController {
  var isDarkMode = false.obs;
  
  // Requirement: Logic to switch between Dark and Light mode
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}

// --- 3. MAIN ENTRY POINT ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
  Get.put(TaskController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();
    return Obx(() => GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager App',
      theme: ThemeData.light().copyWith(
        primaryColor: const Color(0xFFB71C1C),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFB71C1C),
      ),
      themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    ));
  }
}

// --- 4. DESIGN HELPERS ---
class AppColors {
  static const Color primaryRed = Color(0xFFB71C1C);
  static const Color darkBg = Color(0xFF31001F);
  static const List<Color> mainGradient = [primaryRed, darkBg];
}

// --- 5. SCREENS ---

// SPLASH SCREEN
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () => Get.offAll(() => const HomeScreen()));
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppColors.mainGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            // Updated Icon for "Task Manager"
            Icon(Icons.assignment_turned_in, size: 100, color: Colors.white),
            SizedBox(height: 20),
            // Updated Text to "Task ManagerApp"
            Text('Task ManagerApp', 
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)
            ),
          ],
        ),
      ),
    );
  }
}

// HOME SCREEN
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find();
    final ThemeController themeController = Get.find();
    
    return Scaffold(
      // Background remains dark to match your reference image style
      backgroundColor: AppColors.darkBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryRed,
        onPressed: () => Get.to(() => const AddTaskScreen(), transition: Transition.rightToLeft),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 60, left: 30, right: 30, bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Tasks', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                // Clicking this icon toggles Dark Mode for your teacher's requirement
                IconButton(
                  icon: Obx(() => Icon(
                    themeController.isDarkMode.value ? Icons.light_mode : Icons.dark_mode, 
                    color: Colors.white, 
                    size: 30
                  )),
                  onPressed: () => themeController.toggleTheme(),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() => Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: themeController.isDarkMode.value ? Colors.grey[900] : Colors.white,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50)),
              ),
              child: taskController.tasks.isEmpty
                ? const Center(child: Text('No Tasks Found', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(25),
                    itemCount: taskController.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskController.tasks[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        color: themeController.isDarkMode.value ? Colors.grey[850] : Colors.white,
                        child: ListTile(
                          onTap: () => Get.to(() => TaskDetailsScreen(task: task)),
                          title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold, color: themeController.isDarkMode.value ? Colors.white : Colors.black)),
                          subtitle: Text(task.description, maxLines: 1, style: const TextStyle(color: Colors.grey)),
                          trailing: Icon(Icons.circle, color: task.priority == 'High' ? Colors.red : Colors.green, size: 12),
                        ),
                      );
                    },
                  ),
            )),
          ),
        ],
      ),
    );
  }
}

// ADD TASK SCREEN
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  String priority = 'Low';

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode.value;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.mainGradient)),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text('New Task', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white, 
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(50))
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController, 
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: const InputDecoration(labelText: 'Task Title', labelStyle: TextStyle(color: AppColors.primaryRed))
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: descController, 
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        decoration: const InputDecoration(labelText: 'Description')
                      ),
                      const SizedBox(height: 20),
                      DropdownButton<String>(
                        value: priority,
                        isExpanded: true,
                        dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black),
                        items: ['High', 'Medium', 'Low'].map((String value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                        onChanged: (val) => setState(() => priority = val!),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed, shape: const StadiumBorder()),
                          onPressed: () {
                            if(titleController.text.isNotEmpty) {
                              Get.find<TaskController>().addTask(Task(title: titleController.text, description: descController.text, priority: priority));
                              Get.back();
                            }
                          },
                          child: const Text('SAVE TASK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DETAILS SCREEN
class TaskDetailsScreen extends StatelessWidget {
  final Task task;
  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeController>().isDarkMode.value;
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.mainGradient)),
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back())]),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white, 
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(50))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 20),
                    Text(task.description, style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : Colors.black87)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: AppColors.primaryRed.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('Priority: ${task.priority}', style: const TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}