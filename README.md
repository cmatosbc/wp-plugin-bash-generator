# One Click Wordpress Plugin Boilerplate

A modern WordPress plugin boilerplate generator that creates a well-structured, object-oriented plugin with optional support for Elementor, WooCommerce, and Gutenberg blocks.

## Features

- 🏗️ Modern Object-Oriented Architecture
- 🧩 PSR-4 Autoloading
- 🔌 Optional Integration Support:
  - Elementor Extensions
  - WooCommerce Extensions
  - Gutenberg Blocks
- 🛠️ Development Tools:
  - Webpack configuration
  - ESLint and Prettier setup
  - SASS/SCSS support
  - Hot Module Replacement (HMR)
- 🧪 Testing Setup
- 🌐 Internationalization Ready

## Requirements

- PHP 7.4 or higher
- WordPress 5.8 or higher
- Composer
- Node.js and npm (for Gutenberg development)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/cmatosbc/wp-plugin-bash-generator.git
```

2. Make the script executable:
```bash
chmod +x create.sh
```

## Usage

### Basic Plugin Creation

Create a basic plugin with the standard structure:
```bash
./create.sh "Your Plugin Name"
```

### With Elementor Support

Create a plugin with Elementor integration:
```bash
./create.sh "Your Plugin Name" --elementor
```

This will create:
- Custom Elementor widgets structure
- Widget registration system
- Category registration

### With WooCommerce Support

Create a plugin with WooCommerce integration:
```bash
./create.sh "Your Plugin Name" --woocommerce
```

This will create:
- WooCommerce hooks integration
- Settings page
- Product-related functionality

### With Gutenberg Support

Create a plugin with Gutenberg blocks support:
```bash
./create.sh "Your Plugin Name" --gutenberg
```

This will set up:
- Modern block development environment
- Example blocks (static and dynamic)
- Block patterns
- Block extensions
- Full Site Editing (FSE) templates

### Combined Features

You can combine any of the features:
```bash
./create.sh "Your Plugin Name" --elementor --woocommerce --gutenberg
```

## Development

### Initial Setup

1. Install PHP dependencies:
```bash
composer install
```

2. If using Gutenberg blocks, install JavaScript dependencies:
```bash
npm install
```

### Development Commands

#### PHP

- Run PHP tests:
```bash
composer test
```

- Check coding standards:
```bash
composer phpcs
```

- Fix coding standards:
```bash
composer phpcbf
```

#### JavaScript (Gutenberg)

- Start development server:
```bash
npm start
```

- Build for production:
```bash
npm run build
```

- Lint JavaScript:
```bash
npm run lint:js
```

- Lint CSS/SCSS:
```bash
npm run lint:style
```

- Format code:
```bash
npm run format
```

## Plugin Structure

```
your-plugin/
├── assets/                  # Compiled assets
│   ├── css/
│   ├── js/
│   └── images/
├── inc/                     # PHP classes
│   ├── Admin/              # Admin-related classes
│   ├── Api/                # REST API endpoints
│   ├── Blocks/             # Gutenberg blocks (if enabled)
│   ├── Common/             # Shared traits and interfaces
│   ├── Core/               # Core plugin classes
│   ├── Elementor/          # Elementor integration (if enabled)
│   ├── Frontend/           # Frontend-related classes
│   └── WooCommerce/        # WooCommerce integration (if enabled)
├── languages/              # Translation files
├── src/                    # Source files
│   ├── blocks/            # Gutenberg blocks source
│   ├── patterns/          # Block patterns
│   ├── templates/         # FSE templates
│   └── extensions/        # Block extensions
├── templates/             # Template files
├── tests/                 # Test files
├── vendor/                # Composer dependencies
├── node_modules/          # npm dependencies
├── composer.json          # PHP dependencies
├── package.json           # JavaScript dependencies
├── webpack.config.js      # Webpack configuration
├── README.md             # This file
└── your-plugin.php       # Main plugin file
```

## Best Practices

1. Always use namespaces for your classes
2. Follow WordPress coding standards
3. Write unit tests for your functionality
4. Keep your code modular and maintainable
5. Use hooks and filters to make your plugin extensible
6. Document your code thoroughly

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Credits

Created and maintained by Carlos Matos.
