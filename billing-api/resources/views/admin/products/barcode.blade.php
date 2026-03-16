{{-- resources/views/admin/products/barcode.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Barcode — ' . $product->name)

@section('content')
<div class="row justify-content-center">
  <div class="col-lg-6">

    <div class="d-flex justify-content-between align-items-center mb-4">
      <div>
        <h5 class="fw-bold mb-1">Barcode Print</h5>
        <p class="text-muted small mb-0">{{ $product->name }}</p>
      </div>
      <button onclick="window.print()" class="btn btn-primary">
        <i class="bi bi-printer me-1"></i>Print
      </button>
    </div>

    {{-- Barcode Preview Card --}}
    <div class="admin-card mb-3">
      <div class="p-4 text-center">
        <div class="fw-bold mb-1" style="font-size:1.1rem">{{ $product->name }}</div>
        <div class="text-primary fw-bold mb-3">₹{{ number_format($product->price, 2) }}</div>

        <svg id="barcode"></svg>

        <div class="mt-2 text-muted small font-monospace">{{ $product->barcode }}</div>
      </div>
    </div>

    {{-- Print Multiple --}}
    <div class="admin-card mb-3">
      <div class="card-header">Print Multiple Copies</div>
      <div class="p-3">
        <div class="row g-2 align-items-end">
          <div class="col-6">
            <label class="form-label">Copies</label>
            <input type="number" id="copies" value="1" min="1" max="50" class="form-control">
          </div>
          <div class="col-6">
            <button onclick="printMultiple()" class="btn btn-primary w-100">
              <i class="bi bi-printer me-1"></i>Print Copies
            </button>
          </div>
        </div>
      </div>
    </div>

    {{-- Printable Area --}}
    <div id="printArea" class="d-none">
    </div>

    <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary">
      <i class="bi bi-arrow-left me-1"></i>Back to Products
    </a>
  </div>
</div>
@endsection

@push('styles')
<style>
  @media print {
    .sidebar, .topbar, .btn, .admin-card:not(#barcodeCard),
    .breadcrumb, h5, p { display: none !important; }
    .main-content { margin: 0 !important; padding: 0 !important; }
    #printArea { display: block !important; }
    .barcode-label {
      display: inline-block;
      width: 200px;
      text-align: center;
      padding: 8px;
      border: 1px solid #ddd;
      margin: 4px;
      page-break-inside: avoid;
    }
  }
</style>
@endpush

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/jsbarcode@3.11.6/dist/JsBarcode.all.min.js"></script>
<script>
  const barcodeVal = '{{ $product->barcode }}';
  const productName = '{{ addslashes($product->name) }}';
  const productPrice = '{{ number_format($product->price, 2) }}';

  JsBarcode('#barcode', barcodeVal, {
    format: 'CODE128',
    width: 2.5,
    height: 80,
    displayValue: false,
    margin: 10,
    background: '#ffffff',
    lineColor: '#000000',
  });

  function printMultiple() {
    const n = parseInt(document.getElementById('copies').value) || 1;
    let html = '';
    for (let i = 0; i < n; i++) {
      html += `
        <div class="barcode-label">
          <div style="font-weight:700;font-size:12px;margin-bottom:4px">${productName}</div>
          <div style="font-size:11px;color:#1565C0;margin-bottom:6px">₹${productPrice}</div>
          <svg class="bc"></svg>
          <div style="font-size:10px;color:#666;margin-top:4px">${barcodeVal}</div>
        </div>`;
    }
    const area = document.getElementById('printArea');
    area.innerHTML = html;

    document.querySelectorAll('.bc').forEach(el => {
      JsBarcode(el, barcodeVal, {
        format: 'CODE128', width: 1.5, height: 50,
        displayValue: false, margin: 4,
      });
    });

    window.print();
  }
</script>
@endpush