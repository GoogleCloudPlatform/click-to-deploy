from odoo import models


class ThemeLoftspace(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_loftspace_post_copy(self, mod):
        self.enable_view('website.template_header_search')
