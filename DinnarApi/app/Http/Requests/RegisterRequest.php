<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize()
    {
        return true;
    }

    public function rules()
    {
        return [
            'name' => 'required|string|min:3',
            'email' => 'required|email|unique:users,email',
            'phone' => 'required|string|min:4|unique:users',
            'password' => 'required|string|min:6|confirmed', // Laravel automatically checks for password_confirmation
            'password_confirmation' => 'required|string|min:6', // Explicitly include password_confirmation
        ];
    }
}


