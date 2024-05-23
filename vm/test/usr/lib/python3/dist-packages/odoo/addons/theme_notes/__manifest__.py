{
    'name': 'Notes & Play Theme',
    'description': 'Notes & Play Theme',
    'category': 'Theme/Retail',
    'summary': 'Band, Musics, Sound, Concerts, Artists, Records, Event, Food, Stores',
    'sequence': 280,
    'version': '2.1.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/snippets/s_carousel.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_company_team.xml',
        'views/snippets/s_masonry_block.xml',
        'views/snippets/s_product_catalog.xml',
        'views/snippets/s_banner.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_image_gallery.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_features_grid.xml',
        'views/snippets/s_product_list.xml',
        'views/snippets/s_parallax.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/notes_description.jpg',
        'static/description/notes_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_carousel_default_image_1': '/theme_notes/static/src/img/content/content_img_22.jpg',
        'website.s_masonry_block_default_image_1': '/theme_notes/static/src/img/content/content_img_21.jpg',
        'website.s_text_image_default_image': '/theme_notes/static/src/img/content/content_img_15.jpg',
        'website.s_product_catalog_default_image': '/theme_notes/static/src/img/content/s_product_catalog_default_image.jpg',
        'website.s_media_list_default_image_1': '/theme_notes/static/src/img/content/content_img_25.jpg',
        'website.s_media_list_default_image_2': '/theme_notes/static/src/img/content/content_img_26.jpg',
        'website.s_media_list_default_image_3': '/theme_notes/static/src/img/content/content_img_27.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_carousel', 's_masonry_block', 's_text_image', 's_product_catalog', 's_media_list', 's_company_team'],
        # TODO In master, remove unused templates instead.
        '_': ['s_cover'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-notes.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_notes/static/src/js/tour.js',
        ],
    }
}
