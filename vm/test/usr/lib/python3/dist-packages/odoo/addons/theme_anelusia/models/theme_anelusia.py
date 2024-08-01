from odoo import models


class ThemeAnelusia(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_anelusia_post_copy(self, mod):
        self.enable_view('website.template_footer_headline')
