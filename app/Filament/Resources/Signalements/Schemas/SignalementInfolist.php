<?php

namespace App\Filament\Resources\Signalements\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Schema;

class SignalementInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextEntry::make('mission_id')
                    ->numeric(),
                TextEntry::make('client_id')
                    ->numeric(),
                TextEntry::make('type')
                    ->badge(),
                TextEntry::make('description')
                    ->columnSpanFull(),
                TextEntry::make('statut')
                    ->badge(),
                TextEntry::make('created_at')
                    ->dateTime()
                    ->placeholder('-'),
                TextEntry::make('updated_at')
                    ->dateTime()
                    ->placeholder('-'),
            ]);
    }
}
