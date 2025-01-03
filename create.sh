#!/bin/bash

# Check if plugin name argument is provided
if [ $# -lt 1 ] || [ $# -gt 4 ]; then
    echo "Usage: $0 <plugin-name> [--elementor] [--woocommerce] [--gutenberg]"
    exit 1
fi

# Get the plugin name from argument and check for flags
PLUGIN_NAME="$1"
ELEMENTOR_FLAG=false
WOOCOMMERCE_FLAG=false
GUTENBERG_FLAG=false

shift
while [ $# -gt 0 ]; do
    case "$1" in
        --elementor)
            ELEMENTOR_FLAG=true
            ;;
        --woocommerce)
            WOOCOMMERCE_FLAG=true
            ;;
        --gutenberg)
            GUTENBERG_FLAG=true
            ;;
        *)
            echo "Invalid option: $1"
            echo "Usage: $0 <plugin-name> [--elementor] [--woocommerce] [--gutenberg]"
            exit 1
            ;;
    esac
    shift
done

# Create slug (lowercase, replace spaces with hyphens)
PLUGIN_SLUG=$(echo "$PLUGIN_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

# Create class name (remove spaces, capitalize words)
CLASS_NAME=$(echo "$PLUGIN_NAME" | sed -e 's/\b\(.\)/\u\1/g' | tr -d ' ')

# Create directory structure
mkdir -p inc/Core
mkdir -p inc/Admin
mkdir -p inc/Frontend
mkdir -p inc/Api
mkdir -p inc/Common/{Traits,Interfaces}
mkdir -p assets/{js,css,images}
mkdir -p src/{js,css}
mkdir -p languages
mkdir -p templates
mkdir -p tests

# Create initial package.json
cat > "package.json" << EOL
{
    "name": "${PLUGIN_SLUG}",
    "version": "1.0.0",
    "description": "WordPress plugin for ${PLUGIN_NAME}",
    "scripts": {
        "test": "jest",
        "build": "webpack --mode production",
        "start": "webpack --mode development --watch",
        "build:css": "sass src/css:assets/css --style compressed",
        "watch:css": "sass src/css:assets/css --watch",
        "build:all": "npm run build && npm run build:css"
    },
    "author": "Carlos Matos",
    "license": "MIT",
    "devDependencies": {
        "@babel/core": "^7.23.0",
        "@babel/preset-env": "^7.22.20",
        "babel-loader": "^9.1.3",
        "sass": "^1.69.0",
        "webpack": "^5.88.2",
        "webpack-cli": "^5.1.4"
    }
}
EOL

# Create initial JavaScript files
cat > "src/js/main.js" << EOL
// Main frontend JavaScript file
console.log('Frontend script loaded');
EOL

cat > "src/js/admin.js" << EOL
// Admin JavaScript file
console.log('Admin script loaded');
EOL

# Create initial SCSS files
cat > "src/css/main.scss" << EOL
// Main frontend styles
.${PLUGIN_SLUG} {
    &-container {
        padding: 20px;
    }
}
EOL

cat > "src/css/admin.scss" << EOL
// Admin styles
.${PLUGIN_SLUG}-admin {
    &-container {
        padding: 20px;
    }
}
EOL

# Create the main plugin file
cat > "${PLUGIN_SLUG}.php" << EOL
<?php
/**
 * Plugin Name: ${PLUGIN_NAME}
 * Plugin URI: 
 * Description: A modern WordPress plugin using OOP architecture
 * Version: 1.0.0
 * Author: Carlos Matos
 * Author URI: 
 * License: GPL v2 or later
 * License URI: https://www.gnu.org/licenses/gpl-2.0.html
 * Text Domain: ${PLUGIN_SLUG}
 * Domain Path: /languages
 */

declare(strict_types=1);

if (!defined('ABSPATH')) {
    exit;
}

// Plugin constants
define('${CLASS_NAME^^}_PLUGIN_VERSION', '1.0.0');
define('${CLASS_NAME^^}_PLUGIN_FILE', __FILE__);
define('${CLASS_NAME^^}_PLUGIN_PATH', plugin_dir_path(__FILE__));
define('${CLASS_NAME^^}_PLUGIN_URL', plugin_dir_url(__FILE__));

// Composer autoloader
if (file_exists(dirname(__FILE__) . '/vendor/autoload.php')) {
    require_once dirname(__FILE__) . '/vendor/autoload.php';
}

// Initialize the plugin
if (class_exists('${CLASS_NAME}\\Core\\Plugin')) {
    \$plugin = new ${CLASS_NAME}\\Core\\Plugin();
    \$plugin->run();
}
EOL

# Create Plugin.php
cat > "inc/Core/Plugin.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Core;

use ${CLASS_NAME}\\Admin\\Admin;
use ${CLASS_NAME}\\Frontend\\Frontend;
use ${CLASS_NAME}\\Api\\Api;

/**
 * The core plugin class.
 */
class Plugin
{
    /**
     * The loader that's responsible for maintaining and registering all hooks.
     */
    protected Loader \$loader;

    protected \$admin;
    protected \$frontend;
    protected \$api;

    /**
     * Initialize the core plugin.
     */
    public function __construct()
    {
        \$this->loader = new Loader();
        \$this->frontend = new Frontend();
        \$this->api = new Api();
        if (is_admin()) {
            \$this->admin = new Admin();
        }
        \$this->adminHooks();
        \$this->frontendHooks();
        \$this->apiHooks();
    }

    /**
     * Register all of the hooks related to the admin area.
     */
    private function adminHooks(): void
    {
        \$this->loader->action('admin_menu', \$this->admin, 'pluginMenu');
        \$this->loader->action('admin_init', \$this->admin, 'registerSettings');
    }

    /**
     * Register all of the hooks related to the public-facing functionality.
     */
    private function frontendHooks(): void
    {
        \$this->loader->action('wp_enqueue_scripts', \$this->frontend, 'styles');
        \$this->loader->action('wp_enqueue_scripts', \$this->frontend, 'scripts');
    }

    /**
     * Register all of the hooks related to the API functionality.
     */
    private function apiHooks(): void
    {
        \$this->loader->action('rest_api_init', \$this->api, 'addRoutes');
    }

    /**
     * Run the loader to execute all hooks.
     */
    public function run(): void
    {
        \$this->loader->run();
    }
}
EOL

# Create other core files...
# ... (rest of the code remains the same)

# Now update Plugin.php with integration code if needed
if [ "$ELEMENTOR_FLAG" = true ]; then
    sed -i "/apiHooks();/a\        \$this->initElementor();" "inc/Core/Plugin.php"
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize Elementor extensions if Elementor is active.\n     */\n    private function initElementor(): void\n    {\n        if (did_action('elementor\/loaded')) {\n            new \\${CLASS_NAME}\\Elementor\\Elementor();\n        }\n    }\n\n" "inc/Core/Plugin.php"
fi

if [ "$WOOCOMMERCE_FLAG" = true ]; then
    sed -i "/apiHooks();/a\        \$this->initWooCommerce();" "inc/Core/Plugin.php"
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize WooCommerce extensions if WooCommerce is active.\n     */\n    private function initWooCommerce(): void\n    {\n        if (class_exists('\\\\WooCommerce')) {\n            new \\${CLASS_NAME}\\WooCommerce\\WooCommerce();\n        }\n    }\n\n" "inc/Core/Plugin.php"
fi

# Create Gutenberg structure if flag is set
if [ "$GUTENBERG_FLAG" = true ]; then
    mkdir -p inc/Blocks/{Dynamic,Static}
    mkdir -p inc/Patterns
    mkdir -p inc/Templates
    mkdir -p src/{blocks,patterns,templates,extensions}
    
    # Update Plugin.php to include Gutenberg initialization
    sed -i "/apiHooks();/a\        \$this->initGutenberg();" "inc/Core/Plugin.php"
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize Gutenberg blocks and patterns.\n     */\n    private function initGutenberg(): void\n    {\n        new \\${CLASS_NAME}\\Blocks\\Blocks();\n        // Initialize dynamic blocks\n        new \\${CLASS_NAME}\\Blocks\\Dynamic\\ExampleBlock();\n    }\n\n" "inc/Core/Plugin.php"

    # Create temporary file with Gutenberg-specific configuration
    cat > gutenberg.json << EOL
{
    "scripts": {
        "build:blocks": "wp-scripts build",
        "start:blocks": "wp-scripts start",
        "packages-update": "wp-scripts packages-update",
        "check-engines": "wp-scripts check-engines",
        "lint:js": "wp-scripts lint-js",
        "lint:style": "wp-scripts lint-style",
        "format": "wp-scripts format"
    },
    "devDependencies": {
        "@wordpress/scripts": "^26.0.0",
        "@wordpress/components": "^25.0.0",
        "@wordpress/compose": "^6.0.0",
        "@wordpress/data": "^9.0.0",
        "@wordpress/block-editor": "^12.0.0",
        "@wordpress/blocks": "^12.0.0",
        "@wordpress/i18n": "^4.0.0",
        "@wordpress/server-side-render": "^4.0.0"
    }
}
EOL

    # Merge the configurations
    MERGED_CONTENT=$(jq -s '
        .[0] as $orig |
        .[1] as $new |
        $orig * {
            scripts: ($orig.scripts + $new.scripts),
            devDependencies: ($orig.devDependencies + $new.devDependencies)
        }
    ' package.json gutenberg.json)

    # Update package.json with merged content
    echo "$MERGED_CONTENT" > package.json

    # Clean up temporary file
    rm gutenberg.json

    # Update webpack.config.js to include both standard assets and Gutenberg entries
    cat > "webpack.config.js" << EOL
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
EOL

    # Create example block files
    cat > "src/blocks/index.js" << EOL
import { registerBlockType } from '@wordpress/blocks';
import {
    useBlockProps,
    RichText,
    AlignmentToolbar,
    BlockControls,
    InspectorControls,
    PanelColorSettings,
} from '@wordpress/block-editor';
import {
    PanelBody,
    SelectControl,
    TextControl,
    ToggleControl,
} from '@wordpress/components';
import { __ } from '@wordpress/i18n';

import './style.scss';
import './editor.scss';

registerBlockType('${PLUGIN_SLUG}/example', {
    apiVersion: 3,
    title: __('Example Block', '${PLUGIN_SLUG}'),
    description: __('An example block with various controls.', '${PLUGIN_SLUG}'),
    category: '${PLUGIN_SLUG}',
    icon: 'smiley',
    supports: {
        align: true,
        html: false,
        typography: true,
        color: {
            background: true,
            text: true,
            gradients: true,
        },
    },
    transforms: {
        from: [
            {
                type: 'block',
                blocks: ['core/paragraph'],
                transform: ({ content }) => {
                    return createBlock('${PLUGIN_SLUG}/example', {
                        content,
                    });
                },
            },
        ],
    },
    attributes: {
        content: {
            type: 'string',
            default: '',
        },
        alignment: {
            type: 'string',
            default: 'none',
        },
        backgroundColor: {
            type: 'string',
        },
        textColor: {
            type: 'string',
        },
        gradient: {
            type: 'string',
        },
        fontSize: {
            type: 'string',
        },
    },
    edit: ({ attributes, setAttributes }) => {
        const {
            content,
            alignment,
            backgroundColor,
            textColor,
            gradient,
            fontSize,
        } = attributes;
        
        const blockProps = useBlockProps({
            className: `has-text-align-${alignment}`,
            style: {
                backgroundColor,
                color: textColor,
                backgroundImage: gradient,
                fontSize,
            },
        });
        
        return (
            <>
                <BlockControls>
                    <AlignmentToolbar
                        value={alignment}
                        onChange={(newAlignment) =>
                            setAttributes({ alignment: newAlignment })
                        }
                    />
                </BlockControls>
                
                <InspectorControls>
                    <PanelBody title={__('Block Settings', '${PLUGIN_SLUG}')}>
                        <TextControl
                            label={__('Additional Settings', '${PLUGIN_SLUG}')}
                            value={content}
                            onChange={(newContent) =>
                                setAttributes({ content: newContent })
                            }
                        />
                    </PanelBody>
                    <PanelColorSettings
                        title={__('Color Settings', '${PLUGIN_SLUG}')}
                        colorSettings={[
                            {
                                value: backgroundColor,
                                onChange: (newColor) =>
                                    setAttributes({ backgroundColor: newColor }),
                                label: __('Background Color', '${PLUGIN_SLUG}'),
                            },
                            {
                                value: textColor,
                                onChange: (newColor) =>
                                    setAttributes({ textColor: newColor }),
                                label: __('Text Color', '${PLUGIN_SLUG}'),
                            },
                        ]}
                    />
                </InspectorControls>
                
                <div {...blockProps}>
                    <RichText
                        tagName="p"
                        value={content}
                        onChange={(newContent) =>
                            setAttributes({ content: newContent })
                        }
                        placeholder={__('Enter text...', '${PLUGIN_SLUG}')}
                    />
                </div>
            </>
        );
    },
    save: () => null, // Dynamic block, rendered on PHP side
});
EOL

    cat > "src/blocks/style.scss" << EOL
.wp-block-${PLUGIN_SLUG}-example {
    padding: 2em;
    border-radius: 4px;
    
    &.is-style-boxed {
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }
}
EOL

    cat > "src/blocks/editor.scss" << EOL
.wp-block-${PLUGIN_SLUG}-example {
    border: 1px dashed #ccc;
    
    &.is-selected {
        border-style: solid;
    }
}
EOL

    # Create example pattern
    cat > "src/patterns/index.js" << EOL
import { registerBlockPattern } from '@wordpress/blocks';
import { __ } from '@wordpress/i18n';

registerBlockPattern('${PLUGIN_SLUG}/example-pattern', {
    title: __('Example Pattern', '${PLUGIN_SLUG}'),
    description: __('An example block pattern.', '${PLUGIN_SLUG}'),
    categories: ['${PLUGIN_SLUG}'],
    content: \`
        <!-- wp:group {"className":"${PLUGIN_SLUG}-pattern"} -->
        <div class="wp-block-group ${PLUGIN_SLUG}-pattern">
            <!-- wp:heading {"level":2} -->
            <h2>Example Pattern</h2>
            <!-- /wp:heading -->

            <!-- wp:paragraph -->
            <p>This is an example pattern that you can customize.</p>
            <!-- /wp:paragraph -->

            <!-- wp:${PLUGIN_SLUG}/example {"align":"wide"} /-->
        </div>
        <!-- /wp:group -->
    \`,
});
EOL

    # Create FSE template example
    cat > "src/templates/index.js" << EOL
import { registerBlockTemplate } from '@wordpress/blocks';
import { __ } from '@wordpress/i18n';

registerBlockTemplate('${PLUGIN_SLUG}/example-template', {
    title: __('Example Template', '${PLUGIN_SLUG}'),
    description: __('An example block template.', '${PLUGIN_SLUG}'),
    content: \`
        <!-- wp:template-part {"slug":"header","theme":"${PLUGIN_SLUG}"} /-->

        <!-- wp:group {"layout":{"type":"constrained"}} -->
        <div class="wp-block-group">
            <!-- wp:post-title {"level":1,"align":"wide"} /-->
            <!-- wp:post-content {"align":"wide"} /-->
            
            <!-- wp:${PLUGIN_SLUG}/example {"align":"wide"} /-->
        </div>
        <!-- /wp:group -->

        <!-- wp:template-part {"slug":"footer","theme":"${PLUGIN_SLUG}"} /-->
    \`,
});
EOL

    # Create block extensions example
    cat > "src/extensions/index.js" << EOL
import { addFilter } from '@wordpress/hooks';
import { createHigherOrderComponent } from '@wordpress/compose';
import { __ } from '@wordpress/i18n';
import { InspectorControls } from '@wordpress/block-editor';
import { PanelBody, ToggleControl } from '@wordpress/components';

// Add custom attribute to paragraph block
addFilter(
    'blocks.registerBlockType',
    '${PLUGIN_SLUG}/custom-attribute',
    (settings, name) => {
        if (name !== 'core/paragraph') {
            return settings;
        }

        return {
            ...settings,
            attributes: {
                ...settings.attributes,
                isCustom: {
                    type: 'boolean',
                    default: false,
                },
            },
        };
    }
);

// Add custom control to paragraph block
const withCustomControl = createHigherOrderComponent((BlockEdit) => {
    return (props) => {
        if (props.name !== 'core/paragraph') {
            return <BlockEdit {...props} />;
        }

        const { attributes, setAttributes } = props;
        const { isCustom } = attributes;

        return (
            <>
                <BlockEdit {...props} />
                <InspectorControls>
                    <PanelBody
                        title={__('Custom Settings', '${PLUGIN_SLUG}')}
                        initialOpen={true}
                    >
                        <ToggleControl
                            label={__('Custom Feature', '${PLUGIN_SLUG}')}
                            checked={isCustom}
                            onChange={() =>
                                setAttributes({ isCustom: !isCustom })
                            }
                        />
                    </PanelBody>
                </InspectorControls>
            </>
        );
    };
}, '${PLUGIN_SLUG}WithCustomControl');

addFilter(
    'editor.BlockEdit',
    '${PLUGIN_SLUG}/custom-control',
    withCustomControl
);

// Add custom style to paragraph block
const withCustomStyle = createHigherOrderComponent((BlockListBlock) => {
    return (props) => {
        if (
            props.name !== 'core/paragraph' ||
            !props.attributes.isCustom
        ) {
            return <BlockListBlock {...props} />;
        }

        return (
            <BlockListBlock
                {...props}
                className={'has-custom-style'}
            />
        );
    };
}, '${PLUGIN_SLUG}WithCustomStyle');

addFilter(
    'editor.BlockListBlock',
    '${PLUGIN_SLUG}/custom-style',
    withCustomStyle
);
EOL

    # Update Plugin.php to include Gutenberg initialization
    sed -i "/apiHooks();/a\        \$this->initGutenberg();" "inc/Core/Plugin.php"
    
    # Add initialize_gutenberg method to Plugin.php
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize Gutenberg blocks and patterns.\n     */\n    private function initGutenberg(): void\n    {\n        new \\${CLASS_NAME}\\Blocks\\Blocks();\n        // Initialize dynamic blocks\n        new \\${CLASS_NAME}\\Blocks\\Dynamic\\ExampleBlock();\n    }\n\n" "inc/Core/Plugin.php"

    # Create .eslintrc.js
    cat > ".eslintrc.js" << EOL
module.exports = {
    extends: [ 'plugin:@wordpress/eslint-plugin/recommended' ],
};
EOL

    # Create .prettierrc.js
    cat > ".prettierrc.js" << EOL
module.exports = {
    ...require('@wordpress/prettier-config'),
};
EOL
fi

# Create Elementor directory and class if flag is set
if [ "$ELEMENTOR_FLAG" = true ]; then
    mkdir -p inc/Elementor
    
    # Create Elementor.php
    cat > "inc/Elementor/Elementor.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Elementor;

use Elementor\Elements_Manager;

/**
 * Elementor extensions handler class.
 */
class Elementor
{
    /**
     * Initialize Elementor extensions.
     */
    public function __construct()
    {
        add_action(
            'elementor/widgets/register',
            [\$this, 'registerWidgets']
        );
        add_action(
            'elementor/elements/categories_registered',
            [\$this, 'registerCategories']
        );
    }

    /**
     * Register custom Elementor widgets.
     *
     * @return void
     */
    public function registerWidgets(): void
    {
        // Register widgets here
    }

    /**
     * Add custom categories for Elementor widgets.
     *
     * @param Elements_Manager \$elements_manager Elementor elements manager.
     * @return void
     */
    public function registerCategories(Elements_Manager \$elements_manager): void
    {
        \$elements_manager->add_category(
            '${PLUGIN_SLUG}',
            [
                'title' => esc_html__('${PLUGIN_NAME}', '${PLUGIN_SLUG}'),
                'icon' => 'fa fa-plug',
            ]
        );
    }
}
EOL
fi

# Create WooCommerce directory and class if flag is set
if [ "$WOOCOMMERCE_FLAG" = true ]; then
    mkdir -p inc/WooCommerce
    
    # Create WooCommerce.php
    cat > "inc/WooCommerce/WooCommerce.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\WooCommerce;

/**
 * WooCommerce extensions handler class.
 */
class WooCommerce
{
    /**
     * Initialize WooCommerce extensions.
     */
    public function __construct()
    {
        add_action('woocommerce_loaded', [\$this, 'init']);
        add_filter('woocommerce_get_settings_pages', [\$this, 'addSettingsPage']);
    }

    /**
     * Initialize WooCommerce-specific functionality.
     *
     * @return void
     */
    public function init(): void
    {
        // Initialize WooCommerce specific functionality here
        add_action('woocommerce_before_single_product', [\$this, 'beforeSingleProduct']);
        add_action('woocommerce_after_single_product', [\$this, 'afterSingleProduct']);
        add_filter('woocommerce_product_tabs', [\$this, 'productTabs']);
    }

    /**
     * Add WooCommerce settings page.
     *
     * @param array \$settings Array of WC_Settings_Page objects.
     * @return array Modified array of WC_Settings_Page objects.
     */
    public function addSettingsPage(array \$settings): array
    {
        \$settings[] = new Settings();
        return \$settings;
    }

    /**
     * Actions to perform before single product display.
     *
     * @return void
     */
    public function beforeSingleProduct(): void
    {
        // Add your code here
    }

    /**
     * Actions to perform after single product display.
     *
     * @return void
     */
    public function afterSingleProduct(): void
    {
        // Add your code here
    }

    /**
     * Modify product tabs.
     *
     * @param array \$tabs Array of product tabs.
     * @return array Modified array of product tabs.
     */
    public function productTabs(array \$tabs): array
    {
        // Add or modify product tabs here
        return \$tabs;
    }
}
EOL

    # Create Settings.php for WooCommerce settings
    cat > "inc/WooCommerce/Settings.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\WooCommerce;

use WC_Settings_Page;

/**
 * WooCommerce Settings Page handler class.
 */
class Settings extends WC_Settings_Page
{
    /**
     * Constructor.
     */
    public function __construct()
    {
        \$this->id = '${PLUGIN_SLUG}';
        \$this->label = __('${PLUGIN_NAME}', '${PLUGIN_SLUG}');

        parent::__construct();
    }

    /**
     * Get settings array.
     *
     * @return array
     */
    public function get_settings(): array
    {
        \$settings = [
            [
                'title' => __('${PLUGIN_NAME} Settings', '${PLUGIN_SLUG}'),
                'type'  => 'title',
                'desc'  => '',
                'id'    => '${PLUGIN_SLUG}_settings'
            ],
            [
                'type' => 'sectionend',
                'id'   => '${PLUGIN_SLUG}_settings'
            ]
        ];

        return apply_filters('woocommerce_get_settings_' . \$this->id, \$settings);
    }
}
EOL
fi

# Now update Plugin.php with integration code if needed
if [ "$ELEMENTOR_FLAG" = true ]; then
    sed -i "/apiHooks();/a\        \$this->initElementor();" "inc/Core/Plugin.php"
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize Elementor extensions if Elementor is active.\n     */\n    private function initElementor(): void\n    {\n        if (did_action('elementor\/loaded')) {\n            new \\${CLASS_NAME}\\Elementor\\Elementor();\n        }\n    }\n\n" "inc/Core/Plugin.php"
fi

if [ "$WOOCOMMERCE_FLAG" = true ]; then
    sed -i "/apiHooks();/a\        \$this->initWooCommerce();" "inc/Core/Plugin.php"
    sed -i "/apiHooks(): void {/i\    /**\n     * Initialize WooCommerce extensions if WooCommerce is active.\n     */\n    private function initWooCommerce(): void\n    {\n        if (class_exists('\\\\WooCommerce')) {\n            new \\${CLASS_NAME}\\WooCommerce\\WooCommerce();\n        }\n    }\n\n" "inc/Core/Plugin.php"
fi

# Create Loader.php
cat > "inc/Core/Loader.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Core;

/**
 * Register all actions and filters for the plugin.
 */
class Loader
{
    /**
     * The array of actions registered with WordPress.
     */
    protected array \$actions = [];

    /**
     * The array of filters registered with WordPress.
     */
    protected array \$filters = [];

    /**
     * Add a new action to the collection to be registered with WordPress.
     */
    public function action(
        string \$hook,
        object \$component,
        string \$callback,
        int \$priority = 10,
        int \$acceptedArgs = 1): void
    {
        \$this->actions = \$this->add(
            \$this->actions, \$hook, \$component, \$callback, \$priority, \$acceptedArgs
        );
    }

    /**
     * Add a new filter to the collection to be registered with WordPress.
     */
    public function filter(
        string \$hook,
        object \$component,
        string \$callback,
        int \$priority = 10,
        int \$acceptedArgs = 1): void
    {
        \$this->filters = \$this->add(
            \$this->filters, \$hook, \$component, \$callback, \$priority, \$acceptedArgs
        );
    }

    /**
     * A utility function that is used to register the actions and hooks into a single collection.
     */
    private function add(
        array \$hooks,
        string \$hook,
        object \$component,
        string \$callback,
        int \$priority,
        int \$acceptedArgs): array
    {
        \$hooks[] = [
            'hook'          => \$hook,
            'component'     => \$component,
            'callback'      => \$callback,
            'priority'      => \$priority,
            'accepted_args' => \$acceptedArgs
        ];

        return \$hooks;
    }

    /**
     * Run the loader to execute all hooks.
     */
    public function run(): void
    {
        foreach (\$this->filters as \$hook) {
            add_filter(
                \$hook['hook'],
                [\$hook['component'], \$hook['callback']],
                \$hook['priority'],
                \$hook['accepted_args']
            );
        }

        foreach (\$this->actions as \$hook) {
            add_action(
                \$hook['hook'],
                [\$hook['component'], \$hook['callback']],
                \$hook['priority'],
                \$hook['accepted_args']
            );
        }
    }
}
EOL

# Create Admin.php
cat > "inc/Admin/Admin.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Admin;

class Admin
{
    public function pluginMenu(): void
    {
        add_menu_page(
            '${PLUGIN_NAME}',
            '${PLUGIN_NAME}',
            'manage_options',
            '${PLUGIN_SLUG}',
            [\$this, 'render'],
            'dashicons-admin-generic'
        );
    }

    public function registerSettings(): void
    {
        register_setting('${PLUGIN_SLUG}_options', '${PLUGIN_SLUG}_settings');
    }

    public function render(): void
    {
        require_once ${CLASS_NAME}_PLUGIN_PATH . 'templates/admin.php';
    }
}
EOL

# Create Frontend.php
cat > "inc/Frontend/Frontend.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Frontend;

class Frontend
{
    public function styles(): void
    {
        wp_enqueue_style(
            '${PLUGIN_SLUG}',
            ${CLASS_NAME}_PLUGIN_URL . 'assets/css/frontend.css',
            [],
            ${CLASS_NAME}_PLUGIN_VERSION
        );
    }

    public function scripts(): void
    {
        wp_enqueue_script(
            '${PLUGIN_SLUG}',
            ${CLASS_NAME}_PLUGIN_URL . 'assets/js/frontend.js',
            ['jquery'],
            ${CLASS_NAME}_PLUGIN_VERSION,
            true
        );
    }
}
EOL

# Create Api.php
cat > "inc/Api/Api.php" << EOL
<?php

declare(strict_types=1);

namespace ${CLASS_NAME}\\Api;

class Api
{
    public function addRoutes(): void
    {
    }
}
EOL

# Create admin template
cat > "templates/admin.php" << EOL
<div class="wrap">
    <h1><?php echo esc_html(get_admin_page_title()); ?></h1>
    <form method="post" action="options.php">
        <?php
            settings_fields('${PLUGIN_SLUG}_options');
            do_settings_sections('${PLUGIN_SLUG}_options');
            submit_button();
        ?>
    </form>
</div>
EOL

# Create empty CSS and JS files
touch "assets/css/frontend.css"
touch "assets/js/frontend.js"

# Update composer.json PSR-4 autoload
jq ".autoload.\"psr-4\" = {\"${CLASS_NAME}\\\\\": \"inc/\"}" composer.json > composer.json.tmp && mv composer.json.tmp composer.json

echo "Plugin structure created successfully!"
echo "Main plugin file: ${PLUGIN_SLUG}.php"
echo "Namespace updated in composer.json to ${CLASS_NAME}"
echo ""
echo "Next steps:"
echo "1. Run 'composer install' to install dependencies"
echo "2. Run 'npm install' to install npm dependencies"
echo "3. Run 'npm run build' to build the assets"
echo "4. Run 'composer dump-autoload' to update autoload"
echo "5. Activate the plugin in WordPress"
echo "6. Start customizing the code for your needs"
