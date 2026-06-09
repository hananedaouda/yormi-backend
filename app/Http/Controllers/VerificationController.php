<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function uploadCarte(Request $request)
    {
        $request->validate([
            'carte_identite' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120', // max 5MB
        ]);

        $prestataire = $request->user();

        // Supprimer l'ancienne carte si elle existe
        if ($prestataire->carte_identite && \Storage::disk('public')->exists($prestataire->carte_identite)) {
            \Storage::disk('public')->delete($prestataire->carte_identite);
        }

        // Stocker le nouveau fichier
        $path = $request->file('carte_identite')->store('cartes_identite', 'public');

        $prestataire->update([
            'carte_identite' => $path,
            'statut'         => 'en_attente',
        ]);

        return response()->json([
            'message' => 'Carte d\'identité envoyée, en attente de validation',
            'statut'  => 'en_attente',
        ], 201);
    }
}