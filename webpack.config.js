const defaultConfig = require('@wordpress/scripts/config/webpack.config');
const path = require('path');

// Standard assets configuration
const standardConfig = {
    entry: {
        'main': './src/js/main.js',
        'admin': './src/js/admin.js'
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, 'assets/js')
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: ['@babel/preset-env']
                    }
                }
            }
        ]
    }
};

// Gutenberg blocks configuration
const gutenbergConfig = {
    ...defaultConfig,
    entry: {
        'blocks/index': path.resolve(__dirname, 'src/blocks/index.js'),
        'patterns/index': path.resolve(__dirname, 'src/patterns/index.js'),
        'templates/index': path.resolve(__dirname, 'src/templates/index.js'),
        'extensions/index': path.resolve(__dirname, 'src/extensions/index.js')
    }
};

module.exports = [standardConfig, gutenbergConfig];
