from odoo import models


class ThemeNotes(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_notes_post_copy(self, mod):
        self.enable_view('website.template_footer_descriptive')
