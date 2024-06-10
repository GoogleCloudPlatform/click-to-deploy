from odoo import models


class ThemeKea(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_kea_post_copy(self, mod):
        self.enable_view('website.template_footer_minimalist')
