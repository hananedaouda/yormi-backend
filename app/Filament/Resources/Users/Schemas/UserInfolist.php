<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class UserInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Informations personnelles')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('nom')
                            ->label('Nom')
                            ->placeholder('-'),
                        TextEntry::make('prenom')
                            ->label('Prénom')
                            ->placeholder('-'),
                        TextEntry::make('date_naissance')
                            ->label('Date de naissance')
                            ->date('d/m/Y')
                            ->placeholder('-'),
                        TextEntry::make('email')
                            ->label('Email'),
                        TextEntry::make('telephone')
                            ->label('Téléphone')
                            ->placeholder('-'),
                        TextEntry::make('role')
                            ->label('Rôle')
                            ->badge(),
                        TextEntry::make('statut')
                            ->label('Statut')
                            ->badge(),
                    ]),

                Section::make('Informations prestataire')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('metier')
                            ->label('Métier')
                            ->placeholder('-'),
                        TextEntry::make('ville')
                            ->label('Ville')
                            ->placeholder('-'),
                        TextEntry::make('profil_type')
                            ->label('Type de profil')
                            ->badge()
                            ->placeholder('-'),
                        TextEntry::make('note_moyenne')
                            ->label('Note moyenne')
                            ->numeric(),
                        TextEntry::make('nb_avis')
                            ->label('Nombre d\'avis')
                            ->numeric(),
                        TextEntry::make('solde')
                            ->label('Solde')
                            ->numeric(),
                    ]),

                Section::make('Documents de vérification')
                    ->schema([
                        TextEntry::make('carte_identite')
    ->label('Carte d\'identité')
    ->formatStateUsing(fn (?string $state) => $state ? 'Voir le document' : 'Aucun document')
    ->url(fn ($record) => $record->carte_identite ? asset('storage/' . $record->carte_identite) : null)
    ->openUrlInNewTab()
    ->placeholder('Aucune carte d\'identité'),
TextEntry::make('diplome')
    ->label('Diplôme / Certificat')
    ->formatStateUsing(fn (?string $state) => $state ? 'Voir le document' : 'Aucun document')
    ->url(fn ($record) => $record->diplome ? asset('storage/' . $record->diplome) : null)
    ->openUrlInNewTab()
    ->placeholder('Aucun diplôme'),
                    ]),

                Section::make('Fidélité client')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('points')
                            ->label('Points')
                            ->numeric(),
                        TextEntry::make('niveau')
                            ->label('Niveau')
                            ->badge(),
                    ]),
            ]);
    }
}