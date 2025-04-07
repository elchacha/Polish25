global with sharing class FormulaLoanApplicationWrapper implements IntFormulaWrapper{


    global LoanApplication__c record { get; set; }

    global InterestRatePolicy__c paymentPlan{ get; set; }

    public void  setRecord(Sobject record){
        this.record=(LoanApplication__c)record;
    }

    // mainly used for testing purpose
    public void setAdditionalStringProperty(String paymentPlanName){

        List<String> fields = new List<String>(InterestRatePolicy__c.SObjectType.getDescribe().fields.getMap().keySet());

        paymentPlan=Database.query('Select '+String.join(fields, ',')+' FROM  InterestRatePolicy__c WHERE Name =:paymentPlanName LIMIT 1');
    }

    public void setAdditionalObjectProperty(Object objectProp){
        paymentPlan=(InterestRatePolicy__c) objectProp;
    }
    
    global Decimal bound1
    {
        get { return paymentPlan.boundary1__c; }
    }
    global Decimal bound2
    {
        get { return paymentPlan.boundary2__c; }
    }
    global Decimal bound3
    {
        get { return paymentPlan.boundary3__c; }
    }
    global Decimal bound4
    {
        get { return paymentPlan.boundary4__c; }
    }

    global Decimal Rate1
    {
        get { return paymentPlan.rate1__c;}
    }
    global Decimal Rate2
    {
        get { return paymentPlan.rate2__c;}
    }
    global Decimal Rate3
    {
        get { return paymentPlan.rate3__c;}
    }


    public Set<String> getCorrectSObjectFields(Set<String> initialsFields){
        Set<String> realFields = new Set<String>();
        for(String initialField : initialsFields){
            if(initialField.startsWith('record.')){
                realFields.add(initialField.replace('record.', ''));
            }
        }
        return realFields;
    }

    public Map<String,String> getFieldsUsage(){
        Map<String,String> result = new Map<String,String>();
        result.put('record','Contains the LoanApplication__c fields for the record. Must be used with record.FIELDNAME ...');
        result.put('bound1','value for boundary1 coming from the selected paymentPlan');
        result.put('bound2','value for boundary2 coming from the selected paymentPlan');
        result.put('bound3','value for boundary3 coming from the selected paymentPlan');
        result.put('Rate1','value for rate1 coming from the selected paymentPlan');
        result.put('Rate2','value for rate2 coming from the selected paymentPlan');
        result.put('Rate3','value for rate3 coming from the selected paymentPlan');
        return result;
    }


}