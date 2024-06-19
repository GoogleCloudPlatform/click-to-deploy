/** @odoo-module */

import { registry } from "@web/core/registry";

registry.category("web_tour.tours").add("website_theme_preview", {
    test: true,
    url: "/web#action=website.action_website_configuration",
},
[{
    content: "Click on create new website",
    trigger: 'button[name="action_website_create_new"]',
}, {
    content: "insert website name",
    trigger: '[name="name"] input',
    run: "text Website Test",
}, {
    content: "Validate the website creation modal",
    trigger: "button.btn-primary",
},
// Configurator first screen
{
    content: "Click Skip and start from scratch",
    trigger: "button:contains('Skip and start from scratch')",
}, {
    content: "Click on the Live preview of a theme",
    trigger: ".o_theme_preview .o_button_area .btn-secondary:contains('Live Preview')",
}, {
    content: "Switch from desktop to mobile preview",
    trigger: ".btn[for=themeViewerMobile]",
}, {
    content: "Check that the mobile view is active",
    trigger: ".o_view_form_theme_preview_controller .o_field_iframe > div.is_mobile:visible",
    run: () => null, // it's a check
}, {
    content: "Switch back to desktop",
    trigger: ".btn[for=themeViewerDesktop]",
}, {
    content: "Check that the desktop view is active",
    trigger: ".o_view_form_theme_preview_controller .o_field_iframe > div:not(.is_mobile):visible",
    run: () => null, // it's a check
}]);
