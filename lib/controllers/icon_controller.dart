import 'package:flutter/material.dart';

import '../Models/icon_picker_icon.dart';

class FIPIconController with ChangeNotifier {
  FIPIconController({
    required bool shouldScrollToSelectedIcon,
    IconPickerIcon? selectedIcon,
  })  : _selectedIcon = selectedIcon,
        _shouldScrollToSelectedIcon = shouldScrollToSelectedIcon;

  FIPIconController.multiple({
    required bool shouldScrollToSelectedIcon,
    List<IconPickerIcon>? selectedIcons,
  })  : _selectedIcons = selectedIcons,
        _shouldScrollToSelectedIcon = shouldScrollToSelectedIcon;

  final bool _shouldScrollToSelectedIcon;

  bool get shouldScrollToSelectedIcon => _shouldScrollToSelectedIcon;

  IconPickerIcon? _selectedIcon;

  IconPickerIcon? get selectedIcon => _selectedIcon;

  set selectedIcon(IconPickerIcon? val) {
    _selectedIcon = val;
    notifyListeners();
  }

  List<IconPickerIcon>? _selectedIcons;

  List<IconPickerIcon>? get selectedIcons => _selectedIcons;

  set selectedIcons(List<IconPickerIcon>? val) {
    _selectedIcons = val;
    notifyListeners();
  }

  bool get isSelectedIconAvailable => _selectedIcon != null;

  Map<String, IconPickerIcon> _icons = {};

  Map<String, IconPickerIcon> get icons => _icons;

  set icons(Map<String, IconPickerIcon> val) {
    _icons = val;
    notifyListeners();
  }

  final TextEditingController _searchTextController = TextEditingController();

  TextEditingController get searchTextController => _searchTextController;

  set searchTextController(TextEditingController val) {
    searchTextController = val;
    notifyListeners();
  }

  int get length => _icons.length;

  Iterable<MapEntry<String, IconPickerIcon>> get entries => _icons.entries;

  void addAll(Map<String, IconPickerIcon> pack) {
    _icons.addAll(pack);
    notifyListeners();
  }

  void removeAll() {
    _icons.clear();
    notifyListeners();
  }
}
