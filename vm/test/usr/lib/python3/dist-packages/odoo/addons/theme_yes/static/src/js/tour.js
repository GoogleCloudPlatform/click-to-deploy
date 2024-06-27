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
        id: 's_company_team',
        name: 'Team',
    },
    {
        id: 's_media_list',
        name: 'Media List',
    },
    {
        id: 's_images_wall',
        name: 'Images Wall',
    },
    {
        id: 's_quotes_carousel',
        name: 'Quotes',
    },
];

wTourUtils.registerThemeHomepageTour("yes_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"yes-3"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.clickOnText(snippets[1], 'h2'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
]);
