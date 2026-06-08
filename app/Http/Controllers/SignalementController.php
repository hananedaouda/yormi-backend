<?php

namespace App\Http\Controllers;

use App\Models\Mission;
use App\Models\Signalement;
use Illuminate\Http\Request;

class SignalementController extends Controller
{
    public function store(Request $request, $id)
    {
        $request->validate([
            'type'        => 'required|in:comportement,paiement,qualite,autre',
            'description' => 'required|string',
        ]);

        $user    = $request->user();
        $mission = Mission::findOrFail($id);

        // Vérifier que c'est bien le client de cette mission
        if ($mission->client_id !== $user->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Vous n\'êtes pas autorisé à signaler cette mission'
            ], 403);
        }

        // Enregistrer le signalement en base
        $signalement = Signalement::create([
            'mission_id'  => $mission->id,
            'client_id'   => $user->id,
            'type'        => $request->type,
            'description' => $request->description,
            'statut'      => 'en_traitement',
        ]);

        // Mettre la mission en litige
        $mission->update(['statut' => 'litige']);

        return response()->json([
            'signalement' => [
                'id'     => $signalement->id,
                'statut' => $signalement->statut,
            ],
            'message' => "L'équipe YORMI a été notifiée"
        ], 201);
    }
}