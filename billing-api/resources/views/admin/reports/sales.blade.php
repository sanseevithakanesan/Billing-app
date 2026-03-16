{{-- resources/views/admin/reports/sales.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Sales Report')
@section('breadcrumb')
  <li class="breadcrumb-item active">Sales Report</li>
@endsection

@section('content')

<div class="row g-3 mb-4">
  <div class="col-md-3">
    <div class="stat-card text-center">
      <div class="stat-value text-primary">{{ $summary->total_invoices }}</div>
      <div class="stat-label">Total Invoices</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="stat-card text-center">
      <div class="stat-value text-success">₹{{ number_format($summary->paid_total, 0) }}</div>
      <div class="stat-label">Paid Amount</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="stat-card text-center">
      <div class="stat-value text-warning">₹{{ number_format($summary->unpaid_total, 0) }}</div>
      <div class="stat-label">Pending Amount</div>
    </div>
  </div>
  <div class="col-md-3">
    <div class="stat-card text-center">
      <div class="stat-value text-primary">₹{{ number_format($summary->grand_total, 0) }}</div>
      <div class="stat-label">Grand Total</div>
    </div>
  </div>
</div>

{{-- Date Filter --}}
<div class="admin-card mb-4">
  <div class="p-3">
    <form method="GET" class="row g-2 align-items-end">
      <div class="col-md-4">
        <label class="form-label">From</label>
        <input type="date" name="from" value="{{ $from }}" class="form-control">
      </div>
      <div class="col-md-4">
        <label class="form-label">To</label>
        <input type="date" name="to" value="{{ $to }}" class="form-control">
      </div>
      <div class="col-md-4">
        <button type="submit" class="btn btn-primary w-100">
          <i class="bi bi-filter me-1"></i>Apply Filter
        </button>
      </div>
    </form>
  </div>
</div>

{{-- Invoices Table --}}
<div class="admin-card">
  <div class="card-header">
    <i class="bi bi-table me-2 text-primary"></i>
    Invoices ({{ $from }} to {{ $to }})
  </div>
  <div class="table-responsive">
    <table class="table admin-table mb-0">
      <thead>
        <tr>
          <th>Invoice No</th>
          <th>Customer</th>
          <th>Items</th>
          <th>Subtotal</th>
          <th>GST</th>
          <th>Total</th>
          <th>Status</th>
          <th>Date</th>
        </tr>
      </thead>
      <tbody>
        @forelse($invoices as $inv)
        <tr>
          <td><span class="fw-bold text-primary">{{ $inv->invoice_no }}</span></td>
          <td>{{ $inv->customer->name ?? 'Walk-in' }}</td>
          <td class="text-center">{{ $inv->items->count() }}</td>
          <td>₹{{ number_format($inv->subtotal, 2) }}</td>
          <td class="text-warning">₹{{ number_format($inv->tax_amount, 2) }}</td>
          <td class="fw-bold">₹{{ number_format($inv->total, 2) }}</td>
          <td><span class="badge-{{ $inv->status }}">{{ strtoupper($inv->status) }}</span></td>
          <td class="text-muted small">{{ $inv->created_at->format('d M Y, h:i A') }}</td>
        </tr>
        @empty
        <tr><td colspan="8" class="text-center py-4 text-muted">No invoices in this period</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>
  @if($invoices->hasPages())
  <div class="p-3">{{ $invoices->links('pagination::bootstrap-5') }}</div>
  @endif
</div>
@endsection


{{-- ============================================================ --}}
{{-- resources/views/admin/reports/daily.blade.php --}}
{{-- ============================================================ --}}