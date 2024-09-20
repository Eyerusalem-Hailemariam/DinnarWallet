<?php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reminder;

class ReminderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'descripition' => 'nullable|string',
            'date_time' => 'required|date',
            'category' => 'required|string',
            'repeat_option' => 'nullable|string',
        ]);

        $reminder = Reminder::create([
            'title' => $request->title,
            'descripition' => $request->descripition,
            'date_time' => $request->date_time,
            'category' => $request->category,
            'repeat_option' => $request->repeat_option,
        ]);

        return response()->json($reminder, 201);
    }

    public function index()
    {
        return Reminder::all();
    }

    // Laravel: ReminderController.php

public function update(Request $request, $id)
{
    $request->validate([
        'title' => 'required|string|max:255',
        'descripition' => 'nullable|string',
        'date_time' => 'required|date',
        'category' => 'required|string',
        'repeat_option' => 'nullable|string',
    ]);

    $reminder = Reminder::findOrFail($id);

    $reminder->update([
        'title' => $request->title,
        'descripition' => $request->descripition,
        'date_time' => $request->date_time,
        'category' => $request->category,
        'repeat_option' => $request->repeat_option,
    ]);

    return response()->json($reminder, 200);
}

public function destroy($id)
{
    $reminder = Reminder::findOrFail($id);
    $reminder->delete(); // Delete the reminder from the database

    return response()->json(['message' => 'Reminder deleted successfully'], 204); // 204 No Content
}

    
}
