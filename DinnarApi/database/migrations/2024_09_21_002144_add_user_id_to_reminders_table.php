<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class AddUserIdToRemindersTable extends Migration
{
    public function up()
    {
        Schema::table('reminders', function (Blueprint $table) {
            // Check if the column doesn't exist before adding
            if (!Schema::hasColumn('reminders', 'user_id')) {
                $table->foreignId('user_id')->after('id')->constrained('users')->onDelete('cascade');
            }
        });
    }
    
    public function down()
    {
        Schema::table('reminders', function (Blueprint $table) {
            $table->dropForeign(['user_id']); // Drop foreign key
            $table->dropColumn('user_id'); // Drop the column
        });
    }
}
