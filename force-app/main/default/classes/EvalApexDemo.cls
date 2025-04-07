public with sharing class EvalApexDemo {

    /*
    simple formula example :
    contact id : 0030900001lmHdWAAU / 0030900001lmHdaAAE

     Name & ' and owner account is '  & Owner.FirstName & '  ' & Owner.LastName

    wrapped Example :

    Account : 

    0010900001vLQFrAAO / 0010900001vLQFuAAO

    nbContacts + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName

    configValue1 + ' contacts records for recordName : '+ acct.Name +' and owner account is '  + acct.Owner.FirstName +' ' + acct.Owner.LastName

    EvalFormulaExample__c
    a04d2000000DxtVAAS

    hardCodedString2 & ' ' & record.Id

    */

    public static Map<String,FormulaEval.FormulaReturnType> types = new Map<String,FormulaEval.FormulaReturnType>();

    static {
        types.put('Checkbox',FormulaEval.FormulaReturnType.BOOLEAN);   
        types.put('Date',FormulaEval.FormulaReturnType.Date);   
        types.put('DateTime',FormulaEval.FormulaReturnType.DATETIME);   
        types.put('Number',FormulaEval.FormulaReturnType.DOUBLE);   
        types.put('Percent',FormulaEval.FormulaReturnType.DECIMAL);   
        types.put('Text',FormulaEval.FormulaReturnType.STRING);   
        types.put('Time',FormulaEval.FormulaReturnType.TIME);   
    }

    static String formulaToRun;
    static System.type wrapperClass; 
    static IntFormulaWrapper wrappedRecord;


    @AuraEnabled
    public static ObjectInfo getObjectInfo(Id recordId){
        return new ObjectInfo(recordId);
    }


    @AuraEnabled
    public static Map<String,String> getWrapperFields(String wrapperName){
        IntFormulaWrapper wrappedRecord = (IntFormulaWrapper)Type.forName(wrapperName).newInstance();
        return wrappedRecord.getFieldsUsage();
    }


    @AuraEnabled
    public static Object testFormula(Id recordId,String formulaType,String formulaValue,boolean userMode,String additionalInfo){

        FormulaEval.FormulaInstance formulaInstance = null;
        Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();
        formulaToRun=formulaValue;

        try {
            wrapperClass=getWrapperClass(recordType);
            if(wrapperClass!=null){
                wrappedRecord = (IntFormulaWrapper)wrapperClass.newInstance();
            }
            if(wrapperClass!=null&&isWrapperNeeded()){
                formulaInstance=Formula.builder()
                .withReturnType (types.get(formulaType))
                .withType (wrapperClass)
                .withFormula (formulaValue)
                .build();
            }else{
                system.debug('formulaType>'+formulaType);
                system.debug('formulaValue>'+formulaValue);
                system.debug('recordType>'+recordType);
                formulaInstance=Formula.builder()
                .withReturnType (types.get(formulaType))
                .withType (recordType)
                .withFormula (formulaValue)
                .build();
                wrapperClass=null;
            }
        } catch (FormulaValidationException fve) {
            return ' error in formula or type : '+  fve.getMessage();
        } catch (Exception e){
            return ' untype error : '+  e.getMessage();
        }
        
        Set<String> neededFields = new Set<String>(formulaInstance.getReferencedFields());
        if(wrapperClass!=null){
            neededFields=wrappedRecord.getCorrectSObjectFields(neededFields);
        }

        System.debug('neededFields>'+neededFields);

        SObject obj=null;
        if(neededFields.size()>0){
            String queryStr = 'SELECT ' + String.join(neededFields,',') + ' FROM '+recordId.getSobjectType()+' WHERE Id=:recordId';
            if(userMode){
                obj = Database.query(queryStr,AccessLevel.USER_MODE);
            }else{
                obj = Database.query(queryStr);            
            }
        }else{
            obj=recordType.newSObject();
            obj.Id=recordId;
        }

        System.debug(obj);

        Object result=null;

        try {
            if(wrapperClass==null){
                result = formulaInstance.evaluate(obj);
                system.debug('result : '+result);
            }else{
                wrappedRecord.setRecord(obj);
                wrappedRecord.setAdditionalStringProperty(additionalInfo);
                result= formulaInstance.evaluate(wrappedRecord);
            }
        } catch (Exception e) {
            system.debug(e.getMessage());
            return ' unexpected error during eval : '+  e.getMessage();
        }

        system.debug(result);
        return result;

    }


    // looking if we really need to use the wrapper
    private static boolean isWrapperNeeded(){
        for(String varWrapper : wrappedRecord.getFieldsUsage().keySet()){
            if(formulaToRun.contains(varWrapper)) return true;
        }
        return false;
    }

    private static System.Type getWrapperClass(Schema.SObjectType recordType ){
        String sRecordType = String.valueOf(recordType).replaceAll('__c','');
        try {
            return Type.forName('Formula'+sRecordType+'Wrapper');
        } catch (Exception e) {
            return null;
        }
    }


    public class ObjectInfo{
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String wrapperClass;

        public ObjectInfo(Id recordId){
            Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();
            objectName = String.valueOf(recordType);
            wrapperClass=String.valueOf(getWrapperClass(recordType));
        }
    }
}