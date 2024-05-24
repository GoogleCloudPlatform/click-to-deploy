{
    'name': 'Buzzy Theme',
    'description': 'Buzzy Theme - Responsive Bootstrap Theme for Odoo CMS',
    'category': 'Theme/Corporate',
    'summary': 'Corporate, Services, Technology, Shapes, Illustrations',
    'sequence': 140,
    'version': '1.0.0',
    'depends': ['website'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images_library.xml',

        'views/snippets/s_title.xml',
        'views/snippets/s_banner.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_cover.xml',
        'views/snippets/s_text_block.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_three_columns.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_features.xml',
        'views/snippets/s_image_gallery.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_showcase.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_company_team.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_features_grid.xml',
        'views/snippets/s_table_of_content.xml',
        'views/snippets/s_product_catalog.xml',
        'views/snippets/s_product_list.xml',
        'views/snippets/s_tabs.xml',
        'views/snippets/s_references.xml',
        'views/snippets/s_faq_collapse.xml',
        'views/snippets/s_timeline.xml',
        'views/snippets/s_process_steps.xml',
        'views/snippets/s_quotes_carousel.xml',
        'views/snippets/s_countdown.xml',
        'views/snippets/s_text_highlight.xml',
        'views/snippets/s_blockquote.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/buzzy_cover.jpg',
        'static/description/buzzy_screenshot.jpg',
    ],
    'configurator_snippets': {
        'homepage': ['s_banner', 's_text_image', 's_three_columns', 's_image_text', 's_numbers', 's_call_to_action'],
        # TODO In master, remove unused templates instead.
        '_': ['s_title'],
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
    'live_test_url': 'https://theme-buzzy.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_buzzy/static/src/js/tour.js',
        ],
    }
}
