{
    'name': 'Enark Theme',
    'description': 'Enark Theme',
    'category': 'Theme/Corporate',
    'summary': 'Architect, Corporate, Business, Finance, Services',
    'sequence': 190,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/snippets_options.xml',
        'views/image_library.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_parallax.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_image_gallery.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/enark_description.jpg',
        'static/description/enark_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_banner_default_image': '/theme_enark/static/src/img/snippets/s_banner.jpg',
        'website.s_picture_default_image': '/theme_enark/static/src/img/snippets/s_picture.jpg',
        'website.s_text_image_default_image': '/theme_enark/static/src/img/snippets/s_text_image.jpg',
        'website.library_image_10': '/theme_enark/static/src/img/snippets/library_image_03.jpg',
        'website.library_image_05': '/theme_enark/static/src/img/snippets/library_image_15.jpg',
        'website.library_image_16': '/theme_enark/static/src/img/snippets/library_image_14.jpg',
        'website.library_image_13': '/theme_enark/static/src/img/snippets/library_image_10.jpg',
        'website.library_image_08': '/theme_enark/static/src/img/snippets/library_image_05.jpg',
        'website.library_image_02': '/theme_enark/static/src/img/snippets/library_image_16.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_banner', 's_picture', 's_numbers', 's_text_image', 's_images_wall', 's_call_to_action'],
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
    'live_test_url': 'https://theme-enark.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_enark/static/src/js/tour.js',
        ],
    }
}
