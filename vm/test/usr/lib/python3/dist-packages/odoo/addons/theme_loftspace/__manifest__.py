{
    'name': 'Loftspace Theme',
    'description': 'Loftspace Fashion Theme',
    'category': 'Theme/Retail',
    'summary': 'Furniture, Toys, Games, Kids, Boys, Girls, Stores',
    'sequence': 130,
    'version': '2.1.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_content.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_image_gallery.xml',
        'views/snippets/s_banner.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_features_grid.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_product_catalog.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/loftspace_description.jpg',
        'static/description/loftspace_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_loftspace/static/src/img/snippets/s_cover.jpg',
        'website.s_banner_default_image': '/theme_loftspace/static/src/img/snippets/s_banner.jpg',
        'website.s_three_columns_default_image_1': '/theme_loftspace/static/src/img/snippets/library_image_11.jpg',
        'website.s_three_columns_default_image_2': '/theme_loftspace/static/src/img/snippets/library_image_13.jpg',
        'website.s_three_columns_default_image_3': '/theme_loftspace/static/src/img/snippets/library_image_07.jpg',
        'website.library_image_03': '/theme_loftspace/static/src/img/snippets/s_images_wall_01.jpg',
        'website.library_image_02': '/theme_loftspace/static/src/img/snippets/s_images_wall_05.jpg',
        'website.library_image_10': '/theme_loftspace/static/src/img/snippets/s_images_wall_06.jpg',
        'website.library_image_05': '/theme_loftspace/static/src/img/snippets/s_images_wall_02.jpg',
        'website.library_image_16': '/theme_loftspace/static/src/img/snippets/s_images_wall_04.jpg',
        'website.library_image_13': '/theme_loftspace/static/src/img/snippets/s_images_wall_03.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_three_columns', 's_title', 's_images_wall', 's_call_to_action'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-loftspace.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_loftspace/static/src/js/tour.js',
        ],
    }
}
