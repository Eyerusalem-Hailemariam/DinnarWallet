<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    // Define the fillable properties
    protected $fillable = ['user_id', 'category_id', 'transaction_date', 'amount', 'type',   'limit','currency' ];

    // Define the relationship with the Category model
    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function setLimitAttribute($value)
    {
        if ($this->type === 'Expense') {
            $this->attributes['limit'] = $value;
        } else {
            // Optionally, you can throw an exception or handle it differently
            throw new \Exception('Limit can only be set for Expense type transactions');
        }
    }
}



