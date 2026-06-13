<?php

namespace App\Filament\Resources\Missions\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class MissionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('client.nom')
                    ->label('Client')
                    ->searchable(),
                TextColumn::make('prestataire.nom')
                    ->label('Prestataire')
                    ->searchable()
                    ->placeholder('Non assigné'),
                TextColumn::make('service_type')
                    ->label('Service')
                    ->searchable(),
                TextColumn::make('adresse')
                    ->label('Adresse')
                    ->searchable(),
                TextColumn::make('statut')
                    ->label('Statut')
                    ->badge(),
                TextColumn::make('montant')
                    ->label('Montant')
                    ->numeric()
                    ->sortable()
                    ->placeholder('-'),
                TextColumn::make('started_at')
                    ->label('Démarrée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->placeholder('-'),
                TextColumn::make('finished_at')
                    ->label('Terminée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable()
                    ->placeholder('-'),
                TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('statut')
                    ->label('Statut')
                    ->options([
                        'en_recherche'              => 'En recherche',
                        'prestataire_notifie'        => 'Prestataire notifié',
                        'acceptee'                  => 'Acceptée',
                        'en_cours'                  => 'En cours',
                        'terminee_attente_validation'=> 'En attente de validation',
                        'validee'                   => 'Validée',
                        'litige'                    => 'Litige',
                    ]),
                SelectFilter::make('service_type')
                    ->label('Service')
                    ->options([
                        'electricien'  => 'Electricien',
                        'plombier'     => 'Plombier',
                        'menuisier'    => 'Menuisier',
                        'peintre'      => 'Peintre',
                        'autre'        => 'Autre',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}