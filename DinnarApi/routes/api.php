<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthenticationController;
use App\Http\Controllers\Expense\ExpenseController;
use App\Http\Controllers\Auth\PasswordResetController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\TranslationController;
use App\Http\Controllers\ReminderController;
use App\Http\Controllers\NotificationController;




Route::get('/test', function () {
    return response([
        'message' => 'API is working'
    ], 200);
});

// Public routes
Route::post('register', [AuthenticationController::class, 'register']);


Route::post('login', [AuthenticationController::class, 'login'])->name('login');

// routes/web.php
Route::get('/verify-email', [AuthenticationController::class, 'showVerifyEmailForm'])->name('verification.notice');
Route::post('/verify-email', [AuthenticationController::class, 'verifyEmail'])->name('verification.verify');
Route::post('/logout', [AuthenticationController::class, 'logout'])->middleware('auth:sanctum');
Route::post('/reset-password', [AuthenticationController::class, 'resetPassword']);
Route::post('/forgot-password', [AuthenticationController::class, 'sendResetCode']);

Route::middleware('auth:api')->group(function () {
Route::post('/categories', [CategoryController::class, 'store']);
Route::get('/categories', [CategoryController::class, 'index']);
});

Route::middleware('auth:api')->group(function () {
Route::post('/transactions', [TransactionController::class, 'store']);
Route::get('/transactions', [TransactionController::class, 'index']);
Route::put('/transactions/{categoryId}', [TransactionController::class, 'updateLimitByCategory']);
Route::delete('/transactions/{id}', [TransactionController::class, 'destroy']);
});

Route::middleware('auth:api')->group(function () {
    Route::post('/user/update-language', [UserController::class, 'updateLanguage']);
    Route::get('/user/language', [UserController::class, 'getUserLanguage']);
    
});
Route::middleware('auth:sanctum')->group(function () {
    Route::put('/update-user', [UserController::class, 'updateUser']);
    Route::get('/user', [UserController::class, 'getUser']);
  
});
Route::get('reminders', [ReminderController::class, 'index']);
Route::post('reminders', [ReminderController::class, 'store']);
Route::put('/reminders/{id}', [ReminderController::class, 'update']);

Route::apiResource('reminders', ReminderController::class);

Route::middleware('auth:api')->post('/change-password', [UserController::class, 'changePassword']);


Route::middleware('auth:api')->group(function () {
    Route::post('user/update-currency', [UserController::class, 'updateCurrency']);
    Route::get('user/currency', [UserController::class, 'fetchCurrency']);

    Route::post('/transactions/update-currency', [UserController::class, 'updateTransactionCurrency']);
    Route::get('/transactions/currency', [UserController::class, 'getTransactionCurrency']);
});

Route::post('send-notification', [NotificationController::class, 'send'])->middleware('auth:api');
Route::put('/reminders/{id}', [NotificationController::class, 'updateReminder']);

Route::middleware('auth:api')->group(function () {
    Route::get('reminders', [ReminderController::class, 'index']);
    Route::post('reminders', [ReminderController::class, 'store']);
    Route::put('/reminders/{id}', [ReminderController::class, 'update']);
    
    Route::apiResource('reminders', ReminderController::class);
    
});



// Protected routes (requires authentication)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/expenses', [ExpenseController::class, 'index']);
    Route::post('/expense/store', [ExpenseController::class, 'store']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });
});



