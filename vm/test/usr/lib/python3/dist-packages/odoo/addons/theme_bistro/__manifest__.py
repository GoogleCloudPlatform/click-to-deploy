{
    'name': 'Bistro Theme',
    'description': 'Bistro Theme - Restaurant, Food/Drink, Catering, Food trucks',
    'category': 'Theme/Food',
    'summary': 'Bistro, Restaurant, Bar, Pub, Cafe, Food, Catering',
    'sequence': 220,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/layout.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_columns.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_product_catalog.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_text_block.xml',
        'views/snippets/s_text_image.xml',
        'views/new_page_template.xml',

    ],
    'images': [
        'static/description/bistro_cover.jpg',
        'static/description/bistro_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_bistro/static/src/img/backgrounds/17.jpg',
        'website.s_picture_default_image': '/theme_bistro/static/src/img/content/picture.jpg',
        'website.s_product_catalog_default_image': '/theme_bistro/static/src/img/backgrounds/16.jpg',
        'website.s_quotes_carousel_demo_image_1': '/theme_bistro/static/src/img/backgrounds/19.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_features', 's_picture', 's_product_catalog', 's_text_block', 's_quotes_carousel'],
        'pricing': ["s_text_image", "s_product_catalog"],
        # TODO In master, remove unused templates instead.
        '_': ['s_banner'],
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-bistro.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_bistro/static/src/js/tour.js',
        ],
    }
}
