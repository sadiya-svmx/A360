({
    setUnsavedValue: function (cmp, value, options) {
        var unsaved = cmp.find('unsaved');
        unsaved.setUnsavedChanges(value, options);
    }
});