<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddUserIdToCategoriesTable extends Migration
{
    public function up()
    {
        Schema::table('categories', function (Blueprint $table) {
            // Check if the column doesn't exist before adding
            if (!Schema::hasColumn('categories', 'user_id')) {
                $table->foreignId('user_id')->after('id')->constrained('users')->onDelete('cascade');
            }
        });
    }

    public function down()
    {
        Schema::table('categories', function (Blueprint $table) {
            // Drop the foreign key and column if rolling back
            if (Schema::hasColumn('categories', 'user_id')) {
                $table->dropForeign(['user_id']);
                $table->dropColumn('user_id');
            }
        });
    }
}