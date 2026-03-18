<?php
    use Illuminate\Support\Facades\Route;
    use App\Http\Controllers\Admin\DashboardController;
    use App\Http\Controllers\Admin\ProductController;
    use App\Http\Controllers\Admin\ReportController;


    Route::get('/', fn() => redirect('/admin'));

    Route::prefix('admin')->name('admin.')->group(function () {
        Route::get('/', [DashboardController::class, 'index'])->name('dashboard');

        // Products
        Route::get('/products',             [ProductController::class, 'index'])->name('products.index');
        Route::get('/products/create',      [ProductController::class, 'create'])->name('products.create');
        Route::post('/products',            [ProductController::class, 'store'])->name('products.store');
        Route::get('/products/{id}/edit',   [ProductController::class, 'edit'])->name('products.edit');
        Route::put('/products/{id}',        [ProductController::class, 'update'])->name('products.update');
        Route::delete('/products/{id}',     [ProductController::class, 'destroy'])->name('products.destroy');
        Route::get('/products/{id}/barcode',[ProductController::class, 'barcode'])->name('products.barcode');

        // Reports
        Route::get('/reports/sales',        [ReportController::class, 'sales'])->name('reports.sales');
        Route::get('/reports/daily',        [ReportController::class, 'daily'])->name('reports.daily');
        Route::get('/reports/top-products', [ReportController::class, 'topProducts'])->name('reports.top');

        // AJAX endpoints
        Route::get('/api/chart-data',       [DashboardController::class, 'chartData'])->name('api.chart');
        Route::get('/api/daily-data',       [ReportController::class, 'dailyData'])->name('api.daily');
    });