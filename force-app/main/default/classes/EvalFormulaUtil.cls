public with sharing class EvalFormulaUtil {
    public static Map<String,FormulaEval.FormulaReturnType> types = new Map<String,FormulaEval.FormulaReturnType>();

    static {
        types.put('Checkbox',FormulaEval.FormulaReturnType.BOOLEAN);   
        types.put('Date',FormulaEval.FormulaReturnType.Date);   
        types.put('DateTime',FormulaEval.FormulaReturnType.DATETIME);   
        // DOUBLE (not LONG, which would truncate a rate such as 0.08) - same mapping as the demo classes
        types.put('Number',FormulaEval.FormulaReturnType.DOUBLE);
        types.put('Percent',FormulaEval.FormulaReturnType.DECIMAL);   
        types.put('Text',FormulaEval.FormulaReturnType.STRING);   
        types.put('Time',FormulaEval.FormulaReturnType.TIME);   
    }


    public static FormulaEval.FormulaInstance buildInstance(String formulaType,String className,String formulaValue){
        return Formula.builder()
        .withReturnType (types.get(formulaType))
        .withType (Type.forName(className))
        .withFormula (formulaValue)
        .build();
    }


    static Map<String,FormulaEval.FormulaInstance> formulas = new Map<String,FormulaEval.FormulaInstance>();

    public static Object evaluate(String formula,String className,String type,Object obj){
        // The key must include the context class and the return type: the same text
        // evaluated against another class (or returning another type) is another compiled formula.
        String key = className + '|' + type + '|' + formula;
        if(!formulas.containsKey(key)){
            formulas.put(key, EvalFormulaUtil.buildInstance(type,className,formula));
        }
        return formulas.get(key).evaluate(obj);
    }

    // True if the formula uses the variable as a whole word (case-insensitive, as formulas are):
    // 'bound1' must not match 'bound10', nor 'owner.record' match 'record'.
    public static Boolean usesVariable(String formula,String variableName){
        Pattern p = Pattern.compile('(?i)(?<![\\w.])' + Pattern.quote(variableName) + '(?!\\w)');
        return p.matcher(formula).find();
    }

}