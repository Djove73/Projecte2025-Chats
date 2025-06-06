import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<int> _favoriteNewsIndexes = [];

  List<int> get favoriteNewsIndexes => List.unmodifiable(_favoriteNewsIndexes);

  void toggleFavorite(int index) {
    if (_favoriteNewsIndexes.contains(index)) {
      _favoriteNewsIndexes.remove(index);
    } else {
      _favoriteNewsIndexes.add(index);
    }
    notifyListeners();
  }

  bool isFavorite(int index) => _favoriteNewsIndexes.contains(index);
} 