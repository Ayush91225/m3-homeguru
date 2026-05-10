# Razorpay Payment Integration

## Overview
Integrated Razorpay payment gateway with custom Google Pay-style checkout UI throughout the app.

## Credentials
- **Key ID**: `rzp_test_SaRLWC9tRdlI8U`
- **Key Secret**: `W66t7QTrO4nF2fV4d276CcU6`
- **Environment**: Test Mode

## Files Created

### 1. RazorpayService (`lib/services/razorpay_service.dart`)
Payment service handling:
- Order creation via Razorpay API
- Payment initialization with Razorpay SDK
- Success/failure/external wallet callbacks
- Secure authentication with Basic Auth

### 2. CheckoutScreen (`lib/screens/shared/checkout/checkout_screen.dart`)
Google Pay-style checkout UI with:
- Payment summary card with tutor info (optional)
- 4 payment methods: UPI, Card, Net Banking, Wallet
- Animated payment method selection
- Security badge
- Sticky bottom pay button with loading state
- Material 3 design with proper animations

## Integration Points

### 1. Payment Pending Sheet
**File**: `lib/widgets/schedule/payment_pending_sheet.dart`
- "Pay Now" button opens checkout screen
- Passes booking details (tutor, subject, amount, sessions)
- Handles payment success callback

### 2. Tutor Onboarding - Listing Fee
**File**: `lib/screens/onboarding/tutor/step7.dart`
- Annual listing fee payment (₹499)
- Opens checkout screen on "Pay ₹499 & Continue"
- Proceeds to next step on successful payment

### 3. My Requests Page
**File**: `lib/widgets/requests/request_tile.dart`
- "Pay Now" button for accepted requests with pending payment
- Opens payment pending sheet → checkout screen

## Payment Flow

1. **User initiates payment** from any integration point
2. **CheckoutScreen opens** with payment details
3. **User selects payment method** (UPI/Card/NetBanking/Wallet)
4. **Order created** via Razorpay API (`POST /v1/orders`)
5. **Razorpay SDK opens** with payment options
6. **User completes payment** in Razorpay modal
7. **Success callback** triggers:
   - Shows success snackbar
   - Calls `onSuccess` callback
   - Returns `true` to previous screen
8. **Previous screen handles** post-payment actions

## Features

### CheckoutScreen
- **Payment Summary**: Shows title, description, amount, optional tutor info
- **Payment Methods**: 4 options with animated selection
- **Security**: "Secured by Razorpay" badge
- **Loading States**: Button shows spinner during processing
- **Error Handling**: Shows snackbar on payment failure
- **Metadata Support**: Pass custom data with payment

### RazorpayService
- **Order Creation**: Creates Razorpay order with amount, receipt, notes
- **Payment Options**: Configures Razorpay with prefill data
- **Callbacks**: Handles success, failure, external wallet events
- **Cleanup**: Proper disposal of Razorpay instance

## Usage Example

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => CheckoutScreen(
      title: 'Mathematics - JEE Advanced',
      description: '10 sessions with Priya Sharma',
      amount: 5000, // Amount in rupees
      tutorName: 'Priya Sharma',
      tutorImage: 'https://...',
      metadata: {
        'subject': 'Mathematics',
        'level': 'JEE Advanced',
        'sessions': 10,
        'tutor': 'Priya Sharma',
      },
      onSuccess: () {
        // Handle successful payment
        print('Payment completed!');
      },
    ),
  ),
);
```

## Testing

### Test Cards
- **Success**: 4111 1111 1111 1111
- **Failure**: 4000 0000 0000 0002
- **CVV**: Any 3 digits
- **Expiry**: Any future date

### Test UPI
- **Success**: success@razorpay
- **Failure**: failure@razorpay

## Security
- API credentials stored in service file (move to env variables in production)
- Basic Auth for API requests
- HTTPS for all API calls
- Razorpay handles PCI compliance
- No card details stored in app

## Next Steps
1. Move credentials to environment variables
2. Implement webhook for payment verification
3. Add payment history screen
4. Implement refund functionality
5. Add payment analytics
6. Test on production environment

## Dependencies
```yaml
razorpay_flutter: ^1.3.7
```

## Platform Support
- ✅ Android (SDK 21+)
- ✅ iOS (12.0+)
- ✅ Web (via Razorpay Checkout)
