{
    'name': 'Kea Theme',
    'description': 'Kea Theme',
    'category': 'Theme/Technology',
    'summary': 'Technology, Tech, IT, Computers, Stores, Virtual Reality',
    'sequence': 200,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_content.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_references.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_image_gallery.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/kea_description.png',
        'static/description/kea_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_kea/static/src/img/snippets/s_cover.jpg',
        'website.s_picture_default_image': '/theme_kea/static/src/img/snippets/s_picture.jpg',
        'website.s_quotes_carousel_demo_image_1': '/theme_kea/static/src/img/snippets/s_quotes_carousel_1.jpg',
        'website.s_quotes_carousel_demo_image_2': '/theme_kea/static/src/img/snippets/s_quotes_carousel_2.jpg',
        'website.s_media_list_default_image_1': '/theme_kea/static/src/img/snippets/s_media_list_1.jpg',
        'website.s_media_list_default_image_2': '/theme_kea/static/src/img/snippets/s_media_list_2.jpg',
        'website.s_media_list_default_image_3': '/theme_kea/static/src/img/snippets/s_media_list_3.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_picture', 's_image_text', 's_color_blocks_2', 's_media_list'],
        # TODO In master, remove unused templates instead.
        '_': ['s_references'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-kea.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_kea/static/src/js/tour.js',
        ],
    }
}
