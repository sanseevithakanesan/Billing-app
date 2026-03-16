<?php
// app/Http/Controllers/Admin/DashboardController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\Product;
use App\Models\Customer;
use App\Models\InvoiceItem;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index()
    {
        // ── Summary cards ────────────────────
        $totalSales     = Invoice::where('status', 'paid')->sum('total');
        $todaySales     = Invoice::where('status', 'paid')
                            ->whereDate('created_at', today())
                            ->sum('total');
        $totalInvoices  = Invoice::count();
        $totalProducts  = Product::where('is_active', true)->count();
        $totalCustomers = Customer::count();
        $pendingCount   = Invoice::where('status', 'unpaid')->count();

        // ── Recent invoices ──────────────────
        $recentInvoices = Invoice::with('customer')
                            ->orderBy('created_at', 'desc')
                            ->take(8)
                            ->get();

        // ── Top selling products ─────────────
        $topProducts = InvoiceItem::select(
                'product_id',
                DB::raw('SUM(qty) as total_qty'),
                DB::raw('SUM(line_total) as total_revenue')
            )
            ->with('product')
            ->groupBy('product_id')
            ->orderByDesc('total_qty')
            ->take(5)
            ->get();

        // ── Low stock products ───────────────
        $lowStock = Product::where('is_active', true)
                        ->where('stock_qty', '<=', 10)
                        ->orderBy('stock_qty')
                        ->take(5)
                        ->get();

        // ── Monthly sales (last 6 months) ────
        $monthlySales = Invoice::where('status', 'paid')
            ->where('created_at', '>=', now()->subMonths(6))
            ->select(
                DB::raw("DATE_FORMAT(created_at, '%b %Y') as month"),
                DB::raw('SUM(total) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy('month')
            ->orderBy('created_at')
            ->get();

        return view('admin.dashboard', compact(
            'totalSales', 'todaySales', 'totalInvoices',
            'totalProducts', 'totalCustomers', 'pendingCount',
            'recentInvoices', 'topProducts', 'lowStock', 'monthlySales'
        ));
    }

    public function chartData()
    {
        $data = Invoice::where('status', 'paid')
            ->where('created_at', '>=', now()->subDays(30))
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total) as total'),
                DB::raw('COUNT(*) as count')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return response()->json($data);
    }
}