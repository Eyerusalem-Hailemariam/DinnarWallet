<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthenticationController;

Route::get('/test', function () {
    return response([
        'message' => 'Api is working'
    ], 200);
});

Route::post('/register', [AuthenticationController::class, 'register']);




