<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class ResetPassword extends Mailable
{
    use Queueable, SerializesModels;

    public $user;
    public $resetCode;

    public function __construct($user, $resetCode)
    {
        $this->user = $user;
        $this->resetCode = $resetCode;
    }

    public function build()
    {
        return $this->view('emails.reset_password')
                    ->with([
                        'resetCode' => $this->resetCode,
                    ]);
    }
}
