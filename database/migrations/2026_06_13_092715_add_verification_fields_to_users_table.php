<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->enum('profil_type', ['patron', 'ouvrier', 'apprenti'])->nullable()->after('carte_identite');
            $table->string('diplome')->nullable()->after('profil_type');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['profil_type', 'diplome']);
        });
    }
};