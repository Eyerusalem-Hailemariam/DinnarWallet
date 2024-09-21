<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Reminder;
use Illuminate\Support\Facades\Auth;

class ReminderController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'descripition' => 'nullable|string', // Corrected spelling
            'date_time' => 'required|date',
            'category' => 'required|string',
            'repeat_option' => 'nullable|string',
        ]);

        // Create a new reminder with the validated data
        $reminder = Reminder::create(array_merge($request->all(), ['user_id' => Auth::id()]));

        return response()->json($reminder, 201);
    }

    public function index()
    {
        // Retrieve reminders for the authenticated user
        $reminders = Reminder::where('user_id', Auth::id())->get();

        return response()->json($reminders);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'descripition' => 'nullable|string', // Corrected spelling
            'date_time' => 'required|date',
            'category' => 'required|string',
            'repeat_option' => 'nullable|string',
        ]);

        $reminder = Reminder::where('id', $id)->where('user_id', Auth::id())->firstOrFail();

        $reminder->update($request->all());

        return response()->json($reminder, 200);
    }

    public function destroy($id)
    {
        $reminder = Reminder::where('id', $id)->where('user_id', Auth::id())->first();

        if ($reminder) {
            $reminder->delete();
            return response()->json(['message' => 'Reminder deleted successfully'], 204);
        }

        return response()->json(['message' => 'Reminder not found.'], 404);
    }
}

