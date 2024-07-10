/** @odoo-module */

import wTourUtils from '@website/js/tours/tour_utils';

const snippets = [
    {
        id: 's_carousel_wrapper',
        name: 'Carousel',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
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

wTourUtils.registerThemeHomepageTour("artists_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"artists-1"'),
    wTourUtils.dragNDrop(snippets[0], 'top'),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.clickOnText(snippets[1], 'h2'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.clickOnText(snippets[3], 'h2'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
]);
