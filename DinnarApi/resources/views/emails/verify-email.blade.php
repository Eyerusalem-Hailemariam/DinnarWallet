<!DOCTYPE html>
<html>
<head>
    <title>Verify Your Email Address</title>
</head>
<body>
    <h1>Hello, {{ $user->name }}</h1>
    <p>Your account has been created successfully. Please verify your email address by entering the following code:</p>
    <p><strong>{{ $verificationCode }}</strong></p>
    <p>Thank you for registering!</p>
</body>
</html>



