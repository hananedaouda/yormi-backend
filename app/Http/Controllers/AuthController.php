<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    // Inscription Client
    public function registerClient(Request $request)
    {
        $request->validate([
            'nom'       => 'required|string',
            'email'     => 'required|email|unique:users',
            'telephone' => 'required|unique:users',
            'password'  => 'required|min:8',
        ]);

        $user = User::create([
            'nom'       => $request->nom,
            'email'     => $request->email,
            'telephone' => $request->telephone,
            'password'  => Hash::make($request->password),
            'role'      => 'client',
            'niveau'    => 'Bronze',
            'points'    => 0,
        ]);

        $token = Str::random(60);
        $user->update(['token' => $token]);

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'     => $user->id,
                'nom'    => $user->nom,
                'role'   => $user->role,
                'points' => $user->points,
                'niveau' => $user->niveau,
            ]
        ], 201);
    }

    // Inscription Prestataire
    public function registerPrestataire(Request $request)
    {
        $request->validate([
            'nom'       => 'required|string',
            'email'     => 'required|email|unique:users',
            'telephone' => 'required|unique:users',
            'password'  => 'required|min:8',
            'metier'    => 'required|string',
            'ville'     => 'required|string',
        ]);

        $user = User::create([
            'nom'       => $request->nom,
            'email'     => $request->email,
            'telephone' => $request->telephone,
            'password'  => Hash::make($request->password),
            'role'      => 'prestataire',
            'metier'    => $request->metier,
            'ville'     => $request->ville,
            'statut'    => 'en_attente',
        ]);

        $token = Str::random(60);
        $user->update(['token' => $token]);

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'                   => $user->id,
                'nom'                  => $user->nom,
                'role'                 => $user->role,
                'statut_verification'  => $user->statut,
            ]
        ], 201);
    }

    // Connexion
    public function login(Request $request)
    {
        $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'erreur'  => true,
                'message' => 'Email ou mot de passe incorrect'
            ], 401);
        }

        $token = Str::random(60);
        $user->update(['token' => $token]);

        return response()->json([
            'token' => $token,
            'user'  => [
                'id'     => $user->id,
                'nom'    => $user->nom,
                'role'   => $user->role,
                'avatar' => $user->avatar,
            ]
        ]);
    }

    // Déconnexion
    public function logout(Request $request)
    {
        $request->user()->update(['token' => null]);

        return response()->json([
            'message' => 'Déconnexion réussie'
        ]);
    }
}