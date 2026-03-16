{{-- resources/views/admin/reports/top-products.blade.php --}}
@extends('admin.layouts.app')
@section('title', 'Top Selling Products')
@section('breadcrumb')
  <li class="breadcrumb-item active">Top Products</li>
@endsection

@section('content')

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
          <i class="bi bi-filter me-1"></i>Filter
        </button>
      </div>
    </form>
  </div>
</div>

<div class="row g-3">

  {{-- Chart --}}
  <div class="col-lg-6">
    <div class="admin-card">
      <div class="card-header">
        <i class="bi bi-pie-chart me-2 text-primary"></i>Sales Distribution
      </div>
      <div class="p-3">
        <canvas id="topChart" height="220"></canvas>
      </div>
    </div>
  </div>

  {{-- Table --}}
  <div class="col-lg-6">
    <div class="admin-card">
      <div class="card-header">
        <i class="bi bi-trophy me-2 text-warning"></i>Top 20 Products
      </div>
      <div class="table-responsive" style="max-height:420px;overflow-y:auto">
        <table class="table admin-table mb-0">
          <thead>
            <tr>
              <th>#</th>
              <th>Product</th>
              <th class="text-center">Units</th>
              <th class="text-end">Revenue</th>
            </tr>
          </thead>
          <tbody>
            @forelse($topProducts as $i => $tp)
            <tr>
              <td>
                <div class="d-flex align-items-center justify-content-center rounded-circle
                     text-white fw-bold" style="width:26px;height:26px;font-size:.75rem;
                     background:{{ ['#1565C0','#1976D2','#42A5F5','#90CAF9','#BBDEFB'][$i] ?? '#E3F2FD' }}">
                  {{ $i + 1 }}
                </div>
              </td>
              <td>
                <div class="fw-bold small">{{ $tp->product->name ?? 'Unknown' }}</div>
                <div class="progress mt-1" style="height:3px">
                  <div class="progress-bar bg-primary"
                       style="width:{{ min(100, ($tp->total_qty / ($topProducts->first()->total_qty ?? 1)) * 100) }}%">
                  </div>
                </div>
              </td>
              <td class="text-center fw-bold">{{ $tp->total_qty }}</td>
              <td class="text-end fw-bold text-primary">₹{{ number_format($tp->total_revenue, 0) }}</td>
            </tr>
            @empty
            <tr><td colspan="4" class="text-center py-4 text-muted">No data</td></tr>
            @endforelse
          </tbody>
        </table>
      </div>
    </div>
  </div>

</div>
@endsection

@push('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
const top5 = @json($topProducts->take(5));
new Chart(document.getElementById('topChart'), {
  type: 'doughnut',
  data: {
    labels: top5.map(p => p.product?.name ?? 'Unknown'),
    datasets: [{
      data: top5.map(p => p.total_revenue),
      backgroundColor: ['#1565C0','#1976D2','#2196F3','#64B5F6','#BBDEFB'],
      borderWidth: 0,
      hoverOffset: 6,
    }]
  },
  options: {
    responsive: true,
    plugins: {
      legend: { position: 'bottom', labels: { usePointStyle: true, boxWidth: 8, font: { size: 11 } } },
      tooltip: {
        callbacks: {
          label: ctx => ` ₹${ctx.parsed.toLocaleString('en-IN')} (${ctx.label})`
        }
      }
    },
    cutout: '65%',
  }
});
</script>
@endpush