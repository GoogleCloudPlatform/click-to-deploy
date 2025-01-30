{
    'name': 'Clean Theme',
    'description': 'Clean Theme',
    'category': 'Theme/Services',
    'summary': 'Legal, Corporate, Business, Tech, Services',
    'sequence': 120,
    'version': '2.1.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/image_content.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_carousel.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_product_catalog.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/clean_description.jpg',
        'static/description/clean_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_clean/static/src/img/backgrounds/bg_snippet_09.jpg',
        'website.s_text_image_default_image': '/theme_clean/static/src/img/content/image_content_19.jpg',
        'website.s_banner_default_image': '/theme_clean/static/src/img/backgrounds/bg_snippet_07.jpg',
        'website.s_carousel_default_image_1': '/theme_clean/static/src/img/content/image_content_25.jpg',
        'website.s_three_columns_default_image_1': '/theme_clean/static/src/img/content/image_content_22.jpg',
        'website.s_three_columns_default_image_2': '/theme_clean/static/src/img/content/image_content_23.jpg',
        'website.s_three_columns_default_image_3': '/theme_clean/static/src/img/content/image_content_24.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_title', 's_features', 's_carousel', 's_numbers',
                     's_three_columns', 's_call_to_action'],
        # TODO In master, remove unused templates instead.
        '_': ['s_comparisons'],
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-clean.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_clean/static/src/js/tour.js',
        ],
    }
}
