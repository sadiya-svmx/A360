({
    handleDataChange: function (cmp, evt, helper) {
        helper.setUnsavedValue(cmp, true, { label: evt.getParam('value') });
    },

    handleDataSave: function (cmp, evt, helper) {
        helper.setUnsavedValue(cmp, false);
    },

    handleSave: function (cmp, evt, helper) {
        try {
            var wizardDetailCmp = cmp.find('wizardDetail');
            wizardDetailCmp.save();
        } catch (e) {
            helper.setUnsavedValue(cmp, true);
        }
    },

    handleDiscard: function (cmp, evt, helper) {
        helper.setUnsavedValue(cmp, false);
    }
});