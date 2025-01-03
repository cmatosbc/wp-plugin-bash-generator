const path = require('path');

module.exports = {
    entry: {
        'main': './src/js/main.js',
        'admin': './src/js/admin.js',
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, 'assets/js'),
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
