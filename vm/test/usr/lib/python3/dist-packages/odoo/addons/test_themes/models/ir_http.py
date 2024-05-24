# -*- coding: utf-8 -*-
# Part of Odoo. See LICENSE file for full copyright and licensing details.

from odoo import models, tools
from odoo.http import request


class Http(models.AbstractModel):
    _inherit = 'ir.http'

    @classmethod
    def _pre_dispatch(cls, rule, args):
        # Allow public user to use `fw` query string in test mode to ease tests
        force_website_id = request.httprequest.args.get('fw')
        if (request.registry.in_test_mode() or tools.config.options['test_enable']) and force_website_id:
            request.env['website']._force_website(force_website_id)

        super()._pre_dispatch(rule, args)
