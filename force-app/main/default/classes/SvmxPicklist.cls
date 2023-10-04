public class SvmxPicklist {
    public abstract class SvmxDynamicPicklist extends VisualEditor.DynamicPickList{

        private VisualEditor.DesignTimePageContext context;
     
        public SvmxDynamicPicklist(VisualEditor.DesignTimePageContext context) {
           this.context = context;
        }
             
        protected VisualEditor.DataRow getDefaultScreenValue(){
            System.debug( LoggingLevel.DEBUG, 'getDefaultValue() - enter;');
    
            VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('--None--', '');
            return defaultValue;
        }
    
        protected VisualEditor.DynamicPickListRows getScreenValues() {
            System.debug( LoggingLevel.DEBUG, 'getValues() - enter;');
            System.debug( LoggingLevel.DEBUG, 'getValues() - entityName' + this.context.entityName);
            VisualEditor.DynamicPickListRows picklistOptions = new VisualEditor.DynamicPickListRows();
            List<Adm.PageLayout> transactionList = new List<Adm.PageLayout>();
            if (this.context.entityName != null) {
				Common.ServiceResponse response = ADM_PageLayoutManager.getInstance().getLayoutsByObjectNameAndType('Transaction', this.context.entityName );
				transactionList = (List<Adm.PageLayout>)response.data;
            } else {
                transactionList = ADM_PageLayoutManager.getInstance().getAllPageLayouts('Transaction', false);
            }
            if(transactionList != null && !transactionList.isEmpty()){
                for(Adm.PageLayout transactionRec : transactionList){
                    if(transactionRec.pageHeader != null && transactionRec.pageHeader.transactionType.equalsIgnoreCase('Standalone Edit')){
                        VisualEditor.DataRow option = new VisualEditor.DataRow( transactionRec.name, transactionRec.developerName);
                        picklistOptions.addRow(option);                    
                    }
    
                }
            }
            return picklistOptions;
        }
	}
}