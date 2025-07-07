import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trabalho/widgets/appDrawer.dart';
import '../controllers/SettingsController.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Color selectedColor;
  late IconData selectedIcon;
  late TextEditingController nameController;

  final List<Color> colorOptions = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  final List<IconData> iconOptions = [
    Icons.home,
    Icons.star,
    Icons.person,
    Icons.settings,
    Icons.favorite,
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsController>().settings;
    selectedColor = settings.color;
    selectedIcon = settings.icon;
    nameController = TextEditingController(text: settings.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _updateName(String name) {
    context.read<SettingsController>().updateName(name);
  }

  void _updateColor(Color color) {
    context.read<SettingsController>().updateColor(color);
    setState(() => selectedColor = color);
  }

  void _updateIcon(IconData icon) {
    context.read<SettingsController>().updateIcon(icon);
    setState(() => selectedIcon = icon);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Configurações")),
      drawer: const AppDrawer(),
      body: SettingsBody(
        selectedColor: selectedColor,
        onColorChanged: _updateColor,
        selectedIcon: selectedIcon,
        onIconChanged: _updateIcon,
        nameController: nameController,
        onNameChanged: _updateName,
        colorOptions: colorOptions,
        iconOptions: iconOptions,
      ),
    );
  }
}

class SettingsBody extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorChanged;
  final IconData selectedIcon;
  final Function(IconData) onIconChanged;
  final TextEditingController nameController;
  final Function(String) onNameChanged;
  final List<Color> colorOptions;
  final List<IconData> iconOptions;

  const SettingsBody({
    required this.selectedColor,
    required this.onColorChanged,
    required this.selectedIcon,
    required this.onIconChanged,
    required this.nameController,
    required this.onNameChanged,
    required this.colorOptions,
    required this.iconOptions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text("Escolha uma cor personalizada:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          children: colorOptions.map((color) {
            return ChoiceChip(
              label: Container(width: 24, height: 24),
              selectedColor: color,
              backgroundColor: color.withOpacity(0.4),
              selected: selectedColor == color,
              onSelected: (_) => onColorChanged(color),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        Text("Escolha um ícone personalizado:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 10,
          children: iconOptions.map((icon) {
            return ChoiceChip(
              label: Icon(icon, size: 24),
              selected: selectedIcon == icon,
              onSelected: (_) => onIconChanged(icon),
            );
          }).toList(),
        ),
        SizedBox(height: 24),
        Text("Digite um nome personalizado:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: "Digite o nome aqui",
            border: OutlineInputBorder(),
          ),
          onChanged: onNameChanged,
        ),
      ],
    );
  }
}