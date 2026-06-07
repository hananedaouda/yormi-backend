<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('missions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('prestataire_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('service_type');
            $table->text('description');
            $table->string('adresse');
            $table->decimal('latitude', 10, 7);
            $table->decimal('longitude', 10, 7);
            $table->enum('statut', [
                'en_recherche',
                'prestataire_notifie',
                'acceptee',
                'en_cours',
                'terminee_attente_validation',
                'validee',
                'annulee',
                'litige'
            ])->default('en_recherche');
            $table->decimal('montant', 10, 2)->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('finished_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('missions');
    }
};