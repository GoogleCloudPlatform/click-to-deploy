/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_cover',
        name: 'Cover',
    },
    {
        id: 's_features',
        name: 'Features',
    },
    {
        id: 's_picture',
        name: 'Picture',
    },
    {
        id: 's_product_catalog',
        name: 'Pricelist',
    },
    {
        id: 's_text_block',
        name: 'Text',
    },
    {
        id: 's_quotes_carousel',
        name: 'Quotes',
    },
];

wTourUtils.registerThemeHomepageTour("bistro_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"bistro-5"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1', 'top'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.clickOnSnippet(snippets[2]),
    wTourUtils.changeBackgroundColor(),
    wTourUtils.selectColorPalette(),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
]);
