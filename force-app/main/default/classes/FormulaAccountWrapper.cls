global class FormulaAccountWrapper implements IntFormulaWrapper{

    global Account acct { get; set; }
    // normally ,the value should be assigned dynamically but the developer was lazy while writing this example
    global String chosenConfig='ConfigA';

    // mainly used for testing purpose
    public void setAdditionalStringProperty(String strProperty){
        chosenConfig=strProperty;
    }

    public void setAdditionalObjectProperty(Object objectProp){

    }

    public void  setRecord(Sobject record){
        acct=(Account)record;
    }


    global String nbContacts
    {
        get { 
            return ''+Database.countQuery('SELECT COUNT() FROM Contact WHERE AccountId =\''+acct.Id+'\'');
        }
    }


    public Set<String> getCorrectSObjectFields(Set<String> initialsFields){
        Set<String> realFields = new Set<String>();
        for(String initialField : initialsFields){
            if(initialField.startsWith('acct.')){
                realFields.add(initialField.replace('acct.', ''));
            }
        }
        return realFields;
    }


    public Map<String,String> getFieldsUsage(){
        Map<String,String> result = new Map<String,String>();
        result.put('acct','Contains the account fields for the record. Must be used with acct.FIELDNAME ');
        result.put('nbContacts','contains the number of Contacts linked to the account');
        return result;
    }

}