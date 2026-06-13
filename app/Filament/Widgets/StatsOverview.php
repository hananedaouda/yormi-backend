<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\Mission;
use App\Models\Signalement;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverview extends StatsOverviewWidget
{
    protected function getStats(): array
    {
        return [
            Stat::make('Total Clients', User::where('role', 'client')->count())
                ->description('Clients inscrits')
                ->icon('heroicon-o-users')
                ->color('success'),

            Stat::make('Total Prestataires', User::where('role', 'prestataire')->count())
                ->description('Prestataires inscrits')
                ->icon('heroicon-o-briefcase')
                ->color('warning'),

            Stat::make('En attente de validation', User::where('role', 'prestataire')->where('statut', 'en_attente')->count())
                ->description('Prestataires à valider')
                ->icon('heroicon-o-clock')
                ->color('danger'),

            Stat::make('Missions ce mois', Mission::whereMonth('created_at', now()->month)->whereYear('created_at', now()->year)->count())
                ->description('Missions créées ce mois')
                ->icon('heroicon-o-clipboard-document-list')
                ->color('info'),

            Stat::make('Missions en cours', Mission::where('statut', 'en_cours')->count())
                ->description('Missions actives')
                ->icon('heroicon-o-arrow-path')
                ->color('warning'),

            Stat::make('Litiges en cours', Signalement::where('statut', 'en_traitement')->count())
                ->description('Signalements à traiter')
                ->icon('heroicon-o-exclamation-triangle')
                ->color('danger'),
        ];
    }
}