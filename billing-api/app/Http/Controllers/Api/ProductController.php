<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    // GET /api/products
    public function index()
    {
        return response()->json(Product::where('is_active', true)->get());
    }

    // GET /api/products/barcode/{code}
    public function findByBarcode($code)
    {
        $product = Product::where('barcode', $code)
                          ->where('is_active', true)
                          ->first();

        if (!$product) {
            return response()->json([
                'message' => 'Product not found'
            ], 404);
        }

        return response()->json($product);
    }

    // GET /api/products/{id}
    public function show($id)
    {
        $product = Product::findOrFail($id);
        return response()->json($product);
    }

    // POST /api/products
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'      => 'required|string',
            'barcode'   => 'required|string|unique:products,barcode',
            'price'     => 'required|numeric|min:0',
            'stock_qty' => 'required|integer|min:0',
        ]);

        $product = Product::create($validated);
        return response()->json($product, 201);
    }

    // PUT /api/products/{id}
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $product->update($request->all());
        return response()->json($product);
    }

    // DELETE /api/products/{id}
    public function destroy($id)
    {
        Product::findOrFail($id)->delete();
        return response()->json(['message' => 'Deleted']);
    }
}