{{-- resources/views/admin/dashboard.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Dashboard')

@push('styles')
<style>
  .chart-container { position: relative; height: 280px; }
  .product-rank { width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:.8rem; }
</style>
@endpush

@section('content')

{{-- Stat Cards --}}
<div class="row g-3 mb-4">

  <div class="col-6 col-lg-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div class="icon-wrap" style="background:#E3F2FD">
          <i class="bi bi-currency-rupee text-primary"></i>
        </div>
        <small class="stat-change text-success">
          <i class="bi bi-arrow-up"></i> Total
        </small>
      </div>
      <div class="stat-value">₹{{ number_format($totalSales, 0) }}</div>
      <div class="stat-label">Total Sales</div>
      <i class="bi bi-currency-rupee bg-decoration"></i>
    </div>
  </div>

  <div class="col-6 col-lg-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div class="icon-wrap" style="background:#E8F5E9">
          <i class="bi bi-sun text-success"></i>
        </div>
        <small class="stat-change text-success">Today</small>
      </div>
      <div class="stat-value">₹{{ number_format($todaySales, 0) }}</div>
      <div class="stat-label">Today Sales</div>
      <i class="bi bi-sun bg-decoration" style="color:#4CAF50"></i>
    </div>
  </div>

  <div class="col-6 col-lg-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div class="icon-wrap" style="background:#FFF3E0">
          <i class="bi bi-receipt text-warning"></i>
        </div>
        <small class="stat-change text-warning">{{ $pendingCount }} pending</small>
      </div>
      <div class="stat-value">{{ $totalInvoices }}</div>
      <div class="stat-label">Total Invoices</div>
      <i class="bi bi-receipt bg-decoration" style="color:#FF9800"></i>
    </div>
  </div>

  <div class="col-6 col-lg-3">
    <div class="stat-card">
      <div class="d-flex align-items-center justify-content-between">
        <div class="icon-wrap" style="background:#FCE4EC">
          <i class="bi bi-box-seam text-danger"></i>
        </div>
        <small class="stat-change text-muted">{{ $totalCustomers }} customers</small>
      </div>
      <div class="stat-value">{{ $totalProducts }}</div>
      <div class="stat-label">Active Products</div>
      <i class="bi bi-box-seam bg-decoration" style="color:#E91E63"></i>
    </div>
  </div>

</div>

<div class="row g-3 mb-4">

  {{-- Sales Chart --}}
  <div class="col-lg-8">
    <div class="admin-card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="bi bi-bar-chart me-2 text-primary"></i>Monthly Sales</span>
        <div class="btn-group btn-group-sm">
          <button class="btn btn-outline-secondary active" onclick="loadChart(30)">30d</button>
          <button class="btn btn-outline-secondary" onclick="loadChart(60)">60d</button>
          <button class="btn btn-outline-secondary" onclick="loadChart(90)">90d</button>
        </div>
      </div>
      <div class="p-3">
        <div class="chart-container">
          <canvas id="salesChart"></canvas>
        </div>
      </div>
    </div>
  </div>

  {{-- Top Products --}}
  <div class="col-lg-4">
    <div class="admin-card h-100">
      <div class="card-header">
        <i class="bi bi-trophy me-2 text-warning"></i>Top Products
      </div>
      <div class="p-3">
        @forelse($topProducts as $i => $tp)
        <div class="d-flex align-items-center gap-3 mb-3">
          <div class="product-rank" style="background:{{ ['#1565C0','#2196F3','#64B5F6','#BBDEFB','#E3F2FD'][$i] }};color:{{ $i < 2 ? '#fff' : '#1565C0' }}">
            {{ $i + 1 }}
          </div>
          <div class="flex-grow-1">
            <div class="fw-600 small">{{ $tp->product->name ?? 'Unknown' }}</div>
            <div class="text-muted" style="font-size:.75rem">{{ $tp->total_qty }} units sold</div>
            <div class="progress mt-1" style="height:4px">
              <div class="progress-bar bg-primary" style="width:{{ min(100, ($tp->total_qty / ($topProducts->first()->total_qty ?? 1)) * 100) }}%"></div>
            </div>
          </div>
          <div class="text-end">
            <div class="text-primary fw-bold small">₹{{ number_format($tp->total_revenue, 0) }}</div>
          </div>
        </div>
        @empty
        <div class="text-center text-muted py-4">
          <i class="bi bi-inbox fs-2 d-block mb-2"></i>No data
        </div>
        @endforelse
      </div>
    </div>
  </div>

</div>

<div class="row g-3">

  {{-- Recent Invoices --}}
  <div class="col-lg-8">
    <div class="admin-card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span><i class="bi bi-clock-history me-2 text-primary"></i>Recent Invoices</span>
        <a href="{{ route('admin.reports.sales') }}" class="btn btn-sm btn-outline-primary">
          View All <i class="bi bi-arrow-right ms-1"></i>
        </a>
      </div>
      <div class="table-responsive">
        <table class="table admin-table mb-0">
          <thead>
            <tr>
              <th>Invoice No</th>
              <th>Customer</th>
              <th>Amount</th>
              <th>Status</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            @forelse($recentInvoices as $inv)
            <tr>
              <td><span class="fw-bold text-primary">{{ $inv->invoice_no }}</span></td>
              <td>{{ $inv->customer->name ?? 'Walk-in' }}</td>
              <td class="fw-bold">₹{{ number_format($inv->total, 2) }}</td>
              <td>
                <span class="badge-{{ $inv->status }}">{{ strtoupper($inv->status) }}</span>
              </td>
              <td class="text-muted small">{{ $inv->created_at->format('d M, h:i A') }}</td>
            </tr>
            @empty
            <tr><td colspan="5" class="text-center text-muted py-4">No invoices yet</td></tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </div>

  {{-- Low Stock Alert --}}
  <div class="col-lg-4">
    <div class="admin-card">
      <div class="card-header">
        <i class="bi bi-exclamation-triangle me-2 text-warning"></i>Low Stock Alert
      </div>
      <div class="p-3">
        @forelse($lowStock as $product)
        <div class="d-flex align-items-center justify-content-between py-2 border-bottom">
          <div>
            <div class="small fw-bold">{{ $product->name }}</div>
            <div class="text-muted" style="font-size:.75rem">{{ $product->barcode }}</div>
          </div>
          <span class="badge {{ $product->stock_qty == 0 ? 'bg-danger' : 'bg-warning text-dark' }}">
            {{ $product->stock_qty }} left
          </span>
        </div>
        @empty
        <div class="text-center text-muted py-4">
          <i class="bi bi-check-circle text-success fs-3 d-block mb-2"></i>
          All products in stock!
        </div>
        @endforelse
      </div>
    </div>
  </div>

</div>

@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
let chart;

async function loadChart(days = 30) {
  const res  = await fetch(`{{ route('admin.api.chart') }}?days=${days}`);
  const data = await res.json();

  const labels = data.map(d => {
    const dt = new Date(d.date);
    return dt.toLocaleDateString('en-IN', {day:'numeric', month:'short'});
  });
  const totals = data.map(d => parseFloat(d.total));
  const counts = data.map(d => parseInt(d.count));

  if (chart) chart.destroy();

  const ctx = document.getElementById('salesChart').getContext('2d');
  chart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        label: 'Sales (₹)',
        data: totals,
        backgroundColor: 'rgba(21,101,192,.15)',
        borderColor: '#1565C0',
        borderWidth: 2,
        borderRadius: 6,
        borderSkipped: false,
      }, {
        label: 'Invoices',
        data: counts,
        type: 'line',
        borderColor: '#4CAF50',
        backgroundColor: 'rgba(76,175,80,.1)',
        borderWidth: 2,
        fill: true,
        tension: 0.4,
        yAxisID: 'y1',
        pointBackgroundColor: '#4CAF50',
        pointRadius: 4,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: {
        legend: { position: 'top', labels: { usePointStyle: true, boxWidth: 8 } },
        tooltip: {
          callbacks: {
            label: ctx => ctx.dataset.label === 'Sales (₹)'
              ? ` ₹${ctx.parsed.y.toLocaleString('en-IN')}`
              : ` ${ctx.parsed.y} invoices`
          }
        }
      },
      scales: {
        y:  { grid: { color: '#F0F4F8' }, ticks: { callback: v => '₹' + (v/1000).toFixed(0) + 'k' } },
        y1: { position: 'right', grid: { display: false }, ticks: { stepSize: 1 } },
        x:  { grid: { display: false } }
      }
    }
  });

  // Highlight active button
  document.querySelectorAll('.btn-group .btn').forEach(b => b.classList.remove('active'));
  event?.target?.classList.add('active');
}

loadChart(30);
</script>
@endpush