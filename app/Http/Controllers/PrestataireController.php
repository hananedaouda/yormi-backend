<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;

class PrestataireController extends Controller
{
    // Changer la disponibilité
    public function disponibilite(Request $request)
    {
        $request->validate([
            'disponible' => 'required|boolean',
        ]);

        $prestataire = User::where('token', $request->bearerToken())->first();

        if (!$prestataire) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        $prestataire->update([
            'disponible' => $request->disponible,
            'latitude'   => $request->latitude ?? $prestataire->latitude,
            'longitude'  => $request->longitude ?? $prestataire->longitude,
        ]);

        return response()->json([
            'disponible' => $prestataire->disponible,
            'message'    => $request->disponible ? 'Vous êtes maintenant disponible' : 'Vous êtes maintenant indisponible'
        ]);
    }

    // Dashboard prestataire
    public function dashboard(Request $request)
    {
        $prestataire = User::where('token', $request->bearerToken())->first();

        if (!$prestataire) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        $missionsTotal = \App\Models\Mission::where('prestataire_id', $prestataire->id)->count();
        $missionsMois  = \App\Models\Mission::where('prestataire_id', $prestataire->id)
            ->whereMonth('created_at', now()->month)->count();

        return response()->json([
            'missions_total'    => $missionsTotal,
            'missions_ce_mois'  => $missionsMois,
            'revenus_ce_mois'   => 0,
            'solde_disponible'  => $prestataire->solde,
            'note_moyenne'      => $prestataire->note_moyenne,
            'nb_avis'           => $prestataire->nb_avis,
        ]);
    }
}