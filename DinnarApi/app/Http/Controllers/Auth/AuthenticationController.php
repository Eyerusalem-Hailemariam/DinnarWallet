<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Mail\VerifyEmail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class AuthenticationController extends Controller
{  
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|min:3',
            'email' => 'required|email|unique:users',
            'phone' => 'required|string|min:4|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'password_confirmation' => 'required|string|min:6',
        ]);
    
        if ($validator->fails()) {
            $errors = $validator->errors();
            $messages = [];
    
            if ($errors->has('email')) {
                $messages['email'] = 'This email is already registered.';
            }
    
            if ($errors->has('phone')) {
                $messages['phone'] = 'This phone number is already registered.';
            }
    
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $errors
            ], 422);
        }
    
        // Generate a 6-digit verification code
        $verificationCode = random_int(100000, 999999);
    
        // Create the user and store the verification code
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'verification_code' => $verificationCode, // Store the verification code
        ]);
    
        // Send the verification code via email
        Mail::to($user->email)->send(new VerifyEmail($user, $verificationCode));
    
        return response()->json([
            'message' => 'Registration successful. Please check your email for the verification code.',
            'user' => $user
        ], 201);
    }
    

    public function login(Request $request)
    {

    $validator = Validator::make($request->all(), [
        'email' => 'required|email',
        'password' => 'required|string|min:6',
    ]);

    if ($validator->fails()) {
        return response()->json([
            'message' => 'Validation failed',
            'errors' => $validator->errors()
        ], 422);
    }

    $user = User::where('email', $request->email)->first();

    if (!$user) {
        return response()->json(['message' => 'Email not found'], 404);
    }
    if ($user->email_verified_at===null) {
       $verificationCode = random_int(100000, 999999);
 
      
        $user->update(['verification_code' => $verificationCode, // Store the verification code
        ]);
    
        // Send the verification code via email
        Mail::to($user->email)->send(new VerifyEmail($user, $verificationCode));
        return response()->json(['message' => 'unverified'], 404);
       

    }
    if (!Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Incorrect password'], 401);
    }

    $token = $user->createToken('walletapp')->plainTextToken;

    return response()->json([
        'user_id' => $user->id, 
        'token' => $token
    ], 200);
    }

    // API Endpoint to Verify the Code
    public function verifyEmail(Request $request)
{
    // Validate the verification code
    $request->validate([
        'verification_code' => 'required|string'
    ]);

    // Find the user by the verification code
    $user = User::where('verification_code', $request->verification_code)->first();

    // If no user found or the code is invalid, return an error response
    if (!$user) {
        return response()->json(['message' => 'The provided verification code is invalid.'], 422);
    }

    // Mark the email as verified and clear the verification code
    $user->email_verified_at = now();
    $user->verification_code = null;
    $user->save();

    // Return a success response
    return response()->json(['message' => 'Your email has been verified.'], 200);
}

public function logout(Request $request)
{
    try {
        // Ensure the user is authenticated
        $user = $request->user();
        
        if ($user) {
            // Delete all tokens for the user
            $user->tokens()->delete();

            return response()->json([
                'message' => 'Successfully logged out.'
            ], 200);
        } else {
            return response()->json([
                'message' => 'User not authenticated.'
            ], 401);
        }
    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Logout failed.',
            'error' => $e->getMessage()
        ], 500);
    }
}



// Method to send the reset code to the user's email
public function sendResetCode(Request $request)
{
    $request->validate([
        'email' => 'required|email|exists:users,email',
    ]);

    $user = User::where('email', $request->email)->first();
    
    if (!$user) {
        return response()->json(['message' => 'User not found.'], 404);
    }

    $resetCode = random_int(100000, 999999);
    $user->reset_code = $resetCode;
    $user->save();

    // Send the reset code to the user's email
    Mail::to($user->email)->send(new \App\Mail\ResetPassword($user, $resetCode));

    return response()->json(['message' => 'Reset code sent to your email.'], 200);
}

// Method to reset the user's password using the reset code
public function resetPassword(Request $request)
{
    $request->validate([
        'reset_code' => 'required|numeric',
        'email' => 'required|email',
        'password' => 'required|string|min:6|confirmed',
        'password_confirmation' => 'required|string|min:6',
    ]);

    $user = User::where('email', $request->email)
                ->where('reset_code', $request->reset_code)
                ->first();

    if (!$user) {
        return response()->json(['message' => 'Invalid reset code or email.'], 422);
    }

    $user->password = Hash::make($request->password);
    $user->reset_code = null; // Clear the reset code after successful reset
    $user->save();

    return response()->json(['message' => 'Password reset successful.'], 200);
}


}
  






