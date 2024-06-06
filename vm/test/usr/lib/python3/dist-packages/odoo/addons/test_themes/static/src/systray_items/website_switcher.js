/** @odoo-module **/

import { patch } from "@web/core/utils/patch";
import { useService } from '@web/core/utils/hooks';
import { WebsiteSwitcherSystray } from '@website/systray_items/website_switcher';
import { onMounted, useState } from "@odoo/owl";

patch(WebsiteSwitcherSystray.prototype, {
    setup() {
        super.setup();

        this.orm = useService('orm');
        this.tooltips = useState({});
        // Disable the notification service to avoid having a notification for each theme.
        this.notificationService = { add: () => () => null };

        onMounted(async () => {
            const themesWebsites = await this.orm.call('website', 'get_test_themes_websites_theme_preview');
            for (const themeId in themesWebsites) {
                this.tooltips[themeId] = {
                    tooltipTemplate: 'test_themes.ThemeTooltip',
                    tooltipPosition: 'left',
                    tooltipDelay: 100,
                    tooltipInfo: JSON.stringify({url: themesWebsites[themeId]}),
                };
            }
        });
    },
    template: 'test_themes.WebsiteSwitcherSystray',
});
