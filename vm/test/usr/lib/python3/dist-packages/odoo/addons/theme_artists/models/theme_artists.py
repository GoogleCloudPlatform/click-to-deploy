from odoo import models


class ThemeArtists(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_artists_post_copy(self, mod):
        self.enable_view('website.template_header_hamburger')
        self.enable_view('website.no_autohide_menu')

        self.enable_view('website.template_footer_centered')

        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")
