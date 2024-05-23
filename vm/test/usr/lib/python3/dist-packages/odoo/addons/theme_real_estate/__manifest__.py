{
    'name': 'Real Estate Theme',
    'description': 'Real Estate Theme - Houses, Appartments, Real Estate Agencies',
    'category': 'Theme/Services',
    'summary': 'Real Estate, Agencies, Construction, Services, Accomodations, Lodging, Hosting, Houses, Appartments, Vacations, Holidays, Travels',
    'sequence': 320,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_text_block.xml',
        'views/snippets/s_masonry_block.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_image_gallery.xml',
        'views/snippets/s_call_to_action.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/real_estate_description.png',
        'static/description/real_estate_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_banner_default_image': '/theme_real_estate/static/src/img/snippets/s_banner.jpg',
        'website.s_text_image_default_image': '/theme_real_estate/static/src/img/snippets/s_text_image.jpg',
        'website.s_image_text_default_image': '/theme_real_estate/static/src/img/snippets/s_image_text.jpg',
        'website.s_three_columns_default_image_1': '/theme_real_estate/static/src/img/snippets/library_image_11.jpg',
        'website.s_three_columns_default_image_2': '/theme_real_estate/static/src/img/snippets/library_image_13.jpg',
        'website.s_three_columns_default_image_3': '/theme_real_estate/static/src/img/snippets/library_image_07.jpg',
        'website.s_masonry_block_default_image_1': '/theme_real_estate/static/src/img/snippets/s_masonry_block.jpg',
        'website.s_quotes_carousel_demo_image_1': '/theme_real_estate/static/src/img/snippets/s_quotes_carousel_1.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_banner', 's_text_block', 's_text_image', 's_image_text', 's_title', 's_three_columns',
                     's_title', 's_masonry_block', 's_numbers', 's_quotes_carousel'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-real-estate.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_real_estate/static/src/js/tour.js',
        ],
    }
}
