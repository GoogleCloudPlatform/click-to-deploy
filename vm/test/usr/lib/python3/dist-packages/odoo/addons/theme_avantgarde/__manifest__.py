{
    'name': 'Avantgarde Theme',
    'description': 'Avantgarde is a sophisticated theme to inspire and impress',
    'category': 'Theme/Creative',
    'summary': 'Design, Fine Art, Artwork, Creative, Creativity, Galleries, Trends, Shows, Magazines, Blogs',
    'sequence': 150,
    'version': '2.0.0',
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',
        'views/customizations.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/poster.jpg',
        'static/description/avantgarde_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_avantgarde/static/src/img/pictures/bg_image_08.jpg',
        'website.s_picture_default_image': '/theme_avantgarde/static/src/img/pictures/bg_image_14.jpg',
        'website.s_three_columns_default_image_1': '/theme_avantgarde/static/src/img/pictures/bg_image_15',
        'website.s_three_columns_default_image_2': '/theme_avantgarde/static/src/img/pictures/bg_image_16.jpg',
        'website.s_three_columns_default_image_3': '/theme_avantgarde/static/src/img/pictures/bg_image_17.jpg',
        'website.s_text_image_default_image': '/theme_avantgarde/static/src/img/pictures/bg_image_13.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_picture', 's_three_columns', 's_text_image', 's_call_to_action'],
    },
    'depends': ['theme_common'],
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-avantgarde.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_avantgarde/static/src/js/tour.js',
        ],
    }
}
