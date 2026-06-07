<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('paiements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mission_id')->constrained('missions')->onDelete('cascade');
            $table->foreignId('client_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('prestataire_id')->constrained('users')->onDelete('cascade');
            $table->decimal('montant', 10, 2);
            $table->decimal('commission', 10, 2);
            $table->decimal('montant_prestataire', 10, 2);
            $table->enum('operateur', ['mtn', 'moov']);
            $table->string('numero_mobile_money');
            $table->string('reference')->unique();
            $table->enum('statut', ['en_attente', 'libere', 'rembourse'])->default('en_attente');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('paiements');
    }
};