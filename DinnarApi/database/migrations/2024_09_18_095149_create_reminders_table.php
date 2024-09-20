<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateRemindersTable extends Migration
{
    public function up()
    {
        // Migration example
Schema::create('reminders', function (Blueprint $table) {
    $table->id();
    $table->string('title');
    $table->string('descripition'); // Ensure this is correctly spelled and required
    $table->dateTime('date_time');
    $table->string('category');
    $table->string('repeat_option');
    $table->timestamps();
});

    }

    public function down()
    {
        Schema::dropIfExists('reminders');
    }
}
