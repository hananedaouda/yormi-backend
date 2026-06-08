<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FideliteController extends Controller
{
    public function index(Request $request)
    {
        $client = $request->user();

        $pointsProchainNiveau = 0;
        if ($client->niveau === 'Bronze')       $pointsProchainNiveau = 100 - $client->points;
        elseif ($client->niveau === 'Argent')   $pointsProchainNiveau = 200 - $client->points;
        elseif ($client->niveau === 'Or')       $pointsProchainNiveau = 500 - $client->points;

        $avantages = [];
        if ($client->niveau === 'Argent')       $avantages = ['5% de réduction sur chaque mission'];
        elseif ($client->niveau === 'Or')       $avantages = ['10% de réduction', 'Accès prioritaire'];
        elseif ($client->niveau === 'VIP')      $avantages = ['15% de réduction', 'Accès prioritaire', 'Cashback 5%'];

        return response()->json([
            'points'                 => $client->points,
            'niveau'                 => $client->niveau,
            'points_prochain_niveau' => max(0, $pointsProchainNiveau),
            'avantages'              => $avantages,
        ]);
    }
}