/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_cover',
        name: 'Cover',
    },
    {
        id: 's_three_columns',
        name: 'Columns',
    },
    {
        id: 's_title',
        name: 'Title',
    },
    {
        id: 's_images_wall',
        name: 'Images Wall',
    },
    {
        id: 's_call_to_action',
        name: 'Call to Action',
    },
];

wTourUtils.registerThemeHomepageTour("loftspace_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"graphene-2"'),
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
]);
