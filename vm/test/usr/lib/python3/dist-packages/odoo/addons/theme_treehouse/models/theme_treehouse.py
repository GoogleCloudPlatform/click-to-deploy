from odoo import models


class ThemeTreehouse(models.AbstractModel):
    _inherit = 'theme.utils'

    def _theme_treehouse_post_copy(self, mod):
        self.disable_view('website.header_visibility_standard')
        self.enable_view('website.header_visibility_fixed')

        self.enable_view('website.template_footer_contact')
        self.enable_view('website.template_footer_slideout')
        self.enable_view('website.option_footer_scrolltop')

        self.enable_asset("website.ripple_effect_scss")
        self.enable_asset("website.ripple_effect_js")
