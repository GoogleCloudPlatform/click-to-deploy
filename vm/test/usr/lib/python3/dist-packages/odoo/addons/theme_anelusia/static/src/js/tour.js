/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_text_cover',
        name: 'Text Cover',
    },
    {
        id: 's_images_wall',
        name: 'Images Wall',
    },
    {
        id: 's_color_blocks_2',
        name: 'Big Boxes',
    },
    {
        id: 's_references',
        name: 'References',
    },
    {
        id: 's_media_list',
        name: 'Media List',
    },
    {
        id: 's_company_team',
        name: 'Team',
    },
    {
        id: 's_call_to_action',
        name: 'Call to Action',
    },
];

wTourUtils.registerThemeHomepageTour("anelusia_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"generic-17"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1', 'top'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2], 'top'),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.clickOnSnippet(snippets[3], 'top'),
    wTourUtils.changeBackgroundColor(),
    wTourUtils.selectColorPalette(),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
    wTourUtils.dragNDrop(snippets[6]),
]);
