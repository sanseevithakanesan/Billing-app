{{-- resources/views/admin/layouts/app.blade.php --}}
<!DOCTYPE html>
<html lang="ta">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>@yield('title', 'Admin') — Billing System</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <style>
    :root {
      --primary: #1565C0;
      --primary-dark: #0D47A1;
      --primary-light: #E3F2FD;
      --sidebar-width: 260px;
      --topbar-height: 60px;
    }
    body { background: #F0F4F8; font-family: 'Segoe UI', sans-serif; }

    /* Sidebar */
    .sidebar {
      width: var(--sidebar-width);
      height: 100vh;
      position: fixed;
      top: 0; left: 0;
      background: linear-gradient(180deg, #0D47A1 0%, #1565C0 50%, #1976D2 100%);
      z-index: 1000;
      overflow-y: auto;
      transition: transform .3s;
    }
    .sidebar-brand {
      padding: 20px 20px 16px;
      border-bottom: 1px solid rgba(255,255,255,.1);
    }
    .sidebar-brand h5 { color: #fff; font-weight: 700; margin: 0; font-size: 1.1rem; }
    .sidebar-brand small { color: rgba(255,255,255,.6); font-size: .75rem; }
    .sidebar-nav { padding: 12px 0; }
    .sidebar-section {
      padding: 8px 20px 4px;
      font-size: .7rem;
      font-weight: 700;
      text-transform: uppercase;
      letter-spacing: .08em;
      color: rgba(255,255,255,.4);
    }
    .sidebar-link {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 20px;
      color: rgba(255,255,255,.8);
      text-decoration: none;
      border-radius: 0;
      transition: all .2s;
      font-size: .9rem;
      border-left: 3px solid transparent;
    }
    .sidebar-link:hover, .sidebar-link.active {
      background: rgba(255,255,255,.12);
      color: #fff;
      border-left-color: #fff;
    }
    .sidebar-link i { font-size: 1rem; width: 20px; }

    /* Topbar */
    .topbar {
      height: var(--topbar-height);
      margin-left: var(--sidebar-width);
      background: #fff;
      border-bottom: 1px solid #E0E7EF;
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 0 24px;
      position: sticky;
      top: 0;
      z-index: 999;
    }
    .topbar .page-title { font-weight: 700; font-size: 1.05rem; color: #1a1a2e; }
    .topbar .breadcrumb { font-size: .8rem; margin: 0; }

    /* Main content */
    .main-content {
      margin-left: var(--sidebar-width);
      padding: 24px;
      min-height: 100vh;
    }

    /* Stat cards */
    .stat-card {
      background: #fff;
      border-radius: 14px;
      padding: 20px;
      border: none;
      box-shadow: 0 2px 12px rgba(21,101,192,.06);
      transition: transform .2s, box-shadow .2s;
      overflow: hidden;
      position: relative;
    }
    .stat-card:hover { transform: translateY(-2px); box-shadow: 0 6px 24px rgba(21,101,192,.12); }
    .stat-card .icon-wrap {
      width: 52px; height: 52px;
      border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      font-size: 1.4rem;
    }
    .stat-card .stat-value { font-size: 1.6rem; font-weight: 800; color: #1a1a2e; margin: 8px 0 2px; }
    .stat-card .stat-label { font-size: .8rem; color: #6b7280; font-weight: 500; }
    .stat-card .stat-change { font-size: .75rem; font-weight: 600; }
    .stat-card .bg-decoration {
      position: absolute; right: -10px; bottom: -10px;
      font-size: 5rem; opacity: .06; color: #1565C0;
    }

    /* Cards */
    .admin-card {
      background: #fff;
      border-radius: 14px;
      border: none;
      box-shadow: 0 2px 12px rgba(21,101,192,.06);
    }
    .admin-card .card-header {
      background: transparent;
      border-bottom: 1px solid #F0F4F8;
      padding: 16px 20px;
      font-weight: 700;
      font-size: .95rem;
      color: #1a1a2e;
    }

    /* Table */
    .admin-table { font-size: .88rem; }
    .admin-table thead th {
      background: #F8FAFC;
      color: #6b7280;
      font-weight: 600;
      font-size: .78rem;
      text-transform: uppercase;
      letter-spacing: .05em;
      border-bottom: 1px solid #E0E7EF;
      padding: 10px 16px;
    }
    .admin-table tbody td {
      padding: 12px 16px;
      vertical-align: middle;
      border-bottom: 1px solid #F5F7FA;
      color: #374151;
    }
    .admin-table tbody tr:hover { background: #F8FAFF; }

    /* Badges */
    .badge-paid    { background: #DCFCE7; color: #166534; padding: 4px 10px; border-radius: 20px; font-size: .75rem; font-weight: 600; }
    .badge-unpaid  { background: #FEF3C7; color: #92400E; padding: 4px 10px; border-radius: 20px; font-size: .75rem; font-weight: 600; }
    .badge-cancelled { background: #FEE2E2; color: #991B1B; padding: 4px 10px; border-radius: 20px; font-size: .75rem; font-weight: 600; }

    /* Alert flash */
    .flash-alert { position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 280px; }

    /* Form */
    .form-label { font-size: .85rem; font-weight: 600; color: #374151; }
    .form-control, .form-select {
      border: 1px solid #E0E7EF;
      border-radius: 8px;
      font-size: .9rem;
      padding: 8px 12px;
    }
    .form-control:focus, .form-select:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 3px rgba(21,101,192,.1);
    }

    /* Btn */
    .btn-primary { background: var(--primary); border-color: var(--primary); border-radius: 8px; }
    .btn-primary:hover { background: var(--primary-dark); border-color: var(--primary-dark); }
    .btn-outline-primary { color: var(--primary); border-color: var(--primary); border-radius: 8px; }

    @media (max-width: 768px) {
      .sidebar { transform: translateX(-100%); }
      .sidebar.show { transform: translateX(0); }
      .topbar, .main-content { margin-left: 0; }
    }
  </style>
  @stack('styles')
</head>
<body>

{{-- Sidebar --}}
<aside class="sidebar" id="sidebar">
  <div class="sidebar-brand">
    <h5><i class="bi bi-receipt me-2"></i>Billing Admin</h5>
    <small>Management System</small>
  </div>
  <nav class="sidebar-nav">
    <div class="sidebar-section">Main</div>
    <a href="{{ route('admin.dashboard') }}"
       class="sidebar-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
      <i class="bi bi-grid-1x2"></i> Dashboard
    </a>

    <div class="sidebar-section">Products</div>
    <a href="{{ route('admin.products.index') }}"
       class="sidebar-link {{ request()->routeIs('admin.products.*') ? 'active' : '' }}">
      <i class="bi bi-box-seam"></i> Products
    </a>
    <a href="{{ route('admin.products.create') }}"
       class="sidebar-link {{ request()->routeIs('admin.products.create') ? 'active' : '' }}">
      <i class="bi bi-plus-circle"></i> Add Product
    </a>

    <div class="sidebar-section">Reports</div>
    <a href="{{ route('admin.reports.sales') }}"
       class="sidebar-link {{ request()->routeIs('admin.reports.sales') ? 'active' : '' }}">
      <i class="bi bi-bar-chart"></i> Sales Report
    </a>
    <a href="{{ route('admin.reports.daily') }}"
       class="sidebar-link {{ request()->routeIs('admin.reports.daily') ? 'active' : '' }}">
      <i class="bi bi-calendar3"></i> Daily Sales
    </a>
    <a href="{{ route('admin.reports.top') }}"
       class="sidebar-link {{ request()->routeIs('admin.reports.top') ? 'active' : '' }}">
      <i class="bi bi-trophy"></i> Top Products
    </a>
  </nav>
</aside>

{{-- Topbar --}}
<header class="topbar">
  <div class="d-flex align-items-center gap-3">
    <button class="btn btn-sm btn-outline-secondary d-md-none" onclick="toggleSidebar()">
      <i class="bi bi-list"></i>
    </button>
    <div>
      <div class="page-title">@yield('title', 'Dashboard')</div>
      <nav aria-label="breadcrumb">
        <ol class="breadcrumb mb-0">
          <li class="breadcrumb-item"><a href="{{ route('admin.dashboard') }}" class="text-muted">Admin</a></li>
          @yield('breadcrumb')
        </ol>
      </nav>
    </div>
  </div>
  <div class="d-flex align-items-center gap-3">
    <span class="badge bg-success">
      <i class="bi bi-circle-fill me-1" style="font-size:.5rem"></i>Online
    </span>
    <div class="rounded-circle bg-primary text-white d-flex align-items-center justify-content-center"
         style="width:36px;height:36px;font-weight:700">A</div>
  </div>
</header>

{{-- Flash Messages --}}
@if(session('success'))
<div class="flash-alert">
  <div class="alert alert-success alert-dismissible shadow" role="alert">
    <i class="bi bi-check-circle me-2"></i>{{ session('success') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</div>
@endif
@if(session('error'))
<div class="flash-alert">
  <div class="alert alert-danger alert-dismissible shadow" role="alert">
    <i class="bi bi-exclamation-circle me-2"></i>{{ session('error') }}
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
</div>
@endif

{{-- Main Content --}}
<main class="main-content">
  @yield('content')
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function toggleSidebar() {
  document.getElementById('sidebar').classList.toggle('show');
}
// Auto-hide flash
setTimeout(() => {
  document.querySelectorAll('.flash-alert .alert').forEach(el => {
    new bootstrap.Alert(el).close();
  });
}, 4000);
</script>
@stack('scripts')
</body>
</html>