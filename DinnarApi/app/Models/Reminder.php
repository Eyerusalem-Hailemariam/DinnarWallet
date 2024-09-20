<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reminder extends Model
{
    protected $fillable = [
        'title',
        'descripition',
        'date_time',
        'category',
        'repeat_option',
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

