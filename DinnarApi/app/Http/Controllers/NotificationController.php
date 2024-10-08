<?php

namespace App\Http\Controllers;
use App\Models\Notification; 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use App\Mail\ReminderNotification;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    public function send(Request $request) {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }
        \Log::info("Notification request received");

        $email = $user->email;
        
        // Validation to ensure the correct data is received
        $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'date_time' => 'required|date',
        ]);
        
        try {
            \Log::info("Preparing to send email...");
            
            // Sending the reminder email
            Mail::to($email)->send(new \App\Mail\ReminderNotification(
                $request->title,
                $request->description,
                $request->date_time // This should match the Flutter format (ISO 8601)
            ));
    
            \Log::info("Email sent to: {$email}");
            return response()->json(['message' => 'Notification sent'], 200);
        } catch (\Exception $e) {
            \Log::error("Email sending failed: " . $e->getMessage());
            return response()->json(['message' => 'Failed to send notification'], 500);
        }
    }
          
    public function updateReminder(Request $request, $id) {
        $user = $request->user();
        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        \Log::info("Update request received for reminder ID: {$id}");

        // Find the existing reminder
        $reminder = Reminder::find($id);
        if (!$reminder) {
            return response()->json(['message' => 'Reminder not found'], 404);
        }

        // Validate the input
        $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'date_time' => 'required|date',
        ]);

        try {
            // Update the reminder
            $reminder->title = $request->title;
            $reminder->description = $request->description;
            $reminder->date_time = $request->date_time;
            $reminder->save();

            // Re-trigger the notification
            \Log::info("Re-scheduling notification for reminder ID: {$id}");

            Mail::to($user->email)->send(new \App\Mail\ReminderNotification(
                $reminder->title,
                $reminder->description,
                $reminder->date_time
            ));

            \Log::info("Reminder updated and email sent to: {$user->email}");
            return response()->json(['message' => 'Reminder updated and notification sent'], 200);
        } catch (\Exception $e) {
            \Log::error("Failed to update reminder: " . $e->getMessage());
            return response()->json(['message' => 'Failed to update reminder'], 500);
        }
    }

    public function store(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:255',
            'category' => 'required|string|max:255',
            'timestamp' => 'required|date',
        ]);

        // Store notification in data column
        $notification = Notification::create([
          
                'message'   => $request->message,
                'category'  => $request->category,
                'timestamp' => $request->timestamp,
            
        ]);

        return response()->json($notification, 201);
    }
    public function index()
    {
        $notifications = Notification::all();
        
        // Log the notifications fetched to see the output in the logs
        Log::info('Fetched notifications:', ['notifications' => $notifications]);
    
        return response()->json($notifications);
    }

    public function destory($id) {
        $notification = Notification::find($id);

        if(!$notification) {
            return response()->json(['message' => 'Notification not found'], 404);
        }
        $notification->delete();

        return response()->json(['message' => 'Notification deleted successfully'], 200);
    }
}
