public with sharing class EvalFormulaUtil {
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


    public static FormulaEval.FormulaInstance buildInstance(String formulaType,String className,String formulaValue){
        return Formula.builder()
        .withReturnType (types.get(formulaType))
        .withType (Type.forName(className))
        .withFormula (formulaValue)
        .build();
    }


    static Map<String,FormulaEval.FormulaInstance> formulas = new Map<String,FormulaEval.FormulaInstance>();

    public static Object evaluate(String formula,String className,String type,Object obj){
        if(!formulas.containsKey(formula)){
            formulas.put(formula, EvalFormulaUtil.buildInstance(type,className,formula));
        }
        return formulas.get(formula).evaluate(obj);
    }

}