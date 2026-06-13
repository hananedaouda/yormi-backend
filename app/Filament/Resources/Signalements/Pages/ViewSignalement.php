<?php

namespace App\Filament\Resources\Signalements\Pages;

use App\Filament\Resources\Signalements\SignalementResource;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewSignalement extends ViewRecord
{
    protected static string $resource = SignalementResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make(),
        ];
    }
}
