<?php

namespace App\Http\Controllers;

use App\Models\Mission;
use App\Models\User;
use Illuminate\Http\Request;

class MissionController extends Controller
{
    // Créer une mission (Client)
    public function store(Request $request)
    {
        $request->validate([
            'service_type' => 'required|string',
            'description'  => 'required|string',
            'adresse'      => 'required|string',
            'latitude'     => 'required|numeric',
            'longitude'    => 'required|numeric',
        ]);

        $client = User::where('token', $request->bearerToken())->first();

        if (!$client) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        $mission = Mission::create([
            'client_id'    => $client->id,
            'service_type' => $request->service_type,
            'description'  => $request->description,
            'adresse'      => $request->adresse,
            'latitude'     => $request->latitude,
            'longitude'    => $request->longitude,
            'statut'       => 'en_recherche',
        ]);

        // Chercher un prestataire disponible proche
        $prestataire = User::where('role', 'prestataire')
            ->where('disponible', true)
            ->where('statut', 'actif')
            ->first();

        $prestataireTrouve = false;

        if ($prestataire) {
            $mission->update([
                'prestataire_id' => $prestataire->id,
                'statut'         => 'prestataire_notifie'
            ]);
            $prestataireTrouve = true;
        }

        return response()->json([
            'mission' => [
                'id'         => $mission->id,
                'statut'     => $mission->statut,
                'created_at' => $mission->created_at,
            ],
            'prestataire_trouve' => $prestataireTrouve,
        ], 201);
    }

    // Lister les missions
    public function index(Request $request)
    {
        $user = User::where('token', $request->bearerToken())->first();

        if (!$user) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        if ($user->role === 'client') {
            $missions = Mission::where('client_id', $user->id)->get();
        } else {
            $missions = Mission::where('prestataire_id', $user->id)->get();
        }

        return response()->json(['missions' => $missions]);
    }

    // Détail d'une mission
    public function show(Request $request, $id)
    {
        $user = User::where('token', $request->bearerToken())->first();

        if (!$user) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        $mission = Mission::with(['client', 'prestataire'])->find($id);

        if (!$mission) {
            return response()->json(['erreur' => true, 'message' => 'Mission introuvable'], 404);
        }

        return response()->json(['mission' => $mission]);
    }

    // Accepter une mission (Prestataire)
    public function accepter(Request $request, $id)
    {
        $prestataire = User::where('token', $request->bearerToken())->first();

        if (!$prestataire) {
            return response()->json(['erreur' => true, 'message' => 'Non autorisé'], 401);
        }

        $mission = Mission::find($id);
        $mission->update(['statut' => 'acceptee']);

        return response()->json([
            'mission' => [
                'id'     => $mission->id,
                'statut' => $mission->statut,
            ],
            'client' => [
                'nom'     => $mission->client->nom,
                'adresse' => $mission->adresse,
            ]
        ]);
    }

    // Démarrer une mission (Prestataire)
    public function demarrer(Request $request, $id)
    {
        $mission = Mission::find($id);
        $mission->update([
            'statut'     => 'en_cours',
            'started_at' => now(),
        ]);

        return response()->json([
            'mission' => [
                'statut'     => $mission->statut,
                'started_at' => $mission->started_at,
            ]
        ]);
    }

    // Terminer une mission (Prestataire)
    public function terminer(Request $request, $id)
    {
        $mission = Mission::find($id);
        $mission->update([
            'statut'      => 'terminee_attente_validation',
            'finished_at' => now(),
        ]);

        return response()->json([
            'mission' => ['statut' => $mission->statut],
            'message' => 'En attente de validation client'
        ]);
    }

    // Valider une mission (Client)
    public function valider(Request $request, $id)
    {
        $request->validate([
            'note'        => 'required|integer|min:1|max:5',
            'commentaire' => 'required|string',
        ]);

        $client = User::where('token', $request->bearerToken())->first();
        $mission = Mission::find($id);

        // Enregistrer l'avis
        \App\Models\Avis::create([
            'mission_id'     => $mission->id,
            'client_id'      => $client->id,
            'prestataire_id' => $mission->prestataire_id,
            'note'           => $request->note,
            'commentaire'    => $request->commentaire,
        ]);

        // Mettre à jour la note moyenne du prestataire
        $prestataire = User::find($mission->prestataire_id);
        $nbAvis = $prestataire->nb_avis + 1;
        $nouvelleMoyenne = (($prestataire->note_moyenne * $prestataire->nb_avis) + $request->note) / $nbAvis;
        $prestataire->update([
            'note_moyenne' => round($nouvelleMoyenne, 2),
            'nb_avis'      => $nbAvis,
        ]);

        // Mettre à jour la mission
        $mission->update(['statut' => 'validee']);

        // Ajouter des points au client (10 points par mission)
        $nouveauxPoints = $client->points + 10;
        $niveau = $client->niveau;

        if ($nouveauxPoints >= 500) $niveau = 'VIP';
        elseif ($nouveauxPoints >= 200) $niveau = 'Or';
        elseif ($nouveauxPoints >= 100) $niveau = 'Argent';

        $client->update([
            'points' => $nouveauxPoints,
            'niveau' => $niveau,
        ]);

        return response()->json([
            'mission'        => ['statut' => 'validee'],
            'paiement_libere' => true,
            'points_gagnes'  => 10,
            'nouveau_niveau' => $niveau,
        ]);
    }
}