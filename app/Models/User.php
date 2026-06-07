<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use HasFactory;

    protected $fillable = [
        'nom',
        'email',
        'telephone',
        'password',
        'role',
        'avatar',
        'statut',
        'metier',
        'ville',
        'disponible',
        'latitude',
        'longitude',
        'note_moyenne',
        'nb_avis',
        'points',
        'niveau',
        'solde',
        'token',
    ];

    protected $hidden = [
        'password',
        'token',
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