{{-- resources/views/admin/products/edit.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Edit Product')
@section('breadcrumb')
  <li class="breadcrumb-item">
    <a href="{{ route('admin.products.index') }}" class="text-muted">Products</a>
  </li>
  <li class="breadcrumb-item active">Edit — {{ $product->name }}</li>
@endsection

@section('content')
<div class="row justify-content-center">
  <div class="col-lg-7">

    {{-- Product Info Header --}}
    <div class="d-flex align-items-center gap-3 mb-4">
      <div class="d-flex align-items-center justify-content-center rounded-3"
           style="width:52px;height:52px;background:#E3F2FD">
        <i class="bi bi-box-seam text-primary fs-4"></i>
      </div>
      <div>
        <h5 class="fw-bold mb-0">{{ $product->name }}</h5>
        <small class="text-muted">ID: {{ $product->id }} &nbsp;|&nbsp; Added {{ $product->created_at->diffForHumans() }}</small>
      </div>
      <div class="ms-auto">
        <a href="{{ route('admin.products.barcode', $product->id) }}"
           class="btn btn-sm btn-outline-secondary">
          <i class="bi bi-upc-scan me-1"></i>Barcode
        </a>
      </div>
    </div>

    {{-- Edit Form --}}
    <div class="admin-card">
      <div class="card-header">
        <i class="bi bi-pencil me-2 text-primary"></i>Edit Product
      </div>
      <div class="p-4">

        @if($errors->any())
        <div class="alert alert-danger rounded-3">
          <ul class="mb-0 small ps-3">
            @foreach($errors->all() as $error)
              <li>{{ $error }}</li>
            @endforeach
          </ul>
        </div>
        @endif

        <form method="POST" action="{{ route('admin.products.update', $product->id) }}">
          @csrf
          @method('PUT')

          {{-- Name --}}
          <div class="mb-3">
            <label class="form-label">
              Product Name <span class="text-danger">*</span>
            </label>
            <input type="text"
                   name="name"
                   value="{{ old('name', $product->name) }}"
                   class="form-control @error('name') is-invalid @enderror"
                   placeholder="e.g. அரிசி 1kg">
            @error('name')
              <div class="invalid-feedback">{{ $message }}</div>
            @enderror
          </div>

          {{-- Barcode + Price --}}
          <div class="row g-3 mb-3">
            <div class="col-md-7">
              <label class="form-label">
                Barcode <span class="text-danger">*</span>
              </label>
              <div class="input-group">
                <span class="input-group-text bg-white">
                  <i class="bi bi-upc text-muted"></i>
                </span>
                <input type="text"
                       name="barcode"
                       value="{{ old('barcode', $product->barcode) }}"
                       class="form-control @error('barcode') is-invalid @enderror"
                       placeholder="8901234567890">
                @error('barcode')
                  <div class="invalid-feedback">{{ $message }}</div>
                @enderror
              </div>
            </div>
            <div class="col-md-5">
              <label class="form-label">
                Price (₹) <span class="text-danger">*</span>
              </label>
              <div class="input-group">
                <span class="input-group-text bg-white">₹</span>
                <input type="number"
                       name="price"
                       value="{{ old('price', $product->price) }}"
                       step="0.01" min="0"
                       class="form-control @error('price') is-invalid @enderror"
                       placeholder="0.00">
                @error('price')
                  <div class="invalid-feedback">{{ $message }}</div>
                @enderror
              </div>
            </div>
          </div>

          {{-- Stock + Image --}}
          <div class="row g-3 mb-3">
            <div class="col-md-5">
              <label class="form-label">Stock Quantity</label>
              <input type="number"
                     name="stock_qty"
                     value="{{ old('stock_qty', $product->stock_qty) }}"
                     min="0"
                     class="form-control"
                     placeholder="0">
              @if($product->stock_qty <= 10)
                <div class="form-text text-warning">
                  <i class="bi bi-exclamation-triangle me-1"></i>
                  Low stock warning!
                </div>
              @endif
            </div>
            <div class="col-md-7">
              <label class="form-label">Image URL</label>
              <input type="url"
                     name="image_url"
                     value="{{ old('image_url', $product->image_url) }}"
                     class="form-control"
                     placeholder="https://...">
            </div>
          </div>

          {{-- Status --}}
          <div class="mb-4">
            <label class="form-label d-block">Status</label>
            <div class="form-check form-switch">
              <input class="form-check-input"
                     type="checkbox"
                     name="is_active"
                     id="is_active"
                     {{ old('is_active', $product->is_active) ? 'checked' : '' }}>
              <label class="form-check-label" for="is_active">
                Active — App-ல் காட்டப்படும்
              </label>
            </div>
          </div>

          {{-- Buttons --}}
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary px-4">
              <i class="bi bi-check-lg me-1"></i>Update Product
            </button>
            <a href="{{ route('admin.products.index') }}"
               class="btn btn-outline-secondary">
              Cancel
            </a>
          </div>

        </form>
      </div>
    </div>

    {{-- Danger Zone --}}
    <div class="admin-card mt-3" style="border:0.5px solid #f5c6cb">
      <div class="card-header" style="color:#721c24;background:#fff5f5">
        <i class="bi bi-exclamation-triangle me-2"></i>Danger Zone
      </div>
      <div class="p-3 d-flex align-items-center justify-content-between">
        <div>
          <div class="fw-bold small">Delete Product</div>
          <div class="text-muted" style="font-size:.8rem">
            இந்த product-ஐ நிரந்தரமாக நீக்கலாம்
          </div>
        </div>
        <form method="POST"
              action="{{ route('admin.products.destroy', $product->id) }}"
              onsubmit="return confirm('Delete {{ $product->name }}? This cannot be undone.')">
          @csrf @method('DELETE')
          <button type="submit" class="btn btn-sm btn-outline-danger">
            <i class="bi bi-trash me-1"></i>Delete
          </button>
        </form>
      </div>
    </div>

  </div>
</div>
@endsection