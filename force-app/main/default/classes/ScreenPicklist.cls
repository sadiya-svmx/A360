global class ScreenPicklist extends SvmxPicklist.SvmxDynamicPicklist{
 
    global ScreenPicklist(VisualEditor.DesignTimePageContext context) {
       super(context);
    }
 
    global override VisualEditor.DataRow getDefaultValue(){
        System.debug( LoggingLevel.DEBUG, 'getDefaultValue() - enter;');
 		return getDefaultScreenValue();
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        System.debug( LoggingLevel.DEBUG, 'getValues() - enter;');
        return getScreenValues();
    }
}