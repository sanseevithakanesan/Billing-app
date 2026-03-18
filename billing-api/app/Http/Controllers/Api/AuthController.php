<?php

    namespace App\Http\Controllers\Api;

    use App\Http\Controllers\Controller;
    use App\Models\User;
    use Illuminate\Http\Request;
    use Illuminate\Support\Facades\Auth;
    use Illuminate\Support\Facades\Hash;
    use Illuminate\Validation\ValidationException;

    class AuthController extends Controller
    {
        
        public function register(Request $request)
        {
            $validated = $request->validate([
                'name'                  => 'required|string|max:255',
                'email'                 => 'required|email|unique:users,email',
                'password'              => 'required|string|min:6|confirmed',
            ]);

            $user = User::create([
                'name'     => $validated['name'],
                'email'    => $validated['email'],
                'password' => Hash::make($validated['password']),
            ]);

            $token = $user->createToken('billing-app-token')->plainTextToken;

            return response()->json([
                'message' => 'Registration successful',
                'user'    => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                ],
                'token'   => $token,
            ], 201);
        }

    
        public function login(Request $request)
        {
            $request->validate([
                'email'    => 'required|email',
                'password' => 'required|string',
            ]);

        
            $user = User::where('email', $request->email)->first();

            if (! $user || ! Hash::check($request->password, $user->password)) {
                return response()->json([
                    'message' => 'Email or Password is incorrect',
                ], 401);
            }

        
            $user->tokens()->delete();

            
            $token = $user->createToken('billing-app-token')->plainTextToken;

            return response()->json([
                'message' => 'Login successful',
                'user'    => [
                    'id'    => $user->id,
                    'name'  => $user->name,
                    'email' => $user->email,
                ],
                'token'   => $token,
            ]);
        }

    
        public function me(Request $request)
        {
            return response()->json([
                'user' => $request->user(),
            ]);
        }

    
        public function logout(Request $request)
        {
            
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'message' => 'Logged out successfully',
            ]);
        }

        
        public function logoutAll(Request $request)
        {
            $request->user()->tokens()->delete();

            return response()->json([
                'message' => 'Logged out from all devices',
            ]);
        }
    }