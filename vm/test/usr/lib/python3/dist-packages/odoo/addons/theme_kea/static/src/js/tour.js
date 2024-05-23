/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_cover',
        name: 'Cover',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
    {
        id: 's_picture',
        name: 'Picture',
    },
    {
        id: 's_image_text',
        name: 'Image - Text',
    },
    {
        id: 's_color_blocks_2',
        name: 'Big Boxes',
    },
    {
        id: 's_media_list',
        name: 'Media List',
    },
];

wTourUtils.registerThemeHomepageTour("kea_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"bewise-2"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
    wTourUtils.clickOnSnippet(snippets[5], 'top'),
    wTourUtils.changeBackgroundColor(),
    wTourUtils.selectColorPalette(),
]);
