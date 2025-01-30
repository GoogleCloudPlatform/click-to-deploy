/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_cover',
        name: 'Cover',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_text_block',
        name: 'Text',
    },
    {
        id: 's_three_columns',
        name: 'Columns',
    },
    {
        id: 's_image_wall',
        name: 'Images Wall',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_media_list',
        name: 'Media List',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
];

wTourUtils.registerThemeHomepageTour("monglia_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"monglia-1"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1', 'top'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
    wTourUtils.dragNDrop(snippets[6]),
    wTourUtils.dragNDrop(snippets[7]),
]);
