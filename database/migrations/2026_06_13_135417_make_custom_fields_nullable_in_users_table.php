<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('telephone')->nullable()->change();
            $table->string('role')->nullable()->change();
            $table->string('prenom')->nullable()->change();
            $table->date('date_naissance')->nullable()->change();
            $table->string('metier')->nullable()->change();
            $table->string('ville')->nullable()->change();
            $table->string('statut')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('telephone')->nullable(false)->change();
            $table->string('role')->nullable(false)->change();
        });
    }
};