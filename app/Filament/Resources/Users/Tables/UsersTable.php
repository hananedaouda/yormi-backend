<?php

namespace App\Filament\Resources\Users\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class UsersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('nom')
                    ->label('Nom')
                    ->searchable(),
                TextColumn::make('prenom')
                    ->label('Prénom')
                    ->searchable(),
                TextColumn::make('email')
                    ->label('Email')
                    ->searchable(),
                TextColumn::make('telephone')
                    ->label('Téléphone')
                    ->searchable(),
                TextColumn::make('role')
                    ->label('Rôle')
                    ->badge(),
                TextColumn::make('statut')
                    ->label('Statut')
                    ->badge(),
                TextColumn::make('metier')
                    ->label('Métier')
                    ->searchable(),
                TextColumn::make('ville')
                    ->label('Ville')
                    ->searchable(),
                TextColumn::make('profil_type')
                    ->label('Profil')
                    ->badge(),
                TextColumn::make('created_at')
                    ->label('Inscrit le')
                    ->dateTime('d/m/Y')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('role')
                    ->label('Rôle')
                    ->options([
                        'client'      => 'Client',
                        'prestataire' => 'Prestataire',
                        'admin'       => 'Admin',
                    ]),
                SelectFilter::make('statut')
                    ->label('Statut')
                    ->options([
                        'en_attente' => 'En attente',
                        'actif'      => 'Actif',
                        'rejete'     => 'Rejeté',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                Action::make('valider')
                    ->label('Valider')
                    ->color('success')
                    ->icon('heroicon-o-check')
                    ->visible(fn ($record) => $record->role === 'prestataire' && $record->statut === 'en_attente')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['statut' => 'actif']);
                        Notification::make()
                            ->title('Prestataire validé avec succès')
                            ->success()
                            ->send();
                    }),
                Action::make('rejeter')
                    ->label('Rejeter')
                    ->color('danger')
                    ->icon('heroicon-o-x-mark')
                    ->visible(fn ($record) => $record->role === 'prestataire' && $record->statut === 'en_attente')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['statut' => 'rejete']);
                        Notification::make()
                            ->title('Prestataire rejeté')
                            ->danger()
                            ->send();
                    }),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ])
            ->defaultSort('created_at', 'desc');
    }
}