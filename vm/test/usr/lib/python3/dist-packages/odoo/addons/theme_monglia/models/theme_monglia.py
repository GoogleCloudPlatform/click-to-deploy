from odoo import models


class ThemeMonglia(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_monglia_post_copy(self, mod):
        self.enable_view('website.template_footer_minimalist')
