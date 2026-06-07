<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\MissionController;
use App\Http\Controllers\PrestataireController;

// Routes publiques
Route::post('/auth/register/client', [AuthController::class, 'registerClient']);
Route::post('/auth/register/prestataire', [AuthController::class, 'registerPrestataire']);
Route::post('/auth/login', [AuthController::class, 'login']);

// Routes protégées
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/auth/logout', [AuthController::class, 'logout']);
});

// Routes Missions
Route::post('/missions', [MissionController::class, 'store']);
Route::get('/missions', [MissionController::class, 'index']);
Route::get('/missions/{id}', [MissionController::class, 'show']);
Route::post('/missions/{id}/accepter', [MissionController::class, 'accepter']);
Route::put('/missions/{id}/demarrer', [MissionController::class, 'demarrer']);
Route::put('/missions/{id}/terminer', [MissionController::class, 'terminer']);
Route::post('/missions/{id}/valider', [MissionController::class, 'valider']);

// Routes Prestataire
Route::put('/prestataire/disponibilite', [PrestataireController::class, 'disponibilite']);
Route::get('/prestataire/dashboard', [PrestataireController::class, 'dashboard']);