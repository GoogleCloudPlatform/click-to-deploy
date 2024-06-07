{
    'name': 'Aviato Theme',
    'description': 'Aviato Theme - Responsive Bootstrap Theme for Odoo CMS',
    'category': 'Theme/Creative',
    'summary': 'Travel, Excursion, Plane, Tour, Agency ',
    'sequence': 130,
    'version': '1.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_popup.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/aviato_cover.jpg',
        'static/description/aviato_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_aviato/static/src/img/content/s_cover.jpg',
        'website.s_three_columns_default_image_1': '/theme_aviato/static/src/img/content/s_three_columns_1.jpg',
        'website.s_three_columns_default_image_2': '/theme_aviato/static/src/img/content/s_three_columns_2.jpg',
        'website.s_three_columns_default_image_3': '/theme_aviato/static/src/img/content/s_three_columns_3.jpg',
        'website.s_picture_default_image': '/theme_aviato/static/src/img/content/s_picture.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_image_text', 's_title', 's_three_columns', 's_picture'],
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-aviato.odoo.com',

    'assets': {
        'website.assets_editor': [
            'theme_aviato/static/src/js/tour.js',
        ],
    }
}
