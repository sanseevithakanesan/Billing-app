{{-- @extends('admin.layouts.admin')

@section('title', 'Products')

@section('content')
<div class="container-fluid">
    <!-- Header with stats -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <h4 class="mb-0">Products</h4>
                <a href="{{ route('admin.products.create') }}" class="btn btn-primary">
                    <i class="fas fa-plus-circle me-2"></i>Add Product
                </a>
            </div>
        </div>
    </div>

    <!-- Stats Cards (like your total invoices) -->
    <div class="row mb-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white">
                <div class="card-body">
                    <h6>Total Products</h6>
                    <h3>{{ $products->count() }}</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <h6>In Stock</h6>
                    <h3>{{ $products->sum('stock_qty') }}</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-warning text-white">
                <div class="card-body">
                    <h6>Low Stock</h6>
                    <h3>{{ $products->where('stock_qty', '<', 10)->count() }}</h3>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white">
                <div class="card-body">
                    <h6>Total Value</h6>
                    <h3>₹{{ number_format($products->sum(function($p) { return $p->price * $p->stock_qty; }), 2) }}</h3>
                </div>
            </div>
        </div>
    </div>

    <!-- Products Table (like your sales report table) -->
    <div class="card shadow-sm">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead class="table-light">
                        <tr>
                            <th>ID</th>
                            <th>Product Name</th>
                            <th>Barcode</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($products as $product)
                        <tr>
                            <td>#{{ $product->id }}</td>
                            <td>{{ $product->name }}</td>
                            <td><code>{{ $product->barcode }}</code></td>
                            <td>₹{{ number_format($product->price, 2) }}</td>
                            <td>
                                <span class="badge bg-{{ $product->stock_qty > 10 ? 'success' : ($product->stock_qty > 0 ? 'warning' : 'danger') }}">
                                    {{ $product->stock_qty }}
                                </span>
                            </td>
                            <td>
                                <span class="badge bg-{{ $product->is_active ? 'success' : 'secondary' }}">
                                    {{ $product->is_active ? 'ACTIVE' : 'INACTIVE' }}
                                </span>
                            </td>
                            <td>
                                <a href="{{ route('admin.products.edit', $product->id) }}" class="btn btn-sm btn-info">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="{{ route('admin.products.barcode', $product->id) }}" class="btn btn-sm btn-success">
                                    <i class="fas fa-qrcode"></i>
                                </a>
                                <form action="{{ route('admin.products.destroy', $product->id) }}" method="POST" class="d-inline">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Delete this product?')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="7" class="text-center py-4">
                                <i class="fas fa-box-open fa-3x mb-3 text-muted"></i>
                                <p class="text-muted">No products found</p>
                                <a href="{{ route('admin.products.create') }}" class="btn btn-primary">
                                    Add Your First Product
                                </a>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
@endsection --}}


