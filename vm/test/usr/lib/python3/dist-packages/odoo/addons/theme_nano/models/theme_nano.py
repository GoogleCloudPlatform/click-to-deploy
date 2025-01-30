from odoo import models


class ThemeNano(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_nano_post_copy(self, mod):
        self.enable_view('website.template_header_search')
        self.enable_view('website.header_navbar_pills_style')

        self.enable_view('website.template_footer_descriptive')
        self.enable_view('website.template_footer_slideout')
        self.enable_view('website.option_footer_scrolltop')

        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")

        self.disable_view('portal.footer_language_selector')
