<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\MissionController;
use App\Http\Controllers\PrestataireController;
use App\Http\Controllers\MessageController;
use App\Http\Controllers\SignalementController;
use App\Http\Controllers\FideliteController;
use App\Http\Controllers\VerificationController;

// ─────────────────────────────────────────
// Routes PUBLIQUES (pas de token nécessaire)
// ─────────────────────────────────────────
Route::post('/auth/register/client',      [AuthController::class, 'registerClient']);
Route::post('/auth/register/prestataire', [AuthController::class, 'registerPrestataire']);
Route::post('/auth/login',                [AuthController::class, 'login'])->middleware('throttle:login');

// ─────────────────────────────────────────
// Routes PROTÉGÉES — tout utilisateur connecté
// ─────────────────────────────────────────
Route::middleware(['auth:sanctum', 'throttle:api'])->group(function () {

    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Détail d'une mission (client ou prestataire concerné)
    Route::get('/missions/{id}', [MissionController::class, 'show']);

    // Chat (les deux parties de la mission)
    Route::get('/missions/{id}/messages',  [MessageController::class, 'index']);
    Route::post('/missions/{id}/messages', [MessageController::class, 'store']);

    // ─────────────────────────────────────────
    // Routes réservées aux CLIENTS
    // ─────────────────────────────────────────
    Route::middleware('role:client')->group(function () {
        Route::post('/missions',                   [MissionController::class, 'store']);
        Route::get('/missions',                    [MissionController::class, 'index']);
        Route::post('/missions/{id}/valider',      [MissionController::class, 'valider']);
        Route::post('/missions/{id}/signalement',  [SignalementController::class, 'store']);
        Route::get('/client/fidelite',             [FideliteController::class, 'index']);
    });

    // ─────────────────────────────────────────
    // Routes réservées aux PRESTATAIRES
    // ─────────────────────────────────────────
    Route::middleware('role:prestataire')->group(function () {
        Route::get('/missions',                          [MissionController::class, 'index']);
        Route::post('/missions/{id}/accepter',           [MissionController::class, 'accepter']);
        Route::put('/missions/{id}/demarrer',            [MissionController::class, 'demarrer']);
        Route::put('/missions/{id}/terminer',            [MissionController::class, 'terminer']);
        Route::put('/prestataire/disponibilite',         [PrestataireController::class, 'disponibilite']);
        Route::get('/prestataire/dashboard',             [PrestataireController::class, 'dashboard']);
        Route::post('/prestataire/verification',         [VerificationController::class, 'uploadCarte']);
    });

});