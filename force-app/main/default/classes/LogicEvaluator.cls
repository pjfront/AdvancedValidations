/**
 * @description Evaluates complex logic expressions for combining conditions
 */
public with sharing class LogicEvaluator {
    
    /**
     * @description Evaluates logic to combine condition results
     */
    public static Boolean evaluateLogic(List<Boolean> conditionResults, String logicType, String customLogic) {
        if (conditionResults == null || conditionResults.isEmpty()) {
            return false;
        }
        
        // Single condition - return its result
        if (conditionResults.size() == 1) {
            return conditionResults[0];
        }
        
        // Multiple conditions - apply logic
        if (logicType == 'AND') {
            return evaluateAndLogic(conditionResults);
        } else if (logicType == 'OR') {
            return evaluateOrLogic(conditionResults);
        } else if (logicType == 'CUSTOM' && String.isNotBlank(customLogic)) {
            return evaluateCustomLogic(conditionResults, customLogic);
        }
        
        // Default to AND logic
        return evaluateAndLogic(conditionResults);
    }
    
    /**
     * @description Evaluates AND logic - all conditions must be true
     */
    private static Boolean evaluateAndLogic(List<Boolean> conditionResults) {
        for (Boolean result : conditionResults) {
            if (!result) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * @description Evaluates OR logic - at least one condition must be true
     */
    private static Boolean evaluateOrLogic(List<Boolean> conditionResults) {
        for (Boolean result : conditionResults) {
            if (result) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @description Evaluates custom logic expressions
     */
    private static Boolean evaluateCustomLogic(List<Boolean> conditionResults, String customLogic) {
        try {
            // Validate the expression
            if (!isValidCustomLogic(customLogic, conditionResults.size())) {
                System.debug(LoggingLevel.ERROR, 'Invalid custom logic: ' + customLogic);
                return false;
            }
            
            // Parse and evaluate the expression
            String expression = prepareExpression(customLogic, conditionResults);
            return evaluateExpression(expression);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error evaluating custom logic: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Validates custom logic syntax
     */
    private static Boolean isValidCustomLogic(String customLogic, Integer conditionCount) {
        if (String.isBlank(customLogic)) {
            return false;
        }
        
        // Check for balanced parentheses
        Integer openCount = 0;
        Integer closeCount = 0;
        for (Integer i = 0; i < customLogic.length(); i++) {
            String ch = customLogic.substring(i, i + 1);
            if (ch == '(') {
                openCount++;
            } else if (ch == ')') {
                closeCount++;
            }
        }
        
        if (openCount != closeCount) {
            return false;
        }
        
        // Check that all condition numbers are valid
        for (Integer i = 1; i <= conditionCount; i++) {
            if (!customLogic.contains(String.valueOf(i))) {
                return false;
            }
        }
        
        // Check for invalid condition numbers
        for (Integer i = conditionCount + 1; i <= conditionCount + 10; i++) {
            if (customLogic.contains(String.valueOf(i))) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * @description Prepares expression by replacing condition numbers with boolean values
     */
    private static String prepareExpression(String customLogic, List<Boolean> conditionResults) {
        String expression = customLogic.toUpperCase();
        
        // Replace condition numbers with boolean values (in reverse order to handle multi-digit numbers)
        for (Integer i = conditionResults.size(); i >= 1; i--) {
            String conditionNumber = String.valueOf(i);
            String booleanValue = conditionResults[i - 1] ? 'TRUE' : 'FALSE';
            expression = expression.replace(conditionNumber, booleanValue);
        }
        
        return expression;
    }
    
    /**
     * @description Evaluates a boolean expression
     */
    private static Boolean evaluateExpression(String expression) {
        // Remove spaces
        expression = expression.replace(' ', '');
        
        // Repeatedly evaluate innermost parentheses first
        while (expression.contains('(')) {
            Integer startIdx = expression.lastIndexOf('(');
            Integer endIdx = expression.indexOf(')', startIdx);
            
            if (endIdx == -1) {
                throw ValidationRuleException.createException('Unmatched parentheses in expression');
            }
            
            String subExpression = expression.substring(startIdx + 1, endIdx);
            Boolean subResult = evaluateSimpleExpression(subExpression);
            
            expression = expression.substring(0, startIdx) + 
                        (subResult ? 'TRUE' : 'FALSE') + 
                        expression.substring(endIdx + 1);
        }
        
        // Evaluate final expression
        return evaluateSimpleExpression(expression);
    }
    
    /**
     * @description Evaluates simple expression without parentheses
     */
    private static Boolean evaluateSimpleExpression(String expression) {
        // Handle NOT operations first
        while (expression.contains('NOT')) {
            Integer notIdx = expression.indexOf('NOT');
            Integer valueStart = notIdx + 3;
            
            Boolean value;
            if (expression.substring(valueStart).startsWith('TRUE')) {
                value = true;
                expression = expression.substring(0, notIdx) + 'FALSE' + expression.substring(valueStart + 4);
            } else if (expression.substring(valueStart).startsWith('FALSE')) {
                value = false;
                expression = expression.substring(0, notIdx) + 'TRUE' + expression.substring(valueStart + 5);
            } else {
                throw ValidationRuleException.createException('Invalid NOT expression');
            }
        }
        
        // Handle AND operations
        while (expression.contains('AND')) {
            Integer andIdx = expression.indexOf('AND');
            Boolean leftValue = extractBooleanBefore(expression, andIdx);
            Boolean rightValue = extractBooleanAfter(expression, andIdx + 3);
            Boolean result = leftValue && rightValue;
            
            expression = replaceBinaryOperation(expression, andIdx, 3, result);
        }
        
        // Handle OR operations
        while (expression.contains('OR')) {
            Integer orIdx = expression.indexOf('OR');
            Boolean leftValue = extractBooleanBefore(expression, orIdx);
            Boolean rightValue = extractBooleanAfter(expression, orIdx + 2);
            Boolean result = leftValue || rightValue;
            
            expression = replaceBinaryOperation(expression, orIdx, 2, result);
        }
        
        // Final result should be a single boolean
        if (expression == 'TRUE') {
            return true;
        } else if (expression == 'FALSE') {
            return false;
        } else {
            throw ValidationRuleException.createException('Invalid final expression: ' + expression);
        }
    }
    
    /**
     * @description Extracts boolean value before an operator
     */
    private static Boolean extractBooleanBefore(String expression, Integer operatorIdx) {
        String before = expression.substring(0, operatorIdx);
        if (before.endsWith('TRUE')) {
            return true;
        } else if (before.endsWith('FALSE')) {
            return false;
        }
        throw ValidationRuleException.createException('Invalid boolean before operator');
    }
    
    /**
     * @description Extracts boolean value after an operator
     */
    private static Boolean extractBooleanAfter(String expression, Integer startIdx) {
        String after = expression.substring(startIdx);
        if (after.startsWith('TRUE')) {
            return true;
        } else if (after.startsWith('FALSE')) {
            return false;
        }
        throw ValidationRuleException.createException('Invalid boolean after operator');
    }
    
    /**
     * @description Replaces binary operation with result
     */
    private static String replaceBinaryOperation(String expression, Integer operatorIdx, Integer operatorLength, Boolean result) {
        // Find the boolean before the operator
        Integer leftStart = operatorIdx - 5; // 'FALSE' length
        if (leftStart >= 0 && expression.substring(leftStart, operatorIdx) == 'FALSE') {
            // Found FALSE before operator
        } else {
            leftStart = operatorIdx - 4; // 'TRUE' length
        }
        
        // Find the boolean after the operator
        Integer rightEnd = operatorIdx + operatorLength + 4; // 'TRUE' length
        if (rightEnd <= expression.length() && expression.substring(operatorIdx + operatorLength, rightEnd) == 'TRUE') {
            // Found TRUE after operator
        } else {
            rightEnd = operatorIdx + operatorLength + 5; // 'FALSE' length
        }
        
        return expression.substring(0, leftStart) + 
               (result ? 'TRUE' : 'FALSE') + 
               (rightEnd < expression.length() ? expression.substring(rightEnd) : '');
    }
}
