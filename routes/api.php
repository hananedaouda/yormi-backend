<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

// Routes publiques
Route::post('/auth/register/client', [AuthController::class, 'registerClient']);
Route::post('/auth/register/prestataire', [AuthController::class, 'registerPrestataire']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
});