<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CategoryController extends Controller
{
    // Store a new category for the authenticated user
    public function store(Request $request)
    {
        \Log::info('Incoming request data:', $request->all());

        // Validate the incoming request data
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'icon' => 'required|string',
            'color' => 'required|string',
        ]);

        \Log::debug('Validated data:', $validated); // Log validated data

        // Create a new category for the authenticated user
        $category = Category::create(array_merge($validated, ['user_id' => Auth::id()]));

        // Return a JSON response with the created category and a 201 status code
        return response()->json([
            'id' => $category->id, 
            'user_id' => $category->user_id,
            'name' => $category->name,
            'icon' => $category->icon,
            'color' => $category->color,
        ], 201);
    }

    // Retrieve all categories for the authenticated user
   // Retrieve all categories for the authenticated user
public function index()
{
    // Get all categories that belong to the authenticated user
    $categories = Category::where('user_id', Auth::id())->get();

    // Return a JSON response with the list of categories
    return response()->json($categories);
}

}
