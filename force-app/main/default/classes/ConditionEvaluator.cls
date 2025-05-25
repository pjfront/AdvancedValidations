/**
 * @description Evaluates individual conditions against records
 */
public with sharing class ConditionEvaluator {
    
    /**
     * @description Evaluates a single condition against a record
     */
    public static Boolean evaluateCondition(SObject record, SObject oldRecord, Condition__mdt condition) {
        if (condition == null || String.isBlank(condition.Field__c)) {
            return false;
        }
        
        try {
            // Get field value
            Object fieldValue = getFieldValue(record, condition.Field__c);
            Object oldFieldValue = (oldRecord != null) ? getFieldValue(oldRecord, condition.Field__c) : null;
            
            // Check if we need to evaluate based on field change
            if (condition.Operator__c == 'changed') {
                return hasFieldChanged(fieldValue, oldFieldValue);
            } else if (condition.Operator__c == 'not changed') {
                return !hasFieldChanged(fieldValue, oldFieldValue);
            }
            
            // Evaluate the operator
            return evaluateOperator(fieldValue, condition.Operator__c, condition.Value__c);
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error evaluating condition: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Evaluates a child object condition
     */
    public static Boolean evaluateChildObjectCondition(
        Id recordId, 
        Condition__mdt condition, 
        List<Child_Condition__mdt> childConditions
    ) {
        if (recordId == null || condition == null) {
            return false;
        }
        
        try {
            // Build and execute query for child records
            Map<Id, Integer> childCounts = ChildObjectQueryBuilder.getChildRecordCounts(
                new Set<Id>{recordId}, 
                condition, 
                childConditions
            );
            
            Integer matchingCount = childCounts.get(recordId);
            if (matchingCount == null) {
                matchingCount = 0;
            }
            
            // Evaluate the count against the operator
            return evaluateCountOperator(
                matchingCount, 
                condition.Operator__c, 
                condition.Value__c
            );
            
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error evaluating child object condition: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * @description Gets field value from record, handling dot notation for relationships
     */
    private static Object getFieldValue(SObject record, String fieldPath) {
        if (record == null || String.isBlank(fieldPath)) {
            return null;
        }
        
        // Handle simple fields
        if (!fieldPath.contains('.')) {
            return record.get(fieldPath);
        }
        
        // Handle relationship fields (e.g., Account.Name)
        List<String> fieldParts = fieldPath.split('\\.');
        SObject currentRecord = record;
        
        for (Integer i = 0; i < fieldParts.size() - 1; i++) {
            currentRecord = currentRecord.getSObject(fieldParts[i]);
            if (currentRecord == null) {
                return null;
            }
        }
        
        return currentRecord.get(fieldParts[fieldParts.size() - 1]);
    }
    
    /**
     * @description Checks if a field value has changed
     */
    private static Boolean hasFieldChanged(Object newValue, Object oldValue) {
        // Handle nulls
        if (newValue == null && oldValue == null) {
            return false;
        }
        if (newValue == null || oldValue == null) {
            return true;
        }
        
        // Compare values
        return !newValue.equals(oldValue);
    }
    
    /**
     * @description Evaluates an operator against field value and compare value
     */
    private static Boolean evaluateOperator(Object fieldValue, String operator, String compareValue) {
        switch on operator.toLowerCase() {
            when 'equals' {
                return compareValues(fieldValue, compareValue, true);
            }
            when 'not equal to' {
                return !compareValues(fieldValue, compareValue, true);
            }
            when 'contains' {
                return containsValue(fieldValue, compareValue, true);
            }
            when 'does not contain' {
                return !containsValue(fieldValue, compareValue, true);
            }
            when 'is null' {
                return fieldValue == null;
            }
            when 'is not null' {
                return fieldValue != null;
            }
            when 'greater than' {
                return compareNumeric(fieldValue, compareValue, '>');
            }
            when 'less than' {
                return compareNumeric(fieldValue, compareValue, '<');
            }
            when 'greater than or equal' {
                return compareNumeric(fieldValue, compareValue, '>=');
            }
            when 'less than or equal' {
                return compareNumeric(fieldValue, compareValue, '<=');
            }
            when else {
                return false;
            }
        }
    }
    
    /**
     * @description Evaluates count-based operators for child objects
     */
    private static Boolean evaluateCountOperator(Integer actualCount, String operator, String compareValue) {
        if (String.isBlank(compareValue)) {
            return false;
        }
        
        try {
            Integer expectedCount = Integer.valueOf(compareValue);
            
            switch on operator.toLowerCase() {
                when 'no more than' {
                    return actualCount <= expectedCount;
                }
                when 'no fewer than' {
                    return actualCount >= expectedCount;
                }
                when else {
                    return false;
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error parsing count value: ' + compareValue);
            return false;
        }
    }
    
    /**
     * @description Compares two values for equality
     */
    private static Boolean compareValues(Object fieldValue, String compareValue, Boolean caseSensitive) {
        if (fieldValue == null && String.isBlank(compareValue)) {
            return true;
        }
        if (fieldValue == null || compareValue == null) {
            return false;
        }
        
        String fieldStr = String.valueOf(fieldValue);
        
        if (!caseSensitive) {
            return fieldStr.equalsIgnoreCase(compareValue);
        }
        
        return fieldStr.equals(compareValue);
    }
    
    /**
     * @description Checks if field value contains compare value
     */
    private static Boolean containsValue(Object fieldValue, String compareValue, Boolean caseSensitive) {
        if (fieldValue == null || String.isBlank(compareValue)) {
            return false;
        }
        
        String fieldStr = String.valueOf(fieldValue);
        
        if (!caseSensitive) {
            return fieldStr.toLowerCase().contains(compareValue.toLowerCase());
        }
        
        return fieldStr.contains(compareValue);
    }
    
    /**
     * @description Compares numeric values
     */
    private static Boolean compareNumeric(Object fieldValue, String compareValue, String operator) {
        if (fieldValue == null || String.isBlank(compareValue)) {
            return false;
        }
        
        try {
            Decimal fieldNum = Decimal.valueOf(String.valueOf(fieldValue));
            Decimal compareNum = Decimal.valueOf(compareValue);
            
            switch on operator {
                when '>' {
                    return fieldNum > compareNum;
                }
                when '<' {
                    return fieldNum < compareNum;
                }
                when '>=' {
                    return fieldNum >= compareNum;
                }
                when '<=' {
                    return fieldNum <= compareNum;
                }
                when else {
                    return false;
                }
            }
        } catch (Exception e) {
            return false;
        }
    }
}
