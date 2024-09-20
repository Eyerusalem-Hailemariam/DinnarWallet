<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log;
use App\Models\Transaction;
use App\Services\CurrencyConversionService;
use Illuminate\Support\Facades\Hash;



class UserController extends Controller
{

    public function getUser(Request $request){
        return response()->json($request->user());
    }
    public function updateUser(Request $request) {
        // Log request headers for debugging
        \Log::info('Update User Request Headers:', $request->headers->all());
    
        // Fetch the authenticated user
        $user = auth()->user();
    
        // Check if the user is authenticated
        if (!$user) {
            return response()->json(['error' => 'User not authenticated'], 401);
        }
    
        // Validate the input data
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users,email,' . $user->id,
            'phone' => 'nullable|string|max:15',
        ]);
    
        // Update the user's profile details
        $user->name = $request->name;
        $user->email = $request->email;
        $user->phone = $request->phone;
    
        // Save the updated user profile
        $user->save();
    
        return response()->json(['message' => 'Profile updated successfully', 'user' => $user], 200);
    }
    
    

    public function changePassword(Request $request)
{
    // Validate input
    $request->validate([
        'current_password' => 'required',
        'new_password' => 'required|min:6',
    ]);

    $user = auth()->user();

    // Check if the current password matches the user's existing password
    if (!Hash::check($request->current_password, $user->password)) {
        return response()->json(['error' => 'Current password is incorrect'], 400);
    }

    // Update the user's password
    $user->password = Hash::make($request->new_password);
    $user->save();

    return response()->json(['message' => 'Password changed successfully'], 200);
}

    // Update currency preference
    public function updateCurrency(Request $request)
    {
        $request->validate([
            'currency' => 'required|string|in:USD,EUR,GBP,JPY', // Add more currencies as needed
        ]);

        $user = Auth::user();
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        $user->currency = $request->currency;
        $user->save();

        return response()->json(['success' => 'Currency updated'], 200);
    }

    // Fetch user currency preference
    public function fetchCurrency()
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json(['error' => 'User not found'], 404);
        }

        return response()->json(['currency' => $user->currency], 200);
    }

    // Update language preference
  public function updateLanguage(Request $request)
    {
        $request->validate([
            'language' => 'required|string|in:en,am', // Add other languages as needed
        ]);

        $user = Auth::user();
        $user->language = $request->language;
        $user->save();

        return response()->json([
            'message' => 'Language updated successfully',
            'language' => $user->language,
        ]);
    }

    /**
     * Fetch the user's current language preference.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getUserLanguage()
    {
        $user = Auth::user();

        return response()->json([
            'language' => $user->language,
        ]);
    }

   
    protected $currencyConverter;

    public function __construct(CurrencyConversionService $currencyConverter)
    {
        $this->currencyConverter = $currencyConverter;
    }

    public function updateTransactionCurrency(Request $request)
    {
        $request->validate([
            'currency' => 'required|string|max:3',
        ]);
    
        $user = Auth::user();
        $newCurrency = $request->currency;
    
        // Fetch all transactions for the user
        $transactions = Transaction::where('user_id', $user->id)->get();
    
        foreach ($transactions as $transaction) {
            $originalCurrency = $transaction->currency;  // Store the original currency before updating
    
            // Convert the transaction amount
            $convertedAmount = $this->currencyConverter->convert($originalCurrency, $newCurrency, $transaction->amount);
    
            // Check if the conversion was successful
            if ($convertedAmount !== false) {
                // Update transaction with new currency and converted amount
                $transaction->update([
                    'currency' => $newCurrency,
                    'amount' => $convertedAmount,
                ]);
    
                // If the transaction is of type 'Expense', convert the limit
                if ($transaction->type === 'Expense' && isset($transaction->limit)) {
                    // Convert the limit using the original currency
                    $convertedLimit = $this->currencyConverter->convert($originalCurrency, $newCurrency, $transaction->limit);
    
                    // Update the limit if conversion was successful
                    if ($convertedLimit !== false) {
                        $transaction->update(['limit' => $convertedLimit]);
                    }
                }
            }
        }
    
        return response()->json([
            'message' => 'Transaction currency, amounts, and limits updated successfully',
            'currency' => $newCurrency,
        ]);
    }
    
    
    // Fetch the currency used for transactions
    public function getTransactionCurrency()
    {
        $user = Auth::user();
        $transaction = Transaction::where('user_id', $user->id)->first(); // Fetch first transaction

        if ($transaction) {
            return response()->json([
                'currency' => $transaction->currency,
            ]);
        }

        return response()->json([
            'message' => 'No transactions found',
            'currency' => $user->currency, // Fallback to user's currency
        ]);
    }
    
}
