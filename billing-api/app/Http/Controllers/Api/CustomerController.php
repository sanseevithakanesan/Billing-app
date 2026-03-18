<?php
    namespace App\Http\Controllers\Api;

    use App\Http\Controllers\Controller;
    use App\Models\Customer;
    use Illuminate\Http\Request;

    class CustomerController extends Controller
    {
        public function index() {
            return response()->json(Customer::all());
        }

        public function store(Request $request) {
            $validated = $request->validate([
                'name'  => 'required|string',
                'phone' => 'required|string|unique:customers,phone',
                'email' => 'nullable|email',
            ]);
            $customer = Customer::create($validated);
            return response()->json($customer, 201);
        }

        public function show($id) {
            return response()->json(Customer::findOrFail($id));
        }

        public function update(Request $request, $id) {
            $customer = Customer::findOrFail($id);
            $customer->update($request->all());
            return response()->json($customer);
        }

        public function destroy($id) {
            Customer::findOrFail($id)->delete();
            return response()->json(['message' => 'Deleted']);
        }
    }