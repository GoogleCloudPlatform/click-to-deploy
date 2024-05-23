{
    'name': 'Beauty Theme',
    'description': 'Beauty Theme - Cosmetics, Beauty, Make Up, Hairdresser',
    'category': 'Theme/Retail',
    'summary': 'Beauty, Health, Care, Make Up, Cosmetics, Hair Dressers, Stores',
    'sequence': 170,
    'version': '2.1.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',

        'views/snippets/s_cover.xml',
        'views/snippets/s_text_image.xml',
        'views/snippets/s_title.xml',
        'views/snippets/s_company_team.xml',
        'views/snippets/s_call_to_action.xml',
        'views/snippets/s_product_list.xml',
        'views/snippets/s_banner.xml',
        'views/snippets/s_image_text.xml',
        'views/snippets/s_numbers.xml',
        'views/snippets/s_picture.xml',
        'views/snippets/s_color_blocks_2.xml',
        'views/snippets/s_media_list.xml',
        'views/snippets/s_comparisons.xml',
        'views/snippets/s_product_catalog.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/beauty_description.jpg',
        'static/description/beauty_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_beauty/static/src/img/snippets/s_cover.jpg',
        'website.s_text_image_default_image': '/theme_beauty/static/src/img/snippets/s_text_image.jpg',
        'website.s_product_list_default_image_1': '/theme_beauty/static/src/img/snippets/s_product_1.jpg',
        'website.s_product_list_default_image_2': '/theme_beauty/static/src/img/snippets/s_product_2.jpg',
        'website.s_product_list_default_image_3': '/theme_beauty/static/src/img/snippets/s_product_3.jpg',
        'website.s_product_list_default_image_4': '/theme_beauty/static/src/img/snippets/s_product_4.jpg',
        'website.s_product_list_default_image_5': '/theme_beauty/static/src/img/snippets/s_product_5.jpg',
        'website.s_product_list_default_image_6': '/theme_beauty/static/src/img/snippets/s_product_6.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_title', 's_product_list', 's_company_team', 's_call_to_action'],
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-beauty.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_beauty/static/src/js/tour.js',
        ],
    }
}
