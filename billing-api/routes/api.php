<?php

    use App\Http\Controllers\Api\AuthController;
    use App\Http\Controllers\Api\ProductController;
    use App\Http\Controllers\Api\CustomerController;
    use App\Http\Controllers\Api\InvoiceController;


    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/register', [AuthController::class, 'register']);

    Route::middleware('auth:sanctum')->group(function () {

        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/me', [AuthController::class, 'me']);

        Route::apiResource('products', ProductController::class);
        Route::get('/products/barcode/{code}', [ProductController::class, 'findByBarcode']);

        Route::apiResource('customers', CustomerController::class);
        Route::apiResource('invoices', InvoiceController::class);
        Route::patch('/invoices/{id}/status', [InvoiceController::class, 'updateStatus']);

        Route::get('/customers/{id}/invoices', function($id) {
            $invoices = \App\Models\Invoice::where('customer_id', $id)
                ->orderBy('created_at', 'desc')
                ->get();
            return response()->json(['invoices' => $invoices]);
        });

        Route::patch('/invoices/{id}/customer', [InvoiceController::class, 'updateCustomer']);
    });