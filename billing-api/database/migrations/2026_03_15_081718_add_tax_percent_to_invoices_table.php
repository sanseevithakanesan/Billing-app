<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
{
    Schema::table('invoices', function (Blueprint $table) {
        if (!Schema::hasColumn('invoices', 'tax_percent')) {
            $table->decimal('tax_percent', 5, 2)->default(5)->after('subtotal');
        }
        if (!Schema::hasColumn('invoices', 'discount_amount')) {
            $table->decimal('discount_amount', 10, 2)->default(0)->after('tax_amount');
        }
        if (!Schema::hasColumn('invoices', 'notes')) {
            $table->text('notes')->nullable()->after('status');
        }
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('invoices', function (Blueprint $table) {
            //
        });
    }
};
