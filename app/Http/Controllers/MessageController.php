<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Mission;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    // Historique des messages
    public function index(Request $request, $id)
    {
        $user    = $request->user();
        $mission = Mission::findOrFail($id);

        // Vérifier que l'utilisateur est bien concerné par cette mission
        if ($mission->client_id !== $user->id && $mission->prestataire_id !== $user->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Accès non autorisé à cette conversation'
            ], 403);
        }

        $messages = Message::where('mission_id', $id)
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
                return [
                    'id'              => $message->id,
                    'contenu'         => $message->contenu,
                    'expediteur_id'   => $message->expediteur_id,
                    'expediteur_role' => $message->expediteur_role,
                    'created_at'      => $message->created_at,
                ];
            });

        return response()->json(['messages' => $messages]);
    }

    // Envoyer un message
    public function store(Request $request, $id)
    {
        $request->validate([
            'contenu' => 'required|string',
        ]);

        $user    = $request->user();
        $mission = Mission::findOrFail($id);

        // Vérifier que l'utilisateur est bien concerné par cette mission
        if ($mission->client_id !== $user->id && $mission->prestataire_id !== $user->id) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Accès non autorisé à cette conversation'
            ], 403);
        }

        $message = Message::create([
            'mission_id'      => $id,
            'expediteur_id'   => $user->id,
            'expediteur_role' => $user->role,
            'contenu'         => $request->contenu,
        ]);

        return response()->json([
            'message' => [
                'id'         => $message->id,
                'created_at' => $message->created_at,
            ]
        ], 201);
    }
}