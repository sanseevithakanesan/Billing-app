{{-- @extends('admin.layouts.admin') --}}
@extends('admin.layouts.app')
@section('title', 'Add Product')

@section('content')
<div class="container-fluid">
    <!-- Header Section -->
    <div class="row mb-3">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    <div class="bg-primary bg-gradient rounded-3 p-2 me-3 shadow-sm">
                        <i class="fas fa-plus-circle text-white fa-lg"></i>
                    </div>
                    <div>
                        <h5 class="mb-0 fw-bold">Add Product</h5>
                        <small class="text-muted">
                            <i class="fas fa-home fa-xs"></i> Dashboard / Products / Add Product
                        </small>
                    </div>
                </div>
                <span class="badge bg-primary bg-gradient px-3 py-2 rounded-pill shadow-sm">
                    <i class="fas fa-box me-1"></i> NEW
                </span>
            </div>
        </div>
    </div>

    <!-- Main Card - Compact Design -->
    <div class="row">
        <div class="col-12">
            <div class="card border-0 shadow-sm rounded-3">
                <div class="card-body p-4">
                    <form action="{{ route('admin.products.store') }}" method="POST" id="productForm">
                        @csrf
                        
                        <!-- Two Column Layout -->
                        <div class="row g-3">
                            <!-- Left Column -->
                            <div class="col-md-6">
                                <!-- Product Name -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-primary">
                                        <i class="fas fa-tag me-1"></i>PRODUCT NAME
                                    </label>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text bg-light border-end-0">
                                            <i class="fas fa-box text-primary fa-sm"></i>
                                        </span>
                                        <input type="text" 
                                               class="form-control border-start-0 ps-0 @error('name') is-invalid @enderror" 
                                               name="name" 
                                               value="{{ old('name') }}" 
                                               placeholder="e.g., T-Shirt"
                                               required>
                                    </div>
                                    @error('name')
                                        <small class="text-danger">{{ $message }}</small>
                                    @enderror
                                </div>

                                <!-- Price -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-success">
                                        <i class="fas fa-rupee-sign me-1"></i>PRICE
                                    </label>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text bg-light">₹</span>
                                        <input type="number" 
                                               step="0.01" 
                                               min="0"
                                               class="form-control @error('price') is-invalid @enderror" 
                                               name="price" 
                                               value="{{ old('price') }}" 
                                               placeholder="0.00"
                                               required>
                                    </div>
                                </div>

                                <!-- Description -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-info">
                                        <i class="fas fa-align-left me-1"></i>DESCRIPTION
                                    </label>
                                    <textarea class="form-control form-control-sm" 
                                              name="description" 
                                              rows="3" 
                                              placeholder="Product details...">{{ old('description') }}</textarea>
                                    <small class="text-muted float-end" id="charCount">0/200</small>
                                </div>
                            </div>

                            <!-- Right Column -->
                            <div class="col-md-6">
                                <!-- Barcode -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-warning">
                                        <i class="fas fa-qrcode me-1"></i>BARCODE
                                    </label>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text bg-light">
                                            <i class="fas fa-barcode"></i>
                                        </span>
                                        <input type="text" 
                                               class="form-control @error('barcode') is-invalid @enderror" 
                                               id="barcode"
                                               name="barcode" 
                                               value="{{ old('barcode') }}" 
                                               placeholder="Scan or generate"
                                               required>
                                        <button class="btn btn-outline-primary btn-sm" type="button" id="generateBarcode">
                                            <i class="fas fa-sync-alt"></i>
                                        </button>
                                    </div>
                                    @error('barcode')
                                        <small class="text-danger">{{ $message }}</small>
                                    @enderror
                                </div>

                                <!-- Stock -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-warning">
                                        <i class="fas fa-cubes me-1"></i>STOCK QTY
                                    </label>
                                    <div class="input-group input-group-sm">
                                        <span class="input-group-text bg-light">
                                            <i class="fas fa-boxes"></i>
                                        </span>
                                        <input type="number" 
                                               min="0"
                                               class="form-control @error('stock_qty') is-invalid @enderror" 
                                               name="stock_qty" 
                                               value="{{ old('stock_qty', 0) }}" 
                                               placeholder="0"
                                               required>
                                    </div>
                                </div>

                                <!-- Status Toggle -->
                                <div class="mb-3">
                                    <label class="form-label fw-semibold small text-uppercase text-secondary">
                                        <i class="fas fa-toggle-on me-1"></i>STATUS
                                    </label>
                                    <div class="d-flex align-items-center">
                                        <div class="form-check form-switch">
                                            <input class="form-check-input" 
                                                   type="checkbox" 
                                                   name="is_active" 
                                                   id="isActive" 
                                                   value="1" 
                                                   {{ old('is_active', true) ? 'checked' : '' }}>
                                        </div>
                                        <span class="badge bg-{{ old('is_active', true) ? 'success' : 'secondary' }} ms-2" id="statusBadge">
                                            {{ old('is_active', true) ? 'ACTIVE' : 'INACTIVE' }}
                                        </span>
                                        <small class="text-muted ms-2">
                                            <i class="fas fa-info-circle"></i>
                                        </small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Quick Stats Row -->
                        <div class="row g-2 my-3">
                            <div class="col-md-3 col-6">
                                <div class="bg-light rounded-3 p-2 text-center">
                                    <small class="text-muted d-block">TOTAL</small>
                                    <span class="fw-bold" id="totalValue">₹0</span>
                                </div>
                            </div>
                            <div class="col-md-3 col-6">
                                <div class="bg-light rounded-3 p-2 text-center">
                                    <small class="text-muted d-block">GST 18%</small>
                                    <span class="fw-bold" id="gstValue">₹0</span>
                                </div>
                            </div>
                            <div class="col-md-3 col-6">
                                <div class="bg-light rounded-3 p-2 text-center">
                                    <small class="text-muted d-block">FINAL</small>
                                    <span class="fw-bold text-primary" id="finalValue">₹0</span>
                                </div>
                            </div>
                            <div class="col-md-3 col-6">
                                <div class="bg-light rounded-3 p-2 text-center">
                                    <small class="text-muted d-block">STOCK VALUE</small>
                                    <span class="fw-bold text-success" id="stockValue">₹0</span>
                                </div>
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <div class="d-flex gap-2 justify-content-end mt-3">
                            <button type="button" class="btn btn-outline-primary btn-sm px-4" id="quickPreview">
                                <i class="fas fa-eye me-1"></i>Preview
                            </button>
                            <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary btn-sm px-4">
                                <i class="fas fa-times me-1"></i>Cancel
                            </a>
                            <button type="submit" class="btn btn-primary btn-sm px-4" id="saveBtn">
                                <i class="fas fa-save me-1"></i>Save
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Compact CSS -->
<style>
    .form-control:focus, .btn:focus {
        box-shadow: none !important;
        border-color: #0d6efd !important;
    }
    
    .input-group-text {
        background-color: #f8f9fa;
        border: 1px solid #dee2e6;
    }
    
    .btn-sm {
        padding: 0.25rem 0.75rem;
    }
    
    .bg-light {
        background-color: #f8f9fa !important;
    }
    
    .form-check-input:checked {
        background-color: #198754;
        border-color: #198754;
    }
    
    /* Compact spacing */
    .form-label {
        margin-bottom: 0.25rem;
    }
    
    .input-group-sm .form-control {
        font-size: 0.875rem;
    }
    
    .card-body {
        padding: 1.25rem !important;
    }
