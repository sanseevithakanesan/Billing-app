<?php
// app/Http/Controllers/Admin/ReportController.php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\InvoiceItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ReportController extends Controller
{
    // Sales report with date filter
    public function sales(Request $request)
    {
        $from = $request->from ?? now()->startOfMonth()->toDateString();
        $to   = $request->to   ?? now()->toDateString();

        $invoices = Invoice::with(['customer', 'items'])
            ->whereBetween('created_at', [$from, $to . ' 23:59:59'])
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        $summary = Invoice::whereBetween('created_at', [$from, $to . ' 23:59:59'])
            ->selectRaw('
                COUNT(*) as total_invoices,
                SUM(CASE WHEN status="paid" THEN total ELSE 0 END) as paid_total,
                SUM(CASE WHEN status="unpaid" THEN total ELSE 0 END) as unpaid_total,
                SUM(total) as grand_total
            ')
            ->first();

        return view('admin.reports.sales', compact('invoices', 'summary', 'from', 'to'));
    }

    // Daily sales breakdown
    public function daily(Request $request)
    {
        $month = $request->month ?? now()->format('Y-m');

        $dailySales = Invoice::where('status', 'paid')
            ->whereYear('created_at', substr($month, 0, 4))
            ->whereMonth('created_at', substr($month, 5, 2))
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('COUNT(*) as invoice_count'),
                DB::raw('SUM(total) as total_sales')
            )
            ->groupBy('date')
            ->orderBy('date', 'desc')
            ->get();

        return view('admin.reports.daily', compact('dailySales', 'month'));
    }

    // Top selling products
    public function topProducts(Request $request)
    {
        $from = $request->from ?? now()->startOfMonth()->toDateString();
        $to   = $request->to   ?? now()->toDateString();

        $topProducts = InvoiceItem::select(
                'product_id',
                DB::raw('SUM(qty) as total_qty'),
                DB::raw('SUM(line_total) as total_revenue'),
                DB::raw('COUNT(DISTINCT invoice_id) as invoice_count')
            )
            ->with('product')
            ->whereHas('invoice', function ($q) use ($from, $to) {
                $q->whereBetween('created_at', [$from, $to . ' 23:59:59']);
            })
            ->groupBy('product_id')
            ->orderByDesc('total_qty')
            ->take(20)
            ->get();

        return view('admin.reports.top-products', compact('topProducts', 'from', 'to'));
    }

    // AJAX daily chart data
    public function dailyData(Request $request)
    {
        $days = $request->days ?? 30;

        $data = Invoice::where('status', 'paid')
            ->where('created_at', '>=', now()->subDays($days))
            ->select(
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(total) as total')
            )
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return response()->json($data);
    }
}