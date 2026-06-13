<?php

namespace App\Filament\Resources\Missions\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class MissionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('client_id')
                    ->numeric(),
                TextEntry::make('prestataire_id')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('service_type'),
                TextEntry::make('description')
                    ->columnSpanFull(),
                TextEntry::make('adresse'),
                TextEntry::make('latitude')
                    ->numeric(),
                TextEntry::make('longitude')
                    ->numeric(),
                TextEntry::make('statut')
                    ->badge(),
                TextEntry::make('montant')
                    ->numeric()
                    ->placeholder('-'),
                TextEntry::make('started_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('finished_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
