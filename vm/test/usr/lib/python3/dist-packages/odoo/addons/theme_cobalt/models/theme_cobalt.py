from odoo import models


class ThemeCobalt(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_cobalt_post_copy(self, mod):
        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")
