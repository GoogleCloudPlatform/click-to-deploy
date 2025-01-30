{
    'name': 'Kiddo Theme',
    'description': 'Kiddo theme for Odoo Website',
    'category': 'Theme/Retail',
    'summary': 'Nursery, Toys, Games, Kids, Boys, Girls, Stores',
    'sequence': 290,
    'version': '2.1.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_product_list.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_product_catalog.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/kiddo_description.jpg',
        'static/description/kiddo_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_banner_default_image': '/theme_kiddo/static/src/img/snippets/s_banner.jpg',
        'website.s_image_text_default_image': '/theme_kiddo/static/src/img/snippets/s_image_text.jpg',
        'website.s_three_columns_default_image_1': '/theme_kiddo/static/src/img/snippets/s_three_columns_default_image_1.jpg',
        'website.s_three_columns_default_image_2': '/theme_kiddo/static/src/img/snippets/s_three_columns_default_image_2.jpg',
        'website.s_three_columns_default_image_3': '/theme_kiddo/static/src/img/snippets/s_three_columns_default_image_3.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_banner', 's_image_text', 's_three_columns', 's_product_list', 's_call_to_action'],
        # TODO In master, remove unused templates instead.
        '_': ['s_picture'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-kiddo.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_kiddo/static/src/js/tour.js',
        ],
    }
}
