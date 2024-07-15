/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

wTourUtils.registerWebsitePreviewTour('theme_menu_hierarchies', {
    url: '/example',
    test: true,
}, () => [
    {
        content: 'Check Mega Menu is correctly created',
        trigger: "iframe .top_menu a.o_mega_menu_toggle",
    }, {
        content: 'Check Mega Menu content',
        trigger: "iframe .top_menu div.o_mega_menu.show .fa-cube",
        run: () => null, // It's a check.
    }, {
        content: 'Check new top level menu is correctly created',
        trigger: 'iframe .top_menu .nav-item.dropdown .dropdown-toggle:contains("Example 1")',
    }, {
        content: 'Check sub menu are correctly created',
        trigger: 'iframe .top_menu .dropdown-menu.show a.dropdown-item:contains("Item 1")',
        run: () => null, // It's a check.
    }, {
        content: 'The new menu hierarchy should not be included in the navbar',
        trigger: 'iframe body:not(:has(.top_menu a[href="/dogs"]))',
        run: () => null, // It's a check.
    }, {
        content: 'The new menu hierarchy should be inside the footer',
        trigger: 'iframe footer ul li a[href="/dogs"]',
        run: () => null, // It's a check.
    },
    ...wTourUtils.clickOnEditAndWaitEditMode(),
    {
        content: 'Click on footer',
        trigger: 'iframe footer',
    }, {
        content: 'The theme custom footer template should be listed and selected',
        trigger: 'we-select[data-variable="footer-template"] we-toggler img[src*="/theme_test_custo"]',
        run: () => null, // It's a check.
    }, {
        content: 'Click on header',
        trigger: 'iframe header',
    }, {
        content: 'The theme custom header template should be listed and selected',
        trigger: 'we-select[data-variable="header-template"] we-toggler img[src*="/theme_test_custo"]',
        run: () => null, // It's a check.
    }, {
        content: 'Click on image which has a shape',
        trigger: 'iframe #wrap .s_text_image img[data-shape]',
    }, {
        content: 'The theme custom "Blob 01" shape should be listed and selected',
        trigger: 'we-select[data-name="shape_img_opt"] we-toggler:contains("Blob 01")',
        run: () => null, // It's a check.
    }, {
        content: 'Click on section which has a bg shape',
        trigger: 'iframe #wrap .s_text_block[data-oe-shape-data]',
    }, {
        content: 'The theme custom "Curve 01" shape should be listed and selected',
        trigger: 'we-select[data-name="bg_shape_opt"] we-toggler:contains("Curve 01")',
        run: () => null, // It's a check.
    },
]);
