{{-- resources/views/admin/reports/daily.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Daily Sales')
@section('breadcrumb')
  <li class="breadcrumb-item active">Daily Sales</li>
@endsection

@section('content')

<div class="row justify-content-center">
  <div class="col-lg-10">

    {{-- Month Filter --}}
    <div class="admin-card mb-4">
      <div class="p-3">
        <form method="GET" class="row g-2 align-items-end">
          <div class="col-md-4">
            <label class="form-label">Month</label>
            <input type="month" name="month" value="{{ $month }}" class="form-control">
          </div>
          <div class="col-md-2">
            <button type="submit" class="btn btn-primary w-100">
              <i class="bi bi-search me-1"></i>Go
            </button>
          </div>
        </form>
      </div>
    </div>

    {{-- Chart --}}
    <div class="admin-card mb-4">
      <div class="card-header">
        <i class="bi bi-calendar3 me-2 text-primary"></i>
        Daily Sales — {{ \Carbon\Carbon::parse($month)->format('F Y') }}
      </div>
      <div class="p-3">
        <canvas id="dailyChart" height="100"></canvas>
      </div>
    </div>

    {{-- Table --}}
    <div class="admin-card">
      <div class="table-responsive">
        <table class="table admin-table mb-0">
          <thead>
            <tr>
              <th>Date</th>
              <th>Day</th>
              <th class="text-center">Invoices</th>
              <th class="text-end">Total Sales</th>
              <th class="text-end">Avg/Invoice</th>
            </tr>
          </thead>
          <tbody>
            @php $grandTotal = 0; @endphp
            @forelse($dailySales as $day)
            @php $grandTotal += $day->total_sales; @endphp
            <tr>
              <td class="fw-bold">{{ \Carbon\Carbon::parse($day->date)->format('d M Y') }}</td>
              <td class="text-muted">{{ \Carbon\Carbon::parse($day->date)->format('l') }}</td>
              <td class="text-center">
                <span class="badge bg-primary rounded-pill">{{ $day->invoice_count }}</span>
              </td>
              <td class="text-end fw-bold text-primary">₹{{ number_format($day->total_sales, 2) }}</td>
              <td class="text-end text-muted">
                ₹{{ number_format($day->total_sales / max($day->invoice_count, 1), 0) }}
              </td>
            </tr>
            @empty
            <tr>
              <td colspan="5" class="text-center py-5 text-muted">
                <i class="bi bi-calendar-x fs-2 d-block mb-2"></i>No sales this month
              </td>
            </tr>
            @endforelse
          </tbody>
          @if($dailySales->count() > 0)
          <tfoot>
            <tr class="table-primary">
              <td colspan="2" class="fw-bold">Total</td>
              <td class="text-center fw-bold">{{ $dailySales->sum('invoice_count') }}</td>
              <td class="text-end fw-bold">₹{{ number_format($grandTotal, 2) }}</td>
              <td></td>
            </tr>
          </tfoot>
          @endif
        </table>
      </div>
    </div>

  </div>
</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
const labels = @json($dailySales->pluck('date')->map(fn($d) => \Carbon\Carbon::parse($d)->format('d M')));
const totals  = @json($dailySales->pluck('total_sales'));

new Chart(document.getElementById('dailyChart'), {
  type: 'bar',
  data: {
    labels,
    datasets: [{
      label: 'Daily Sales (₹)',
      data: totals,
      backgroundColor: labels.map(() => 'rgba(21,101,192,.15)'),
      borderColor: '#1565C0',
      borderWidth: 2,
      borderRadius: 6,
    }]
  },
  options: {
    responsive: true,
    plugins: { legend: { display: false },
      tooltip: { callbacks: { label: ctx => ' ₹' + ctx.parsed.y.toLocaleString('en-IN') } }
    },
    scales: {
      y: { grid: { color: '#F0F4F8' }, ticks: { callback: v => '₹' + (v/1000).toFixed(0) + 'k' } },
      x: { grid: { display: false } }
    }
  }
});
</script>
@endpush


{{-- ============================================================
     resources/views/admin/reports/top-products.blade.php
     ============================================================ --}}