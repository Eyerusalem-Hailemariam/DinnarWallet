<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Messages\DatabaseMessage;

class ReminderNotification extends Notification implements ShouldQueue
{
    use Queueable;

    public $reminder;

    public function __construct($reminder)
    {
        $this->reminder = $reminder;
    }

    public function via($notifiable)
    {
        return ['mail', 'database']; // Send both email and in-app notification
    }

    public function toDatabase($notifiable)
    {
        return [
            'title' => $this->reminder->title,
            'message' => 'Your reminder for ' . $this->reminder->title . ' is due.',
            'due_date' => $this->reminder->date_time,
        ];
    }

    public function toMail($notifiable)
    {
        return (new MailMessage)
            ->subject('Reminder Due: ' . $this->reminder->title)
            ->line('Your reminder "' . $this->reminder->title . '" is due.')
            ->line('Due Date: ' . $this->reminder->date_time);
    }
}
