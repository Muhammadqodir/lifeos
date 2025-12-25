# Finance Main Page Implementation

## Overview
This document describes the implementation of the Finance main page for the LifeOS mobile app. The page is displayed when users tap the "Finances" item in the bottom navigation bar.

## Architecture

The implementation follows **Clean Architecture** with the BLoC pattern for state management:

```
lib/features/finance/
├── data/
│   ├── datasources/
│   │   └── finance_api_client.dart          # API client for finance endpoints
│   ├── models/
│   │   ├── currency_dto.dart                # Currency data model
│   │   ├── finance_summary_dto.dart         # Finance summary model (total balance)
│   │   ├── transaction_category_dto.dart    # Transaction category model
│   │   ├── transaction_dto.dart             # Transaction & entries models
│   │   └── wallet_dto.dart                  # Wallet model
│   └── repositories/
│       └── finance_repository_impl.dart     # Repository implementation
├── domain/
│   └── repositories/
│       └── finance_repository.dart          # Repository interface
└── presentation/
    ├── bloc/
    │   ├── finance_home_bloc.dart           # BLoC logic
    │   ├── finance_home_event.dart          # BLoC events
    │   └── finance_home_state.dart          # BLoC states
    ├── pages/
    │   └── finance_main_page.dart           # Main finance page UI
    └── widgets/
        ├── empty_state.dart                 # Empty state widget
        ├── error_state.dart                 # Error state widget
        ├── loading_skeleton.dart            # Loading skeleton
        ├── total_card.dart                  # Total balance card
        ├── transaction_tile.dart            # Transaction list item
        ├── wallet_card.dart                 # Single wallet card
        └── wallet_carousel.dart             # Horizontal wallet list
```

## Features Implemented

### 1. App Bar
- **Title**: "Finances"
- **Actions**:
  - Add transaction button (stub route - shows "Coming Soon" toast)
  - Settings button (stub route - shows "Coming Soon" toast)

### 2. Total Balance Card
- Displays total balance in user's base/favorite currency
- Shows loading skeleton while fetching data
- Data source: Computed from wallet balances (TODO: replace with dedicated API endpoint when available)

### 3. Wallets Carousel
- Horizontal scrolling list of wallet cards
- Each wallet card shows:
  - Icon based on wallet type (card/bank_account/cash/other) using HugeIcons
  - Wallet name
  - Currency code
  - Balance (formatted with K/M abbreviations)
- Tap handler: Shows "Coming Soon" toast (TODO: navigate to WalletDetailsPage)
- Empty state: Shows a card with "Add wallet" button when no wallets exist

### 4. Transaction History
- Section header: "History"
- List of recent transactions (first page: 20 items)
- Each transaction displays:
  - Category icon (emoji from category or default based on type)
  - Category title or description
  - Formatted date (Today/Yesterday/Weekday/Date)
  - Amount with sign (+/-)
  - Currency code
- Pagination: "Load more" button at the end
- Tap handler: Shows "Coming Soon" toast (TODO: navigate to TransactionDetailsPage)
- Empty state: Shows message when no transactions exist

### 5. State Management

**BLoC Events**:
- `FinanceHomeStarted`: Initial data load
- `FinanceHomeRefreshed`: Pull-to-refresh
- `FinanceHomeRetried`: Retry after error
- `FinanceHomeLoadMoreHistory`: Load next page of transactions

**BLoC States**:
- `FinanceHomeInitial`: Initial state
- `FinanceHomeLoading`: Loading data
- `FinanceHomeSuccess`: Data loaded successfully
- `FinanceHomeEmpty`: No wallets or transactions
- `FinanceHomeFailure`: Error occurred

### 6. UI Components

All components follow the shadcn UI design system:

- **ShadCard**: Container component
- **ShadButton**: Primary/ghost/outline buttons
- **ShadToast**: Toast notifications
- **HugeIcon**: Icon component (strokeRounded variants)
- **Theme**: Uses `ShadTheme.of(context)` for color scheme

