<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Reminder;
use Carbon\Carbon;
use Illuminate\Support\Facades\Notification;
use App\Notifications\ReminderNotification;

class CheckReminders extends Command
{
    protected $signature = 'reminders:check';
    protected $description = 'Check for reminders due soon and send notifications';

    public function __construct()
    {
        parent::__construct();
    }

    public function handle()
    {
        $now = Carbon::now();
        $soon = $now->copy()->addMinutes(30); // Change the time frame as needed

        // Fetch reminders due within the next 30 minutes
        $reminders = Reminder::whereBetween('date_time', [$now, $soon])
            ->get();

        foreach ($reminders as $reminder) {
            // Notify the user
            $reminder->user->notify(new ReminderNotification($reminder));
        }

        $this->info('Reminder check completed.');
    }
}
