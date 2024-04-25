/** @odoo-module */
import wTourUtils from '@website/js/tours/tour_utils';
import { _t } from "@web/core/l10n/translation";

const snippets = [
    {
        id: 's_banner',
        name: 'Banner',
    },
    {
        id: 's_image_text',
        name: 'Image - Text',
    },
    {
        id: 's_three_columns',
        name: 'Columns',
    },
    {
        id: 's_product_list',
        name: 'Items',
    },
    {
        id: 's_call_to_action',
        name: 'Call to Action',
    },
];

wTourUtils.registerThemeHomepageTour("kiddo_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"default-16"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.clickOnSnippet(snippets[3]),
    wTourUtils.changeOption('ContainerWidth', 'we-button-group.o_we_user_value_widget', _t('width')),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[4]),
]);
