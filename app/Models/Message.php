<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    use HasFactory;

    protected $fillable = [
        'mission_id',
        'expediteur_id',
        'expediteur_role',
        'contenu',
    ];

    public function mission()
    {
        return $this->belongsTo(Mission::class);
    }

    public function expediteur()
    {
        return $this->belongsTo(User::class, 'expediteur_id');
    }
}