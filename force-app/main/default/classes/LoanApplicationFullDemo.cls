public with sharing class LoanApplicationFullDemo {
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


        static List<LoanCalculationRules__mdt> orderedRules;

        static Map<String,FormulaEval.FormulaInstance> formulas = new Map<String,FormulaEval.FormulaInstance>();
        static Set<String> neededFields = new Set<String>();
    
        static String formulaToRun;
        static FormulaLoanApplicationWrapper loanWrapper =new FormulaLoanApplicationWrapper();
        static boolean useWrapper=true;

        @AuraEnabled
        public static Map<String,Object> testMe(Id recordId,String paymentName,Integer loanAmount){
            Map<String,Object> values = new Map<String,Object>();
            // We inject a non hardcoded Id here for the purpose of the demo
            recordId = [Select Id from LoanApplication__c LIMIT 1][0].Id;
            Schema.SObjectType recordType = (Schema.SObjectType)recordId.getSobjectType();

            // STEP 1 : FIND ALL FIELDS THAT THE "COMPLEX" RECORD MAY NEED
            loadAllFormulas(recordType);
            // STEP 2 : BUILD THE COMPLEX RECORD WITH ALL THE FIELDS THAT WE'LL NEED
            LoanApplication__c record = getRecordWithFieldsLoaded(recordId);
            record.Loan_Amount__c=loanAmount;

            // STEP 4 : STORE INFORMATION INSIDE THE WRAPPER
            FormulaLoanApplicationWrapper wrapper = new FormulaLoanApplicationWrapper();
            wrapper.setRecord(record);
            wrapper.setAdditionalStringProperty(paymentName);
            
            // STORING INFORMATION TO DISPLAY IN THE LWC
            values.put('PaymentPlanName',wrapper.paymentPlan.Name);
            values.put('Years',wrapper.paymentPlan.number__c);
            values.put('Ammount',record.Loan_Amount__c);

            String tgtField ;
            // STEP 5 : PROCESSING THE "FORMULAS RULES"
            for(LoanCalculationRules__mdt rule : orderedRules){
                if(rule.targetField__c !=tgtField){
                    if(rule.Condition__c=='true'||(Boolean) formulas.get(rule.Condition__c).evaluate(wrapper)){
                        record.put(rule.targetField__c, formulas.get(rule.FieldValue__c).evaluate(wrapper));
                        tgtField=rule.targetField__c;
                        values.put(tgtField,formulas.get(rule.FieldValue__c).evaluate(wrapper));
                    }
                }
            }

            return values;

        }

    
    
        private static FormulaEval.FormulaInstance buildFormula(Schema.SObjectType recordType,String formulaType,String formulaValue){
            FormulaEval.FormulaInstance formulaInstance;
            useWrapper=true;
            if(isWrapperNeeded(formulaValue)){
                formulaInstance=Formula.builder()
                .withReturnType (types.get(formulaType))
                .withType (FormulaLoanApplicationWrapper.class)
                .withFormula (formulaValue)
                .build();
            }else{
                formulaInstance=Formula.builder()
                .withReturnType (types.get(formulaType))
                .withType (recordType)
                .withFormula (formulaValue)
                .build();
                useWrapper=false;
            }
            return formulaInstance;
        } 
    
    
        // looking if we really need to use the wrapper
        private static boolean isWrapperNeeded(String formulaValue){
            if(!useWrapper) return false;
            for(String varWrapper : loanWrapper.getFieldsUsage().keySet()){
                if(formulaValue.contains(varWrapper)) return true;
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
    
   

        private static void loadAllFormulas(Schema.SObjectType recordType){
            orderedRules = [SELECT Condition__c,FieldType__c,targetField__c,FieldValue__c FROM LoanCalculationRules__mdt order by targetField__c];
            for(LoanCalculationRules__mdt rule : orderedRules){
                FormulaEval.FormulaInstance conditionInstance =buildFormula(recordType,'Checkbox',rule.Condition__c);
                if(loanWrapper!=null){
                    neededFields.addAll(loanWrapper.getCorrectSObjectFields(new Set<String>(conditionInstance.getReferencedFields())));
                }else{
                    neededFields.addAll(new Set<String>(conditionInstance.getReferencedFields()));
                }
                formulas.put(rule.Condition__c,conditionInstance);
                FormulaEval.FormulaInstance resultInstance =buildFormula(recordType,rule.FieldType__c,rule.FieldValue__c);
                neededFields.addAll(loanWrapper.getCorrectSObjectFields(new Set<String>(resultInstance.getReferencedFields())));
                formulas.put(rule.FieldValue__c,resultInstance);
            }
        }



        // METHOD TO STORE "SIMPLE" record object
        private static LoanApplication__c getRecordWithFieldsLoaded(Id recordId){
            return Database.query('SELECT ' + String.join(neededFields,',') + ' FROM '+recordId.getSobjectType()+' WHERE Id=:recordId');     
        } 



        private class FormulaInstanceHolder{
            FormulaEval.FormulaInstance instance;
            public FormulaInstanceHolder(Schema.SObjectType recordType,String formulaType,String formulaValue){
                instance=buildFormula(recordType,formulaType,formulaValue);
            }

        }
    
    }