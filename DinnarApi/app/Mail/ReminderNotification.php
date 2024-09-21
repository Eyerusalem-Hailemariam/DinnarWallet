<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ReminderNotification extends Mailable
{
    use Queueable, SerializesModels;

    public $title;
    public $description;
    public $dateTime;

    public function __construct($title, $description, $dateTime)
    {
        $this->title = $title;
        $this->description = $description;
        $this->dateTime = $dateTime;
    }

    public function build()
    {
        return $this->subject($this->title)
                    ->view('emails.reminder') // Ensure the view exists: resources/views/emails/reminder.blade.php
                    ->with([
                        'title' => $this->title,
                        'description' => $this->description,
                        'dateTime' => $this->dateTime,
                    ]);
    }
}
