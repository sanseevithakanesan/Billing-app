{{-- resources/views/admin/products/index.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Products')
@section('breadcrumb')
  <li class="breadcrumb-item active">Products</li>
@endsection

@section('content')

<div class="d-flex justify-content-between align-items-center mb-4">
  <div>
    <h5 class="fw-bold mb-1">Products Management</h5>
    <p class="text-muted small mb-0">{{ $products->total() }} products found</p>
  </div>
  <a href="{{ route('admin.products.create') }}" class="btn btn-primary">
    <i class="bi bi-plus-lg me-1"></i>Add Product
  </a>
</div>

{{-- Search & Filter --}}
<div class="admin-card mb-4">
  <div class="p-3">
    <form method="GET" class="row g-2 align-items-end">
      <div class="col-md-6">
        <label class="form-label">Search</label>
        <div class="input-group">
          <span class="input-group-text bg-white"><i class="bi bi-search text-muted"></i></span>
          <input type="text" name="search" value="{{ request('search') }}"
                 class="form-control" placeholder="Product name or barcode...">
        </div>
      </div>
      <div class="col-md-3">
        <label class="form-label">Status</label>
        <select name="status" class="form-select">
          <option value="">All</option>
          <option value="1" {{ request('status') == '1' ? 'selected' : '' }}>Active</option>
          <option value="0" {{ request('status') == '0' ? 'selected' : '' }}>Inactive</option>
        </select>
      </div>
      <div class="col-md-3">
        <button type="submit" class="btn btn-primary w-100">
          <i class="bi bi-filter me-1"></i>Filter
        </button>
      </div>
    </form>
  </div>
</div>

{{-- Products Table --}}
<div class="admin-card">
  <div class="table-responsive">
    <table class="table admin-table mb-0">
      <thead>
        <tr>
          <th>#</th>
          <th>Product</th>
          <th>Barcode</th>
          <th>Price</th>
          <th>Stock</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>
        @forelse($products as $i => $product)
        <tr>
          <td class="text-muted small">{{ $products->firstItem() + $i }}</td>
          <td>
            <div class="fw-bold">{{ $product->name }}</div>
            <div class="text-muted small">Added {{ $product->created_at->diffForHumans() }}</div>
          </td>
          <td>
            <code class="bg-light px-2 py-1 rounded small">{{ $product->barcode }}</code>
          </td>
          <td class="fw-bold text-primary">₹{{ number_format($product->price, 2) }}</td>
          <td>
            <span class="badge {{ $product->stock_qty <= 0 ? 'bg-danger' : ($product->stock_qty <= 10 ? 'bg-warning text-dark' : 'bg-success') }}">
              {{ $product->stock_qty }}
            </span>
          </td>
          <td>
            @if($product->is_active)
              <span class="badge-paid">Active</span>
            @else
              <span class="badge-cancelled">Inactive</span>
            @endif
          </td>
          <td>
            <div class="d-flex gap-1">
              <a href="{{ route('admin.products.barcode', $product->id) }}"
                 class="btn btn-sm btn-outline-secondary" title="Barcode">
                <i class="bi bi-upc-scan"></i>
              </a>
              <a href="{{ route('admin.products.edit', $product->id) }}"
                 class="btn btn-sm btn-outline-primary" title="Edit">
                <i class="bi bi-pencil"></i>
              </a>
              <form method="POST" action="{{ route('admin.products.destroy', $product->id) }}"
                    onsubmit="return confirm('Delete this product?')">
                @csrf @method('DELETE')
                <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                  <i class="bi bi-trash"></i>
                </button>
              </form>
            </div>
          </td>
        </tr>
        @empty
        <tr>
          <td colspan="7" class="text-center py-5">
            <i class="bi bi-inbox fs-2 text-muted d-block mb-2"></i>
            <p class="text-muted">No products found</p>
            <a href="{{ route('admin.products.create') }}" class="btn btn-primary btn-sm">Add Product</a>
          </td>
        </tr>
        @endforelse
      </tbody>
    </table>
  </div>
  @if($products->hasPages())
  <div class="p-3 border-top">
    {{ $products->links('pagination::bootstrap-5') }}
  </div>
  @endif
</div>

@endsection