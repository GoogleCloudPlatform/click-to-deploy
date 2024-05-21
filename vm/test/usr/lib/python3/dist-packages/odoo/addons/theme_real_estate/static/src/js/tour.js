/** @odoo-module **/

import wTourUtils from "@website/js/tours/tour_utils";

const snippets = [
    {
        id: 's_banner',
        name: 'Banner',
    },
    {
        id: 's_text_block',
        name: 'Text',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
    {
        id: 's_image_text',
        name: 'Image - Text',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_three_columns',
        name: 'Columns',
    },
    {
        id: 's_title:last-child',
        name: 'Title',
    },
    {
        id: 's_masonry_block',
        name: 'Masonry',
    },
    {
        id: 's_numbers',
        name: 'Numbers',
    },
    {
        id: 's_quotes_carousel',
        name: 'Quotes',
    },
];

wTourUtils.registerThemeHomepageTour("real_estate_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"real-estate-4"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.clickOnSnippet(snippets[4]),
    wTourUtils.changeBackgroundColor(),
    wTourUtils.selectColorPalette(),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[5]),
    wTourUtils.dragNDrop(snippets[6]),
    wTourUtils.dragNDrop(snippets[7]),
    wTourUtils.dragNDrop(snippets[8]),
    wTourUtils.dragNDrop(snippets[9]),
]);
