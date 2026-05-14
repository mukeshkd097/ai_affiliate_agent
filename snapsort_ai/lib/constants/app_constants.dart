class AppConstants {
  static const String appName = 'SnapSort AI';
  static const String appVersion = '1.0.0';

  // Free tier limit
  static const int freeScreenshotLimit = 500;

  // Subscription product IDs
  static const String proMonthlyId = 'snapsort_pro_monthly';
  static const String proYearlyId = 'snapsort_pro_yearly';
  static const String proLifetimeId = 'snapsort_pro_lifetime';

  // Display pricing
  static const String proMonthlyPriceINR = '₹99/month';
  static const String proYearlyPriceINR = '₹799/year';
  static const String proLifetimePriceINR = '₹1,999';
  static const String proMonthlyPriceUSD = '\$1.99/month';
  static const String proYearlyPriceUSD = '\$14.99/year';

  // SharedPreferences keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyIsPro = 'is_pro';
  static const String keyProExpiry = 'pro_expiry';
  static const String keyTotalScanned = 'total_scanned';
  static const String keyLastScanTime = 'last_scan_time';

  // Database
  static const String dbName = 'snapsort.db';
  static const int dbVersion = 1;

  // OTP patterns — 6-digit codes within context keywords
  static const List<String> otpKeywords = [
    'otp', 'one time password', 'one-time', 'verification code',
    'your code', 'use code', 'enter code', 'passcode',
    'login code', 'security code', 'auth code', 'authentication',
    '2fa', 'two factor', 'expires in', 'do not share',
  ];

  static const List<String> receiptKeywords = [
    'receipt', 'invoice', 'order id', 'order #', 'order no',
    'subtotal', 'grand total', 'amount paid', 'payment successful',
    'transaction successful', 'payment confirmed', 'thank you for your order',
    'order confirmed', 'delivery by', 'estimated delivery',
  ];

  static const List<String> billKeywords = [
    'electricity bill', 'water bill', 'gas bill', 'phone bill',
    'internet bill', 'broadband', 'due date', 'units consumed',
    'meter reading', 'consumer number', 'bill amount', 'bill no',
    'airtel', 'jio', 'vi ', 'bsnl', 'act fibernet', 'tata sky',
    'dish tv', 'd2h', 'sun direct',
  ];

  static const List<String> tradingKeywords = [
    'zerodha', 'groww', 'upstox', 'kite', 'angel broking', 'angel one',
    'nse', 'bse', 'nifty', 'sensex', 'p&l', 'profit & loss',
    'buy order', 'sell order', 'portfolio value', 'holdings',
    'open positions', 'equity', 'f&o', 'futures', 'options',
    'mutual fund', 'nav', 'sip', 'intraday', 'delivery',
    'traded qty', 'avg price', 'ltp',
  ];

  static const List<String> cryptoKeywords = [
    'bitcoin', 'btc', 'ethereum', 'eth', 'binance', 'bnb',
    'coinbase', 'wazirx', 'coindcx', 'zebpay', 'usdt', 'usdc',
    'crypto', 'blockchain', 'wallet address', 'defi',
    'nft', 'altcoin', 'dogecoin', 'solana', 'sol',
    'polygon', 'matic', 'cardano', 'ada', 'xrp', 'ripple',
    'gas fee', 'transaction hash', 'txid',
  ];

  static const List<String> shoppingKeywords = [
    'amazon', 'flipkart', 'myntra', 'meesho', 'ajio', 'nykaa',
    'zomato', 'swiggy', 'blinkit', 'zepto', 'bigbasket', 'instamart',
    'order placed', 'order shipped', 'out for delivery',
    'delivered', 'track your order', 'return window',
    'discount applied', 'coupon code', 'cashback', 'loyalty points',
    'add to cart', 'wish list',
  ];

  static const List<String> ticketKeywords = [
    'pnr', 'pnr no', 'booking id', 'booking confirmation',
    'seat no', 'coach', 'berth', 'flight', 'train', 'bus',
    'irctc', 'makemytrip', 'goibibo', 'redbus', 'cleartrip', 'ixigo',
    'boarding pass', 'e-ticket', 'ticket id', 'movie ticket',
    'bookmyshow', 'paytm insider', 'gate closes', 'terminal',
    'departure', 'arrival', 'platform no',
  ];

  static const List<String> bankKeywords = [
    'account number', 'a/c no', 'ifsc', 'bank statement',
    'available balance', 'transaction id', 'utr no', 'ref no',
    'net banking', 'mobile banking', 'credit card statement',
    'debit card', 'atm', 'mini statement', 'passbook',
    'hdfc', 'sbi', 'icici', 'axis bank', 'kotak', 'yes bank',
    'pnb', 'bob', 'canara', 'idfc', 'rbl', 'federal bank',
  ];

  static const List<String> notesKeywords = [
    'todo', 'to-do', 'reminder', 'note to self', 'remember',
    'important:', 'meeting', 'agenda', 'checklist',
    'idea:', 'thought:', 'draft:', 'summary:',
  ];
}
