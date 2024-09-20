<!-- resources/views/auth/verify-email.blade.php -->
<!DOCTYPE html>
<html>
<head>
    <title>Verify Email</title>
</head>
<body>
    <h1>Verify Your Email</h1>

    @if ($errors->any())
        <div>
            <ul>
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <form action="{{ route('verification.verify') }}" method="POST">
        @csrf
        <div>
            <label for="email">Email:</label>
            <input type="email" name="email" id="email" value="{{ old('email') }}" required>
        </div>
        <div>
            <label for="verification_code">Verification Code:</label>
            <input type="text" name="verification_code" id="verification_code" required>
        </div>
        <button type="submit">Verify Email</button>
    </form>
</body>
</html>
