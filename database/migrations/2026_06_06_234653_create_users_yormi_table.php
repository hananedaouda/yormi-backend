<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('email')->unique();
            $table->string('telephone')->unique();
            $table->string('password');
            $table->enum('role', ['client', 'prestataire', 'admin']);
            $table->string('avatar')->nullable();
            $table->enum('statut', ['actif', 'suspendu', 'en_attente'])->default('actif');
            $table->string('metier')->nullable();
            $table->string('ville')->nullable();
            $table->boolean('disponible')->default(false);
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->decimal('note_moyenne', 3, 2)->default(0);
            $table->integer('nb_avis')->default(0);
            $table->integer('points')->default(0);
            $table->enum('niveau', ['Bronze', 'Argent', 'Or', 'VIP'])->default('Bronze');
            $table->decimal('solde', 10, 2)->default(0);
            $table->string('token')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};