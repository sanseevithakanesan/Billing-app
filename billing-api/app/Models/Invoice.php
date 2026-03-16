<?php
// app/Models/Invoice.php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Invoice extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'customer_id', 'invoice_no',
        'subtotal', 'tax_percent', 'tax_amount',
        'discount_amount', 'total', 'status', 'notes',
    ];

    protected $casts = [
        'subtotal'        => 'float',
        'tax_percent'     => 'float',
        'tax_amount'      => 'float',
        'discount_amount' => 'float',
        'total'           => 'float',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function items()
    {
        return $this->hasMany(InvoiceItem::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Status badge color helper
    public function getStatusColorAttribute(): string
    {
        return match ($this->status) {
            'paid'      => 'green',
            'unpaid'    => 'orange',
            'cancelled' => 'red',
            default     => 'grey',
        };
    }
}

// ============================================
// app/Models/InvoiceItem.php
// ============================================
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InvoiceItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'invoice_id', 'product_id', 'qty', 'unit_price', 'line_total',
    ];

    protected $casts = [
        'unit_price' => 'float',
        'line_total' => 'float',
    ];

    public function product()
    {
        return $this->belongsTo(Product::class);
    }

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}