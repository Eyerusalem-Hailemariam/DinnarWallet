<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $title }}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            padding: 20px;
            margin: 0;
        }
        .container {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #4CAF50;
        }
        .due-date {
            font-weight: bold;
            color: #FF5733; /* Highlight color for emphasis */
        }
        p {
            line-height: 1.6;
        }
        .footer {
            margin-top: 20px;
            font-size: 0.9em;
            color: #777;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{ $title }}</h1>
        <p>{{ $description }}</p>
        <p class="due-date">Reminder: The due date is today!</p>
        <p>Date and Time: {{ $dateTime }}</p>
    </div>
    <div class="footer">
        <p>Thank you for using our reminder service!</p>
    </div>
</body>
</html>