</style>
@endsection

@push('scripts')
<script>
// Character Counter
const desc = document.querySelector('textarea[name="description"]');
const charCount = document.getElementById('charCount');
desc.addEventListener('input', function() {
    const count = this.value.length;
    charCount.textContent = count + '/200';
    charCount.style.color = count > 180 ? 'red' : '#6c757d';
});
charCount.textContent = desc.value.length + '/200';

// Barcode Generator
document.getElementById('generateBarcode').addEventListener('click', function() {
    const barcode = 'PROD' + Date.now().toString().slice(-8);
    document.getElementById('barcode').value = barcode;
});

// Calculate totals
function calculateTotals() {
    const price = parseFloat(document.querySelector('input[name="price"]').value) || 0;
    const stock = parseFloat(document.querySelector('input[name="stock_qty"]').value) || 0;
    
    document.getElementById('totalValue').textContent = '₹' + price.toFixed(2);
    document.getElementById('gstValue').textContent = '₹' + (price * 0.18).toFixed(2);
    document.getElementById('finalValue').textContent = '₹' + (price * 1.18).toFixed(2);
    document.getElementById('stockValue').textContent = '₹' + (price * stock).toFixed(2);
}

// Add input listeners
document.querySelector('input[name="price"]').addEventListener('input', calculateTotals);
document.querySelector('input[name="stock_qty"]').addEventListener('input', calculateTotals);
calculateTotals(); // Initial calculation

// Status toggle
document.getElementById('isActive').addEventListener('change', function() {
    const badge = document.getElementById('statusBadge');
    if(this.checked) {
        badge.className = 'badge bg-success ms-2';
        badge.textContent = 'ACTIVE';
    } else {
        badge.className = 'badge bg-secondary ms-2';
        badge.textContent = 'INACTIVE';
    }
});

// Quick preview
document.getElementById('quickPreview').addEventListener('click', function() {
    const name = document.querySelector('input[name="name"]').value || 'Not Set';
    const price = document.querySelector('input[name="price"]').value || '0';
    const barcode = document.getElementById('barcode').value || 'Not Set';
    
    alert(`📋 QUICK PREVIEW\n━━━━━━━━━━━━\nName: ${name}\nPrice: ₹${price}\nBarcode: ${barcode}\nGST 18%: ₹${(price * 0.18).toFixed(2)}\nTotal: ₹${(price * 1.18).toFixed(2)}`);
});
</script>
@endpush