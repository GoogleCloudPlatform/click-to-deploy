{
    'name': 'Orchid Theme',
    'description': 'Orchid Theme - Flowers, Beauty',
    'category': 'Theme/Retail',
    'summary': 'Florist, Gardens, Flowers, Nature, Green, Beauty, Stores',
    'sequence': 230,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_product_catalog.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/orchid_description.jpg',
        'static/description/orchid_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_orchid/static/src/img/snippets/s_parallax.jpg',
        'website.s_image_text_default_image': '/theme_orchid/static/src/img/snippets/s_carousel_2.jpg',
        'website.s_text_image_default_image': '/theme_orchid/static/src/img/snippets/s_media_list_3.jpg',
        'website.s_three_columns_default_image_1': '/theme_orchid/static/src/img/snippets/library_image_11.jpg',
        'website.s_three_columns_default_image_2': '/theme_orchid/static/src/img/snippets/library_image_13.jpg',
        'website.s_three_columns_default_image_3': '/theme_orchid/static/src/img/snippets/library_image_07.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_image_text', 's_text_image', 's_three_columns', 's_quotes_carousel', 's_call_to_action'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
        'landing': {
            '1': ['s_banner', 's_features', 's_masonry_block', 's_call_to_action', 's_references', 's_quotes_carousel'],
            '2': ['s_cover', 's_text_image', 's_text_block_h2', 's_three_columns_landing_1', 's_call_to_action'],
            '3': ['s_text_cover', 's_text_block_h2', 's_three_columns', 's_showcase', 's_color_blocks_2', 's_quotes_carousel', 's_call_to_action'],
        },
        'services': {
            '2': ['s_text_cover', 's_image_text', 's_text_image', 's_image_text_2nd', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-orchid.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_orchid/static/src/js/tour.js',
        ],
    }
}
