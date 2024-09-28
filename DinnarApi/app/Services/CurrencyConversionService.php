<?php

// app/Services/CurrencyConversionService.php

namespace App\Services;

use GuzzleHttp\Client;

class CurrencyConversionService
{
    protected $client;

    public function __construct()
    {
        $this->client = new Client();
    }

    // Method to convert currency using the external API
    public function convert($fromCurrency, $toCurrency, $amount)
    {
        $apiKey = env('CURRENCY_API_KEY'); 
        $url = "https://v6.exchangerate-api.com/v6/{$apiKey}/latest/{$fromCurrency}";

        try {
            $response = $this->client->get($url);
            $data = json_decode($response->getBody(), true);

            if (isset($data['conversion_rates'][$toCurrency])) {
                $rate = $data['conversion_rates'][$toCurrency];
                return $amount * $rate;
            }
        } catch (\Exception $e) {
            \Log::error("Currency conversion failed: " . $e->getMessage());
            return false;
        }

        return false;
    }
}