{{-- //@extends('admin.layouts.admin') --}}
@extends('admin.layouts.app')
@section('title', 'Products')

@section('content')
<div class="container-fluid px-4 py-4">
    <!-- Page Header -->
    <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4 gap-3">
        <div>
            <h3 class="mb-1 fw-bold text-dark">Products Management</h3>
            <p class="text-muted mb-0">Manage your inventory, stock levels and product details</p>
        </div>
        <a href="{{ route('admin.products.create') }}" class="btn btn-primary btn-lg shadow-sm">
            <i class="fas fa-plus-circle me-2"></i> Add New Product
        </a>
    </div>

    <!-- Stats Cards -->
    <div class="row g-4 mb-5">
        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm h-100 hover-lift">
                <div class="card-body text-center">
                    <div class="icon-circle bg-primary-subtle text-primary mb-3 mx-auto">
                        <i class="fas fa-boxes-stacked fa-2x"></i>
                    </div>
                    <h6 class="text-uppercase text-muted mb-1">Total Products</h6>
                    <h3 class="fw-bold mb-0">{{ $products->count() }}</h3>
                </div>
            </div>
        </div>

        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm h-100 hover-lift">
                <div class="card-body text-center">
                    <div class="icon-circle bg-success-subtle text-success mb-3 mx-auto">
                        <i class="fas fa-check-circle fa-2x"></i>
                    </div>
                    <h6 class="text-uppercase text-muted mb-1">In Stock</h6>
                    <h3 class="fw-bold mb-0">{{ $products->sum('stock_qty') }}</h3>
                </div>
            </div>
        </div>

        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm h-100 hover-lift">
                <div class="card-body text-center">
                    <div class="icon-circle bg-warning-subtle text-warning mb-3 mx-auto">
                        <i class="fas fa-exclamation-triangle fa-2x"></i>
                    </div>
                    <h6 class="text-uppercase text-muted mb-1">Low Stock</h6>
                    <h3 class="fw-bold mb-0">{{ $products->where('stock_qty', '<', 10)->count() }}</h3>
                </div>
            </div>
        </div>

        <div class="col-6 col-md-3">
            <div class="card border-0 shadow-sm h-100 hover-lift">
                <div class="card-body text-center">
                    <div class="icon-circle bg-info-subtle text-info mb-3 mx-auto">
                        <i class="fas fa-rupee-sign fa-2x"></i>
                    </div>
                    <h6 class="text-uppercase text-muted mb-1">Inventory Value</h6>
                    <h3 class="fw-bold mb-0">₹{{ number_format($products->sum(fn($p) => $p->price * $p->stock_qty), 2) }}</h3>
                </div>
            </div>
        </div>
    </div>

    <!-- Products Table Card -->
    <div class="card border-0 shadow-lg">
        <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
            <h5 class="mb-0 fw-semibold text-dark">All Products</h5>
            <!-- You can add search/filter here later -->
            <div class="input-group w-50 w-md-25">
                <input type="text" class="form-control" placeholder="Search products..." disabled>
                <span class="input-group-text"><i class="fas fa-search"></i></span>
            </div>
        </div>

        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light sticky-top">
                        <tr>
                            <th class="ps-4">ID</th>
                            <th>Product Name</th>
                            <th>Barcode</th>
                            <th>Price</th>
                            <th>Stock</th>
                            <th>Status</th>
                            <th class="text-end pe-4">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @forelse($products as $product)
                        <tr>
                            <td class="ps-4 fw-medium text-muted">#{{ $product->id }}</td>
                            <td class="fw-semibold">{{ $product->name }}</td>
                            <td><code class="bg-light px-2 py-1 rounded">{{ $product->barcode }}</code></td>
                            <td>₹{{ number_format($product->price, 2) }}</td>
                            <td>
                                <span class="badge rounded-pill px-3 py-2 fs-6
                                    {{ $product->stock_qty > 20 ? 'bg-success' : 
                                       ($product->stock_qty > 5  ? 'bg-warning' : 'bg-danger') }}">
                                    {{ $product->stock_qty }}
                                </span>
                            </td>
                            <td>
                                <span class="badge rounded-pill px-3 py-2 fs-6
                                    {{ $product->is_active ? 'bg-success' : 'bg-secondary' }}">
                                    {{ $product->is_active ? 'ACTIVE' : 'INACTIVE' }}
                                </span>
                            </td>
                            <td class="text-end pe-4">
                                <div class="d-flex gap-2 justify-content-end">
                                    <a href="{{ route('admin.products.edit', $product->id) }}"
                                       class="btn btn-sm btn-outline-primary rounded-circle"
                                       data-bs-toggle="tooltip" title="Edit Product">
                                        <i class="fas fa-edit"></i>
                                    </a>

                                    <a href="{{ route('admin.products.barcode', $product->id) }}"
                                       class="btn btn-sm btn-outline-success rounded-circle"
                                       data-bs-toggle="tooltip" title="View Barcode">
                                        <i class="fas fa-qrcode"></i>
                                    </a>

                                    <form action="{{ route('admin.products.destroy', $product->id) }}"
                                          method="POST" class="d-inline">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit"
                                                class="btn btn-sm btn-outline-danger rounded-circle"
                                                data-bs-toggle="tooltip" title="Delete Product"
                                                onclick="return confirm('Are you sure you want to delete this product?')">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="7" class="text-center py-5">
                                <div class="py-5">
                                    <i class="fas fa-box-open fa-4x text-muted mb-4"></i>
                                    <h5 class="text-muted mb-3">No products found</h5>
                                    <p class="text-muted mb-4">Start by adding your first product to the inventory.</p>
                                    <a href="{{ route('admin.products.create') }}"
                                       class="btn btn-primary btn-lg px-5">
                                        <i class="fas fa-plus-circle me-2"></i>Add First Product
                                    </a>
                                </div>
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <div class="card-footer bg-white border-0 text-muted small">
            Showing {{ $products->count() }} of {{ $products->count() }} products
        </div>
    </div>
</div>

<style>
    .hover-lift {
        transition: all 0.25s ease;
    }
    .hover-lift:hover {
        transform: translateY(-5px);
        box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04) !important;
    }
    .icon-circle {
        width: 70px;
        height: 70px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .table thead th {
        text-transform: uppercase;
        font-size: 0.85rem;
        letter-spacing: 0.5px;
        color: #6c757d;
    }
</style>
@endsection