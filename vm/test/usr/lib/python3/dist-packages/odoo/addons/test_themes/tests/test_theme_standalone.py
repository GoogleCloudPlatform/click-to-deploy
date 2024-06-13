# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo.addons.website.tools import MockRequest
from odoo.tests import standalone


@standalone('website_standalone')
def test_01_theme_install_generate_primary_templates(env):
    """ This test ensures the theme `_generate_primary_snippet_templates()`
    method is correctly called before xml views are generated.
    """
    # 1. Setup
    theme_buzzy = env.ref('base.module_theme_clean')

    if theme_buzzy.state == 'installed':
        theme_buzzy.button_immediate_uninstall()
    # Ensure those views are deleted to mimic the initial state of theme not installed.
    # Because "theme_buzzy" was installed before through "test_themes" dependencies, removing
    # those views is needed to replicate the bug: if the configurator views are not generated,
    # the theme install will fail because some of the imported views inherit them.
    env['ir.ui.view'].with_context(_force_unlink=True).search([('key', '=', 'website.configurator_s_banner')]).unlink()
    env['ir.ui.view'].with_context(_force_unlink=True).search([('key', '=', 'website.configurator_s_cover')]).unlink()
    theme_buzzy.button_immediate_install()
