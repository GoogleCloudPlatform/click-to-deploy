{
    'name': 'Yes Theme',
    'description': 'Yes Theme - Wedding',
    'category': 'Theme/Personal',
    'summary': 'Wedding, Love, Photography, Services',
    'sequence': 330,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_carousel.xml',
        'views/snippets/s_company_team.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_image_gallery.xml',
        'views/snippets/s_images_wall.xml',
        'views/snippets/s_masonry_block.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_popup.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_title.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/yes_description.png',
        'static/description/yes_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_yes/static/src/img/snippets/s_cover.jpg',
        'website.s_media_list_default_image_1': '/theme_yes/static/src/img/snippets/s_media_list_1.jpg',
        'website.s_media_list_default_image_2': '/theme_yes/static/src/img/snippets/s_media_list_2.jpg',
        'website.s_media_list_default_image_3': '/theme_yes/static/src/img/snippets/s_media_list_3.jpg',
        'website.s_quotes_carousel_demo_image_0': '/theme_yes/static/src/img/snippets/s_quotes_carousel_1.jpg',
        'website.library_image_10': '/theme_yes/static/src/img/snippets/library_image_10.jpg',
        'website.library_image_05': '/theme_yes/static/src/img/snippets/library_image_05.jpg',
        'website.library_image_08': '/theme_yes/static/src/img/snippets/library_image_08.jpg',
        'website.library_image_13': '/theme_yes/static/src/img/snippets/library_image_13.jpg',
        'website.library_image_03': '/theme_yes/static/src/img/snippets/library_image_03.jpg',
        'website.library_image_02': '/theme_yes/static/src/img/snippets/library_image_02.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_title', 's_company_team', 's_media_list', 's_images_wall', 's_quotes_carousel'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-yes.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_yes/static/src/js/tour.js',
        ],
    }
}
