<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Signalement extends Model
{
    use HasFactory;

    protected $fillable = [
        'mission_id',
        'client_id',
        'type',
        'description',
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
}