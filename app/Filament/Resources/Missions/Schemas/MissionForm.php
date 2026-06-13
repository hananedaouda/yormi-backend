<?php

namespace App\Filament\Resources\Missions\Schemas;

use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Schemas\Schema;

class MissionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('client_id')
                    ->required()
                    ->numeric(),
                TextInput::make('prestataire_id')
                    ->numeric(),
                TextInput::make('service_type')
                    ->required(),
                Textarea::make('description')
                    ->required()
                    ->columnSpanFull(),
                TextInput::make('adresse')
                    ->required(),
                TextInput::make('latitude')
                    ->required()
                    ->numeric(),
                TextInput::make('longitude')
                    ->required()
                    ->numeric(),
                Select::make('statut')
                    ->options([
            'en_recherche' => 'En recherche',
            'prestataire_notifie' => 'Prestataire notifie',
            'acceptee' => 'Acceptee',
            'en_cours' => 'En cours',
            'terminee_attente_validation' => 'Terminee attente validation',
            'validee' => 'Validee',
            'annulee' => 'Annulee',
            'litige' => 'Litige',
        ])
                    ->default('en_recherche')
                    ->required(),
                TextInput::make('montant')
                    ->numeric(),
                DateTimePicker::make('started_at'),
                DateTimePicker::make('finished_at'),
            ]);
    }
}
