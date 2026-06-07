<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Mission extends Model
{
    use HasFactory;

    protected $fillable = [
        'client_id',
        'prestataire_id',
        'service_type',
        'description',
        'adresse',
        'latitude',
        'longitude',
        'statut',
        'montant',
        'started_at',
        'finished_at',
    ];

    // Relations
    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    public function prestataire()
    {
        return $this->belongsTo(User::class, 'prestataire_id');
    }

    public function avis()
    {
        return $this->hasOne(Avis::class);
    }

    public function messages()
    {
        return $this->hasMany(Message::class);
    }

    public function paiement()
    {
        return $this->hasOne(Paiement::class);
    }
}