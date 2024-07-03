/** @odoo-module **/

import sOptions from "@web_editor/js/editor/snippets.options";

sOptions.registry.BackgroundImage.include({
    /**
     * @override
     */
    background: function (previewMode, widgetValue, params) {
        this._super.apply(this, arguments);

        var customClass = this.$target.attr('class').match(/\b(bg-img-\d+)\b/);
        if (customClass) {
            this.$target.removeClass(customClass[1]);
        }
    },
});
