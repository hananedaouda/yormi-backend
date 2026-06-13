<?php

namespace App\Filament\Resources\Signalements\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Actions\Action;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Filament\Notifications\Notification;

class SignalementsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('client.nom')
                    ->label('Client')
                    ->searchable(),
                TextColumn::make('mission.service_type')
                    ->label('Service')
                    ->searchable(),
                TextColumn::make('type')
                    ->label('Type')
                    ->badge(),
                TextColumn::make('description')
                    ->label('Description')
                    ->limit(50),
                TextColumn::make('statut')
                    ->label('Statut')
                    ->badge(),
                TextColumn::make('created_at')
                    ->label('Signalé le')
                    ->dateTime('d/m/Y H:i')
                    ->sortable(),
            ])
            ->filters([
                SelectFilter::make('statut')
                    ->label('Statut')
                    ->options([
                        'en_traitement' => 'En traitement',
                        'resolu'        => 'Résolu',
                        'rejete'        => 'Rejeté',
                    ]),
                SelectFilter::make('type')
                    ->label('Type')
                    ->options([
                        'comportement' => 'Comportement',
                        'paiement'     => 'Paiement',
                        'qualite'      => 'Qualité',
                        'autre'        => 'Autre',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                Action::make('resoudre')
                    ->label('Résoudre')
                    ->color('success')
                    ->icon('heroicon-o-check')
                    ->visible(fn ($record) => $record->statut === 'en_traitement')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['statut' => 'resolu']);
                        $record->mission()->update(['statut' => 'validee']);
                        Notification::make()
                            ->title('Signalement résolu')
                            ->success()
                            ->send();
                    }),
                Action::make('rejeter')
                    ->label('Rejeter')
                    ->color('danger')
                    ->icon('heroicon-o-x-mark')
                    ->visible(fn ($record) => $record->statut === 'en_traitement')
                    ->requiresConfirmation()
                    ->action(function ($record) {
                        $record->update(['statut' => 'rejete']);
                        Notification::make()
                            ->title('Signalement rejeté')
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