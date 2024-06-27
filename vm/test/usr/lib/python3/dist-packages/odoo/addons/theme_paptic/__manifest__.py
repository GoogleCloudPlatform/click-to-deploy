{
    'name': 'Paptic Theme',
    'description': 'Clean and sharp design.',
    'category': 'Theme/Corporate',
    'summary': 'Consultancy, Design, Tech, Computers, IT, Blogs',
    'sequence': 110,
    'version': '2.1.0',
    'depends': ['website'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',
        'views/customizations.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/paptic_poster.jpg',
        'static/description/paptic_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_three_columns_default_image_1': '/theme_paptic/static/src/img/pictures/s_three_columns_1.jpg',
        'website.s_three_columns_default_image_2': '/theme_paptic/static/src/img/pictures/s_three_columns_2.jpg',
        'website.s_three_columns_default_image_3': '/theme_paptic/static/src/img/pictures/s_three_columns_3.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_image_text', 's_references', 's_three_columns', 's_comparisons', 's_call_to_action'],
        # TODO In master, remove unused templates instead.
        '_': ['s_media_list'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-paptic.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_paptic/static/src/js/tour.js',
        ],
    }
}
