{
    'name': 'Treehouse Theme',
    'description': 'Treehouse Theme - Responsive Bootstrap Theme for Odoo CMS',
    'category': 'Theme/Environment',
    'summary': 'Environment, Nature, Ecology, Sustainable Development, Non Profit, NGO, Travels',
    'sequence': 140,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/snippets/s_banner.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_carousel.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_faq_collapse.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_tabs.xml',
        'views/snippets/s_text_block.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_title.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/treehouse_cover.jpg',
        'static/description/treehouse_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_treehouse/static/src/img/content/cover.jpg',
        'website.s_text_image_default_image': '/theme_treehouse/static/src/img/content/text_image.jpg',
        'website.s_parallax_default_image': '/website/static/src/img/snippets_demo/s_parallax.jpg',
        'website.s_three_columns_default_image_1': '/theme_treehouse/static/src/img/content/three_columns_01.jpg',
        'website.s_three_columns_default_image_2': '/theme_treehouse/static/src/img/content/three_columns_02.jpg',
        'website.s_three_columns_default_image_3': '/theme_treehouse/static/src/img/content/three_columns_03.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_title', 's_three_columns', 's_call_to_action'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-treehouse.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_treehouse/static/src/js/tour.js',
        ],
    }
}