Custom skeleton loading uses `Container` with `colorScheme.muted` background.

## API Integration

### Endpoints Used

1. **GET /api/v1/wallets**
   - Returns list of user's wallets
   - Response: `{ data: [WalletDto, ...] }`

2. **GET /api/v1/wallets/{id}/balance**
   - Returns balance for specific wallet
   - Response: `{ data: { wallet_id, balance, currency_id } }`

3. **GET /api/v1/transactions?page=1&per_page=20**
   - Returns paginated transactions
   - Query params: page, per_page, type, wallet_id, category_id, date_from, date_to, q
   - Response: `{ data: [TransactionDto, ...], meta: { current_page, last_page, per_page, total } }`

4. **Finance Summary** (TODO)
   - Currently computed client-side from wallet balances
   - Should be replaced with dedicated API endpoint when available

### Data Models

All models include:
- `fromJson` factory constructors
- `toJson` methods
- Equatable for value comparison
- Proper null safety

Key models:
- `CurrencyDto`: Currency information
- `WalletDto`: Wallet with currency and balance
- `TransactionDto`: Transaction with entries and category
- `TransactionEntryDto`: Individual transaction entry
- `FinanceSummaryDto`: Total balance summary
- `PaginationMeta`: Pagination metadata

## Dependency Injection

Updated `injection.dart` to register:
- `FinanceApiClient`: Singleton API client
- `FinanceRepository`: Singleton repository
- `FinanceHomeBloc`: Factory (new instance per use)

## Integration

### Navigation Integration

Updated `main_page.dart` to:
1. Import finance components
2. Create `FinanceHomeBloc` with dependency injection
3. Replace placeholder with `FinanceMainPage`
4. Update app bar actions (Add Transaction, Settings)

The Finance page is shown when navigation index is 1 (Finances tab).

## Design System Compliance

✅ Uses shadcn UI components exclusively
✅ Uses HugeIcons for all icons
✅ Reads colors from `ShadTheme.of(context).colorScheme`
✅ No hardcoded hex colors
✅ Consistent styling with rest of app

## TODOs

1. **API Endpoint**: Replace client-side total computation with dedicated `/api/v1/finance/summary` endpoint
2. **Navigation Routes**:
   - AddTransactionPage
   - FinanceSettingsPage
   - WalletDetailsPage(walletId)
   - TransactionDetailsPage(transactionId)
3. **Features**:
   - Add wallet functionality
   - Transaction filtering
   - Search functionality
   - Date range selection
4. **Optimizations**:
   - Cache wallet balances
   - Implement offline support
   - Add loading states for individual wallets

## Testing

To test the implementation:

1. Ensure backend is running with seeded data
2. Login to the app
3. Tap "Finances" in bottom navigation
4. Verify:
   - Loading skeleton appears
   - Total card shows correct balance
   - Wallets scroll horizontally
   - Transactions display with correct formatting
   - Pull-to-refresh works
   - Load more pagination works
   - Error states show retry button
   - Empty states show appropriate messages

## Known Limitations

1. Total balance is computed client-side (sum of wallet balances) - should use dedicated API endpoint
2. No currency conversion yet - displays amounts in original currency
3. All navigation actions show "Coming Soon" toasts
4. No filters or search implemented yet
5. Wallet balance formatting uses simplified K/M abbreviations

## Production Considerations

Before production:
- [ ] Implement proper error tracking (Sentry/Firebase)
- [ ] Add analytics events (page view, button taps)
- [ ] Implement proper loading states for each section
- [ ] Add accessibility labels
- [ ] Test with large datasets (1000+ transactions)
- [ ] Implement virtualized scrolling for performance
- [ ] Add unit tests for BLoC
- [ ] Add widget tests for UI components
- [ ] Test with different locales and currencies
- [ ] Verify RTL language support
