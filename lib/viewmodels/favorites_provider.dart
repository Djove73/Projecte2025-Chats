import 'package:flutter/material.dart';

class FavoriteItem {
  final int index;
  final DateTime savedAt;
  FavoriteItem(this.index, this.savedAt);
}

class FavoritesProvider extends ChangeNotifier {
  final List<FavoriteItem> _favorites = [];

  List<FavoriteItem> get favorites => List.unmodifiable(_favorites);

  void toggleFavorite(int index) {
    final existing = _favorites.indexWhere((item) => item.index == index);
    if (existing != -1) {
      _favorites.removeAt(existing);
    } else {
      _favorites.add(FavoriteItem(index, DateTime.now()));
    }
    notifyListeners();
  }

  bool isFavorite(int index) => _favorites.any((item) => item.index == index);
} 