<?php

namespace App\Http\Controllers\Expense;

use App\Http\Controllers\Controller;
use App\Http\Requests\PostRequest;
use App\Models\Expense;
use Illuminate\Http\Request;

class ExpenseController extends Controller
{
    /**
     * Display a listing of the expenses.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        $expenses = auth()->user()->expenses()->with('user')->get();
        return response()->json([
            'expenses' => $expenses
        ], 200);
    }

    /**
     * Store a newly created expense in storage.
     *
     * @param  \App\Http\Requests\PostRequest  $request
     * @return \Illuminate\Http\Response
     */
    public function store(PostRequest $request)
    {
        $validated = $request->validated();

        $expense = auth()->user()->expenses()->create([
            'amount' => $validated['amount'],
            'category' => $validated['category'],
            'description' => $validated['description'],
            'date' => $validated['date'],
        ]);

        return response()->json([
            'message' => 'Expense created successfully',
            'expense' => $expense
        ], 201);
    }
}
