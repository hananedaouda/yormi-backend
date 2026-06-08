<?php

namespace App\Http\Controllers;

use App\Models\Mission;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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

        $client = $request->user(); // Sanctum : plus besoin de chercher par token

        $mission = Mission::create([
            'client_id'    => $client->id,
            'service_type' => $request->service_type,
            'description'  => $request->description,
            'adresse'      => $request->adresse,
            'latitude'     => $request->latitude,
            'longitude'    => $request->longitude,
            'statut'       => 'en_recherche',
        ]);

        // Chercher un prestataire disponible avec le bon métier
        $prestataire = User::where('role', 'prestataire')
            ->where('disponible', true)
            ->where('statut', 'actif')
            ->where('metier', $request->service_type) // ✅ filtrer par métier
            ->first();

        $prestataireTrouve = false;

        if ($prestataire) {
            $mission->update([
                'prestataire_id' => $prestataire->id,
                'statut'         => 'prestataire_notifie',
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
        $user = $request->user();

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
        $user    = $request->user();
        $mission = Mission::with(['client', 'prestataire'])->findOrFail($id);

        // Vérifier que l'utilisateur est bien concerné par cette mission
        if ($mission->client_id !== $user->id && $mission->prestataire_id !== $user->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Accès non autorisé à cette mission'
            ], 403);
        }

        return response()->json(['mission' => $mission]);
    }

    // Accepter une mission (Prestataire)
    public function accepter(Request $request, $id)
    {
        $prestataire = $request->user();
        $mission     = Mission::findOrFail($id);

        // Vérifier que c'est bien ce prestataire qui a été notifié
        if ($mission->prestataire_id !== $prestataire->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Cette mission ne vous est pas assignée'
            ], 403);
        }

        if ($mission->statut !== 'prestataire_notifie') {
            return response()->json([
                'erreur'  => true,
                'message' => 'Cette mission ne peut pas être acceptée (statut : ' . $mission->statut . ')'
            ], 422);
        }

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
        $prestataire = $request->user();
        $mission     = Mission::findOrFail($id);

        if ($mission->prestataire_id !== $prestataire->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Cette mission ne vous est pas assignée'
            ], 403);
        }

        if ($mission->statut !== 'acceptee') {
            return response()->json([
                'erreur'  => true,
                'message' => 'La mission doit être acceptée avant de démarrer'
            ], 422);
        }

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
        $prestataire = $request->user();
        $mission     = Mission::findOrFail($id);

        if ($mission->prestataire_id !== $prestataire->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Cette mission ne vous est pas assignée'
            ], 403);
        }

        if ($mission->statut !== 'en_cours') {
            return response()->json([
                'erreur'  => true,
                'message' => 'La mission doit être en cours pour être terminée'
            ], 422);
        }

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

        $client  = $request->user();
        $mission = Mission::findOrFail($id);

        // Vérifier que c'est bien le client de cette mission
        if ($mission->client_id !== $client->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Vous n\'êtes pas le client de cette mission'
            ], 403);
        }

        if ($mission->statut !== 'terminee_attente_validation') {
            return response()->json([
                'erreur'  => true,
                'message' => 'La mission n\'est pas encore terminée par le prestataire'
            ], 422);
        }

        // ✅ Transaction : tout réussit ou rien ne s'enregistre
        DB::transaction(function () use ($mission, $client, $request) {

            // Enregistrer l'avis
            \App\Models\Avis::create([
                'mission_id'     => $mission->id,
                'client_id'      => $client->id,
                'prestataire_id' => $mission->prestataire_id,
                'note'           => $request->note,
                'commentaire'    => $request->commentaire,
            ]);

            // Mettre à jour la note moyenne du prestataire
            $prestataire = User::findOrFail($mission->prestataire_id);
            $nbAvis      = $prestataire->nb_avis + 1;
            $nouvelleMoyenne = (($prestataire->note_moyenne * $prestataire->nb_avis) + $request->note) / $nbAvis;

            $prestataire->update([
                'note_moyenne' => round($nouvelleMoyenne, 2),
                'nb_avis'      => $nbAvis,
            ]);

            // Valider la mission
            $mission->update(['statut' => 'validee']);

            // Ajouter des points au client (10 points par mission)
            $nouveauxPoints = $client->points + 10;
            $niveau = $client->niveau;

            if ($nouveauxPoints >= 500)      $niveau = 'VIP';
            elseif ($nouveauxPoints >= 200)  $niveau = 'Or';
            elseif ($nouveauxPoints >= 100)  $niveau = 'Argent';

            $client->update([
                'points' => $nouveauxPoints,
                'niveau' => $niveau,
            ]);
        });

        // Récupérer le client mis à jour pour retourner les bonnes valeurs
        $client->refresh();

        return response()->json([
            'mission'         => ['statut' => 'validee'],
            'paiement_libere' => true,
            'points_gagnes'   => 10,
            'nouveau_niveau'  => $client->niveau,
        ]);
    }
}