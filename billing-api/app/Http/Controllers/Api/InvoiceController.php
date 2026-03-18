<?php
    namespace App\Http\Controllers\Api;

    use App\Http\Controllers\Controller;
    use App\Models\Invoice;
    use App\Models\InvoiceItem;
    use App\Models\Product;
    use App\Models\Customer;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\DB;

    class InvoiceController extends Controller
    {
        
        public function index(Request $request)
        {
            $invoices = Invoice::with(['customer', 'items.product'])
                ->orderBy('created_at', 'desc')
                ->paginate(20);

            return response()->json($invoices);
        }

    
        public function show($id)
        {
            $invoice = Invoice::with(['customer', 'items.product', 'user'])
                ->findOrFail($id);

            return response()->json($invoice);
        }

        
        public function store(Request $request)
        {
            $validated = $request->validate([
                'customer_id'     => 'required|exists:customers,id',
                'tax_percent'     => 'nullable|numeric|min:0|max:100',
                'discount_amount' => 'nullable|numeric|min:0',
                'notes'           => 'nullable|string|max:500',
                'items'           => 'required|array|min:1',
                'items.*.product_id' => 'required|exists:products,id',
                'items.*.qty'        => 'required|integer|min:1',
            ]);

        
            return DB::transaction(function () use ($validated, $request) {
                $date        = now()->format('Ymd');
                $lastInvoice = Invoice::whereDate('created_at', today())->count();
                $sequence    = str_pad($lastInvoice + 1, 4, '0', STR_PAD_LEFT);
                $invoiceNo   = "INV-{$date}-{$sequence}";

                // ── Calculate totals ─────────────────────
                $subtotal       = 0;
                $itemsData      = [];
                $taxPercent     = $validated['tax_percent']     ?? 5;
                $discountAmount = $validated['discount_amount'] ?? 0;

                foreach ($validated['items'] as $item) {
                    $product   = Product::findOrFail($item['product_id']);
                    $lineTotal = $product->price * $item['qty'];
                    $subtotal += $lineTotal;

                    $itemsData[] = [
                        'product_id' => $product->id,
                        'qty'        => $item['qty'],
                        'unit_price' => $product->price,
                        'line_total' => $lineTotal,
                    ];
                    $product->decrement('stock_qty', $item['qty']);
                }

                $taxAmount   = $subtotal * ($taxPercent / 100);
                $grandTotal  = $subtotal + $taxAmount - $discountAmount;

                // ── Invoice create ───────────────────────
                $invoice = Invoice::create([
                    'user_id'         => auth()->id(),
                    'customer_id'     => $validated['customer_id'],
                    'invoice_no'      => $invoiceNo,
                    'subtotal'        => $subtotal,
                    'tax_percent'     => $taxPercent,
                    'tax_amount'      => $taxAmount,
                    'discount_amount' => $discountAmount,
                    'total'           => $grandTotal,
                    'status'          => 'unpaid',
                    'notes'           => $validated['notes'] ?? null,
                ]);

                // ── Invoice Items save ───────────────────
                foreach ($itemsData as $itemData) {
                    InvoiceItem::create(array_merge(
                        $itemData,
                        ['invoice_id' => $invoice->id]
                    ));
                }

                // ── Load relationships ───────────────────
                $invoice->load(['customer', 'items.product', 'user']);

                return response()->json([
                    'message' => 'Invoice created successfully',
                    'invoice' => $invoice,
                ], 201);
            });
        }

        
        public function updateStatus(Request $request, $id)
        {
            $request->validate([
                'status' => 'required|in:paid,unpaid,cancelled',
            ]);

            $invoice = Invoice::findOrFail($id);
            $invoice->update(['status' => $request->status]);

            return response()->json([
                'message' => 'Status updated',
                'invoice' => $invoice,
            ]);
        }

        
        public function destroy($id)
        {
            $invoice = Invoice::findOrFail($id);
            $invoice->update(['status' => 'cancelled']);

            return response()->json(['message' => 'Invoice cancelled']);
        }
    }