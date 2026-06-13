<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class CheckRole
{
    public function handle(Request $request, Closure $next, string $role): mixed
    {
        $user = $request->user();

        if (!$user || $user->role !== $role) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Accès non autorisé pour ce rôle'
            ], 403);
        }

        // Vérification supplémentaire pour les prestataires
        if ($role === 'prestataire' && $user->statut !== 'actif') {
            return response()->json([
                'erreur'  => true,
                'message' => 'Votre compte est en attente de validation par l\'administrateur'
            ], 403);
        }

        return $next($request);
    }
}