# Simple POS Flutter

A simple Point of Sale (POS) system for small shops built with Flutter.

## Features

- **Authentication**: Simple PIN or username/password login
- **Product Management**: Full CRUD operations for products with categories, stock tracking, and barcode support
- **Point of Sale**: Intuitive cart system with discount and tax calculation
- **Sales History**: View past transactions with detailed breakdowns
- **Dashboard**: Daily revenue summary and top-selling products
- **Settings**: Configure shop information, tax rates, and currency

## Tech Stack

- **Flutter**: Latest stable version
- **State Management**: Provider
- **Local Database**: sqflite (offline-first)
- **Platforms**: Android & iOS (optimized for tablets and phones)

## Project Structure

```
lib/
├── core/
│   ├── constants/     # App colors, strings
│   └── utils/         # Validators, formatters
├── models/            # Data models
├── data/
│   ├── db/           # Database setup
│   └── repositories/ # Data access layer
├── services/         # Business logic
├── providers/        # State management
└── ui/
    ├── widgets/      # Reusable widgets
    └── screens/     # App screens
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/mdung/simple_pos_flutter.git
cd simple_pos_flutter
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Default Credentials

- **PIN**: `1234`
- **Username**: `admin` (optional, can use PIN only)

## Usage

1. **Login**: Use PIN `1234` or username `admin` with PIN `1234`
2. **Add Products**: Navigate to Products → Add Product
3. **Make Sales**: Go to POS screen, add products to cart, and complete sale
4. **View History**: Check Sales History for past transactions
5. **Configure Settings**: Set up shop info, tax rate, and currency in Settings

## Database

The app uses sqflite for local storage. All data is stored locally on the device.

## Features in Detail

### Product Management
- Add/edit/delete products
- Search and filter by category
- Track stock quantities
- Support for SKU and barcode

### POS System
- Grid/list view of products
- Add items to cart with quantity control
- Apply discounts (amount or percentage)
- Automatic tax calculation
- Cash and card payment options
- Change calculation for cash payments

### Sales & Reporting
- Complete sales history
- Detailed sale breakdowns
- Daily revenue tracking
- Top 5 products by quantity sold

### Settings
- Shop name, address, phone
- Configurable tax rate
- Custom currency symbol

## Development

The project follows clean architecture principles:
- **Models**: Data structures
- **Repositories**: Data access abstraction
- **Services**: Business logic
- **Providers**: State management
- **UI**: Presentation layer

## License

This project is open source and available for use.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

