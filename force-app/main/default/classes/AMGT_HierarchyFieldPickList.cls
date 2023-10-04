global class AMGT_HierarchyFieldPickList extends VisualEditor.DynamicPickList{
    private static final COMM_MetadataManager metadataManager = COMM_MetadataManager.getInstance();

    VisualEditor.DesignTimePageContext context;
 
    private final static List<String> STD_OBJECTS = new List<String>{
        'WORKORDER',
        'CASE'
    };

    private final static List<String> AH_OBJECTS = new List<String>{
        'ASSET',
        'LOCATION',
        'ACCOUNT'
    };
    global AMGT_HierarchyFieldPickList(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }
 
    global override VisualEditor.DataRow getDefaultValue(){
        System.debug( LoggingLevel.DEBUG, 'getDefaultValue() - enter;');

        try {
            return getDefaultRow(this.context.entityName);
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getDefaultValue() : Failed to retrieve a default value. Error= ' + e.getStackTraceString() );
            throw e;
        }
        finally {
            System.debug( LoggingLevel.DEBUG, 'getDefaultValue() - exit' );
        }
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        System.debug( LoggingLevel.DEBUG, 'getValues() - enter;');
        VisualEditor.DynamicPickListRows picklistOptions = new VisualEditor.DynamicPickListRows();
        boolean idFieldNotAdded = true;
        try {
            if (String.isNotBlank(this.context.entityName)) {
                String assetObject = String.valueOf(Schema.Asset.getSObjectType());
                String locationObject = String.valueOf(Schema.Location.getSObjectType());
                String accountObject = String.valueOf(Schema.Account.getSObjectType());

                Common.EntityDefinition objectDef = metadataManager.getFieldDefinitions( new List<String>{this.context.entityName}, true, true).get(0);

                if ( objectDef != null ) {

                    for ( Common.FieldDefinition field : objectDef.fieldDefinitions ) {

                        if (field.dataType == Schema.Displaytype.REFERENCE.name()
                            && field.referenceTo != null 
                            && !field.referenceTo.isEmpty()
                            && (field.referenceTo.contains(assetObject)
                            || field.referenceTo.contains(locationObject)
                            || field.referenceTo.contains(accountObject))) {

                            VisualEditor.DataRow option = new VisualEditor.DataRow( field.label, field.apiName);
                            picklistOptions.addRow(option);
                        }

                        if (objectDef.apiName.equalsIgnoreCase(assetObject) && field.dataType == Schema.DisplayType.ID.name()) {
                            VisualEditor.DataRow option = new VisualEditor.DataRow( field.label, field.apiName);
                            picklistOptions.addRow(option);
                            idFieldNotAdded = false;
                        }

                        if (objectDef.apiName.equalsIgnoreCase(locationObject) && field.dataType == Schema.DisplayType.ID.name()) {
                            VisualEditor.DataRow option = new VisualEditor.DataRow( field.label, field.apiName);
                            picklistOptions.addRow(option);
                            idFieldNotAdded = false;
                        }

                        if (objectDef.apiName.equalsIgnoreCase(accountObject) && field.dataType == Schema.DisplayType.ID.name()) {
                            VisualEditor.DataRow option = new VisualEditor.DataRow( field.label, field.apiName);
                            picklistOptions.addRow(option);
                            idFieldNotAdded = false;
                        }
                    }
                }
            }
        }
        catch( Exception e ) {
            System.debug( LoggingLevel.ERROR, 'getValues() : Failed to retrieve values. Error= ' + e.getStackTraceString() );
            //TODO: commenting out below line for testing #A360AM-1311, will be revisited
            //throw e;
        }
        finally {
            if (picklistOptions.size() == 0
                && (String.isEmpty(this.context.entityName)
                || STD_OBJECTS.contains(this.context.entityName.toUpperCase()))){
                    VisualEditor.DataRow option = new VisualEditor.DataRow( 'Asset Id', 'AssetId');
                    picklistOptions.addRow(option);
            }
            if ((picklistOptions.size() == 0 || idFieldNotAdded) 
                && (String.isEmpty(this.context.entityName)
                || AH_OBJECTS.contains(this.context.entityName.toUpperCase()))) {
                VisualEditor.DataRow option = new VisualEditor.DataRow( 'Id', 'Id');
                picklistOptions.addRow(option);
            }
            System.debug( LoggingLevel.DEBUG, 'getValues() - exit' );
        }

        return picklistOptions;
    }

    private VisualEditor.DataRow getDefaultRow( String entityName ) {
        if (String.isBlank(entityName)) {
            return null;
        }

        String assetObject = String.valueOf(Schema.Asset.getSObjectType());
        Common.EntityDefinition objectDef = metadataManager.getFieldDefinitions( entityName, true);

        if ( objectDef == null ) {
            return null;
        }

        List<DefaultDataRow> rows = new List<DefaultDataRow>();
        Boolean containsIdField = false;
        for ( Common.FieldDefinition field : objectDef.fieldDefinitions ) {
            if (field.dataType == Schema.DisplayType.REFERENCE.name() && field.referenceTo.contains(assetObject) ) {
                DefaultDataRow row = new DefaultDataRow(false, new VisualEditor.DataRow( field.label, field.apiName ));
                rows.add(row);
            }

            if (entityName.equalsIgnoreCase(assetObject) && field.dataType == Schema.DisplayType.ID.name()) {
                containsIdField = true;
                DefaultDataRow row = new DefaultDataRow(true, new VisualEditor.DataRow( field.label, field.apiName ));
                rows.add(row);
            }
        }

        if ( rows.isEmpty() ) {
            return null;
        }

        // If there is only 1, return that value
        if ( rows.size() == 1 ) {
            return rows[0].dataRow;
        }

        // If there is more than 1 and one of them is an ID field for the Asset object, return that field.
        if (containsIdField) {
            for (DefaultDataRow row : rows) {
                if (row.isID) {
                    return row.dataRow;
                }
            }
        }

        // Since the row size is greater than 1 and does not have an ID field, return the 1st row.
        return rows[0].dataRow;
    }

    private class DefaultDataRow {
        public Boolean isID { get; set; }
        public VisualEditor.DataRow dataRow { get; set; }

        public DefaultDataRow( Boolean isIDField, VisualEditor.DataRow picklistDataRow ) {
            this.isID = isIDField;
            this.dataRow = picklistDataRow;
        }
    }
}