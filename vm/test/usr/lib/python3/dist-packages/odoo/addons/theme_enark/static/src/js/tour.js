/** @odoo-module **/

import wTourUtils from "@website/js/tours/tour_utils";

const snippets = [
    {
        id: 's_banner',
        name: 'Banner',
    },
    {
        id: 's_picture',
        name: 'Picture',
    },
    {
        id: 's_numbers',
        name: 'Numbers',
    },
    {
        id: 's_text_image',
        name: 'Text - Image',
    },
    {
        id: 's_image_wall',
        name: 'Images Wall',
    },
    {
        id: 's_call_to_action',
        name: 'Call to Action',
    },
];

wTourUtils.registerThemeHomepageTour("enark_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"enark-1"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1'),
    wTourUtils.goBackToBlocks(),
    wTourUtils.dragNDrop(snippets[1]),
    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3]),
    wTourUtils.dragNDrop(snippets[4]),
    wTourUtils.dragNDrop(snippets[5]),
]);
