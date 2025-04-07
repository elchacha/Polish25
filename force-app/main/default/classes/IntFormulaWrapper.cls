global interface IntFormulaWrapper {
  
    void setRecord(SObject record);

    // mainly used for testing purpose
    void setAdditionalStringProperty(String strProperty);

    void setAdditionalObjectProperty(Object objectProp);

    // will fix the list of fields of returned by FormulaInstance.getReferencedFields()
    Set<String> getCorrectSObjectFields(Set<String> initialsFields);


    // Should return all declaredVariables including varRecordName and the usage/description for each fields
    Map<String,String> getFieldsUsage();

}