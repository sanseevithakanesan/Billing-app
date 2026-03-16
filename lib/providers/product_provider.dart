// lib/providers/product_provider.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

enum LoadState { idle, loading, loaded, error }

class ProductProvider extends ChangeNotifier {
  final _api = ApiService();

  List<Product> _products = [];
  List<Product> _filtered = [];
  LoadState _state = LoadState.idle;
  String? _error;
  String _searchQuery = '';

  List<Product> get products    => _filtered;
  List<Product> get allProducts => _products;
  LoadState get state           => _state;
  String? get error             => _error;
  bool get isLoading            => _state == LoadState.loading;

  // ── API-லிருந்து Products load செய்யவும் ──
  Future<void> loadProducts() async {
    _state = LoadState.loading;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/products');
     _products = (data as List<dynamic>)
      .map((json) => Product.fromJson(json as Map<String, dynamic>))
      .toList();
      _applyFilter();
      _state = LoadState.loaded;
    } catch (e) {
      _state = LoadState.error;
      _error = 'Products load ஆகவில்லை. மீண்டும் try செய்யுங்கள்.';
    }
    notifyListeners();
  }

  // ── Barcode மூலம் product தேடவும் ──
  Future<Product?> findByBarcode(String barcode) async {
    try {
      final data = await _api.get('/products/barcode/$barcode');
      return Product.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // ── Search filter ──
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filtered = List.from(_products);
    } else {
      _filtered = _products.where((p) =>
        p.name.toLowerCase().contains(_searchQuery) ||
        p.barcode.contains(_searchQuery)
      ).toList();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filtered = List.from(_products);
    notifyListeners();
  }
}