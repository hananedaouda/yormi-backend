<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens; // ✅ ajout Sanctum

class User extends Authenticatable
{
    use HasApiTokens, HasFactory; // ✅ ajout HasApiTokens

protected $fillable = [
    'nom',
    'prenom',        // ✅ ajout
    'date_naissance', // ✅ ajout
    'email',
    'telephone',
    'password',
    'role',
    'avatar',
    'statut',
    'metier',
    'ville',
    'carte_identite',
    'profil_type',
    'diplome',
    'disponible',
    'latitude',
    'longitude',
    'note_moyenne',
    'nb_avis',
    'points',
    'niveau',
    'solde',
];
    protected $hidden = [
        'password',
        // ✅ 'token' supprimé
    ];

    // Relations
    public function missionsClient()
    {
        return $this->hasMany(Mission::class, 'client_id');
    }

    public function missionsPrestataire()
    {
        return $this->hasMany(Mission::class, 'prestataire_id');
    }

    public function avis()
    {
        return $this->hasMany(Avis::class, 'prestataire_id');
    }
}