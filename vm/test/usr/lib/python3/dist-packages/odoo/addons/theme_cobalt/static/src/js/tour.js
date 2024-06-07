/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_banner',
        name: 'Banner',
    },
    {
        id: 's_references',
        name: 'References',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
    {
        id: 's_color_blocks_2',
        name: 'Big Boxes',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_image_gallery',
        name: 'Images Wall',
    },
];


wTourUtils.registerThemeHomepageTour("cobalt_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"cobalt-1"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1', 'top'),
    wTourUtils.goBackToBlocks(),

    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),

    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
]);
