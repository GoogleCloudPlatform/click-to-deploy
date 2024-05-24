from odoo import models


class ThemeBuzzy(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_buzzy_post_copy(self, mod):
        self.enable_view('website.template_footer_minimalist')

        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")
