<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class VerificationController extends Controller
{
    public function uploadCarte(Request $request)
    {
        $user = $request->user();

        // Vérifier que c'est bien un prestataire
        if ($user->role !== 'prestataire') {
            return response()->json([
                'erreur'  => true,
                'message' => 'Seuls les prestataires peuvent envoyer des documents'
            ], 403);
        }

        $request->validate([
            'profil_type'    => 'required|in:patron,ouvrier,apprenti',
            'carte_identite' => 'required|file|mimes:jpg,jpeg,png,pdf|max:5120',
            'diplome'        => 'nullable|file|mimes:jpg,jpeg,png,pdf|max:5120',
        ]);

        // Supprimer l'ancienne carte si elle existe
        if ($user->carte_identite && \Storage::disk('public')->exists($user->carte_identite)) {
            \Storage::disk('public')->delete($user->carte_identite);
        }

        // Stocker la carte d'identité
        $cartePath = $request->file('carte_identite')->store('cartes_identite', 'public');

        $updateData = [
            'carte_identite' => $cartePath,
            'profil_type'    => $request->profil_type,
            'statut'         => 'en_attente',
        ];

        // Si patron → diplôme obligatoire
        if ($request->profil_type === 'patron') {
            if (!$request->hasFile('diplome')) {
                return response()->json([
                    'erreur'  => true,
                    'message' => 'Un patron doit fournir un diplôme ou certificat professionnel'
                ], 422);
            }

            // Supprimer l'ancien diplôme si il existe
            if ($user->diplome && \Storage::disk('public')->exists($user->diplome)) {
                \Storage::disk('public')->delete($user->diplome);
            }

            $diplomePath = $request->file('diplome')->store('diplomes', 'public');
            $updateData['diplome'] = $diplomePath;
        }

        $user->update($updateData);

        return response()->json([
            'message'      => 'Documents envoyés, en attente de validation',
            'profil_type'  => $request->profil_type,
            'statut'       => 'en_attente',
        ], 201);
    }
}