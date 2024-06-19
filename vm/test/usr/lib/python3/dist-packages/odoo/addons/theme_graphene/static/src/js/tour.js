/** @odoo-module **/

import wTourUtils from "@website/js/tours/tour_utils";

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
        id: 's_numbers',
        name: 'Numbers',
    },
    {
        id: 's_picture',
        name: 'Picture',
    },
    {
        id: 's_comparisons',
        name: 'Comparisons',
    },
];


wTourUtils.registerThemeHomepageTour("graphene_tour", () => [
    wTourUtils.assertCssVariable('--color-palettes-name', '"graphene-1"'),
    wTourUtils.dragNDrop(snippets[0]),
    wTourUtils.clickOnText(snippets[0], 'h1', 'top'),
    wTourUtils.goBackToBlocks('left'),

    wTourUtils.dragNDrop(snippets[1]),

    wTourUtils.dragNDrop(snippets[2]),
    wTourUtils.dragNDrop(snippets[3], 'top'),

    wTourUtils.dragNDrop(snippets[4], 'top'),
    wTourUtils.clickOnSnippet(snippets[4], 'top'),
    wTourUtils.changeBackgroundColor('left'),
    wTourUtils.selectColorPalette(),
]);
