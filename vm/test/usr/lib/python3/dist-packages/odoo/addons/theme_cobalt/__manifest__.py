{
    'name': 'Cobalt Theme',
    'description': 'Clean and sharp design.',
    'category': 'Theme/Corporate',
    'summary': 'Development, IT development, Design, Tech, Computers, IT, Blogs',
    'sequence': 110,
    'version': '2.0.0',
    'depends': ['website'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',
        'views/customizations.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/cobalt_poster.jpg',
        'static/description/cobalt_screenshot.jpg',
    ],
    'images_preview_theme': {
        'website.library_image_03': '/theme_cobalt/static/src/img/pictures/s_image_1.jpg',
        'website.library_image_14': '/theme_cobalt/static/src/img/pictures/s_image_6.jpg',
        'website.library_image_10': '/theme_cobalt/static/src/img/pictures/s_image_4.jpg',
        'website.library_image_13': '/theme_cobalt/static/src/img/pictures/s_image_2.jpg',
        'website.library_image_16': '/theme_cobalt/static/src/img/pictures/s_image_3.jpg',
        'website.library_image_05': '/theme_cobalt/static/src/img/pictures/s_image_5.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_banner', 's_references', 's_text_image', 's_color_blocks_2', 's_images_wall'],
        # TODO In master, remove unused templates instead.
        '_': ['s_image_text', 's_three_columns', 's_picture'],
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-cobalt.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_cobalt/static/src/js/tour.js',
        ],
    }
}
