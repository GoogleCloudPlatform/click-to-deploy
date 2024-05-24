from odoo import models


class ThemeYes(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_yes_post_copy(self, mod):
        self.enable_view('website.template_footer_descriptive')

        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")
