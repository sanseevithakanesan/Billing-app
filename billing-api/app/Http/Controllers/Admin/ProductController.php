<?php
// app/Http/Controllers/Admin/ProductController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::query();

        if ($request->search) {
            $query->where('name', 'like', "%{$request->search}%")
                  ->orWhere('barcode', 'like', "%{$request->search}%");
        }
        if ($request->status !== null) {
            $query->where('is_active', $request->status);
        }

        $products = $query->orderBy('created_at', 'desc')->paginate(15);
        return view('admin.products.index', compact('products'));
    }

    public function create()
    {
        return view('admin.products.create');
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name'      => 'required|string|max:255',
            'barcode'   => 'required|string|unique:products,barcode',
            'price'     => 'required|numeric|min:0',
            'stock_qty' => 'required|integer|min:0',
            'image_url' => 'nullable|url',
        ]);

        Product::create(array_merge($validated, ['is_active' => true]));

        return redirect()->route('admin.products.index')
                         ->with('success', 'Product சேர்க்கப்பட்டது!');
    }

    public function edit($id)
    {
        $product = Product::findOrFail($id);
        return view('admin.products.edit', compact('product'));
    }

    public function update(Request $request, $id)
    {
        $product   = Product::findOrFail($id);
        $validated = $request->validate([
            'name'      => 'required|string|max:255',
            'barcode'   => "required|string|unique:products,barcode,{$id}",
            'price'     => 'required|numeric|min:0',
            'stock_qty' => 'required|integer|min:0',
        ]);

        $product->update(array_merge($validated, [
            'is_active' => $request->has('is_active'),
        ]));

        return redirect()->route('admin.products.index')
                         ->with('success', 'Product update ஆனது!');
    }

    public function destroy($id)
    {
        Product::findOrFail($id)->delete();
        return redirect()->route('admin.products.index')
                         ->with('success', 'Product நீக்கப்பட்டது!');
    }

    // Barcode print page
    public function barcode($id)
    {
        $product = Product::findOrFail($id);
        return view('admin.products.barcode', compact('product'));
    }
}