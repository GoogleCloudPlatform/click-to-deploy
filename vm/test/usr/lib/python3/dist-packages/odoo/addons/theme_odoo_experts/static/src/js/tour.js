/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';
import { _t } from "@web/core/l10n/translation";

const snippets = [
    {
        id: 's_picture',
        name: 'Picture',
    },
    {
        id: 's_references',
        name: 'References',
    },
    {
        id: 's_text_image',
        name: 'Image - Text',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_comparisons',
        name: 'Comparisons',
    },
    {
        id: 's_call_to_action',
        name: 'Call to Action',
    },
];

wTourUtils.registerThemeHomepageTour("odoo_experts_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"odoo-experts-1"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.clickOnText(snippets[2], 'h2'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
    wTourUtils.clickOnSnippet(snippets[5], 'top'),
    wTourUtils.changeOption('ColoredLevelBackground', 'we-button[data-toggle-bg-shape]', _t('Background Shape')),
    wTourUtils.selectNested('we-select-page', 'BackgroundShape', ':not(.o_we_pager_controls)', _t('Background Shape')),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[6]),
]);
