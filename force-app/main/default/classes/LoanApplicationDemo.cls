public with sharing class LoanApplicationDemo {
    public static Map<String,FormulaEval.FormulaReturnType> types = new Map<String,FormulaEval.FormulaReturnType>();

    static {
        types.put('Checkbox',FormulaEval.FormulaReturnType.BOOLEAN);   
        types.put('Date',FormulaEval.FormulaReturnType.Date);   
        types.put('DateTime',FormulaEval.FormulaReturnType.DATETIME);   
        types.put('Number',FormulaEval.FormulaReturnType.LONG);   
        types.put('Percent',FormulaEval.FormulaReturnType.DECIMAL);   
        types.put('Text',FormulaEval.FormulaReturnType.STRING);   
        types.put('Time',FormulaEval.FormulaReturnType.TIME);   
    }

    static String formulaToRun;
    static FormulaLoanApplicationWrapper loanWrapper =new FormulaLoanApplicationWrapper();

    @AuraEnabled
    public static Object evalFormula(Id recordId,String formulaType,String formulaValue,String additionalInfo){

        loanWrapper = new FormulaLoanApplicationWrapper();
        formulaToRun=formulaValue;
        FormulaEval.FormulaInstance formulaInstance = null;
        Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();

        // STEP 1 : Build the formulaInstance (Record or Class based ??)
        try {
            formulaInstance = buildFormula(recordType,formulaType,formulaValue);
        } catch (FormulaValidationException fve) {
            return ' error in formula or type : '+  fve.getMessage();
        } catch (Exception e){
            return ' untype error : '+  e.getMessage();
        }
        
        // STEP 2 : Find all fields needed by the formula (the below code is not bulkified, all formulas should be compiled first)
        Set<String> neededFields = new Set<String>(formulaInstance.getReferencedFields());
        if(loanWrapper!=null){
            neededFields=loanWrapper.getCorrectSObjectFields(neededFields);
        }

        // STEP 3 : Retrieve the record with all the fields needed by the formula (again, not bulkified if we want to process a list of formulas through customMetadata)
        Sobject recordWithFields = getRecordWithFieldsLoaded(neededFields,recordId);

        // STEP 4 : get the formula result using either the record or the class wrapper
        try {
            if(loanWrapper==null){
                return formulaInstance.evaluate(recordWithFields);
            }else{
                loanWrapper.setRecord(recordWithFields);
                loanWrapper.setAdditionalStringProperty(additionalInfo);
                return formulaInstance.evaluate(loanWrapper);
            }
        } catch (Exception e) {
            return ' unexpected error during eval : '+  e.getMessage();
        }
    }


    private static FormulaEval.FormulaInstance buildFormula(Schema.SObjectType recordType,String formulaType,String formulaValue){
        FormulaEval.FormulaInstance formulaInstance;
        if(isWrapperNeeded()){
            formulaInstance=Formula.builder()
            .withReturnType(types.get(formulaType))
            .withType(FormulaLoanApplicationWrapper.class)
            .withFormula(formulaValue)
            .build();
        }else{
            formulaInstance=Formula.builder()
            .withReturnType(types.get(formulaType))
            .withType(recordType)
            .withFormula(formulaValue)
            .build();
            loanWrapper=null;
        }
        return formulaInstance;
    } 


    // looking if we really need to use the wrapper
    private static boolean isWrapperNeeded(){
        for(String varWrapper : loanWrapper.getFieldsUsage().keySet()){
            if(formulaToRun.contains(varWrapper)) return true;
        }
        return false;
    }
    

    private static SObject getRecordWithFieldsLoaded(Set<String> neededFields,Id recordId){
        SObject record=null;
        if(neededFields.size()>0){
            String queryStr = 'SELECT ' + String.join(neededFields,',') + ' FROM '+recordId.getSobjectType()+' WHERE Id=:recordId';
            // We could prevent the acess to non visible fields if neeeded here
            record = Database.query(queryStr);            
        }else{
            record= recordId.getSobjectType().newSObject();
            record.Id=recordId;
        }
        return record;
    } 



}