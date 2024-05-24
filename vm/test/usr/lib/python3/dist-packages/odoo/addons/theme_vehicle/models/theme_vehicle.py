from odoo import models


class ThemeVehicle(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_vehicle_post_copy(self, mod):
        self.enable_view('website.template_footer_minimalist')
