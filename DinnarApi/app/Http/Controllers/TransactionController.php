<?php

namespace App\Http\Controllers;

use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log; 
use App\Models\Category;

use Illuminate\Support\Facades\Auth;


class TransactionController extends Controller
{
    // Store a new transaction
    public function store(Request $request)
    {
        \Log::info('Incoming request data:', $request->all()); // Log the incoming data
    
        // Validate the incoming request data
        $validated = $request->validate([
            'category_id' => 'required|exists:categories,id',
            'transaction_date' => 'required|date',
            'amount' => 'required|numeric',
            'type' => 'required|in:Income,Expense',
            'limit' => 'nullable|numeric',
        ]);
    
        \Log::debug('Validated data:', $validated); // Log validated data
    
        // Create a new transaction with the validated data
        $transaction = Transaction::create(array_merge($validated, ['user_id' => Auth::id()]));
    
        // Return a JSON response with the created transaction and a 201 status code
        return response()->json([
            'id' => $transaction->id,
            'user_id' => $transaction->user_id,
            'category_id' => $transaction->category_id,
            'transaction_date' => $transaction->transaction_date,
            'amount' => $transaction->amount,
            'type' => $transaction->type,
            'limit' => $transaction->limit,
        ], 201);
    }
    
    public function index()
    {
        $transactions = Transaction::where('user_id', Auth::id())
            ->with('category')
            ->get();

        return response()->json($transactions->map(function($transaction) {
            return [
                'id' => $transaction->id,
                'user_id' => $transaction->user_id,
                'category_id' => $transaction->category_id,
                'transaction_date' => $transaction->transaction_date,
                'amount' => $transaction->amount,
                'type' => $transaction->type,
                'limit' => $transaction->limit,
                'category' => [
                    'name' => $transaction->category->name,
                    'icon' => $transaction->category->icon,
                    'color' => $transaction->category->color,
                ],
            ];
        }));
    }

    public function updateLimitByCategory(Request $request, $categoryId)
    {
        // Validate the incoming request data
        $validated = $request->validate([
            'limit' => 'required|numeric|min:0',
        ]);

        // Find the transaction for the current user
        $transaction = Transaction::where('category_id', $categoryId)
            ->where('user_id', Auth::id())
            ->first();

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        // Check if the transaction type is 'Expense'
        if ($transaction->type !== 'Expense') {
            return response()->json(['message' => 'Limit can only be set for Expense type transactions'], 400);
        }

        // Update the limit
        $transaction->update(['limit' => $validated['limit']]);

        return response()->json(['message' => 'Limit updated successfully']);
    }

    public function destroy($id)
    {
        \Log::info('Attempting to delete transaction with ID: ' . $id);

        $transaction = Transaction::where('id', $id)
            ->where('user_id', Auth::id())
            ->first();

        if ($transaction) {
            \Log::info('Transaction found: ', $transaction->toArray());
            $transaction->delete();
            \Log::info('Transaction deleted successfully.');
            return response()->json(['message' => 'Transaction deleted successfully.']);
        } else {
            \Log::warning('Transaction not found for ID: ' . $id);
            return response()->json(['message' => 'Transaction not found.'], 404);
        }
    }
}
