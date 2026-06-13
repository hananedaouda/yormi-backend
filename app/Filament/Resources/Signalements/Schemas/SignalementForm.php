<?php

namespace App\Filament\Resources\Signalements\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class SignalementForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('mission_id')
                    ->required()
                    ->numeric(),
                TextInput::make('client_id')
                    ->required()
                    ->numeric(),
                Select::make('type')
                    ->options([
            'comportement' => 'Comportement',
            'paiement' => 'Paiement',
            'qualite' => 'Qualite',
            'autre' => 'Autre',
        ])
                    ->required(),
                Textarea::make('description')
                    ->required()
                    ->columnSpanFull(),
                Select::make('statut')
                    ->options(['en_traitement' => 'En traitement', 'resolu' => 'Resolu', 'rejete' => 'Rejete'])
                    ->default('en_traitement')
                    ->required(),
            ]);
    }
}
