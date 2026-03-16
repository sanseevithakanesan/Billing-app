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
    // ==========================================
    // REGISTER — புதிய user பதிவு
    // POST /api/auth/register
    // ==========================================
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

        // Email சரியா என்று பார்க்கவும்
        $user = User::where('email', $request->email)->first();

        // Password சரியா என்று பார்க்கவும்
        // if (! $user || ! Hash::check($request->password, $user->password)) {
        //     return response()->json([
        //         'message' => 'Email அல்லது Password தவறு',
        //     ], 401);
        // }

        // பழைய tokens delete செய்யவும் (optional)
        $user->tokens()->delete();

        // புதிய token உருவாக்கவும்
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

    // ==========================================
    // ME — தற்போதைய user info
    // GET /api/auth/me
    // Header: Authorization: Bearer {token}
    // ==========================================
    public function me(Request $request)
    {
        return response()->json([
            'user' => $request->user(),
        ]);
    }

    // ==========================================
    // LOGOUT — வெளியேறு
    // POST /api/auth/logout
    // Header: Authorization: Bearer {token}
    // ==========================================
    public function logout(Request $request)
    {
        // தற்போதைய token மட்டும் delete செய்யவும்
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logged out successfully',
        ]);
    }

    // ==========================================
    // LOGOUT ALL — அனைத்து devices-லும் logout
    // POST /api/auth/logout-all
    // ==========================================
    public function logoutAll(Request $request)
    {
        // அனைத்து tokens-ம் delete ஆகும்
        $request->user()->tokens()->delete();

        return response()->json([
            'message' => 'Logged out from all devices',
        ]);
    }
}