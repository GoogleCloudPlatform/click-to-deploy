{
    'name': 'Vehicle Theme',
    'description': 'Vehicle Theme - Cars, Motorbikes, Bikes, Tires',
    'category': 'Theme/Services',
    'summary': 'Vehicle, Cars, Motorbikes, Bikes, Tires, Transports, Repair, Mechanics, Garages, Sports, Services',
    'sequence': 300,
    'version': '2.0.0',
    'depends': ['theme_common'],
    'data': [
        'data/generate_primary_template.xml',
        'data/ir_asset.xml',
        'views/images.xml',
        'views/customizations.xml',
        'views/new_page_template.xml',
    ],
    'images': [
        'static/description/vehicle_description.png',
        'static/description/vehicle_screenshot.png',
    ],
    'images_preview_theme': {
        'website.s_cover_default_image': '/theme_vehicle/static/src/img/snippets/s_cover.jpg',
        'website.s_text_image_default_image': '/theme_vehicle/static/src/img/snippets/s_text_image.jpg',
        'website.s_masonry_block_default_image_1': '/theme_vehicle/static/src/img/snippets/s_masonry_block.jpg',
        'website.s_image_text_default_image': '/theme_vehicle/static/src/img/snippets/s_image_text.jpg',
        'website.s_parallax_default_image': '/theme_vehicle/static/src/img/snippets/s_parallax.jpg',
        'website.s_picture_default_image': '/theme_vehicle/static/src/img/snippets/s_picture.jpg',
    },
    'configurator_snippets': {
        'homepage': ['s_cover', 's_text_image', 's_image_text', 's_picture', 's_masonry_block', 's_call_to_action'],
        # TODO In master, remove unused templates instead.
        '_': ['s_numbers', 's_references'],
    },
    'new_page_templates': {
        'about': {
            'personal': ['s_text_cover', 's_image_text', 's_text_block_h2', 's_numbers', 's_features', 's_call_to_action'],
        },
        'team': {
            '5': ['s_text_block_h1', 's_text_block', 's_image_gallery', 's_picture'],
        },
    },
    'license': 'LGPL-3',
    'live_test_url': 'https://theme-vehicle.odoo.com',
    'assets': {
        'website.assets_editor': [
            'theme_vehicle/static/src/js/tour.js',
        ],
    }
}
