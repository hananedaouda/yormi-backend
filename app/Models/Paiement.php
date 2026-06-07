<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Paiement extends Model
{
    use HasFactory;

    protected $fillable = [
        'mission_id',
        'client_id',
        'prestataire_id',
        'montant',
        'commission',
        'montant_prestataire',
        'operateur',
        'numero_mobile_money',
        'reference',
        'statut',
    ];

    public function mission()
    {
        return $this->belongsTo(Mission::class);
    }

    public function client()
    {
        return $this->belongsTo(User::class, 'client_id');
    }

    public function prestataire()
    {
        return $this->belongsTo(User::class, 'prestataire_id');
    }
}