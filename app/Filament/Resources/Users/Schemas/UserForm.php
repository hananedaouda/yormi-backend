<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('nom'),
                TextInput::make('prenom'),
                DatePicker::make('date_naissance'),
                TextInput::make('email')
                    ->label('Email address')
                    ->email()
                    ->required(),
                TextInput::make('telephone')
                    ->tel(),
                TextInput::make('password')
                    ->password()
                    ->required(),
                TextInput::make('role'),
                TextInput::make('avatar'),
                TextInput::make('statut'),
                TextInput::make('metier'),
                TextInput::make('ville'),
                TextInput::make('carte_identite'),
                Select::make('profil_type')
                    ->options(['patron' => 'Patron', 'ouvrier' => 'Ouvrier', 'apprenti' => 'Apprenti']),
                TextInput::make('diplome'),
                Toggle::make('disponible')
                    ->required(),
                TextInput::make('latitude')
                    ->numeric(),
                TextInput::make('longitude')
                    ->numeric(),
                TextInput::make('note_moyenne')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('nb_avis')
                    ->required()
                    ->numeric()
                    ->default(0),
                TextInput::make('points')
                    ->required()
                    ->numeric()
                    ->default(0),
                Select::make('niveau')
                    ->options(['Bronze' => 'Bronze', 'Argent' => 'Argent', 'Or' => 'Or', 'VIP' => 'V i p'])
                    ->default('Bronze')
                    ->required(),
                TextInput::make('solde')
                    ->required()
                    ->numeric()
                    ->default(0.0),
                TextInput::make('token'),
            ]);
    }
}
